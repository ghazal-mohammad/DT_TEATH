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
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/employee_role_label.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/layout/app_scroll_view.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../domain/repositories/warehouse_notifications_repository.dart';
import '../bloc/warehouse_notifications_cubit.dart';
import '../bloc/warehouse_notifications_state.dart';
import '../navigation/warehouse_sidebar_sections.dart';
import '../widgets/notifications/warehouse_notifications_content.dart';

/// صفحة الإشعارات — نظام المستودع.
class WarehouseNotificationsPage extends StatefulWidget {
  const WarehouseNotificationsPage({super.key});

  @override
  State<WarehouseNotificationsPage> createState() =>
      _WarehouseNotificationsPageState();
}

class _WarehouseNotificationsPageState
    extends State<WarehouseNotificationsPage> {
  // البحث موحّد عبر شريط الـ topbar (زي المخبر) — لا شريط بحث داخل الصفحة.
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WarehouseNotificationsCubit(
        repository: sl<WarehouseNotificationsRepository>(),
      )..load(),
      child: BlocBuilder<WarehouseNotificationsCubit, WarehouseNotificationsState>(
        builder: (context, state) {
          final unread = state.items.where((n) => !n.isRead).length;
          return AppShellLayout(
            system: AppSystemType.warehouse,
            currentRoute: RouteNames.warehouseNotifications,
            sections: WarehouseSidebarSections.buildWithBadges(
              context,
              // هذه الصفحة لا تحمّل InventoryCubit/WarehouseRequestsCubit — 0 بدل
              // رقم وهمي مضلّل (نفس اتفاقية لوحة التحكم/المواد/الطلبيات).
              lowStockCount: 0,
              pendingOrdersCount: 0,
            ),
            pageTitle: context.l10n.whNotificationsTitle,
            pageSubtitle: context.l10n.warehouseTopbarSubtitle,
            searchPlaceholder: context.l10n.notifSearchHint,
            onSearchChanged: (v) => setState(() => _query = v.trim()),
            userRole: currentUserRoleLabel(context,
                fallback: context.l10n.roleWarehouseManager),
            notificationCount: unread,
            body:
                AppScrollView(child: WarehouseNotificationsContent(query: _query)),
          );
        },
      ),
    );
  }
}
