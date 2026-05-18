// ════════════════════════════════════════════════════════════════════════════
// warehouse_settings_page.dart
//
// صفحة الإعدادات لنظام المستودع — Phase 4.8 مكتملة.
//
// 🎯 Phase 4.8 (الحالي):
//   استبدال ComingSoonContent بـ WarehouseSettingsContent الفعلي:
//     - 4 tabs: الملف الشخصي / الإشعارات / الأمان / عن التطبيق
//     - Tab الملف الشخصي: avatar + بيانات المستخدم
//     - Tab الإشعارات: toggles ديناميكية
//     - Tab الأمان: تغيير كلمة المرور
//     - Tab عن التطبيق: معلومات النظام
//
// 🔮 Phases المستقبلية:
//   - Phase 6: ربط بـ SettingsBloc + API لحفظ التغييرات
//
// المرجع: DT_Teeth_Warehouse_v6_Enhanced.html — pg-set
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/core/mock_user_data.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../navigation/warehouse_sidebar_sections.dart';
import '../widgets/settings/warehouse_settings_content.dart';

/// صفحة الإعدادات — نظام المستودع.
class WarehouseSettingsPage extends StatelessWidget {
  const WarehouseSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShellLayout(
      system: AppSystemType.warehouse,
      currentRoute: RouteNames.warehouseSettings,
      sections: WarehouseSidebarSections.buildWithBadges(
        context,
        lowStockCount: 8,
        pendingOrdersCount: 3,
        unreadNotifsCount: 5,
      ),
      pageTitle: context.l10n.whSettingsTitle,
      pageSubtitle: context.l10n.warehouseTopbarSubtitle,
      userName: MockUserData.defaultUserName,
      userRole: context.l10n.roleWarehouseManager,
      notificationCount: 5,
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: const WarehouseSettingsContent(),
      ),
    );
  }
}
