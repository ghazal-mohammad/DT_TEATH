// ════════════════════════════════════════════════════════════════════════════
// warehouse_orders_page.dart
//
// صفحة الطلبيات الواردة لنظام المستودع — Phase 4.4 مكتملة.
//
// 🎯 Phase 4.4 (الحالي):
//   استبدال ComingSoonContent بـ WarehouseOrdersContent الفعلي:
//     - 4 filter chips (الكل / جديد / تم / غير موجود)
//     - جدول 7 أعمدة: رقم الطلب / المادة / الكمية / الطالب / التاريخ / الحالة / إجراء
//     - Modal: تفاصيل الطلب + إجراءات (تأكيد / رفض / مادة بديلة)
//
// 🔮 Phases المستقبلية:
//   - Phase 6: ربط بـ WarehouseOrdersBloc + Repository لـ live data
//
// المرجع: DT_Teeth_Warehouse_v6_Enhanced.html — pg-o
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/core/mock_user_data.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../navigation/warehouse_sidebar_sections.dart';
import '../widgets/orders/warehouse_orders_content.dart';

/// صفحة الطلبيات الواردة — نظام المستودع.
class WarehouseOrdersPage extends StatelessWidget {
  const WarehouseOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShellLayout(
      system: AppSystemType.warehouse,
      currentRoute: RouteNames.warehouseOrders,
      sections: WarehouseSidebarSections.buildWithBadges(
        context,
        lowStockCount: 8,
        pendingOrdersCount: 3,
        unreadNotifsCount: 5,
      ),
      pageTitle: context.l10n.whOrdersTitle,
      pageSubtitle: context.l10n.warehouseTopbarSubtitle,
      userName: MockUserData.defaultUserName,
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
                child: const WarehouseOrdersContent(),
              ),
            ),
          );
        },
      ),
    );
  }
}
