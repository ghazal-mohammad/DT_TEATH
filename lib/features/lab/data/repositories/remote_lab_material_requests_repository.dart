// ════════════════════════════════════════════════════════════════════════════
// remote_lab_material_requests_repository.dart
//
// تنفيذ Remote لـ [LabMaterialRequestsRepository] — يجلب/ينشئ طلبات المواد عبر
// [LabMaterialRequestsRemoteDataSource]، ويطابق عقد الـ Mock (نفس الواجهة + stream).
//
// مطابقة العقد مع الباك (تحقّق فعلي 2026-06-24):
//   الطلب: {id, status(pending/...), requester_type, notes, items:[{material,
//           quantity_requested, status, notes}], new_items:[{material_name,
//           quantity, unit, company_name, reason, status}], created_at}.
//   نموذج الفرونت MatRequest مسطّح (مادة واحدة) ⇒ نأخذ أول new_item وإلا أول item.
//   الإضافة من الفرونت (اسم/كمية/وحدة/شركة/سبب بلا material_id) تُرسَل كـ
//   new_items[0] — يطابق مسار "مادة جديدة" بالباك تماماً.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/lab_material_request.dart';
import '../../domain/repositories/lab_material_requests_repository.dart';
import '../../../../core/session/session_cache_registry.dart';
import '../datasources/lab_material_requests_remote_datasource.dart';

class RemoteLabMaterialRequestsRepository
    implements LabMaterialRequestsRepository {
  RemoteLabMaterialRequestsRepository(this._remote) {
    _controller = StreamController<List<MatRequest>>.broadcast(onListen: _emit);
    SessionCacheRegistry.instance.register(_clearCache);
  }

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
      _emit();
      return List.unmodifiable(_cache);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> addRequest({
    required String material,
    required String quantity,
    required String unit,
    required String requestedBy,
    String? company,
    String? reason,
  }) async {
    try {
      // requestedBy لا يُرسَل — الباك يعتمد المستخدم المُصادَق. المادة بلا
      // material_id ⇒ مسار "مادة جديدة" (new_items).
      await _remote.create({
        'new_items': [
          {
            'material_name': material,
            'quantity': quantity,
            if (unit.isNotEmpty) 'unit': unit,
            if (company != null && company.isNotEmpty) 'company_name': company,
            if (reason != null && reason.isNotEmpty) 'reason': reason,
          },
        ],
      });
      await getAll(); // إعادة الجلب ليعكس الـ stream القائمة بعد الإضافة.
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
    final newItems =
        (j['new_items'] is List) ? j['new_items'] as List : const <dynamic>[];
    final items =
        (j['items'] is List) ? j['items'] as List : const <dynamic>[];

    // الأولوية لمادة جديدة (new_item)، وإلا مادة موجودة (item).
    final Map<String, dynamic> newItem =
        newItems.isNotEmpty && newItems.first is Map
            ? Map<String, dynamic>.from(newItems.first as Map)
            : const {};
    final Map<String, dynamic> item = items.isNotEmpty && items.first is Map
        ? Map<String, dynamic>.from(items.first as Map)
        : const {};

    final requester = j['requester'] is Map
        ? Map<String, dynamic>.from(j['requester'] as Map)
        : const <String, dynamic>{};

    final bool isNew = newItem.isNotEmpty;

    return MatRequest(
      id: '${j['id'] ?? ''}',
      material: (isNew ? newItem['material_name'] : item['material'] ?? '')
          .toString(),
      quantity:
          '${isNew ? newItem['quantity'] : item['quantity_requested'] ?? ''}',
      unit: (isNew ? (newItem['unit'] ?? '') : '').toString(),
      requestedBy: (requester['name'] ?? '').toString(),
      date: '${j['created_at'] ?? ''}'.split(' ').first,
      status: _mapStatus('${j['status'] ?? ''}'),
      note: (j['notes'] as String?)?.isNotEmpty == true
          ? j['notes'] as String
          : null,
      company: isNew ? newItem['company_name']?.toString() : null,
      reason: isNew ? newItem['reason']?.toString() : null,
    );
  }

  /// خريطة حالة الباك → حالة الفرونت.
  MatRequestStatus _mapStatus(String s) {
    switch (s) {
      case 'fulfilled':
      case 'delivered':
      case 'approved':
        return MatRequestStatus.delivered;
      case 'rejected':
      case 'unavailable':
        return MatRequestStatus.unavailable;
      case 'pending':
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
