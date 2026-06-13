// ════════════════════════════════════════════════════════════════════════════
// warehouse_profile_page.dart
//
// صفحة الملف الشخصي لموظف المستودع.
// تجمع: Hero strip (صورة + اسم + زر تعديل) + بطاقتي معلومات + ملاحظات إدارية.
// التعديل inline — الحقول تتحوّل لـ TextField عند الضغط على "تعديل الملف".
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

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
        lowStockCount: 8,
        pendingOrdersCount: 3,
        unreadNotifsCount: 5,
      ),
      pageTitle: context.l10n.labProfile,
      pageSubtitle: context.l10n.profilePageSubtitle,
      userRole: context.l10n.roleWarehouseManager,
      notificationCount: 5,
      // صفحة الملف الشخصي: حقل البحث وحده في التوب بار بلا أيقونات جانبية.
      showTopbarActions: false,
      searchPlaceholder: context.l10n.settingsSearchHint,
      // المحتوى يدير السكرول داخلياً ليتمكّن العمود الجانبي من البقاء ثابتاً (sticky).
      body: const EmployeeProfileContent(),
    );
  }
}
