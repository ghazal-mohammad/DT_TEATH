// ════════════════════════════════════════════════════════════════════════════
// lab_sidebar_sections.dart
//
// مصنع (factory) ينتج List<SidebarSectionData> لنظام المخبر.
// تصميم موحّد: قسم واحد بدون عنوان فرعي يضم كل التبويبات بالترتيب.
//
// التبويبات بالترتيب:
//   1. الصفحة الرئيسية   (labDashboard)
//   2. الملف الشخصي     (labProfile)
//   3. طلبات الأطباء    (labOrders)
//   4. إدارة المخبريين  (labTechnicians)
//   5. مخزون المخبر      (labInventory)
//   6. طلبات المستودع    (labMaterialRequests) — طلب مواد ناقصة من المستودع
//   7. المنتجات          (labProducts)
//   8. التقارير          (labReports)
//   9. الإشعارات         (labNotifications)
//   10. الإعدادات        (labSettings)
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/widgets.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../shared/widgets/navigation/app_sidebar.dart';

/// مصنع ينتج أقسام السايدبار لنظام المخبر.
class LabSidebarSections {
  LabSidebarSections._();

  /// يبني قائمة الأقسام مع badges ديناميكية.
  ///
  /// [newOrdersCount]: عدد الطلبات الجديدة (يظهر على "طلبات الأطباء").
  /// [unreadNotifsCount]: عدد الإشعارات غير المقروءة.
  static List<SidebarSectionData> buildWithBadges(
    BuildContext context, {
    int? newOrdersCount,
    int? unreadNotifsCount,
  }) {
    return [
      SidebarSectionData(
        title: '',
        items: [
          SidebarItemData(
            icon: AppIcons.dashboard,
            label: context.l10n.dashboard,
            route: RouteNames.labDashboard,
          ),
          SidebarItemData(
            icon: AppIcons.profile,
            label: context.l10n.labProfile,
            route: RouteNames.labProfile,
          ),
          SidebarItemData(
            icon: AppIcons.labOrders,
            label: context.l10n.doctorOrders,
            route: RouteNames.labOrders,
            badge: _badgeOrNull(newOrdersCount),
          ),
          SidebarItemData(
            icon: AppIcons.technicians,
            label: context.l10n.labManageTechnicians,
            route: RouteNames.labTechnicians,
          ),
          SidebarItemData(
            icon: AppIcons.materials,
            label: context.l10n.labInventory,
            route: RouteNames.labInventory,
          ),
          SidebarItemData(
            icon: AppIcons.orders,
            label: context.l10n.materialRequests,
            route: RouteNames.labMaterialRequests,
          ),
          SidebarItemData(
            icon: AppIcons.tooth,
            label: context.l10n.labProducts,
            route: RouteNames.labProducts,
          ),
          SidebarItemData(
            icon: AppIcons.reports,
            label: context.l10n.labReports,
            route: RouteNames.labReports,
          ),
          SidebarItemData(
            icon: AppIcons.notifications,
            label: context.l10n.notifications,
            route: RouteNames.labNotifications,
            badge: _badgeOrNull(unreadNotifsCount),
          ),
          SidebarItemData(
            icon: AppIcons.settings,
            label: context.l10n.settings,
            route: RouteNames.labSettings,
          ),
        ],
      ),
    ];
  }

  /// يبني قائمة الأقسام بدون badges (للصفحات الداخلية).
  static List<SidebarSectionData> build(BuildContext context) {
    return buildWithBadges(context);
  }

  static String? _badgeOrNull(int? count) {
    if (count == null || count <= 0) return null;
    return count.toString();
  }
}
