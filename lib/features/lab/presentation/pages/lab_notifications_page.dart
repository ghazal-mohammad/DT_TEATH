// ════════════════════════════════════════════════════════════════════════════
// lab_notifications_page.dart  — Phase 5.5 ✅
//
// شاشة الإشعارات — مطابقة 100% لـ HTML المرجعي (pg-ln).
//
// الهيكل:
//   - Notification cards: تنبيه عاجل (برتقالي) / طلب جديد (سماوي) / تم التسليم (أخضر)
//   - تمييز بين المقروء وغير المقروء
//   - نقطة ملونة تحدد نوع الإشعار
//
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — pg-ln
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/core/mock_user_data.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../navigation/lab_sidebar_sections.dart';

// ══════════════════════════════════════════════════════════════════════════
//  MODELS & MOCK DATA
// ══════════════════════════════════════════════════════════════════════════

enum _NotifType { urgent, newOrder, completed }

class _NotifItem {
  const _NotifItem({
    required this.type,
    required this.icon,
    required this.title,
    required this.detail,
    required this.time,
    required this.isUnread,
  });

  final _NotifType type;
  final String icon;
  final String title;
  final String detail;
  final String time;
  final bool isUnread;
}

const _kNotifications = [
  _NotifItem(
    type: _NotifType.urgent,
    icon: '⚡',
    title: 'تنبيه: تلبيسة د. سارة — تنتهي اليوم',
    detail: 'LAB-042 يجب تسليمه قبل 14:00',
    time: 'منذ 30 دقيقة',
    isUnread: true,
  ),
  _NotifItem(
    type: _NotifType.newOrder,
    icon: '🦷',
    title: 'طلب جديد من د. خالد',
    detail: 'جسر 3 أسنان PFM — 48 ساعة',
    time: 'منذ ساعة',
    isUnread: true,
  ),
  _NotifItem(
    type: _NotifType.completed,
    icon: '✅',
    title: 'تم تسليم LAB-039',
    detail: 'تم إشعار د. سامية بالجاهزية',
    time: 'أمس',
    isUnread: false,
  ),
];

// ══════════════════════════════════════════════════════════════════════════
//  PAGE
// ══════════════════════════════════════════════════════════════════════════

/// صفحة الإشعارات — نظام المخبر.
class LabNotificationsPage extends StatelessWidget {
  const LabNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppShellLayout(
      system: AppSystemType.lab,
      currentRoute: RouteNames.labNotifications,
      sections: LabSidebarSections.buildWithBadges(
        context,
        newOrdersCount: 0,
        unreadNotifsCount: 2,
      ),
      pageTitle: l10n.notifications,
      pageSubtitle: l10n.labTopbarSubtitle,
      userName: MockUserData.labUserName,
      userRole: l10n.roleLabManager,
      notificationCount: 2,
      body: const _LabNotificationsBody(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  BODY
// ══════════════════════════════════════════════════════════════════════════

class _LabNotificationsBody extends StatelessWidget {
  const _LabNotificationsBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _kNotifications
            .map((n) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.spaceMD),
                  child: _NotifCard(item: n),
                ))
            .toList(),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  NOTIFICATION CARD
// ══════════════════════════════════════════════════════════════════════════

class _NotifCard extends StatelessWidget {
  const _NotifCard({required this.item});
  final _NotifItem item;

  Color _dotColor() {
    switch (item.type) {
      case _NotifType.urgent:
        return AppColors.dashOrange;
      case _NotifType.newOrder:
        return Colors.transparent; // no dot for new order (per HTML)
      case _NotifType.completed:
        return Colors.transparent;
    }
  }

  Color _iconBgColor() {
    switch (item.type) {
      case _NotifType.urgent:
        return AppColors.dashOrange.withValues(alpha: 0.15);
      case _NotifType.newOrder:
        return AppColors.accent.withValues(alpha: 0.12);
      case _NotifType.completed:
        return AppColors.success.withValues(alpha: 0.12);
    }
  }

  Color _borderColor(bool isLight) {
    switch (item.type) {
      case _NotifType.urgent:
        return AppColors.dashOrange.withValues(alpha: 0.3);
      case _NotifType.newOrder:
        return AppColors.accent.withValues(alpha: 0.2);
      case _NotifType.completed:
        return isLight ? AppColors.lightBorder : AppColors.darkBorder;
    }
  }

  Color _bgColor(bool isLight) {
    if (!item.isUnread) {
      return isLight ? AppColors.lightSurface : AppColors.darkSurface;
    }
    switch (item.type) {
      case _NotifType.urgent:
        return AppColors.dashOrange.withValues(alpha: 0.05);
      case _NotifType.newOrder:
        return AppColors.accent.withValues(alpha: 0.04);
      case _NotifType.completed:
        return isLight ? AppColors.lightSurface : AppColors.darkSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      decoration: BoxDecoration(
        color: _bgColor(isLight),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: _borderColor(isLight)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Circle
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _iconBgColor(),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                item.icon,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceMD),

          // Body
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isLight
                        ? AppColors.lightText1
                        : AppColors.darkText1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.detail,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isLight
                        ? AppColors.lightText4
                        : AppColors.darkText3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.time,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isLight
                        ? AppColors.lightText4
                        : AppColors.darkText4,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Dot indicator (للإشعارات غير المقروءة العاجلة)
          if (item.isUnread && item.type == _NotifType.urgent)
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _dotColor(),
                shape: BoxShape.circle,
              ),
            )
          else if (item.isUnread)
            // نقطة زرقاء للإشعارات الجديدة
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
