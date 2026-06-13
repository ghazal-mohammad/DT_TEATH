// ════════════════════════════════════════════════════════════════════════════
// warehouse_invoices_page.dart
//
// صفحة إدارة الفواتير لنظام المستودع — Phase 4.5 مكتملة.
//
// 🎯 Phase 4.5 (الحالي):
//   استبدال ComingSoonContent بـ WarehouseInvoicesContent الفعلي:
//     - 3 filter chips (الكل / شراء / استخدام)
//     - قائمة الفواتير مع ملخص الأسبوع
//     - Modal إضافة فاتورة جديدة
//
// 🔮 Phases المستقبلية:
//   - Phase 6: ربط بـ InvoicesBloc + Repository لـ live data
//
// المرجع: DT_Teeth_Warehouse_v6_Enhanced.html — pg-inv
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../navigation/warehouse_sidebar_sections.dart';
import '../widgets/invoices/warehouse_invoices_content.dart';

/// صفحة إدارة الفواتير — نظام المستودع.
class WarehouseInvoicesPage extends StatelessWidget {
  const WarehouseInvoicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShellLayout(
      system: AppSystemType.warehouse,
      currentRoute: RouteNames.warehouseInvoices,
      sections: WarehouseSidebarSections.buildWithBadges(
        context,
        lowStockCount: 8,
        pendingOrdersCount: 3,
        unreadNotifsCount: 5,
      ),
      pageTitle: context.l10n.whInvoicesTitle,
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
                child: const WarehouseInvoicesContent(),
              ),
            ),
          );
        },
      ),
    );
  }
}
