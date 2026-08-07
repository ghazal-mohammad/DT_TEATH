// ════════════════════════════════════════════════════════════════════════════
// warehouse_dashboard_page.dart
//
// صفحة لوحة التحكم لنظام المستودع (Phase 4.2 — مكتملة).
//
// 🎯 Phase 4.2 (الحالي):
//   استبدال ComingSoonContent بـ WarehouseDashboardContent الفعلي:
//     - Hero section (مرحباً بك + 3 إحصائيات)
//     - 4 stat cards ملوّنة
//     - 2 جداول (مواد أكثر طلباً + صلاحيات)
//     - 2 alert boxes (نفاد + طلبيات جديدة)
//     - Quick Actions (4 أزرار)
//     - Donut chart (توزيع المخزون)
//
// 🔮 Phases المستقبلية:
//   - Phase 6: ربط بـ WarehouseRepository + WarehouseBloc لـ live data
//
// المرجع: DT_Teeth_Warehouse_v6_Enhanced.html — pg-d (السطور 2127–2204)
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/layout/app_scroll_view.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../domain/repositories/warehouse_inventory_repository.dart';
import '../bloc/inventory_cubit.dart';
import '../navigation/warehouse_sidebar_sections.dart';
import '../widgets/dashboard/warehouse_dashboard_content.dart';

/// صفحة لوحة التحكم — نظام المستودع (المؤشّرات مربوطة بالباك).
class WarehouseDashboardPage extends StatelessWidget {
  const WarehouseDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          InventoryCubit(sl<WarehouseInventoryRepository>())..load(),
      child: AppShellLayout(
        system: AppSystemType.warehouse,
        currentRoute: RouteNames.warehouseDashboard,
        sections: WarehouseSidebarSections.buildWithBadges(
          context,
          lowStockCount: 8,
          pendingOrdersCount: 3,
          unreadNotifsCount: 5,
        ),
        pageTitle: context.l10n.whDashboardTitle,
        pageSubtitle: context.l10n.warehouseTopbarSubtitle,
        userRole: context.l10n.roleWarehouseManager,
        notificationCount: 5,
        body: const AppScrollView(child: WarehouseDashboardContent()),
      ),
    );
  }
}
