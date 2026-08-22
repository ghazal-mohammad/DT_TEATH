// ════════════════════════════════════════════════════════════════════════════
// lab_notifications_remote_datasource.dart
//
// مصدر بيانات إشعارات المخبر البعيد — /api/labManager/notifications.
// الباك يرجّع إشعارات خاصة بالمستخدم الحالي (user_id)، لا على مستوى المخبر
// كامل (تحقّق فعلي 2026-08-22 من routes/api.php + NotificationController).
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/endpoints.dart';

class LabNotificationsRemoteDataSource {
  LabNotificationsRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /api/labManager/notifications → قائمة مُرقّمة (paginate)، الأحدث أولاً.
  Future<List<Map<String, dynamic>>> getAll() async {
    final res = await _dio.get<dynamic>(ApiEndpoints.labManagerNotifications);
    final body = res.data;
    // الباك يلفّ الـ paginator جوا data: {data:{data:[...], ...meta}}.
    final inner = (body is Map) ? body['data'] : null;
    final list = (inner is Map) ? inner['data'] : inner;
    if (list is! List) return const <Map<String, dynamic>>[];
    return list
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// PATCH /api/labManager/notifications/{id}/read
  Future<void> markRead(Object id) async {
    await _dio.patch<dynamic>(ApiEndpoints.labManagerMarkNotificationRead(id));
  }
}
