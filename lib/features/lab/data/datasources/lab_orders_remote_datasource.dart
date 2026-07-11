// ════════════════════════════════════════════════════════════════════════════
// lab_orders_remote_datasource.dart
//
// مصدر بيانات طلبات المخبر البعيد — يتصل مباشرة بـ Dio.
// التوكن يُضاف تلقائياً عبر interceptor في DioClient. يرجّع JSON خام؛ التحويل
// لـ entity من مسؤولية الـ repository.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/endpoints.dart';

class LabOrdersRemoteDataSource {
  LabOrdersRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /api/labManager/showAllLabOrders → قائمة الطلبات الخام.
  Future<List<Map<String, dynamic>>> getAll() async {
    final res =
        await _dio.get<dynamic>(ApiEndpoints.labManagerShowAllLabOrders);
    return _asList(res.data);
  }

  /// GET /api/labManager/showLabOrder/{id} → طلب واحد كامل (مع modifications).
  Future<Map<String, dynamic>> getOne(Object id) async {
    final res =
        await _dio.get<dynamic>(ApiEndpoints.labManagerShowLabOrder(id));
    return _asData(res.data);
  }

  /// POST /api/labManager/setStatusInProgress/{id} — تعيين فنّي وبدء التصنيع.
  /// يتطلّب الباك حالة الطلب = new + technician_id لفنّي متاح.
  Future<void> setInProgress(Object id, int technicianId) async {
    await _dio.post<dynamic>(
      ApiEndpoints.labManagerSetOrderInProgress(id),
      data: FormData.fromMap({'technician_id': technicianId}),
    );
  }

  /// POST /api/labManager/setStatusCompleted/{id} — إكمال الطلب.
  /// (الباك يتطلّب الحالة = in_progress؛ materials اختيارية لخصم المخزون.)
  Future<void> setCompleted(Object id) async {
    await _dio.post<dynamic>(ApiEndpoints.labManagerSetOrderCompleted(id));
  }

  /// POST /api/labManager/setStatusCancelled/{id} — إلغاء الطلب.
  Future<void> setCancelled(Object id) async {
    await _dio.post<dynamic>(ApiEndpoints.labManagerSetOrderCancelled(id));
  }

  List<Map<String, dynamic>> _asList(Object? data) {
    final list = (data is Map) ? data['data'] : null;
    if (list is! List) return <Map<String, dynamic>>[];
    return list
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// يستخرج `data` كـ Map من ردّ `{success, data:{...}}`.
  Map<String, dynamic> _asData(Object? data) {
    final inner = (data is Map) ? data['data'] : null;
    if (inner is Map) return Map<String, dynamic>.from(inner);
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }
}
