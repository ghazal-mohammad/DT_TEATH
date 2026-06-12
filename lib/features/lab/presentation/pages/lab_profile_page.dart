// ════════════════════════════════════════════════════════════════════════════
// lab_profile_page.dart
//
// صفحة الملف الشخصي لمدير/مخبري المخبر.
// تستخدم EmployeeProfileContent الموحّد (مشترك مع المستودع).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/core/mock_user_data.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../navigation/lab_sidebar_sections.dart';
import '../../../profile/presentation/widgets/employee_profile_content.dart';

/// صفحة الملف الشخصي — نظام المخبر.
class LabProfilePage extends StatelessWidget {
  const LabProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShellLayout(
      system: AppSystemType.lab,
      currentRoute: RouteNames.labProfile,
      sections: LabSidebarSections.build(context),
      pageTitle: context.l10n.labProfile,
      pageSubtitle: context.l10n.profilePageSubtitle,
      userName: MockUserData.labUserName,
      userRole: context.l10n.roleLabManager,
      notificationCount: 2,
      // صفحة الملف الشخصي: بلا بحث وبلا أيقونات جانبية.
      showTopbarActions: false,
      showSearch: false,
      // المحتوى يدير السكرول داخلياً ليتمكّن العمود الجانبي من البقاء ثابتاً (sticky).
      body: const EmployeeProfileContent(),
    );
  }
}
