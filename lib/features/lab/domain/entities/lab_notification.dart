// ════════════════════════════════════════════════════════════════════════════
// lab_notification.dart
//
// كيان domain لإشعار المخبر + نوعه + يومه. نُقل من presentation ضمن بناء طبقة
// domain؛ يُعاد تصديره من lab_notification_data.dart (مع الـ style helpers) كي
// تبقى الملفات القديمة تعمل دون تعديل.
//
// ملاحظة: يعتمد على IconData (نوع قيمة من Flutter) لأن لكل إشعار أيقونته الخاصة
// غير المشتقّة من النوع — تنازل مقبول لكيان view-model.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/widgets.dart' show IconData;

enum NotificationKind { urgent, order, material, system }

enum NotificationDay { today, yesterday }

/// عنصر إشعار واحد في قائمة إشعارات المخبر.
class NotificationItem {
  NotificationItem({
    required this.kind,
    required this.title,
    required this.description,
    required this.category,
    required this.timeLabel,
    required this.day,
    required this.icon,
    this.action,
    this.isRead = false,
    this.id,
  });

  /// معرّف الإشعار بالباك — null بالبيانات الوهمية (Mock) القديمة.
  /// مطلوب لاستدعاء "تحديد كمقروء" على عنصر واحد بالـ Remote repository.
  final Object? id;
  final NotificationKind kind;
  final String title;
  final String description;
  final String category;
  final String timeLabel;
  final NotificationDay day;
  final IconData icon;
  final String? action;
  bool isRead;
}
