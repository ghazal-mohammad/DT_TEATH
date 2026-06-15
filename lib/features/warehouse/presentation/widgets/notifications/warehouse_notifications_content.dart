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

part 'warehouse_notifications_parts.dart';

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
