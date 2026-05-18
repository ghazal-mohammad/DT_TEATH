// ════════════════════════════════════════════════════════════════════════════
// warehouse_notifications_content.dart
//
// المحتوى الكامل لصفحة الإشعارات — Phase 4.7 مكتملة.
//
// 🎯 الهدف:
//   - 5 filter chips (الكل / غير مقروء / نفاد / صلاحية / طلبيات)
//   - قائمة إشعارات: أيقونة + عنوان + نص + وقت + إجراء
//   - CTA "تحديد الكل كمقروء"
//   - Empty state
//
// المرجع: DT_Teeth_Warehouse_v6_Enhanced.html — pg-not
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../../../shared/widgets/layout/app_page_action_bar.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../../../shared/widgets/primitives/app_filter_chip.dart';
import '../../../../warehouse/data/mock/warehouse_pages_mock_data.dart';

// ══════════════════════════════════════════════════════════════════════════
//                          MAIN CONTENT
// ══════════════════════════════════════════════════════════════════════════

class WarehouseNotificationsContent extends StatefulWidget {
  const WarehouseNotificationsContent({super.key});

  @override
  State<WarehouseNotificationsContent> createState() =>
      _WarehouseNotificationsContentState();
}

class _WarehouseNotificationsContentState
    extends State<WarehouseNotificationsContent> {
  // 0=الكل، 1=غير مقروء، 2=نفاد، 3=صلاحية، 4=طلبيات
  int _filterIndex = 0;
  List<WarehouseNotification> _notifications =
      List.from(WarehouseNotificationsMockData.notifications);

  List<WarehouseNotification> get _filtered {
    switch (_filterIndex) {
      case 1:
        return _notifications.where((n) => !n.isRead).toList();
      case 2:
        return _notifications
            .where((n) => n.category == NotificationCategory.low)
            .toList();
      case 3:
        return _notifications
            .where((n) => n.category == NotificationCategory.expiry)
            .toList();
      case 4:
        return _notifications
            .where((n) => n.category == NotificationCategory.order)
            .toList();
      default:
        return _notifications;
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => WarehouseNotification(
                id: n.id,
                title: n.title,
                body: n.body,
                time: n.time,
                category: n.category,
                isRead: true,
                actionLabel: n.actionLabel,
              ))
          .toList();
    });
  }

  void _markOneRead(String id) {
    setState(() {
      _notifications = _notifications
          .map((n) => n.id == id
              ? WarehouseNotification(
                  id: n.id,
                  title: n.title,
                  body: n.body,
                  time: n.time,
                  category: n.category,
                  isRead: true,
                  actionLabel: n.actionLabel,
                )
              : n)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Toolbar ─────────────────────────────────────────────────
        AppPageActionBar(
          filter: _buildFilterChips(context),
          actions: _unreadCount > 0
              ? [
                  AppButton(
                    label: context.l10n.whNotifMarkAllRead,
                    onPressed: _markAllRead,
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.small,
                  ),
                ]
              : [],
        ),

        // ── قائمة الإشعارات ──────────────────────────────────────────
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: AppEmptyState(
              icon: Icons.notifications_none_outlined,
              title: context.l10n.emptyNoNotificationsTitle,
              message: context.l10n.emptyNoNotificationsMessage,
            ),
          )
        else
          _buildNotificationsList(context, filtered),
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final labels = [
      context.l10n.whFilterAll,
      context.l10n.whNotifFilterUnread,
      context.l10n.whNotifFilterLow,
      context.l10n.whNotifFilterExpiry,
      context.l10n.whNotifFilterOrder,
    ];

    return AppFilterChipRow(
      options: labels,
      selectedIndex: _filterIndex,
      onChanged: (i) => setState(() => _filterIndex = i),
    );
  }

  Widget _buildNotificationsList(
      BuildContext context, List<WarehouseNotification> notifications) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      decoration: BoxDecoration(
        color: isLight ? AppColors.baseComponent : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: Column(
        children: [
          for (var i = 0; i < notifications.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                color:
                    isLight ? AppColors.lightBorder : AppColors.darkBorder,
              ),
            _NotificationTile(
              notification: notifications[i],
              isLight: isLight,
              onMarkRead: () => _markOneRead(notifications[i].id),
            ),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  NOTIFICATION TILE
// ════════════════════════════════════════════════════════════════════════════

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.isLight,
    required this.onMarkRead,
  });

  final WarehouseNotification notification;
  final bool isLight;
  final VoidCallback onMarkRead;

  Color get _categoryColor {
    switch (notification.category) {
      case NotificationCategory.low:
        return AppColors.dashPink;
      case NotificationCategory.expiry:
        return AppColors.dashAmber;
      case NotificationCategory.order:
        return AppColors.dashCyan;
      case NotificationCategory.general:
        return AppColors.warehouseSystem;
    }
  }

  IconData get _categoryIcon {
    switch (notification.category) {
      case NotificationCategory.low:
        return Icons.inventory_2_outlined;
      case NotificationCategory.expiry:
        return Icons.timer_outlined;
      case NotificationCategory.order:
        return Icons.shopping_bag_outlined;
      case NotificationCategory.general:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !notification.isRead;
    final unreadBg = isLight
        ? const Color(0x08BED8FA)
        : const Color(0x089EFBEC);

    return Container(
      color: isUnread ? unreadBg : Colors.transparent,
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── أيقونة الفئة ────────────────────────────────────────────
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _categoryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_categoryIcon, color: _categoryColor, size: 22),
              ),
              // نقطة "غير مقروء"
              if (isUnread)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.alertRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 14),

          // ── المحتوى ─────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عنوان + وقت
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14,
                          fontWeight:
                              isUnread ? FontWeight.w700 : FontWeight.w600,
                          color: isLight
                              ? AppColors.lightText1
                              : AppColors.darkText1,
                        ),
                      ),
                    ),
                    Text(
                      notification.time,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12,
                        color: isLight
                            ? AppColors.lightText4
                            : AppColors.darkText4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // نص الإشعار
                Text(
                  notification.body,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    color: isLight ? AppColors.lightText3 : AppColors.darkText3,
                  ),
                ),

                // Action button
                if (notification.actionLabel != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          if (isUnread) onMarkRead();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          backgroundColor:
                              _categoryColor.withValues(alpha: 0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusFull),
                          ),
                        ),
                        child: Text(
                          notification.actionLabel!,
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _categoryColor,
                          ),
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: onMarkRead,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                          ),
                          child: Text(
                            'تحديد كمقروء',
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 12,
                              color: isLight
                                  ? AppColors.lightText3
                                  : AppColors.darkText3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
