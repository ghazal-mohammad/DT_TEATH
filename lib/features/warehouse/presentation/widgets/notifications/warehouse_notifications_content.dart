// ════════════════════════════════════════════════════════════════════════════
// warehouse_notifications_content.dart
//
// محتوى صفحة إشعارات المستودع — مطابق لـ mockup التصميم.
//
// 🎯 البنية:
//   - شريط فلاتر: 6 تابات مع counts (الكل / غير مقروءة / عاجل / طلبيات / مواد / نظام)
//   - زر "تحديد الكل كمقروء" (يظهر فقط لو فيه إشعارات غير مقروءة)
//   - قائمة الإشعارات مجمّعة حسب اليوم (اليوم / أمس / أقدم)
//   - كل إشعار: شريط جانبي ملوّن + أيقونة + عنوان + شارة فئة + إجراء
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../../../shared/widgets/layout/app_page_action_bar.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../../../shared/widgets/primitives/app_filter_chip.dart';
import '../../../../warehouse/data/mock/warehouse_pages_mock_data.dart';

// ══════════════════════════════════════════════════════════════════════════
//                              FILTERS
// ══════════════════════════════════════════════════════════════════════════

enum _NotifFilter { all, unread, urgent, orders, materials, system }

extension on _NotifFilter {
  String get label => switch (this) {
        _NotifFilter.all => 'الكل',
        _NotifFilter.unread => 'غير مقروءة',
        _NotifFilter.urgent => 'عاجل',
        _NotifFilter.orders => 'طلبيات',
        _NotifFilter.materials => 'مواد',
        _NotifFilter.system => 'نظام',
      };

  bool matches(WarehouseNotification n) {
    switch (this) {
      case _NotifFilter.all:
        return true;
      case _NotifFilter.unread:
        return !n.isRead;
      case _NotifFilter.urgent:
        return _isUrgent(n);
      case _NotifFilter.orders:
        return n.category == NotificationCategory.order;
      case _NotifFilter.materials:
        return n.category == NotificationCategory.low ||
            n.category == NotificationCategory.expiry;
      case _NotifFilter.system:
        return n.category == NotificationCategory.general;
    }
  }
}

bool _isUrgent(WarehouseNotification n) =>
    !n.isRead &&
    (n.category == NotificationCategory.low ||
        n.category == NotificationCategory.expiry);

// ══════════════════════════════════════════════════════════════════════════
//                              MAIN CONTENT
// ══════════════════════════════════════════════════════════════════════════

class WarehouseNotificationsContent extends StatefulWidget {
  const WarehouseNotificationsContent({super.key});

  @override
  State<WarehouseNotificationsContent> createState() =>
      _WarehouseNotificationsContentState();
}

class _WarehouseNotificationsContentState
    extends State<WarehouseNotificationsContent> {
  _NotifFilter _filter = _NotifFilter.all;
  late List<WarehouseNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(WarehouseNotificationsMockData.notifications);
  }

  int _count(_NotifFilter f) =>
      _notifications.where(f.matches).length;

  List<WarehouseNotification> get _filtered =>
      _notifications.where(_filter.matches).toList();

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      _notifications =
          _notifications.map((n) => _copyAsRead(n)).toList(growable: false);
    });
  }

  void _markOneRead(String id) {
    setState(() {
      _notifications = _notifications
          .map((n) => n.id == id ? _copyAsRead(n) : n)
          .toList(growable: false);
    });
  }

  WarehouseNotification _copyAsRead(WarehouseNotification n) =>
      WarehouseNotification(
        id: n.id,
        title: n.title,
        body: n.body,
        time: n.time,
        category: n.category,
        isRead: true,
        actionLabel: n.actionLabel,
      );

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final filtered = _filtered;
    final grouped = _groupByDay(filtered);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── شريط الفلاتر + زر تحديد الكل كمقروء ─────────────────────────
        AppPageActionBar(
          filter: _buildFilterChips(),
          actions: _unreadCount > 0
              ? [
                  AppButton(
                    label: 'تحديد الكل كمقروء',
                    onPressed: _markAllRead,
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.small,
                  ),
                ]
              : [],
        ),

        const SizedBox(height: 14),

        // ── المحتوى ────────────────────────────────────────────────────
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: AppEmptyState(
              icon: Icons.notifications_none_outlined,
              title: 'لا توجد إشعارات',
              message: 'لا يوجد إشعارات لعرضها في هذا الفلتر',
            ),
          )
        else
          _buildGroups(grouped, isLight),
      ],
    );
  }

  Widget _buildFilterChips() {
    return AppFilterChipRow(
      options: _NotifFilter.values
          .map((f) => '${f.label} ${_count(f)}')
          .toList(),
      selectedIndex: _filter.index,
      onChanged: (i) =>
          setState(() => _filter = _NotifFilter.values[i]),
    );
  }

  Widget _buildGroups(
      Map<String, List<WarehouseNotification>> grouped, bool isLight) {
    final entries = grouped.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i != 0) const SizedBox(height: 18),
          _DayHeader(label: entries[i].key, isLight: isLight),
          const SizedBox(height: 10),
          ...entries[i].value.map((n) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _NotificationCard(
                  isLight: isLight,
                  notification: n,
                  onMarkRead: () => _markOneRead(n.id),
                ),
              )),
        ],
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                              DAY GROUPING
// ══════════════════════════════════════════════════════════════════════════

/// يصنّف الإشعارات حسب اليوم اعتماداً على نص الـ time.
/// "منذ ..." → اليوم   |   "أمس" → أمس   |   باقي → أقدم.
Map<String, List<WarehouseNotification>> _groupByDay(
    List<WarehouseNotification> items) {
  final today = <WarehouseNotification>[];
  final yesterday = <WarehouseNotification>[];
  final older = <WarehouseNotification>[];

  for (final n in items) {
    if (n.time.startsWith('منذ')) {
      today.add(n);
    } else if (n.time.trim() == 'أمس') {
      yesterday.add(n);
    } else {
      older.add(n);
    }
  }

  return {
    if (today.isNotEmpty) 'اليوم': today,
    if (yesterday.isNotEmpty) 'أمس': yesterday,
    if (older.isNotEmpty) 'أقدم': older,
  };
}

// ══════════════════════════════════════════════════════════════════════════
//                              DAY HEADER
// ══════════════════════════════════════════════════════════════════════════

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.label, required this.isLight});

  final String label;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 2),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isLight ? AppColors.lightText3 : AppColors.darkText3,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                              NOTIFICATION CARD
// ══════════════════════════════════════════════════════════════════════════

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.isLight,
    required this.notification,
    required this.onMarkRead,
  });

  final bool isLight;
  final WarehouseNotification notification;
  final VoidCallback onMarkRead;

  bool get _isUrgent => _isUrgentN(notification);

  Color get _accentColor {
    if (_isUrgent) return AppColors.alertRed;
    switch (notification.category) {
      case NotificationCategory.low:
      case NotificationCategory.expiry:
        return AppColors.dashAmber;
      case NotificationCategory.order:
        return AppColors.dashCyan;
      case NotificationCategory.general:
        return AppColors.warehouseSystem;
    }
  }

  IconData get _icon {
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

  String get _badgeText {
    if (_isUrgent) return 'عاجل';
    switch (notification.category) {
      case NotificationCategory.low:
      case NotificationCategory.expiry:
        return 'مواد';
      case NotificationCategory.order:
        return 'طلبية';
      case NotificationCategory.general:
        return 'إنجاز';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !notification.isRead;
    final cardBg = isLight ? AppColors.baseComponent : AppColors.darkSurface;
    final unreadTint = isLight
        ? _accentColor.withValues(alpha: 0.04)
        : _accentColor.withValues(alpha: 0.08);

    return Container(
      decoration: BoxDecoration(
        color: isUnread ? unreadTint : cardBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // شريط جانبي ملوّن (يسار البطاقة بصرياً في RTL = end)
            Container(width: 4, color: _accentColor),
            Expanded(child: _buildBody(isUnread)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(bool isUnread) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أيقونة الفئة
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, color: _accentColor, size: 20),
          ),
          const SizedBox(width: 12),

          // محتوى
          Expanded(child: _buildContent(isUnread)),
        ],
      ),
    );
  }

  Widget _buildContent(bool isUnread) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان + badge + (نقطة غير مقروء)
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: isUnread ? FontWeight.w800 : FontWeight.w700,
                  color: isLight
                      ? AppColors.lightText1
                      : AppColors.darkText1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _CategoryBadge(text: _badgeText, color: _accentColor),
            const Spacer(),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.alertRed,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),

        // نص الإشعار
        Text(
          notification.body,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13,
            height: 1.5,
            color:
                isLight ? AppColors.lightText3 : AppColors.darkText2,
          ),
        ),

        const SizedBox(height: 10),

        // الصف السفلي: الوقت + الإجراءات
        Row(
          children: [
            Text(
              notification.time,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 11.5,
                color:
                    isLight ? AppColors.lightText4 : AppColors.darkText4,
              ),
            ),
            const Spacer(),
            if (notification.actionLabel != null)
              _ActionPill(
                label: notification.actionLabel!,
                color: _accentColor,
                onTap: () {
                  if (isUnread) onMarkRead();
                },
              ),
            if (isUnread) ...[
              const SizedBox(width: 6),
              _MarkReadButton(
                isLight: isLight,
                onTap: onMarkRead,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

bool _isUrgentN(WarehouseNotification n) => _isUrgent(n);

// ── Pieces ──────────────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(color: color.withValues(alpha: 0.32)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _MarkReadButton extends StatelessWidget {
  const _MarkReadButton({required this.isLight, required this.onTap});
  final bool isLight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        'تحديد كمقروء',
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isLight ? AppColors.lightText3 : AppColors.darkText3,
        ),
      ),
    );
  }
}
