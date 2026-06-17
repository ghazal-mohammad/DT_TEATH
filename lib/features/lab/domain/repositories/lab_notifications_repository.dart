// ════════════════════════════════════════════════════════════════════════════
// lab_notifications_repository.dart
//
// عقد الوصول لإشعارات المخبر. عند ربط الباك: Remote يستبدل الـ Mock.
// ════════════════════════════════════════════════════════════════════════════

import '../entities/lab_notification.dart';

/// عقد الوصول لإشعارات المخبر.
abstract class LabNotificationsRepository {
  /// يجلب كل الإشعارات.
  Future<List<NotificationItem>> getAll();

  /// تحديد كل الإشعارات كمقروءة.
  Future<void> markAllRead();

  /// stream للإشعارات — لتحديث الـ UI تلقائياً.
  Stream<List<NotificationItem>> watchAll();
}
