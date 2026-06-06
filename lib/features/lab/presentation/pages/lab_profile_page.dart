// ════════════════════════════════════════════════════════════════════════════
// lab_profile_page.dart
//
// صفحة الملف الشخصي لمدير/مخبري المخبر.
// تستخدم LabProfileContent المطابق هيكلياً لـ WarehouseProfileContent.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/core/mock_user_data.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../navigation/lab_sidebar_sections.dart';
import '../widgets/profile/lab_profile_content.dart';

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
      // صفحة الملف الشخصي: حقل البحث وحده في التوب بار بلا أيقونات جانبية.
      showTopbarActions: false,
      searchPlaceholder: context.l10n.settingsSearchHint,
      // المحتوى يدير السكرول داخلياً ليتمكّن العمود الجانبي من البقاء ثابتاً (sticky).
      body: const LabProfileContent(),
    );
  }
}
