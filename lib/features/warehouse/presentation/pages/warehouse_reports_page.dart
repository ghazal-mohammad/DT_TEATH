// ════════════════════════════════════════════════════════════════════════════
// warehouse_reports_page.dart
//
// صفحة التقارير لنظام المستودع — 3 تبويبات، كلها مربوطة بالباك فعلاً:
// نظرة عامة (reports/dashboard)، المشتريات، حركة المخزون.
//
// تبويب "طلبات المواد" أُزيل 2026-08-21 — الباك يرمي 500 دائماً (Call to
// undefined relationship [requester] on model [App\Models\MaterialRequest]).
// أعد إضافته بعد ما يُصلَح الباك (راجع warehouse_reports_repository.dart).
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
import '../../domain/repositories/warehouse_reports_repository.dart';
import '../bloc/warehouse_reports_cubit.dart';
import '../navigation/warehouse_sidebar_sections.dart';
import '../widgets/reports/warehouse_reports_content.dart';

/// صفحة التقارير — نظام المستودع (تقرير المشتريات مربوط بالباك).
class WarehouseReportsPage extends StatelessWidget {
  const WarehouseReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WarehouseReportsCubit(sl<WarehouseReportsRepository>())
        ..load()
        ..loadStockMovement()
        ..loadDashboard(),
      child: AppShellLayout(
        system: AppSystemType.warehouse,
        currentRoute: RouteNames.warehouseReports,
        sections: WarehouseSidebarSections.buildWithBadges(
          context,
          // هذه الصفحة لا تحمّل InventoryCubit/WarehouseRequestsCubit — 0 بدل
          // رقم وهمي مضلّل (نفس اتفاقية لوحة التحكم/المواد/الطلبيات).
          lowStockCount: 0,
          pendingOrdersCount: 0,
        ),
        pageTitle: context.l10n.whReportsTitle,
        pageSubtitle: context.l10n.warehouseTopbarSubtitle,
        userRole: currentUserRoleLabel(context, fallback: context.l10n.roleWarehouseManager),
        notificationCount: 0,
        body: const AppScrollView(child: WarehouseReportsContent()),
      ),
    );
  }
}
