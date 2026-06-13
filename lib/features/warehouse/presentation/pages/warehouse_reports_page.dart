// ════════════════════════════════════════════════════════════════════════════
// warehouse_reports_page.dart
//
// صفحة التقارير لنظام المستودع — Phase 4.6 مكتملة.
//
// 🎯 Phase 4.6 (الحالي):
//   استبدال ComingSoonContent بـ WarehouseReportsContent الفعلي:
//     - 2 tabs: أكثر 10 مواد / المالي
//     - جدول المواد الأكثر طلباً مع Rank badges
//     - Bar chart للطلبات الشهرية
//     - ملخص مالي (3 stat cards)
//
// 🔮 Phases المستقبلية:
//   - Phase 6: ربط بـ ReportsBloc + Repository لـ live data
//
// المرجع: DT_Teeth_Warehouse_v6_Enhanced.html — pg-rep
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../navigation/warehouse_sidebar_sections.dart';
import '../widgets/reports/warehouse_reports_content.dart';

/// صفحة التقارير — نظام المستودع.
class WarehouseReportsPage extends StatelessWidget {
  const WarehouseReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShellLayout(
      system: AppSystemType.warehouse,
      currentRoute: RouteNames.warehouseReports,
      sections: WarehouseSidebarSections.buildWithBadges(
        context,
        lowStockCount: 8,
        pendingOrdersCount: 3,
        unreadNotifsCount: 5,
      ),
      pageTitle: context.l10n.whReportsTitle,
      pageSubtitle: context.l10n.warehouseTopbarSubtitle,
      userRole: context.l10n.roleWarehouseManager,
      notificationCount: 5,
      body: LayoutBuilder(
        builder: (ctx, constraints) {
          final controller = ScrollController();
          return Scrollbar(
            controller: controller,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: controller,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.spaceLG),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  maxWidth: constraints.maxWidth,
                ),
                child: const WarehouseReportsContent(),
              ),
            ),
          );
        },
      ),
    );
  }
}
