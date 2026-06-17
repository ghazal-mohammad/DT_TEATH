// ════════════════════════════════════════════════════════════════════════════
// lab_notification_data.dart
//
// ستايل نوع الإشعار (خلفية/لون) + نص الشارة المترجم (يعتمدان على AppColors و
// l10n — من اختصاص presentation). الكيان (NotificationItem + الـ enums) انتقل
// إلى domain/entities/lab_notification.dart ونُعيد تصديره هنا.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/lab_notification.dart';

export '../../../domain/entities/lab_notification.dart'
    show NotificationItem, NotificationKind, NotificationDay;

/// ستايل شارة/أيقونة الإشعار (خلفية + لون أمامي) حسب النوع.
class NotificationStyle {
  const NotificationStyle(this.bg, this.fg);
  final Color bg;
  final Color fg;
}

/// يرجع ستايل النوع حسب الوضع (فاتح/غامق).
NotificationStyle notificationStyleOf(NotificationKind k, bool isLight) {
  switch (k) {
    case NotificationKind.urgent:
      return isLight
          ? const NotificationStyle(AppColors.statusWarnBg, AppColors.statusWarn)
          : NotificationStyle(
              AppColors.darkChipOrangeBg, AppColors.darkChipOrangeText);
    case NotificationKind.order:
      return isLight
          ? const NotificationStyle(AppColors.statusInfoBg, AppColors.statusInfo)
          : NotificationStyle(
              AppColors.darkChipBlueBg, AppColors.darkChipBlueText);
    case NotificationKind.material:
      return isLight
          ? const NotificationStyle(
              AppColors.statusProgressBg, AppColors.statusProgress)
          : NotificationStyle(
              AppColors.darkChipVioletBg, AppColors.darkChipVioletText);
    case NotificationKind.system:
      return isLight
          ? const NotificationStyle(
              AppColors.statusSuccessBg, AppColors.statusSuccess)
          : NotificationStyle(
              AppColors.darkChipGreenBg, AppColors.darkChipGreenText);
  }
}

/// نص شارة نوع الإشعار المترجم.
String notificationKindLabel(BuildContext context, NotificationKind k) {
  final l10n = context.l10n;
  switch (k) {
    case NotificationKind.urgent:
      return l10n.priorityUrgent;
    case NotificationKind.order:
      return l10n.notifBadgeOrder;
    case NotificationKind.material:
      return l10n.notifFilterMaterials;
    case NotificationKind.system:
      return l10n.notifFilterSystem;
  }
}
