// ════════════════════════════════════════════════════════════════════════════
// warehouse_sidebar_sections.dart
//
// مصنع (factory) ينتج List<SidebarSectionData> لنظام المستودع.
// تصميم موحّد: قسم واحد بدون عنوان فرعي يضم كل التبويبات بالترتيب.
//
// التبويبات بالترتيب:
//   1. الصفحة الرئيسية   (warehouseDashboard)
//   2. الملف الشخصي      (warehouseProfile)
//   3. المواد            (warehouseMaterials)
//   4. الطلبيات          (warehouseOrders)
//   5. الفواتير          (warehouseInvoices)
//   6. التقارير          (warehouseReports)
//   7. الإشعارات         (warehouseNotifications)
//   8. الإعدادات         (warehouseSettings)
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/widgets.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../shared/widgets/navigation/app_sidebar.dart';

/// مصنع ينتج أقسام السايدبار لنظام المستودع.
class WarehouseSidebarSections {
  WarehouseSidebarSections._();

  static List<SidebarSectionData> build(BuildContext context) {
    return buildWithBadges(context);
  }

  static List<SidebarSectionData> buildWithBadges(
    BuildContext context, {
    int? lowStockCount,
    int? pendingOrdersCount,
    int? unreadNotifsCount,
  }) {
    return [
      SidebarSectionData(
        title: '',
        items: [
          SidebarItemData(
            icon: AppIcons.dashboard,
            label: context.l10n.dashboard,
            route: RouteNames.warehouseDashboard,
          ),
          const SidebarItemData(
            icon: AppIcons.profile,
            label: 'الملف الشخصي',
            route: RouteNames.warehouseProfile,
          ),
          SidebarItemData(
            icon: AppIcons.materials,
            label: context.l10n.materials,
            route: RouteNames.warehouseMaterials,
            badge: _badgeOrNull(lowStockCount),
          ),
          SidebarItemData(
            icon: AppIcons.orders,
            label: context.l10n.orders,
            route: RouteNames.warehouseOrders,
            badge: _badgeOrNull(pendingOrdersCount),
          ),
          SidebarItemData(
            icon: AppIcons.invoices,
            label: context.l10n.invoices,
            route: RouteNames.warehouseInvoices,
          ),
          SidebarItemData(
            icon: AppIcons.reports,
            label: context.l10n.reports,
            route: RouteNames.warehouseReports,
          ),
          SidebarItemData(
            icon: AppIcons.notifications,
            label: context.l10n.notifications,
            route: RouteNames.warehouseNotifications,
            badge: _badgeOrNull(unreadNotifsCount),
          ),
          SidebarItemData(
            icon: AppIcons.settings,
            label: context.l10n.settings,
            route: RouteNames.warehouseSettings,
          ),
        ],
      ),
    ];
  }

  static String? _badgeOrNull(int? count) {
    if (count == null || count <= 0) return null;
    return count.toString();
  }
}
