// ════════════════════════════════════════════════════════════════════════════
// remote_lab_orders_repository.dart
//
// تنفيذ Remote لـ [LabOrdersRepository] — يجلب طلبات المخبر ويحوّل حالتها عبر
// [LabOrdersRemoteDataSource]، ويطابق عقد الـ Mock تماماً (نفس الواجهة + stream).
//
// مطابقة العقد مع الباك (تحقّق فعلي 2026-06-24):
//   الطلب: {id, status(new/in_progress/completed/cancelled),
//           delivery_date_requested, notes, total_cost, dentist{name},
//           patient{name}, technician{id,name}|null, items:[{tooth_number,
//           price, type:{name,type,material}}]}.
//   نموذج الفرونت LabOrderFull مُسطّح (نوع/مادة/سن واحد) → نأخذ أول عنصر.
//   تحويل الحالة:
//     - manufacturing → setStatusInProgress/{id} (يتطلّب technician_id؛ نحلّ
//       الاسم→id عبر LabRepository).
//     - ready        → setStatusCompleted/{id}.
//   ثم نُعيد الجلب من السيرفر ليعكس الـ stream حقيقة الباك (هو يفرض الانتقالات).
//
// قيود معروفة (تحتاج تطوّر UI لاحقاً): الطلب متعدّد العناصر يظهر بأول عنصر فقط،
// وحالة cancelled تُعرض كـ ready (لا توجد شارة إلغاء في النموذج الحالي).
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/lab_order.dart';
import '../../domain/repositories/lab_orders_repository.dart';
import '../../domain/repositories/lab_repository.dart';
import '../datasources/lab_orders_remote_datasource.dart';

class RemoteLabOrdersRepository implements LabOrdersRepository {
  RemoteLabOrdersRepository(this._remote, this._labRepo) {
    _controller = StreamController<List<LabOrderFull>>.broadcast(
      onListen: _emit,
    );
  }

  final LabOrdersRemoteDataSource _remote;

  /// لحلّ اسم الفنّي → معرّفه عند التعيين (setInProgress يحتاج technician_id).
  final LabRepository _labRepo;

  late final StreamController<List<LabOrderFull>> _controller;
  List<LabOrderFull> _cache = const [];

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_cache));
    }
  }

  @override
  Future<List<LabOrderFull>> getAll() async {
    try {
      final raw = await _remote.getAll();
      _cache = raw.map(_fromJson).toList();
      _emit();
      return List.unmodifiable(_cache);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> processOrder({
    required String id,
    required LabOrderBadgeVariant status,
    int? cost,
    String? technician,
  }) async {
    try {
      switch (status) {
        case LabOrderBadgeVariant.manufacturing:
          final techId = await _resolveTechnicianId(technician);
          await _remote.setInProgress(id, techId);
        case LabOrderBadgeVariant.ready:
          await _remote.setCompleted(id);
        case LabOrderBadgeVariant.newOrder:
          // لا يوجد انتقال للوراء إلى "جديد" في الباك — تجاهل بهدوء.
          return;
      }
      // إعادة الجلب لتعكس القائمة حالة الباك بعد الانتقال (هو مصدر الحقيقة).
      await getAll();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Stream<List<LabOrderFull>> watchAll() => _controller.stream;

  /// يحلّ اسم الفنّي إلى معرّفه عبر قائمة الفنّيين من الباك.
  Future<int> _resolveTechnicianId(String? name) async {
    final trimmed = (name ?? '').trim();
    if (trimmed.isEmpty) {
      throw const ServerFailure('اختر فنّياً لتعيينه على الطلب.', code: '422');
    }
    final techs = await _labRepo.getTechnicians();
    for (final t in techs) {
      if (t.name.trim() == trimmed) return t.id;
    }
    throw const ServerFailure('الفنّي غير موجود في القائمة.', code: '422');
  }

  // ── تحويل JSON → entity ──────────────────────────────────────────────────

  LabOrderFull _fromJson(Map<String, dynamic> j) {
    final items = (j['items'] is List) ? j['items'] as List : const <dynamic>[];
    final first = items.isNotEmpty && items.first is Map
        ? Map<String, dynamic>.from(items.first as Map)
        : const <String, dynamic>{};
    final type = first['type'] is Map
        ? Map<String, dynamic>.from(first['type'] as Map)
        : const <String, dynamic>{};
    final dentist = j['dentist'] is Map
        ? Map<String, dynamic>.from(j['dentist'] as Map)
        : const <String, dynamic>{};
    final tech = j['technician'] is Map
        ? Map<String, dynamic>.from(j['technician'] as Map)
        : null;

    final tooth = first['tooth_number'];

    return LabOrderFull(
      id: '${j['id'] ?? ''}',
      doctor: (dentist['name'] ?? '').toString(),
      type: (type['name'] ?? '').toString(),
      material: (type['material'] ?? '').toString(),
      tooth: tooth == null ? '' : '#$tooth',
      date: (j['delivery_date_requested'] ?? '').toString(),
      statusVariant: _mapStatus('${j['status'] ?? ''}'),
      notes: (j['notes'] ?? '').toString(),
      cost: _toInt(j['total_cost']),
      assignedTechnician: tech?['name']?.toString(),
    );
  }

  /// خريطة حالة الباك → شارة الفرونت (cancelled تُعرض ضمن ready مؤقّتاً).
  LabOrderBadgeVariant _mapStatus(String s) {
    switch (s) {
      case 'in_progress':
        return LabOrderBadgeVariant.manufacturing;
      case 'completed':
      case 'cancelled':
        return LabOrderBadgeVariant.ready;
      case 'new':
      default:
        return LabOrderBadgeVariant.newOrder;
    }
  }

  static int _toInt(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return double.tryParse('${v ?? ''}')?.toInt() ??
        int.tryParse('${v ?? ''}') ??
        0;
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
