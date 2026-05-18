// ════════════════════════════════════════════════════════════════════════════
// warehouse_notifications_page.dart
//
// صفحة الإشعارات لنظام المستودع — Phase 4.7 مكتملة.
//
// 🎯 Phase 4.7 (الحالي):
//   استبدال ComingSoonContent بـ WarehouseNotificationsContent الفعلي:
//     - 5 filter chips (الكل / غير مقروء / نفاد / صلاحية / طلبيات)
//     - قائمة إشعارات: أيقونة + عنوان + نص + وقت + إجراء
//     - "تحديد الكل كمقروء" CTA
//
// 🔮 Phases المستقبلية:
//   - Phase 6: ربط بـ NotificationsBloc + Firebase FCM
//
// المرجع: DT_Teeth_Warehouse_v6_Enhanced.html — pg-not
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/core/mock_user_data.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../navigation/warehouse_sidebar_sections.dart';
import '../widgets/notifications/warehouse_notifications_content.dart';

/// صفحة الإشعارات — نظام المستودع.
class WarehouseNotificationsPage extends StatelessWidget {
  const WarehouseNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShellLayout(
      system: AppSystemType.warehouse,
      currentRoute: RouteNames.warehouseNotifications,
      sections: WarehouseSidebarSections.buildWithBadges(
        context,
        lowStockCount: 8,
        pendingOrdersCount: 3,
        unreadNotifsCount: 5,
      ),
      pageTitle: context.l10n.whNotificationsTitle,
      pageSubtitle: context.l10n.warehouseTopbarSubtitle,
      userName: MockUserData.defaultUserName,
      userRole: context.l10n.roleWarehouseManager,
      notificationCount: 5,
      body: const SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.all(22.0),
        child: WarehouseNotificationsContent(),
      ),
    );
  }
}
