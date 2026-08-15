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
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/employee_role_label.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/layout/app_scroll_view.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../domain/repositories/purchase_invoices_repository.dart';
import '../bloc/purchase_invoices_cubit.dart';
import '../navigation/warehouse_sidebar_sections.dart';
import '../widgets/invoices/warehouse_invoices_content.dart';

/// صفحة إدارة الفواتير — نظام المستودع (مربوطة بالباك).
class WarehouseInvoicesPage extends StatelessWidget {
  const WarehouseInvoicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          PurchaseInvoicesCubit(sl<PurchaseInvoicesRepository>())..load(),
      child: AppShellLayout(
        system: AppSystemType.warehouse,
        currentRoute: RouteNames.warehouseInvoices,
        sections: WarehouseSidebarSections.buildWithBadges(
          context,
          // هذه الصفحة لا تحمّل InventoryCubit/WarehouseRequestsCubit — 0 بدل
          // رقم وهمي مضلّل (نفس اتفاقية لوحة التحكم/المواد/الطلبيات).
          lowStockCount: 0,
          pendingOrdersCount: 0,
          unreadNotifsCount: 0,
        ),
        pageTitle: context.l10n.whInvoicesTitle,
        pageSubtitle: context.l10n.warehouseTopbarSubtitle,
        userRole: currentUserRoleLabel(context, fallback: context.l10n.roleWarehouseManager),
        notificationCount: 0,
        body: const AppScrollView(child: WarehouseInvoicesContent()),
      ),
    );
  }
}
