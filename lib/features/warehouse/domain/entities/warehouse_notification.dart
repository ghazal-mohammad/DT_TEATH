// ════════════════════════════════════════════════════════════════════════════
// warehouse_notification.dart
//
// كيان domain لإشعار المستودع. نُقل من data/mock/warehouse_pages_mock_data.dart
// عند ربط الباك (2026-08-22) كي تستخدمه طبقة الـ Repository/Cubit، وبقي
// warehouse_pages_mock_data.dart يستورده لتفادي كسر أي مرجع قديم.
// ════════════════════════════════════════════════════════════════════════════

enum NotificationCategory { low, expiry, order, general }

class WarehouseNotification {
  const WarehouseNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.category,
    this.isRead = false,
    this.actionLabel,
  });

  final String id;
  final String title;
  final String body;
  final String time;
  final NotificationCategory category;
  final bool isRead;
  final String? actionLabel;
}
