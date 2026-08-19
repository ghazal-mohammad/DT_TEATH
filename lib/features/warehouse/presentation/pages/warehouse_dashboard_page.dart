// ════════════════════════════════════════════════════════════════════════════
// warehouse_dashboard_page.dart
//
// صفحة لوحة التحكم لنظام المستودع — مربوطة بـ InventoryCubit (مؤشّرات حقيقية:
// المواد الأكثر طلباً، قريبة الصلاحية، منخفضة المخزون) و WarehouseRequestsCubit
// (طلبات المواد الواردة — لهيرو "طلبات اليوم" وجدول "طلبات اليوم" الحقيقيين
// بدل البيانات المزيّفة). شارتا السايدبار "مواد منخفضة"/"طلبيات" تُقرآن من
// نفس الملخّصين reactive عبر BlocBuilder.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/employee_role_label.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/layout/app_scroll_view.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../domain/repositories/warehouse_inventory_repository.dart';
import '../../domain/repositories/warehouse_requests_repository.dart';
import '../bloc/inventory_cubit.dart';
import '../bloc/warehouse_requests_cubit.dart';
import '../navigation/warehouse_sidebar_sections.dart';
import '../widgets/dashboard/warehouse_dashboard_content.dart';

/// صفحة لوحة التحكم — نظام المستودع (المؤشّرات مربوطة بالباك).
class WarehouseDashboardPage extends StatelessWidget {
  const WarehouseDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              InventoryCubit(sl<WarehouseInventoryRepository>())..load(),
        ),
        BlocProvider(
          create: (_) =>
              WarehouseRequestsCubit(sl<WarehouseRequestsRepository>())
                ..load(),
        ),
      ],
      child: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, inventoryState) =>
            BlocBuilder<WarehouseRequestsCubit, WarehouseRequestsState>(
          builder: (context, requestsState) => AppShellLayout(
            system: AppSystemType.warehouse,
            currentRoute: RouteNames.warehouseDashboard,
            sections: WarehouseSidebarSections.buildWithBadges(
              context,
              lowStockCount: inventoryState.summary?.lowStockCount,
              pendingOrdersCount:
                  requestsState.countOf(RequestsFilter.newReq),
            ),
            pageTitle: context.l10n.whDashboardTitle,
            pageSubtitle: context.l10n.warehouseTopbarSubtitle,
            userRole: currentUserRoleLabel(context, fallback: context.l10n.roleWarehouseManager),
            notificationCount: 0,
            body: const AppScrollView(child: WarehouseDashboardContent()),
          ),
        ),
      ),
    );
  }
}
