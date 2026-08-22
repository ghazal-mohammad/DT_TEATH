// ════════════════════════════════════════════════════════════════════════════
// warehouse_notifications_remote_datasource.dart
//
// مصدر بيانات إشعارات المستودع البعيد — /api/warehouseManager/notifications.
// ⚠️ ملاحظة (تحقّق فعلي 2026-08-22): لا يوجد بالباك الحالي أي مكان يرسل
// إشعاراً لدور Warehouse Manager فعلياً (كل تنبيهات نقص مخزون المستودع تُرسَل
// لـ Admin) — القائمة رح تظهر فاضية لحتى يضيف الباك نداء NotificationService
// بالمكان المناسب. راجع docs/superpowers/specs للتفاصيل.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/endpoints.dart';

class WarehouseNotificationsRemoteDataSource {
  WarehouseNotificationsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> getAll() async {
    final res = await _dio.get<dynamic>(ApiEndpoints.warehouseNotifications);
    final body = res.data;
    final inner = (body is Map) ? body['data'] : null;
    final list = (inner is Map) ? inner['data'] : inner;
    if (list is! List) return const <Map<String, dynamic>>[];
    return list
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> markRead(Object id) async {
    await _dio
        .patch<dynamic>(ApiEndpoints.warehouseMarkNotificationRead(id));
  }
}
