// ════════════════════════════════════════════════════════════════════════════
// lab_notifications_page.dart  — الإشعارات
//
// مطابق للصورة المرجعية:
//   - شريط فلاتر (الكل / غير مقروءة / عاجل / طلبات / مواد / نظام) + counts
//   - "تحديد الكل كمقروء" link
//   - أقسام زمنية (اليوم / أمس)
//   - بطاقات إشعارات: شريط ملوّن جانبي + أيقونة دائرية + عنوان + pill +
//     وصف + meta + زر إجراء
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
//  MODEL
// ══════════════════════════════════════════════════════════════════════════

enum NotificationKind { urgent, order, material, system }

enum NotificationDay { today, yesterday }

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
  });

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

class _Style {
  const _Style(this.bg, this.fg, this.label);
  final Color bg;
  final Color fg;
  final String label;
}

_Style _styleOf(NotificationKind k) {
  switch (k) {
    case NotificationKind.urgent:
      return const _Style(Color(0xFFFFEDD5), Color(0xFFEA580C), 'عاجل');
    case NotificationKind.order:
      return const _Style(Color(0xFFE2EDFF), Color(0xFF3B82F6), 'طلبية');
    case NotificationKind.material:
      return const _Style(Color(0xFFF1DAFE), Color(0xFF8B5CF6), 'مواد');
    case NotificationKind.system:
      return const _Style(Color(0xFFD0FBD7), Color(0xFF10B981), 'نظام');
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  PAGE
// ══════════════════════════════════════════════════════════════════════════

class LabNotificationsPage extends StatefulWidget {
  const LabNotificationsPage({super.key});

  @override
  State<LabNotificationsPage> createState() => _LabNotificationsPageState();
}

class _LabNotificationsPageState extends State<LabNotificationsPage> {
  String _filter = 'all'; // all | unread | urgent | order | material | system
  late List<NotificationItem> _items;

  @override
  void initState() {
    super.initState();
    _items = [
      NotificationItem(
        kind: NotificationKind.urgent,
        title: 'طلبية تنتهي اليوم',
        description:
            'الطلبية LAB-045 (تلبيسة PFM) للطبيبة د. سارة يجب تسليمها قبل الساعة 14:00.',
        category: 'الطلبات',
        timeLabel: 'الآن',
        day: NotificationDay.today,
        icon: Icons.local_fire_department_rounded,
        action: 'فتح الطلب',
      ),
      NotificationItem(
        kind: NotificationKind.urgent,
        title: 'طلبية تنتهي اليوم',
        description:
            'جسر 3 وحدات (LAB-042) للطبيب د. خالد يجب إنهاؤه قبل الساعة 16:00.',
        category: 'الطلبات',
        timeLabel: 'منذ 12 دقيقة',
        day: NotificationDay.today,
        icon: Icons.local_fire_department_rounded,
        action: 'فتح الطلب',
      ),
      NotificationItem(
        kind: NotificationKind.material,
        title: 'مادة وصلت للحد الأدنى',
        description:
            'كمية سيراميك زيركون انخفضت إلى 8 قطع — أقل من الحد الأدنى المسموح (10 قطع).',
        category: 'المواد',
        timeLabel: 'منذ ساعة',
        day: NotificationDay.today,
        icon: Icons.inventory_2_outlined,
        action: 'طلب من المستودع',
      ),
      NotificationItem(
        kind: NotificationKind.order,
        title: 'طلبية جديدة وصلت',
        description:
            'الطبيبة د. ليلى أرسلت طلبية جديدة — طقم Acrylic كامل (LAB-041).',
        category: 'الطلبات',
        timeLabel: 'منذ ساعتين',
        day: NotificationDay.today,
        icon: Icons.add_circle_outline_rounded,
        action: 'مراجعة',
      ),
      NotificationItem(
        kind: NotificationKind.system,
        title: 'تم توريد المواد',
        description:
            'وصلت 30 قطعة من PFM Alloy من المستودع — طلبية رقم MAT-104.',
        category: 'المستودع',
        timeLabel: 'أمس 16:42',
        day: NotificationDay.yesterday,
        icon: Icons.check_circle_outline_rounded,
        isRead: true,
      ),
      NotificationItem(
        kind: NotificationKind.order,
        title: 'تم تسليم الطلبية',
        description:
            'تم تسليم الطلبية LAB-039 (جسر PFM) للطبيب د. أحمد بنجاح.',
        category: 'الطلبات',
        timeLabel: 'أمس 14:15',
        day: NotificationDay.yesterday,
        icon: Icons.task_alt_rounded,
        isRead: true,
      ),
      NotificationItem(
        kind: NotificationKind.system,
        title: 'تم إضافة مخبري جديد',
        description: 'انضم يوسف ناصر (فني زيركون) إلى فريق المخبر.',
        category: 'الفريق',
        timeLabel: 'أمس 09:30',
        day: NotificationDay.yesterday,
        icon: Icons.person_add_alt_1_rounded,
        isRead: true,
      ),
      NotificationItem(
        kind: NotificationKind.material,
        title: 'تحديث مخزون',
        description: 'تم تحديث مستويات مخزون 12 مادة في النظام.',
        category: 'المواد',
        timeLabel: 'أمس 08:00',
        day: NotificationDay.yesterday,
        icon: Icons.refresh_rounded,
        isRead: true,
      ),
      NotificationItem(
        kind: NotificationKind.system,
        title: 'صيانة النظام',
        description: 'صيانة دورية ستجري الليلة بين الساعة 02:00 و 03:00 ص.',
        category: 'النظام',
        timeLabel: 'أمس 12:00',
        day: NotificationDay.yesterday,
        icon: Icons.build_outlined,
        isRead: true,
      ),
    ];
  }

  int _count(bool Function(NotificationItem) test) =>
      _items.where(test).length;

  List<NotificationItem> get _filtered {
    switch (_filter) {
      case 'unread':
        return _items.where((i) => !i.isRead).toList();
      case 'urgent':
        return _items.where((i) => i.kind == NotificationKind.urgent).toList();
      case 'order':
        return _items.where((i) => i.kind == NotificationKind.order).toList();
      case 'material':
        return _items
            .where((i) => i.kind == NotificationKind.material)
            .toList();
      case 'system':
        return _items.where((i) => i.kind == NotificationKind.system).toList();
      default:
        return _items;
    }
  }

  void _markAllRead() => setState(() {
        for (final n in _items) {
          n.isRead = true;
        }
      });

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final today = filtered.where((n) => n.day == NotificationDay.today).toList();
    final yesterday =
        filtered.where((n) => n.day == NotificationDay.yesterday).toList();

    return AppShellLayout(
      system: AppSystemType.lab,
      currentRoute: RouteNames.labNotifications,
      sections: LabSidebarSections.buildWithBadges(
        context,
        newOrdersCount: 4,
        unreadNotifsCount: _items.where((n) => !n.isRead).length,
      ),
      pageTitle: context.l10n.notifications,
      pageSubtitle: null,
      searchPlaceholder: 'بحث في الإشعارات...',
      showThemeToggle: false,
      userName: MockUserData.labUserName,
      userRole: context.l10n.roleLabManager,
      notificationCount: _items.where((n) => !n.isRead).length,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Filter row + mark all read
            _FilterRow(
              current: _filter,
              total: _items.length,
              unread: _count((i) => !i.isRead),
              urgent: _count((i) => i.kind == NotificationKind.urgent),
              orders: _count((i) => i.kind == NotificationKind.order),
              materials: _count((i) => i.kind == NotificationKind.material),
              systemCount: _count((i) => i.kind == NotificationKind.system),
              onChange: (v) => setState(() => _filter = v),
              onMarkAllRead: _markAllRead,
            ),
            const SizedBox(height: AppSizes.spaceLG),
            if (today.isNotEmpty) ...[
              _SectionHeading(label: 'اليوم'),
              const SizedBox(height: 10),
              for (final n in today) ...[
                _NotificationCard(item: n),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: AppSizes.spaceMD),
            ],
            if (yesterday.isNotEmpty) ...[
              _SectionHeading(label: 'أمس'),
              const SizedBox(height: 10),
              for (final n in yesterday) ...[
                _NotificationCard(item: n),
                const SizedBox(height: 10),
              ],
            ],
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.notifications_none_rounded,
                          size: 48, color: Color(0xFFB0B6C3)),
                      const SizedBox(height: AppSizes.spaceMD),
                      Text(
                        'لا توجد إشعارات في هذه الفئة',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.lightText3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  FILTER ROW
// ══════════════════════════════════════════════════════════════════════════

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.current,
    required this.total,
    required this.unread,
    required this.urgent,
    required this.orders,
    required this.materials,
    required this.systemCount,
    required this.onChange,
    required this.onMarkAllRead,
  });

  final String current;
  final int total;
  final int unread;
  final int urgent;
  final int orders;
  final int materials;
  final int systemCount;
  final ValueChanged<String> onChange;
  final VoidCallback onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // tabs (RTL start = right visual)
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _Tab(
                label: 'الكل',
                count: total,
                active: current == 'all',
                onTap: () => onChange('all'),
              ),
              _Tab(
                label: 'غير مقروءة',
                count: unread,
                active: current == 'unread',
                onTap: () => onChange('unread'),
              ),
              _Tab(
                label: 'عاجل',
                count: urgent,
                active: current == 'urgent',
                accent: const Color(0xFFEA580C),
                onTap: () => onChange('urgent'),
              ),
              _Tab(
                label: 'طلبات',
                count: orders,
                active: current == 'order',
                onTap: () => onChange('order'),
              ),
              _Tab(
                label: 'مواد',
                count: materials,
                active: current == 'material',
                onTap: () => onChange('material'),
              ),
              _Tab(
                label: 'نظام',
                count: systemCount,
                active: current == 'system',
                onTap: () => onChange('system'),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // mark all read (left visual)
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onMarkAllRead,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.lightBorder),
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.done_all_rounded,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 5),
                  Text(
                    'تحديد الكل كمقروء',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightText1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
    this.accent,
  });

  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final Color activeBg = accent ?? AppColors.primary;
    final Color idleText = accent ?? AppColors.lightText2;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : idleText,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$count',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: active ? Colors.white : AppColors.lightText3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  SECTION HEADING
// ══════════════════════════════════════════════════════════════════════════

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.lightBorder,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.lightText3,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  NOTIFICATION CARD
// ══════════════════════════════════════════════════════════════════════════

class _NotificationCard extends StatefulWidget {
  const _NotificationCard({required this.item});
  final NotificationItem item;

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final n = widget.item;
    final s = _styleOf(n.kind);
    final radius = BorderRadius.circular(14);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: n.isRead ? const Color(0xFFFCFCFD) : Colors.white,
          borderRadius: radius,
          border: Border.all(color: AppColors.lightBorder),
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
                child: Container(width: 4, color: s.fg),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 18, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // icon round على اليمين (start في RTL) — يطابق المحاكاة
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: s.bg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(n.icon, size: 20, color: s.fg),
                    ),
                    const SizedBox(width: 12),
                    // body content (وسط)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _Pill(label: s.label, color: s.fg, bg: s.bg),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  n.title,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.lightText1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            n.description,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.lightText2,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                n.timeLabel,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.lightText3,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('·',
                                  style: TextStyle(
                                    color: AppColors.lightText4,
                                  )),
                              const SizedBox(width: 6),
                              Text(
                                n.category,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.lightText3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // action button على اليسار (end في RTL) — يطابق المحاكاة
                    if (n.action != null) ...[
                      const SizedBox(width: 16),
                      _ActionBtn(
                        label: n.action!,
                        color: s.fg,
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

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color, required this.bg});
  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
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

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
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
