// ════════════════════════════════════════════════════════════════════════════
// remote_lab_products_repository.dart
//
// تنفيذ Remote لـ [LabProductsRepository] — يجلب/ينشئ/يحدّث منتجات المخبر من
// الباك عبر [LabProductsRemoteDataSource]، ويحوّل أخطاء Dio لـ Failure واضحة.
//
// مطابقة العقد مع الباك (تحقّق فعلي 2026-06-24):
//   - الصنف يرجع: {id, category{}, name, name_en, type, material,
//                  price:"99000.00"(نص), duration:"3"(نص), is_active}.
//   - الإنشاء/التحديث يقبلان: name,type,material,price,duration (category_id
//     و name_en اختياريان) — فحقول نموذج LabProduct الحالية تكفي بلا تغيير UI.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core/network/endpoints.dart';
import '../../../../core/network/failure.dart';
import '../../../../core/network/network_status.dart';
import '../../../../core/offline/cached_list_repository.dart';
import '../../../../core/offline/outbox.dart';
import '../../../../core/offline/outbox_entry.dart';
import '../../../../core/offline/persistent_cache.dart';
import '../../domain/entities/lab_product.dart';
import '../../domain/repositories/lab_products_repository.dart';
import '../../../../core/session/session_cache_registry.dart';
import '../datasources/lab_products_remote_datasource.dart';

class RemoteLabProductsRepository
    with PersistentListCache
    implements LabProductsRepository {
  RemoteLabProductsRepository(
    this._remote,
    this.persistentCache,
    this._outbox, {
    NetworkStatus? networkStatus,
  }) : _network = networkStatus ?? NetworkStatus.instance {
    _controller = StreamController<List<LabProduct>>.broadcast(
      onListen: _emit,
    );
    SessionCacheRegistry.instance.register(_clearCache);
  }

  /// مفتاح المورد في الكاش/الطابور.
  static const String resource = 'lab_products';

  @override
  final PersistentCache persistentCache;

  final Outbox _outbox;
  final NetworkStatus _network;

  @override
  String get cacheResource => resource;

  /// يمسح كاش الجلسة (يُستدعى عند تسجيل الخروج) — منعًا لتسريب بيانات مستخدم لآخر.
  void _clearCache() {
    _cache = const [];
    _loaded = false;
    _emit();
  }

  final LabProductsRemoteDataSource _remote;
  late final StreamController<List<LabProduct>> _controller;

  /// نسخة بالذاكرة من الكتالوج — مصدر التحديثات للـ stream بعد كل عملية.
  List<LabProduct> _cache = const [];

  /// هل جُلب الكتالوج مرة على الأقل؟ (لتمييز "لم يُحمَّل" عن "مُحمَّل وفارغ").
  bool _loaded = false;

  @override
  List<LabProduct>? get cached => _loaded ? List.unmodifiable(_cache) : null;

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_cache));
    }
  }

  @override
  Future<List<LabProduct>> getAll() async {
    try {
      final raw = await _remote.getAll();
      _cache = raw.map(_fromJson).toList();
      _loaded = true;
      await saveCachedRows(raw);
      _emit();
      return List.unmodifiable(_cache);
    } on DioException catch (e) {
      final failure = _mapDioError(e);
      // انقطاع شبكة ⇒ اعرض آخر نسخة دائمة معروفة بدل الفشل.
      if (failure is NetworkFailure || failure is TimeoutFailure) {
        final cached = await loadCachedRows();
        if (cached != null) {
          _cache = cached.map(_fromJson).toList();
          _loaded = true;
          _emit();
          return List.unmodifiable(_cache);
        }
      }
      throw failure;
    }
  }

  @override
  Future<List<LabProductCategory>> getCategories() async {
    try {
      final raw = await _remote.getCategories();
      return raw.map(_categoryFromJson).toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<LabProductCategory> createCategory(String name) async {
    try {
      final raw = await _remote.createCategory(name);
      return _categoryFromJson(raw);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<LabProductCategory> updateCategory(int id, String name) async {
    try {
      final raw = await _remote.updateCategory(id, name);
      return _categoryFromJson(raw);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    try {
      await _remote.deleteCategory(id);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  LabProductCategory _categoryFromJson(Map<String, dynamic> j) =>
      LabProductCategory(id: _toInt(j['id']), name: (j['name'] ?? '').toString());

  @override
  Future<LabProduct> create(LabProduct product) async {
    if (_network.isOnline) {
      try {
        final created = _fromJson(await _remote.create(_toBody(product)));
        _cache = [..._cache, created];
        _emit();
        await _persistMemory();
        return created;
      } on DioException catch (e) {
        final f = _mapDioError(e);
        if (!_isTransient(f)) throw f; // خطأ دائم ⇒ يُظهَر للمستخدم.
      }
    }
    return _enqueueCreate(product);
  }

  Future<LabProduct> _enqueueCreate(LabProduct product) async {
    final localId = _localId();
    final optimistic = product.copyWith(id: localId);
    _cache = [..._cache, optimistic];
    _loaded = true;
    _emit();
    await _persistMemory();
    await _outbox.add(OutboxEntry(
      id: localId,
      resource: resource,
      method: OutboxMethod.post,
      path: ApiEndpoints.labManagerAddLabItem,
      body: _toBody(product),
      localEntityId: localId,
      createdAt: DateTime.now(),
      asForm: true,
    ));
    return optimistic;
  }

  @override
  Future<LabProduct> update(LabProduct product) async {
    if (_network.isOnline && !_isLocal(product.id)) {
      try {
        final updated =
            _fromJson(await _remote.update(product.id, _toBody(product)));
        _cache = _cache
            .map((p) => p.id == updated.id ? updated : p)
            .toList(growable: false);
        _emit();
        await _persistMemory();
        return updated;
      } on DioException catch (e) {
        final f = _mapDioError(e);
        if (!_isTransient(f)) throw f;
      }
    }
    return _enqueueUpdate(product);
  }

  Future<LabProduct> _enqueueUpdate(LabProduct product) async {
    _cache = _cache
        .map((p) => p.id == product.id ? product : p)
        .toList(growable: false);
    _emit();
    await _persistMemory();

    if (_isLocal(product.id)) {
      // تعديل صنف أُنشئ أوفلاين ولم يُزامَن ⇒ عدّل جسم POST المعلّق نفسه.
      final idx = _outbox.entries.indexWhere(
          (e) => e.id == product.id && e.method == OutboxMethod.post);
      if (idx >= 0) {
        final old = _outbox.entries[idx];
        await _outbox.update(OutboxEntry(
          id: old.id,
          resource: old.resource,
          method: old.method,
          path: old.path,
          body: _toBody(product),
          localEntityId: old.localEntityId,
          createdAt: old.createdAt,
          asForm: old.asForm,
        ));
      }
    } else {
      await _outbox.add(OutboxEntry(
        id: _localId(),
        resource: resource,
        method: OutboxMethod.post,
        path: ApiEndpoints.labManagerUpdateLabItem(product.id),
        body: _toBody(product),
        localEntityId: product.id,
        createdAt: DateTime.now(),
        asForm: true,
      ));
    }
    return product;
  }

  @override
  Future<void> delete(String id) async {
    if (_network.isOnline && !_isLocal(id)) {
      try {
        await _remote.delete(id);
        _cache = _cache.where((p) => p.id != id).toList(growable: false);
        _emit();
        await _persistMemory();
        return;
      } on DioException catch (e) {
        final f = _mapDioError(e);
        if (!_isTransient(f)) throw f;
      }
    }
    _cache = _cache.where((p) => p.id != id).toList(growable: false);
    _emit();
    await _persistMemory();
    if (_isLocal(id)) {
      await _outbox.remove(id); // إلغاء إنشاء لم يُزامَن.
    } else {
      await _outbox.add(OutboxEntry(
        id: _localId(),
        resource: resource,
        method: OutboxMethod.post,
        path: ApiEndpoints.labManagerDeleteLabItem(id),
        localEntityId: id,
        createdAt: DateTime.now(),
      ));
    }
  }

  // ── مساعدات الأوفلاين ────────────────────────────────────────────────────
  String _localId() => 'local_${DateTime.now().microsecondsSinceEpoch}';
  bool _isLocal(String id) => id.startsWith('local_');
  bool _isTransient(Failure f) => f is NetworkFailure || f is TimeoutFailure;

  Future<void> _persistMemory() =>
      saveCachedRows(_cache.map(_toCacheRow).toList());

  /// صفّ الكاش الدائم — بشكل صنف الباك كي يُعاد بناؤه بنفس [_fromJson].
  Map<String, dynamic> _toCacheRow(LabProduct p) => {
        'id': p.id,
        'name': p.name,
        'type': p.type,
        'material': p.material,
        'price': p.price,
        'duration': p.productionDays,
        if (p.categoryId != null)
          'category': {'id': p.categoryId, 'name': p.categoryName},
      };

  @override
  Stream<List<LabProduct>> watchAll() => _controller.stream;

  // ── تحويل JSON ↔ entity ──────────────────────────────────────────────────

  /// يحوّل صنف الباك إلى [LabProduct]. price/duration قد يرجعان نصوصاً.
  LabProduct _fromJson(Map<String, dynamic> j) {
    final cat = j['category'] is Map
        ? Map<String, dynamic>.from(j['category'] as Map)
        : null;
    return LabProduct(
      id: '${j['id'] ?? ''}',
      name: (j['name'] ?? '').toString(),
      type: (j['type'] ?? '').toString(),
      material: (j['material'] ?? '').toString(),
      price: _toInt(j['price']),
      productionDays: _toInt(j['duration']),
      categoryId: cat != null ? _toInt(cat['id']) : null,
      categoryName: cat?['name']?.toString(),
    );
  }

  /// جسم الطلب للإنشاء/التحديث (الحقول التي يقبلها الباك من نموذجنا).
  /// category_id يُرسَل دايماً (حتى فارغاً) لا شرطياً — الباك يعتمد multipart
  /// sometimes|nullable: غياب المفتاح = "لا تغيير"، ووجوده فارغاً = "امسح
  /// الفئة". حذفه شرطياً كان يمنع تصفير الفئة من الحفظ فعلياً.
  Map<String, dynamic> _toBody(LabProduct p) => {
        'name': p.name,
        'type': p.type,
        'material': p.material,
        'price': p.price,
        'duration': p.productionDays,
        'category_id': p.categoryId?.toString() ?? '',
      };

  static int _toInt(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return double.tryParse('${v ?? ''}')?.toInt() ??
        int.tryParse('${v ?? ''}') ??
        0;
  }

  /// تحويل DioException لـ Failure مناسب (نفس منطق طبقة الـ auth/lab).
  Failure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const TimeoutFailure();
    }
    if (e.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }
    final status = e.response?.statusCode;
    if (status == null) return const NetworkFailure();

    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return ServerFailure(data['message'] as String, code: '$status');
    }
    return ServerFailure.fromStatusCode(status);
  }
}
