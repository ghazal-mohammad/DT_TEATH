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
import '../../../../../shared/widgets/primitives/app_segmented_tabs.dart';
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
  const WarehouseNotificationsContent({super.key, this.query = ''});

  /// نص البحث القادم من شريط الـ topbar الموحّد (لا بحث داخل الصفحة).
  final String query;

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

  bool _matchesQuery(WarehouseNotification n) {
    final q = widget.query.trim().toLowerCase();
    if (q.isEmpty) return true;
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
        // البحث صار عبر شريط الـ topbar الموحّد (زي المخبر).
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

class _NotificationCard extends StatefulWidget {
  const _NotificationCard({
    required this.isLight,
    required this.notification,
    required this.onMarkRead,
  });

  final bool isLight;
  final WarehouseNotification notification;
  final VoidCallback onMarkRead;

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
  bool _hover = false;

  bool get isLight => widget.isLight;
  WarehouseNotification get notification => widget.notification;
  VoidCallback get onMarkRead => widget.onMarkRead;

  bool get _isUrgent => _isUrgentN(notification);

  // الباليتة الدلالية الموحّدة (نفس إشعارات المخبر).
  Color get _accentColor {
    if (_isUrgent) return AppColors.statusUrgent;
    switch (notification.category) {
      case NotificationCategory.low:
      case NotificationCategory.expiry:
        return AppColors.statusWarn;
      case NotificationCategory.order:
        return AppColors.statusInfo;
      case NotificationCategory.general:
        return AppColors.statusSuccess;
    }
  }

  Color get _accentBg {
    if (_isUrgent) {
      return isLight ? AppColors.statusUrgentBg : AppColors.darkChipRedBg;
    }
    switch (notification.category) {
      case NotificationCategory.low:
      case NotificationCategory.expiry:
        return isLight ? AppColors.statusWarnBg : AppColors.darkChipOrangeBg;
      case NotificationCategory.order:
        return isLight ? AppColors.statusInfoBg : AppColors.darkChipBlueBg;
      case NotificationCategory.general:
        return isLight ? AppColors.statusSuccessBg : AppColors.darkChipGreenBg;
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
    final radius = BorderRadius.circular(AppSizes.radiusLG);

    // التصميم الأبيض الموحّد — مطابق لبطاقة إشعارات المخبر بالحرف:
    // كرت أبيض + شريط جانبي ملوّن (end) + أيقونة دائرية + hover lift.
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: isLight
              ? (notification.isRead ? AppColors.surfaceFaint : Colors.white)
              : (notification.isRead ? AppColors.darkBg2 : AppColors.darkBg1),
          borderRadius: radius,
          border: Border.all(
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hover ? 0.05 : 0.02),
              blurRadius: _hover ? 14 : 8,
              offset: Offset(0, _hover ? 6 : 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            children: [
              // الشريط الجانبي الملوّن — حافة يسرى بصرياً (end في RTL)
              PositionedDirectional(
                end: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 4, color: _accentColor),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 18, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // icon دائري على اليمين (start في RTL)
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _accentBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_icon, size: 20, color: _accentColor),
                    ),
                    const SizedBox(width: 12),
                    // body content (وسط)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  notification.title,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: isLight
                                        ? AppColors.lightText1
                                        : AppColors.darkText1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _CategoryBadge(
                                  text: _badgeText(l10n),
                                  color: _accentColor),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notification.body,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isLight
                                  ? AppColors.lightText2
                                  : AppColors.darkText2,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                _badgeText(l10n),
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isLight
                                      ? AppColors.lightText3
                                      : AppColors.darkText3,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('·',
                                  style: TextStyle(
                                    color: isLight
                                        ? AppColors.lightText4
                                        : AppColors.darkText4,
                                  )),
                              const SizedBox(width: 6),
                              Text(
                                notification.time,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isLight
                                      ? AppColors.lightText3
                                      : AppColors.darkText3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // action button على اليسار (end في RTL)
                    if (notification.actionLabel != null) ...[
                      const SizedBox(width: 16),
                      _ActionBtn(
                        label: notification.actionLabel!,
                        color: _accentColor,
                        onTap: () {
                          if (!notification.isRead) onMarkRead();
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

/// زر الإجراء — نفس ستايل المخبر (أبيض بحدود ملوّنة).
class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : AppColors.darkBg1,
            border: Border.all(color: color.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
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
    final pills = AppSegmentedTabs<_NotifFilter>(
      values: _NotifFilter.values,
      selected: filter,
      labelOf: (f) => f.label(context.l10n),
      countOf: (f) => counts[f] ?? 0,
      onChanged: onChanged,
    );

    final markBtn = showMarkAll
        ? InkWell(
            onTap: onMarkAll,
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isLight ? AppColors.surfaceTintCool2 : AppColors.darkBg2,
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
                      fontSize: 13,
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
