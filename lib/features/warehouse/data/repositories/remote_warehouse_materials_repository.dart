// ════════════════════════════════════════════════════════════════════════════
// remote_warehouse_materials_repository.dart
//
// تنفيذ Remote لـ WarehouseMaterialsRepository عبر warehouseManager/* — **مع
// صمود أوفلاين كامل**:
//
//   • القراءة: عند نجاح الجلب نحفظ نسخة دائمة (PersistentCache). عند انقطاع
//     الشبكة نُرجع آخر نسخة معروفة بدل خطأ/فراغ.
//   • الكتابة: أوفلاين (أو عند فشل شبكة عابر) نطبّق تعديلاً تفاؤلياً محلياً +
//     نُدرج العملية في [Outbox] لتُعاد للباك عند رجوع الشبكة — فلا تضيع بيانات.
//
// عقد الباك (formatMaterial): {id, name, name_en, company_name, price_per_unit,
// dosage, unit, category(clinic|lab|both), total_stock, batches_count}. الحدّ
// الأدنى للمخزون غير موجود بالباك ⇒ minStock=0 (لا حالة "منخفض" زائفة).
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core/network/endpoints.dart';
import '../../../../core/network/failure.dart';
import '../../../../core/network/network_status.dart';
import '../../../../core/offline/outbox.dart';
import '../../../../core/offline/outbox_entry.dart';
import '../../../../core/offline/persistent_cache.dart';
import '../../../../core/session/session_cache_registry.dart';
import '../../domain/entities/material_category.dart';
import '../../domain/entities/warehouse_material.dart';
import '../../domain/repositories/warehouse_materials_repository.dart';
import '../datasources/warehouse_materials_remote_datasource.dart';

class RemoteWarehouseMaterialsRepository
    implements WarehouseMaterialsRepository {
  RemoteWarehouseMaterialsRepository(
    this._remote,
    this._cache,
    this._outbox, {
    NetworkStatus? networkStatus,
  }) : _network = networkStatus ?? NetworkStatus.instance {
    _controller =
        StreamController<List<WarehouseMaterial>>.broadcast(onListen: _emit);
    SessionCacheRegistry.instance.register(_clearCache);
  }

  /// مفتاح المورد في الكاش/الطابور.
  static const String resource = 'warehouse_materials';

  final WarehouseMaterialsRemoteDataSource _remote;
  final PersistentCache _cache;
  final Outbox _outbox;
  final NetworkStatus _network;

  late final StreamController<List<WarehouseMaterial>> _controller;
  List<WarehouseMaterial> _memory = const [];

  void _clearCache() {
    _memory = const [];
    _emit();
  }

  void _emit() {
    if (!_controller.isClosed) _controller.add(List.unmodifiable(_memory));
  }

  String _localId() => 'local_${DateTime.now().microsecondsSinceEpoch}';

  bool _isTransient(Failure f) => f is NetworkFailure || f is TimeoutFailure;

  Future<void> _persistMemory() =>
      _cache.save(resource, _memory.map(_toCacheRow).toList());

  @override
  Future<List<WarehouseMaterial>> getAll() async {
    try {
      final raw = await _remote.getAll();
      _memory = raw.map(_fromJson).toList();
      await _cache.save(resource, raw);
      _emit();
      return List.unmodifiable(_memory);
    } on DioException catch (e) {
      final failure = _mapDioError(e);
      // انقطاع شبكة ⇒ اعرض آخر نسخة دائمة معروفة بدل الفشل.
      if (_isTransient(failure)) {
        final cached = await _cache.load(resource);
        if (cached != null) {
          _memory = cached.map(_fromJson).toList();
          _emit();
          return List.unmodifiable(_memory);
        }
      }
      throw failure;
    }
  }

  @override
  Future<WarehouseMaterial> getById(String id) async {
    // أوفلاين/محلّي ⇒ من الذاكرة.
    final local = _memory.where((m) => m.id == id);
    if (!_network.isOnline && local.isNotEmpty) return local.first;
    try {
      return _fromJson(await _remote.getById(id));
    } on DioException catch (e) {
      if (local.isNotEmpty) return local.first;
      throw _mapDioError(e);
    }
  }

  @override
  Future<WarehouseMaterial> create(WarehouseMaterial material) async {
    if (_network.isOnline) {
      try {
        final created = _fromJson(await _remote.create(_toBody(material)));
        _memory = [..._memory, created];
        _emit();
        await _persistMemory();
        return created;
      } on DioException catch (e) {
        final f = _mapDioError(e);
        if (!_isTransient(f)) throw f; // خطأ دائم ⇒ يُظهَر للمستخدم.
        // عابر ⇒ تابع للمسار الأوفلاين.
      }
    }
    return _enqueueCreate(material);
  }

  Future<WarehouseMaterial> _enqueueCreate(WarehouseMaterial material) async {
    final localId = _localId();
    final optimistic = material.copyWith(id: localId);
    _memory = [..._memory, optimistic];
    _emit();
    await _persistMemory();
    await _outbox.add(OutboxEntry(
      id: localId,
      resource: resource,
      method: OutboxMethod.post,
      path: ApiEndpoints.warehouseAddMaterial,
      body: _toBody(material),
      localEntityId: localId,
      createdAt: DateTime.now(),
      asForm: true,
    ));
    return optimistic;
  }

  @override
  Future<WarehouseMaterial> update(WarehouseMaterial material) async {
    if (_network.isOnline && !_isLocal(material.id)) {
      try {
        final updated =
            _fromJson(await _remote.update(material.id, _toBody(material)));
        _memory = _memory
            .map((m) => m.id == updated.id ? updated : m)
            .toList(growable: false);
        _emit();
        await _persistMemory();
        return updated;
      } on DioException catch (e) {
        final f = _mapDioError(e);
        if (!_isTransient(f)) throw f;
      }
    }
    return _enqueueUpdate(material);
  }

  Future<WarehouseMaterial> _enqueueUpdate(WarehouseMaterial material) async {
    _memory = _memory
        .map((m) => m.id == material.id ? material : m)
        .toList(growable: false);
    _emit();
    await _persistMemory();

    if (_isLocal(material.id)) {
      // تعديل عنصر أُنشئ أوفلاين ولم يُزامَن بعد ⇒ عدّل جسم POST المعلّق نفسه
      // بدل إدراج PUT على معرّف محلّي لا يعرفه الباك.
      final idx = _outbox.entries.indexWhere(
          (e) => e.id == material.id && e.method == OutboxMethod.post);
      if (idx >= 0) {
        final old = _outbox.entries[idx];
        await _outbox.update(OutboxEntry(
          id: old.id,
          resource: old.resource,
          method: old.method,
          path: old.path,
          body: _toBody(material),
          localEntityId: old.localEntityId,
          createdAt: old.createdAt,
          asForm: old.asForm,
        ));
      }
    } else {
      await _outbox.add(OutboxEntry(
        id: _localId(),
        resource: resource,
        method: OutboxMethod.put,
        path: ApiEndpoints.warehouseUpdateMaterial(material.id),
        body: _toBody(material),
        localEntityId: material.id,
        createdAt: DateTime.now(),
        asForm: true,
      ));
    }
    return material;
  }

  @override
  Future<void> delete(String id) async {
    if (_network.isOnline && !_isLocal(id)) {
      try {
        await _remote.delete(id);
        _memory = _memory.where((m) => m.id != id).toList(growable: false);
        _emit();
        await _persistMemory();
        return;
      } on DioException catch (e) {
        final f = _mapDioError(e);
        if (!_isTransient(f)) throw f;
      }
    }
    await _enqueueDelete(id);
  }

  Future<void> _enqueueDelete(String id) async {
    _memory = _memory.where((m) => m.id != id).toList(growable: false);
    _emit();
    await _persistMemory();

    if (_isLocal(id)) {
      // حذف عنصر لم يُزامَن ⇒ يكفي إلغاء عملية الإنشاء المعلّقة.
      await _outbox.remove(id);
    } else {
      await _outbox.add(OutboxEntry(
        id: _localId(),
        resource: resource,
        method: OutboxMethod.delete,
        path: ApiEndpoints.warehouseDeleteMaterial(id),
        localEntityId: id,
        createdAt: DateTime.now(),
      ));
    }
  }

  @override
  Stream<List<WarehouseMaterial>> watchAll() => _controller.stream;

  bool _isLocal(String id) => id.startsWith('local_');

  // ── تحويل (مطابق لعقد الباك: formatMaterial) ────────────────────────────
  WarehouseMaterial _fromJson(Map<String, dynamic> j) {
    final nameEn = (j['name_en'] ?? '').toString();
    final dosage = (j['dosage'] ?? '').toString();
    return WarehouseMaterial(
      id: '${j['id'] ?? ''}',
      name: (j['name'] ?? '').toString(),
      nameEn: nameEn.isEmpty ? null : nameEn,
      companyName: (j['company_name'] ?? '').toString(),
      // إن غابت الفئة (استجابة قديمة) نضع clinic كافتراضي آمن.
      category: materialCategoryFromString('${j['category'] ?? ''}') ??
          MaterialCategory.clinic,
      quantity: _toInt(j['total_stock'] ?? j['quantity']),
      unit: (j['unit'] ?? '').toString(),
      pricePerUnit: _toDouble(j['price_per_unit']) ?? 0,
      dosage: dosage.isEmpty ? null : dosage,
      batchesCount: _toInt(j['batches_count']),
    );
  }

  /// صفّ الكاش الدائم — بشكل formatMaterial كي يُعاد بناؤه بنفس [_fromJson].
  Map<String, dynamic> _toCacheRow(WarehouseMaterial m) => {
        'id': m.id,
        'name': m.name,
        if (m.nameEn != null) 'name_en': m.nameEn,
        'company_name': m.companyName,
        'price_per_unit': m.pricePerUnit,
        if (m.dosage != null) 'dosage': m.dosage,
        'unit': m.unit,
        'category': m.category.apiKey,
        'total_stock': m.quantity,
        'batches_count': m.batchesCount,
      };

  /// body الإرسال — مطابق لـ StoreMaterialRequest:
  /// name, name_en?, company_name, price_per_unit, dosage?, unit, category.
  Map<String, dynamic> _toBody(WarehouseMaterial m) => {
        'name': m.name,
        if (m.nameEn != null && m.nameEn!.isNotEmpty) 'name_en': m.nameEn,
        'company_name': m.companyName,
        'price_per_unit': m.pricePerUnit,
        if (m.dosage != null && m.dosage!.isNotEmpty) 'dosage': m.dosage,
        'unit': m.unit,
        'category': m.category.apiKey,
      };

  static int _toInt(Object? v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
  static double? _toDouble(Object? v) =>
      v is num ? v.toDouble() : double.tryParse('${v ?? ''}');

  Failure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const TimeoutFailure();
    }
    if (e.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }
    if (e.response == null) return const NetworkFailure();
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return ServerFailure(data['message'] as String,
          code: '${e.response?.statusCode ?? ''}');
    }
    return const ServerFailure('تعذّر تنفيذ العملية على المستودع.');
  }
}
