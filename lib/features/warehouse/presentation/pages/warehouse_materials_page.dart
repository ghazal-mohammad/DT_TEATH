// ════════════════════════════════════════════════════════════════════════════
// warehouse_materials_page.dart
//
// صفحة إدارة المواد لنظام المستودع — مربوطة بـ MaterialsCubit. شارة السايدبار
// "مواد منخفضة" تُقرأ من InventoryCubit (نفس مصدر لوحة التحكم) لتبقى الأرقام
// متّسقة بين الصفحتين، لا محسوبة محلّياً بمنطق مختلف.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/layout/app_scroll_view.dart';
import '../../../../core/auth/employee_role_label.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../domain/repositories/warehouse_inventory_repository.dart';
import '../../domain/repositories/warehouse_materials_repository.dart';
import '../bloc/inventory_cubit.dart';
import '../bloc/materials_cubit.dart';
import '../navigation/warehouse_sidebar_sections.dart';
import '../widgets/materials/warehouse_materials_content.dart';

/// صفحة إدارة المواد — نظام المستودع.
///
/// تُنشئ [MaterialsCubit] محلياً وتزوّده للـ subtree، بالإضافة إلى
/// [InventoryCubit] لشارة "مواد منخفضة" بالسايدبار.
class WarehouseMaterialsPage extends StatelessWidget {
  const WarehouseMaterialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => MaterialsCubit(
            repository: sl<WarehouseMaterialsRepository>(),
          )..load(),
        ),
        BlocProvider(
          create: (_) =>
              InventoryCubit(sl<WarehouseInventoryRepository>())..load(),
        ),
      ],
      // Builder ليصبح للسياق وصولٌ لـ MaterialsCubit عند ربط البحث المُوجَّه.
      child: Builder(
        builder: (context) => BlocBuilder<InventoryCubit, InventoryState>(
          builder: (context, inventoryState) => AppShellLayout(
            system: AppSystemType.warehouse,
            currentRoute: RouteNames.warehouseMaterials,
            sections: WarehouseSidebarSections.buildWithBadges(
              context,
              lowStockCount: inventoryState.summary?.lowStockCount,
              // هذه الصفحة لا تحمّل WarehouseRequestsCubit ولا مصدر إشعارات —
              // 0 بدل رقم وهمي مضلّل (نفس اتفاقية لوحة المخبر).
              pendingOrdersCount: 0,
            ),
            pageTitle: context.l10n.whMaterialsTitle,
            pageSubtitle: context.l10n.warehouseTopbarSubtitle,
            userRole: currentUserRoleLabel(context, fallback: context.l10n.roleWarehouseManager),
            notificationCount: 0,
            // بحث مُوجَّه: يفلتر مواد هذه الصفحة فقط عبر كيوبتها.
            searchPlaceholder: context.l10n.whMaterialsSearchHint,
            onSearchChanged: (q) =>
                context.read<MaterialsCubit>().setSearchQuery(q),
            body: const AppScrollView(child: WarehouseMaterialsContent()),
          ),
        ),
      ),
    );
  }
}
