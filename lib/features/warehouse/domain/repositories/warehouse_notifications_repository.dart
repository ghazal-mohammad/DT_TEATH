// ════════════════════════════════════════════════════════════════════════════
// warehouse_notifications_repository.dart
//
// عقد الوصول لإشعارات المستودع.
// ════════════════════════════════════════════════════════════════════════════

import '../entities/warehouse_notification.dart';

abstract class WarehouseNotificationsRepository {
  /// يجلب كل إشعارات المستخدم الحالي.
  Future<List<WarehouseNotification>> getAll();

  /// تحديد إشعار واحد كمقروء.
  Future<void> markRead(String id);

  /// تحديد كل الإشعارات كمقروءة.
  Future<void> markAllRead();

  /// stream للإشعارات — لتحديث الـ UI تلقائياً.
  Stream<List<WarehouseNotification>> watchAll();
}
