// ════════════════════════════════════════════════════════════════════════════
// lab_profile_page.dart
//
// صفحة الملف الشخصي لمدير/مخبري المخبر.
// تستخدم EmployeeProfileContent الموحّد (مشترك مع المستودع).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/auth/employee_role_label.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../domain/entities/lab_order.dart';
import '../../domain/repositories/lab_orders_repository.dart';
import '../navigation/lab_sidebar_sections.dart';
import '../../../profile/presentation/widgets/employee_profile_content.dart';

/// صفحة الملف الشخصي — نظام المخبر.
class LabProfilePage extends StatelessWidget {
  const LabProfilePage({super.key});

  /// عدّادات حقيقية من الطلبات الفعلية (نفس منطق LabDashboardState) — تُبنى
  /// هنا بدل تمرير أرقام ثابتة.
  static Future<ProfileOrderStats> loadStats() async {
    final orders = await sl<LabOrdersRepository>().getAll();
    final now = DateTime.now();
    final monthPrefix = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}';
    final completedThisMonth = orders
        .where((o) =>
            o.statusVariant == LabOrderBadgeVariant.ready &&
            o.date.startsWith(monthPrefix))
        .length;
    final inProgress = orders
        .where((o) => o.statusVariant == LabOrderBadgeVariant.manufacturing)
        .length;
    final readyTotal =
        orders.where((o) => o.statusVariant == LabOrderBadgeVariant.ready).length;
    return ProfileOrderStats(
      completedThisMonth: completedThisMonth,
      inProgress: inProgress,
      readyTotal: readyTotal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShellLayout(
      system: AppSystemType.lab,
      currentRoute: RouteNames.labProfile,
      sections: LabSidebarSections.build(context),
      pageTitle: context.l10n.labProfile,
      pageSubtitle: context.l10n.profilePageSubtitle,
      userRole: currentUserRoleLabel(context, fallback: context.l10n.roleLabManager),
      // لا مصدر إشعارات حقيقي متاح لهذه الصفحة بعد (نفس وضع باقي شاشات
      // المخبر) — 0 بدل رقم ثابت مضلِّل.
      notificationCount: 0,
      // صفحة الملف الشخصي: بلا بحث وبلا أيقونات جانبية.
      showTopbarActions: false,
      showSearch: false,
      // المحتوى يدير السكرول داخلياً ليتمكّن العمود الجانبي من البقاء ثابتاً (sticky).
      body: const EmployeeProfileContent(statsLoader: loadStats),
    );
  }
}
