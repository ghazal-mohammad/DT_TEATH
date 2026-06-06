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

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../../warehouse/data/mock/warehouse_pages_mock_data.dart';

// ══════════════════════════════════════════════════════════════════════════
//                              FILTERS
// ══════════════════════════════════════════════════════════════════════════

enum _NotifFilter { all, unread, urgent, orders, materials, system }

extension on _NotifFilter {
  String label(AppLocalizations l10n) => switch (this) {
        _NotifFilter.all => l10n.ordersFilterAll,
        _NotifFilter.unread => l10n.notifFilterUnread,
        _NotifFilter.urgent => l10n.ordersUrgent,
        _NotifFilter.orders => l10n.notifFilterOrders,
        _NotifFilter.materials => l10n.notifFilterMaterials,
        _NotifFilter.system => l10n.notifFilterSystem,
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
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _notifications = List.from(WarehouseNotificationsMockData.notifications);
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  int _count(_NotifFilter f) =>
      _notifications.where(f.matches).length;

  bool _matchesQuery(WarehouseNotification n) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return n.title.toLowerCase().contains(q) ||
        n.body.toLowerCase().contains(q);
  }

  List<WarehouseNotification> get _filtered => _notifications
      .where((n) => _filter.matches(n) && _matchesQuery(n))
      .toList();

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
    final l10n = context.l10n;
    final filtered = _filtered;
    final grouped = _groupByDay(filtered, l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── شريط البحث + أيقونات ───────────────────────────────────────
        _SearchRow(
          controller: _searchCtrl,
          isLight: isLight,
        ),
        const SizedBox(height: 14),

        // ── شريط الفلاتر + زر تحديد الكل كمقروء ─────────────────────────
        _FilterAndActionRow(
          filter: _filter,
          counts: {
            for (final f in _NotifFilter.values) f: _count(f),
          },
          onChanged: (f) => setState(() => _filter = f),
          showMarkAll: _unreadCount > 0,
          onMarkAll: _markAllRead,
          isLight: isLight,
        ),

        const SizedBox(height: 14),

        // ── المحتوى ────────────────────────────────────────────────────
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: AppEmptyState(
              icon: Icons.notifications_none_outlined,
              title: l10n.notifEmptyTitle,
              message: l10n.notifEmptyMessage,
            ),
          )
        else
          _buildGroups(grouped, isLight),
      ],
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
    List<WarehouseNotification> items, AppLocalizations l10n) {
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
    if (today.isNotEmpty) l10n.notifGroupToday: today,
    if (yesterday.isNotEmpty) l10n.notifGroupYesterday: yesterday,
    if (older.isNotEmpty) l10n.notifGroupOlder: older,
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

  String _badgeText(AppLocalizations l10n) {
    if (_isUrgent) return l10n.ordersUrgent;
    switch (notification.category) {
      case NotificationCategory.low:
      case NotificationCategory.expiry:
        return l10n.notifFilterMaterials;
      case NotificationCategory.order:
        return l10n.notifBadgeOrder;
      case NotificationCategory.general:
        return l10n.notifBadgeDone;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bool isUnread = !notification.isRead;
    final cardBg = isLight ? AppColors.baseComponent : AppColors.darkSurface;
    final unreadTint = isLight
        ? _accentColor.withValues(alpha: 0.04)
        : _accentColor.withValues(alpha: 0.08);

    // RTL Row: أوّل child = يمين، آخر child = يسار.
    // ترتيب المطلوب فيزيائياً: [stripe-يسار][icon][content-وسط/يمين]
    //                          [actionBtn-يسار-تحت]
    // لذلك بالـ Row: [content-أول=يمين, icon, actionBtn, stripe-آخر=يسار]
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── المحتوى (يمين) ────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: _buildContent(isUnread, l10n),
              ),
            ),
            // ── العمود الأيسر: أيقونة فوق + زر الإجراء تحت ──────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _accentColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_icon, color: _accentColor, size: 20),
                  ),
                  if (notification.actionLabel != null) ...[
                    const SizedBox(height: 10),
                    _ActionPill(
                      label: notification.actionLabel!,
                      color: _accentColor,
                      onTap: () {
                        if (isUnread) onMarkRead();
                      },
                    ),
                  ],
                ],
              ),
            ),
            // ── شريط جانبي ملوّن (يسار البطاقة فيزيائياً) ───────
            Container(width: 4, color: _accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isUnread, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان + badge
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
            _CategoryBadge(text: _badgeText(l10n), color: _accentColor),
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

        // الصف السفلي: تصنيف · الوقت  (محاذاة يمين في RTL)
        Row(
          children: [
            Text(
              _badgeText(l10n),
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isLight ? AppColors.lightText3 : AppColors.darkText3,
              ),
            ),
            Text(
              '  ·  ',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 11.5,
                color: isLight ? AppColors.lightText4 : AppColors.darkText4,
              ),
            ),
            Text(
              notification.time,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 11.5,
                color:
                    isLight ? AppColors.lightText4 : AppColors.darkText4,
              ),
            ),
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

// ══════════════════════════════════════════════════════════════════════════
//                        SEARCH ROW (settings + bell + search)
// ══════════════════════════════════════════════════════════════════════════

class _SearchRow extends StatelessWidget {
  const _SearchRow({required this.controller, required this.isLight});

  final TextEditingController controller;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final Color iconBg = isLight ? const Color(0xFFF8F9FC) : AppColors.darkBg2;
    final Color border = isLight ? AppColors.lightBorder : AppColors.darkBorder;
    final Color text2 = isLight ? AppColors.lightText2 : AppColors.darkText2;
    final Color text4 = isLight ? AppColors.lightText4 : AppColors.darkText4;
    return Row(
      children: [
        _IconBox(
          icon: Icons.settings_outlined,
          bg: iconBg,
          border: border,
          color: text2,
          onTap: () {},
        ),
        const SizedBox(width: 8),
        _IconBox(
          icon: Icons.notifications_none_outlined,
          bg: iconBg,
          border: border,
          color: text2,
          onTap: () {},
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13.5,
                      color: isLight
                          ? AppColors.lightText1
                          : AppColors.darkText1,
                    ),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: context.l10n.notifSearchHint,
                      hintStyle: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13.5,
                        color: text4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.search, size: 18, color: text2),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({
    required this.icon,
    required this.bg,
    required this.border,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color bg;
  final Color border;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          border: Border.all(color: border),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                  FILTER PILLS + MARK-ALL-READ BUTTON ROW
// ══════════════════════════════════════════════════════════════════════════

class _FilterAndActionRow extends StatelessWidget {
  const _FilterAndActionRow({
    required this.filter,
    required this.counts,
    required this.onChanged,
    required this.showMarkAll,
    required this.onMarkAll,
    required this.isLight,
  });

  final _NotifFilter filter;
  final Map<_NotifFilter, int> counts;
  final ValueChanged<_NotifFilter> onChanged;
  final bool showMarkAll;
  final VoidCallback onMarkAll;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final pills = Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _NotifFilter.values.map((f) {
        return _NotifPill(
          label: f.label(context.l10n),
          count: counts[f] ?? 0,
          isActive: f == filter,
          onTap: () => onChanged(f),
          isLight: isLight,
        );
      }).toList(),
    );

    final markBtn = showMarkAll
        ? InkWell(
            onTap: onMarkAll,
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isLight ? const Color(0xFFF8F9FC) : AppColors.darkBg2,
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                border: Border.all(
                  color:
                      isLight ? AppColors.lightBorder : AppColors.darkBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_rounded,
                      size: 16,
                      color: isLight
                          ? AppColors.lightText2
                          : AppColors.darkText2),
                  const SizedBox(width: 6),
                  Text(
                    context.l10n.notifMarkAllRead,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isLight
                          ? AppColors.lightText2
                          : AppColors.darkText2,
                    ),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();

    // في RTL: أوّل child = يمين. لتثبيت pills يمين و markBtn يسار:
    // [pills, Spacer, markBtn].
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(child: pills),
        const SizedBox(width: 10),
        const Spacer(),
        markBtn,
      ],
    );
  }
}

// ── Pill chip للفلتر: label + count داخل كبسولة، النشط dark navy ─────────
class _NotifPill extends StatelessWidget {
  const _NotifPill({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
    required this.isLight,
  });

  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final bg = isActive
        ? AppColors.primary
        : (isLight ? const Color(0xFFF1EDE6) : AppColors.darkBg2);
    final labelColor = isActive
        ? Colors.white
        : (isLight ? AppColors.lightText1 : AppColors.darkText1);
    final countBg = isActive
        ? Colors.white.withValues(alpha: 0.18)
        : (isLight ? Colors.white : AppColors.darkBg1);
    final countColor = isActive
        ? Colors.white
        : (isLight ? AppColors.lightText3 : AppColors.darkText3);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.fromLTRB(6, 4, 12, 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: countBg,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: countColor,
                ),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
