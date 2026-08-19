// ════════════════════════════════════════════════════════════════════════════
// warehouse_profile_page.dart
//
// صفحة الملف الشخصي لموظف المستودع.
// تجمع: Hero strip (صورة + اسم + زر تعديل) + بطاقتي معلومات + ملاحظات إدارية.
// التعديل inline — الحقول تتحوّل لـ TextField عند الضغط على "تعديل الملف".
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/auth/employee_role_label.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../navigation/warehouse_sidebar_sections.dart';
import '../../../profile/presentation/widgets/employee_profile_content.dart';

/// صفحة الملف الشخصي — نظام المستودع.
class WarehouseProfilePage extends StatelessWidget {
  const WarehouseProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShellLayout(
      system: AppSystemType.warehouse,
      currentRoute: RouteNames.warehouseProfile,
      sections: WarehouseSidebarSections.buildWithBadges(
        context,
        // هذه الصفحة لا تحمّل InventoryCubit/WarehouseRequestsCubit — 0 بدل
        // رقم وهمي مضلّل (نفس اتفاقية لوحة التحكم/المواد/الطلبيات).
        lowStockCount: 0,
        pendingOrdersCount: 0,
      ),
      pageTitle: context.l10n.labProfile,
      pageSubtitle: context.l10n.profilePageSubtitle,
      userRole: currentUserRoleLabel(context, fallback: context.l10n.roleWarehouseManager),
      notificationCount: 0,
      // صفحة الملف الشخصي: بلا حقل بحث وبلا أيقونات جانبية في التوب بار.
      showTopbarActions: false,
      showSearch: false,
      // المحتوى يدير السكرول داخلياً ليتمكّن العمود الجانبي من البقاء ثابتاً (sticky).
      body: const EmployeeProfileContent(),
    );
  }
}
