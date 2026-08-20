// ════════════════════════════════════════════════════════════════════════════
// remote_lab_material_requests_repository.dart
//
// تنفيذ Remote لـ [LabMaterialRequestsRepository] — يجلب/ينشئ فواتير طلب مواد
// عبر [LabMaterialRequestsRemoteDataSource].
//
// مطابقة العقد مع الباك (نفس مورد MaterialRequestResource المستخدم بجهة
// المستودع warehouseManager — تحقّق عبر warehouse_request.dart الشغّال):
//   {id, status(new/pending/completed/rejected/cancelled), requester:{name},
//    requester_type, notes,
//    items:[{id, material, quantity_requested, notes}],
//    new_items:[{id, material_name, quantity, unit, company_name, reason}],
//    created_at}.
//   الإرسال: items[] لمواد كتالوج المستودع (material_id)، new_items[] لمواد
//   شركة خارجية (material_name) — جسم JSON خام (Map)، ليس FormData.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core/network/failure.dart';
import '../../../../core/offline/cached_list_repository.dart';
import '../../../../core/offline/persistent_cache.dart';
import '../../domain/entities/lab_material_request.dart';
import '../../domain/entities/warehouse_material_ref.dart';
import '../../domain/repositories/lab_material_requests_repository.dart';
import '../../../../core/session/session_cache_registry.dart';
import '../datasources/lab_material_requests_remote_datasource.dart';

class RemoteLabMaterialRequestsRepository
    with PersistentListCache
    implements LabMaterialRequestsRepository {
  RemoteLabMaterialRequestsRepository(this._remote, this.persistentCache) {
    _controller = StreamController<List<MatRequest>>.broadcast(onListen: _emit);
    SessionCacheRegistry.instance.register(_clearCache);
  }

  @override
  final PersistentCache persistentCache;

  @override
  String get cacheResource => 'lab_material_requests';

  /// يمسح كاش الجلسة (يُستدعى عند تسجيل الخروج) — منعًا لتسريب بيانات مستخدم لآخر.
  void _clearCache() {
    _cache = const [];
    _loaded = false;
    _emit();
  }

  final LabMaterialRequestsRemoteDataSource _remote;
  late final StreamController<List<MatRequest>> _controller;
  List<MatRequest> _cache = const [];

  /// هل جُلبت القائمة مرة على الأقل؟ (لتمييز "لم يُحمَّل" عن "مُحمَّل وفارغ").
  bool _loaded = false;

  @override
  List<MatRequest>? get cached => _loaded ? List.unmodifiable(_cache) : null;

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_cache));
    }
  }

  @override
  Future<List<MatRequest>> getAll() async {
    try {
      final raw = await _remote.getAll();
      _cache = raw.map(_fromJson).toList();
      _loaded = true;
      await saveCachedRows(raw);
      _emit();
      return List.unmodifiable(_cache);
    } on DioException catch (e) {
      final failure = _mapDioError(e);
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
  Future<MatRequest> getOne(String id) async {
    try {
      // id (String) → int حين يكون رقمياً محضاً (الحالة الشائعة)، وإلا يُترك
      // كما هو؛ التحويل نفسه يفيد أيضاً في بناء الـ URL بشكل نظيف.
      final raw = await _remote.getOne(int.tryParse(id) ?? id);
      return _fromJson(raw);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<WarehouseMaterialRef>> getWarehouseMaterials() async {
    try {
      final raw = await _remote.getWarehouseMaterials();
      return raw.map(_refFromJson).where((m) => m.materialId > 0 && m.name.isNotEmpty).toList(growable: false);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<WarehouseMaterialRef> getWarehouseMaterial(int id) async {
    try {
      final raw = await _remote.getWarehouseMaterial(id);
      return _refFromJson(raw);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  WarehouseMaterialRef _refFromJson(Map<String, dynamic> m) => WarehouseMaterialRef(
        materialId: int.tryParse('${m['material_id'] ?? ''}') ?? 0,
        name: '${m['material'] ?? ''}'.trim(),
        unit: '${m['unit'] ?? ''}'.trim(),
      );

  @override
  Future<void> addRequestFromWarehouse({
    required List<({int materialId, int quantity, String? notes})> items,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        'items': [
          for (final it in items)
            {
              'material_id': it.materialId,
              'quantity_requested': it.quantity,
              if (it.notes != null && it.notes!.isNotEmpty) 'notes': it.notes,
            },
        ],
      };
      await _remote.create(body);
      await getAll();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> addRequestFromCompany({
    required String companyName,
    required List<({String materialName, int quantity, String unit, String? reason})> items,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        'new_items': [
          for (final it in items)
            {
              'material_name': it.materialName,
              'quantity': it.quantity,
              'unit': it.unit,
              'company_name': companyName,
              if (it.reason != null && it.reason!.isNotEmpty) 'reason': it.reason,
            },
        ],
      };
      await _remote.create(body);
      await getAll();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _remote.delete(id);
      _cache = _cache.where((r) => r.id != id).toList(growable: false);
      _emit();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Stream<List<MatRequest>> watchAll() => _controller.stream;

  // ── تحويل JSON → entity ──────────────────────────────────────────────────

  MatRequest _fromJson(Map<String, dynamic> j) {
    final requester = j['requester'] is Map
        ? Map<String, dynamic>.from(j['requester'] as Map)
        : const <String, dynamic>{};

    return MatRequest(
      id: '${j['id'] ?? ''}',
      status: _mapStatus('${j['status'] ?? ''}'),
      requestedBy: (requester['name'] ?? '').toString(),
      requesterType: (j['requester_type'] ?? '').toString(),
      date: '${j['created_at'] ?? ''}'.split(' ').first,
      notes: (j['notes']?.toString().isEmpty ?? true) ? null : j['notes'].toString(),
      items: _asList(j['items']).map(_itemFromJson).toList(growable: false),
      newItems: _asList(j['new_items']).map(_newItemFromJson).toList(growable: false),
    );
  }

  MatRequestItem _itemFromJson(Map<String, dynamic> j) => MatRequestItem(
        id: '${j['id'] ?? ''}',
        materialName: (j['material'] ?? '').toString(),
        quantityRequested: _toInt(j['quantity_requested']),
        notes: (j['notes']?.toString().isEmpty ?? true) ? null : j['notes'].toString(),
      );

  MatRequestNewItem _newItemFromJson(Map<String, dynamic> j) => MatRequestNewItem(
        id: '${j['id'] ?? ''}',
        materialName: (j['material_name'] ?? '').toString(),
        quantity: _toInt(j['quantity']),
        unit: (j['unit'] ?? '').toString(),
        companyName: _nn(j['company_name']),
        reason: _nn(j['reason']),
      );

  static List<Map<String, dynamic>> _asList(Object? v) => (v is List)
      ? v.whereType<Map<dynamic, dynamic>>().map((e) => Map<String, dynamic>.from(e)).toList()
      : const [];

  static int _toInt(Object? v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;

  static String? _nn(Object? v) => (v == null || v.toString().isEmpty) ? null : v.toString();

  /// خريطة حالة الباك → حالة الفرونت. القيم الحقيقية بالباك (enum
  /// material_requests.status، تحقّق مباشر من migration الباك بتاريخ
  /// 2026-08-14 بعد إعادة تسمية الباك لـ in_progress ⇒ pending):
  /// new | pending | completed | rejected | cancelled.
  MatRequestStatus _mapStatus(String s) {
    switch (s) {
      case 'pending':
        return MatRequestStatus.inProgress;
      case 'completed':
        return MatRequestStatus.delivered;
      case 'rejected':
        return MatRequestStatus.unavailable;
      case 'cancelled':
        return MatRequestStatus.cancelled;
      case 'new':
      default:
        return MatRequestStatus.newRequest;
    }
  }

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
