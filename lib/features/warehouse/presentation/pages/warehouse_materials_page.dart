// ════════════════════════════════════════════════════════════════════════════
// warehouse_materials_page.dart
//
// صفحة إدارة المواد لنظام المستودع (Phase 4.3 — مكتملة).
//
// 🎯 Phase 4.3 (الحالي):
//   استبدال ComingSoonContent بـ WarehouseMaterialsContent الفعلي:
//     - شريط Filter chips + زر إضافة
//     - شبكة Material cards متجاوبة
//     - Modal إضافة/تعديل
//     - تأكيد حذف
//     - Empty/Loading/Error states
//
// 🔮 Phases المستقبلية:
//   - Phase 6: استبدال MockRepository بـ Remote (REST API)
//
// المرجع: DT_Teeth_Warehouse_v6_Enhanced.html — pg-m (السطور 2207–2220)
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/core/mock_user_data.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../data/repositories/mock_warehouse_materials_repository.dart';
import '../bloc/materials_cubit.dart';
import '../navigation/warehouse_sidebar_sections.dart';
import '../widgets/materials/warehouse_materials_content.dart';

/// صفحة إدارة المواد — نظام المستودع.
///
/// تُنشئ [MaterialsCubit] محلياً وتزوّده للـ subtree.
/// عند الانتقال لـ Phase 6، نستبدل الـ MockRepository بـ Remote.
class WarehouseMaterialsPage extends StatelessWidget {
  const WarehouseMaterialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MaterialsCubit(
        repository: MockWarehouseMaterialsRepository(),
      )..load(),
      child: AppShellLayout(
        system: AppSystemType.warehouse,
        currentRoute: RouteNames.warehouseMaterials,
        sections: WarehouseSidebarSections.buildWithBadges(
          context,
          lowStockCount: 8,
          pendingOrdersCount: 3,
          unreadNotifsCount: 5,
        ),
        pageTitle: context.l10n.whMaterialsTitle,
        pageSubtitle: context.l10n.warehouseTopbarSubtitle,
        userName: MockUserData.defaultUserName,
        userRole: context.l10n.roleWarehouseManager,
        notificationCount: 5,
        body: Builder(
          builder: (context) {
            final controller = ScrollController();
            return Scrollbar(
              controller: controller,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: controller,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSizes.spaceLG),
                child: const WarehouseMaterialsContent(),
              ),
            );
          },
        ),
      ),
    );
  }
}
