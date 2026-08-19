// ════════════════════════════════════════════════════════════════════════════
// lab_settings_page.dart  — Phase 6 ✅
//
// شاشة الإعدادات — مطابقة للتصميم الجديد (4 تبويبات):
//   1) 🔒 الأمان: تغيير كلمة المرور + المصادقة الثنائية
//   2) 🔔 الإشعارات: تفضيلات الإشعارات + قنوات الإشعار
//   3) ⚙️ التفضيلات: السمة + اللغة + العرض والأداء
//   4) 👤 الملف الشخصي: نفس محتوى /lab/profile (EmployeeProfileContent)
//
// كل الـ paddings و alignments بتستخدم Directional → آمنة بـ RTL/LTR.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/employee_role_label.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/bloc/compact_view_cubit.dart';
import '../../../../shared/bloc/theme_cubit.dart';
import '../../../../shared/widgets/settings/app_text_size_selector.dart';
import '../../../../shared/widgets/primitives/app_theme_option.dart';
import '../../../../shared/bloc/locale_cubit.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../../profile/presentation/widgets/employee_profile_content.dart';
import '../bloc/lab_settings_prefs_cubit.dart';
import '../navigation/lab_sidebar_sections.dart';
import 'lab_profile_page.dart';

part '../widgets/settings/lab_settings_tab_nav.dart';
part '../widgets/settings/lab_settings_security_tab.dart';
part '../widgets/settings/lab_settings_notifications_tab.dart';
part '../widgets/settings/lab_settings_preferences_tab.dart';
part '../widgets/settings/lab_settings_widgets.dart';

/// يحوّل قيمة `?tab=` من رابط الراوت لفهرس تبويب [LabSettingsPage.initialTab].
/// حالياً القيمة الوحيدة المدعومة "profile" (تبويب الملف الشخصي) — أي قيمة
/// تانية أو null تعطي 0 (تبويب الأمان الافتراضي).
int labSettingsTabFromQuery(String? tab) => tab == 'profile' ? 3 : 0;

// ══════════════════════════════════════════════════════════════════════════
//  PAGE
// ══════════════════════════════════════════════════════════════════════════

class LabSettingsPage extends StatefulWidget {
  const LabSettingsPage({super.key, this.initialTab = 0});

  /// التبويب المبدئي (0=الأمان 1=الإشعارات 2=التفضيلات 3=الملف الشخصي) —
  /// يُمرَّر من الراوتر عبر `?tab=profile` (راجع [labSettingsTabFromQuery])
  /// لما يوصل المستخدم من نتيجة بحث "الملف الشخصي" أو من إعادة توجيه
  /// `/lab/profile` القديم، بدل ما يفتح دايماً على تبويب الأمان الافتراضي.
  final int initialTab;

  @override
  State<LabSettingsPage> createState() => _LabSettingsPageState();
}

class _LabSettingsPageState extends State<LabSettingsPage> {
  // 0=الأمان 1=الإشعارات 2=التفضيلات 3=الملف الشخصي
  late int _selectedTab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LabSettingsPrefsCubit()..loadSaved(),
      child: AppShellLayout(
        system: AppSystemType.lab,
        currentRoute: RouteNames.labSettings,
        sections: LabSidebarSections.build(context),
        pageTitle: context.l10n.settings,
        pageSubtitle: null,
        // صفحة الإعدادات لا تحتاج حقل بحث في التوب بار.
        showSearch: false,
        userRole: currentUserRoleLabel(context, fallback: context.l10n.roleLabManager),
        // بلا مصدر حقيقي رخيص لهالشاشة (نفس ملاحظة صفحة الفريق) — 0 بدل رقم وهمي.
        notificationCount: 0,
        body: _LabSettingsBody(
          selectedTab: _selectedTab,
          onTabChanged: (i) => setState(() => _selectedTab = i),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  BODY
// ══════════════════════════════════════════════════════════════════════════

class _LabSettingsBody extends StatelessWidget {
  const _LabSettingsBody({
    required this.selectedTab,
    required this.onTabChanged,
  });

  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    // شريط تبويب أفقي فوق المحتوى دائماً (بكل الأحجام) — الأربع تبويبات
    // بسطر واحد جنب بعض، بدل عمود جانبي عمودي بعرض سطح المكتب.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TabNav(
            selectedIndex: selectedTab,
            onTap: onTabChanged,
            isLight: isLight,
          ),
          const SizedBox(height: AppSizes.spaceLG),
          _buildContent(context, isLight),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isLight) {
    switch (selectedTab) {
      case 1:
        return _NotificationsTab(isLight: isLight);
      case 2:
        return _PreferencesTab(isLight: isLight);
      case 3:
        return const EmployeeProfileContent(statsLoader: LabProfilePage.loadStats);
      default:
        return _SecurityTab(isLight: isLight);
    }
  }
}

