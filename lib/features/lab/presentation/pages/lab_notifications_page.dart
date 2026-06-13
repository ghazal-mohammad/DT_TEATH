// ════════════════════════════════════════════════════════════════════════════
// lab_notifications_page.dart  — الإشعارات
//
// مطابق للصورة المرجعية:
//   - شريط فلاتر (الكل / غير مقروءة / عاجل / طلبات / مواد / نظام) + counts
//   - "تحديد الكل كمقروء" link
//   - أقسام زمنية (اليوم / أمس)
//   - بطاقات إشعارات: شريط ملوّن جانبي + أيقونة دائرية + عنوان + pill +
//     وصف + meta + زر إجراء
//
// النموذج والستايل في widgets/notifications/lab_notification_data.dart،
// والبطاقة وشريط الفلاتر في widgets/notifications/ (تقسيم الصفحات).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../navigation/lab_sidebar_sections.dart';
import '../widgets/notifications/lab_notification_card.dart';
import '../widgets/notifications/lab_notification_data.dart';
import '../widgets/notifications/lab_notifications_filter_row.dart';

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
    final bool isLight = Theme.of(context).brightness == Brightness.light;
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
      searchPlaceholder: context.l10n.notifSearchHint,
      showThemeToggle: false,
      userRole: context.l10n.roleLabManager,
      notificationCount: _items.where((n) => !n.isRead).length,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Filter row + mark all read
            LabNotificationsFilterRow(
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
              LabNotificationsSectionHeading(label: context.l10n.sectionToday),
              const SizedBox(height: 10),
              for (final n in today) ...[
                LabNotificationCard(item: n),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: AppSizes.spaceMD),
            ],
            if (yesterday.isNotEmpty) ...[
              LabNotificationsSectionHeading(
                  label: context.l10n.sectionYesterday),
              const SizedBox(height: 10),
              for (final n in yesterday) ...[
                LabNotificationCard(item: n),
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
                          size: 48, color: AppColors.iconMutedLight),
                      const SizedBox(height: AppSizes.spaceMD),
                      Text(
                        context.l10n.notifEmptyInCategory,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color:
                              isLight ? AppColors.lightText3 : AppColors.darkText3,
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
