// ════════════════════════════════════════════════════════════════════════════
// warehouse_orders_page.dart
//
// صفحة الطلبيات الواردة لنظام المستودع — مربوطة بـ WarehouseRequestsCubit.
// شارة السايدبار "الطلبيات" تُقرأ من عدد الطلبات "الجديدة" الحقيقي عبر
// BlocBuilder.
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
import '../../domain/repositories/warehouse_requests_repository.dart';
import '../bloc/warehouse_requests_cubit.dart';
import '../navigation/warehouse_sidebar_sections.dart';
import '../widgets/orders/warehouse_orders_content.dart';

/// صفحة الطلبيات الواردة — نظام المستودع (مربوطة بالباك).
class WarehouseOrdersPage extends StatelessWidget {
  const WarehouseOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          WarehouseRequestsCubit(sl<WarehouseRequestsRepository>())..load(),
      child: BlocBuilder<WarehouseRequestsCubit, WarehouseRequestsState>(
        builder: (context, state) => AppShellLayout(
          system: AppSystemType.warehouse,
          currentRoute: RouteNames.warehouseOrders,
          sections: WarehouseSidebarSections.buildWithBadges(
            context,
            // هذه الصفحة لا تحمّل InventoryCubit ولا مصدر إشعارات — 0 بدل
            // رقم وهمي مضلّل (نفس اتفاقية لوحة المخبر).
            lowStockCount: 0,
            pendingOrdersCount: state.countOf(RequestsFilter.newReq),
            unreadNotifsCount: 0,
          ),
          pageTitle: context.l10n.whOrdersTitle,
          pageSubtitle: context.l10n.warehouseTopbarSubtitle,
          userRole: currentUserRoleLabel(context, fallback: context.l10n.roleWarehouseManager),
          notificationCount: 0,
          body: const AppScrollView(child: WarehouseOrdersContent()),
        ),
      ),
    );
  }
}
