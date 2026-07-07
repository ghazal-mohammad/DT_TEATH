// ════════════════════════════════════════════════════════════════════════════
// lab_settings_page.dart  — Phase 6 ✅
//
// شاشة الإعدادات — مطابقة للتصميم الجديد (3 تبويبات):
//   1) 🔒 الأمان: تغيير كلمة المرور + المصادقة الثنائية + تسجيل خروج
//   2) 🔔 الإشعارات: تفضيلات الإشعارات + قنوات الإشعار
//   3) ⚙️ التفضيلات: السمة + اللغة + العرض والأداء
//
// كل الـ paddings و alignments بتستخدم Directional → آمنة بـ RTL/LTR.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/logout_action.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/bloc/theme_cubit.dart';
import '../../../../shared/widgets/settings/app_text_size_selector.dart';
import '../../../../shared/widgets/primitives/app_theme_option.dart';
import '../../../../shared/bloc/locale_cubit.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../navigation/lab_sidebar_sections.dart';

part '../widgets/settings/lab_settings_tab_nav.dart';
part '../widgets/settings/lab_settings_security_tab.dart';
part '../widgets/settings/lab_settings_notifications_tab.dart';
part '../widgets/settings/lab_settings_preferences_tab.dart';
part '../widgets/settings/lab_settings_widgets.dart';

// ══════════════════════════════════════════════════════════════════════════
//  PAGE
// ══════════════════════════════════════════════════════════════════════════

class LabSettingsPage extends StatefulWidget {
  const LabSettingsPage({super.key});

  @override
  State<LabSettingsPage> createState() => _LabSettingsPageState();
}

class _LabSettingsPageState extends State<LabSettingsPage> {
  int _selectedTab = 0; // 0=الأمان 1=الإشعارات 2=التفضيلات

  @override
  Widget build(BuildContext context) {
    return AppShellLayout(
      system: AppSystemType.lab,
      currentRoute: RouteNames.labSettings,
      sections: LabSidebarSections.build(context),
      pageTitle: context.l10n.settings,
      pageSubtitle: null,
      // صفحة الإعدادات لا تحتاج حقل بحث في التوب بار.
      showSearch: false,
      userRole: context.l10n.roleLabManager,
      notificationCount: 2,
      body: _LabSettingsBody(
        selectedTab: _selectedTab,
        onTabChanged: (i) => setState(() => _selectedTab = i),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 720;

          if (isWide) {
            // التصميم: TabNav على اليمين (بين السايدبار الرئيسي والفورم)،
            // الفورم على اليسار. في RTL: أوّل child = يمين، فالـ TabNav أوّلاً.
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 220,
                  child: _TabNav(
                    selectedIndex: selectedTab,
                    onTap: onTabChanged,
                    isLight: isLight,
                  ),
                ),
                const SizedBox(width: AppSizes.spaceLG),
                Expanded(
                  child: _buildContent(context, isLight),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TabNav(
                selectedIndex: selectedTab,
                onTap: onTabChanged,
                isLight: isLight,
                horizontal: true,
              ),
              const SizedBox(height: AppSizes.spaceLG),
              _buildContent(context, isLight),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isLight) {
    switch (selectedTab) {
      case 1:
        return _NotificationsTab(isLight: isLight);
      case 2:
        return _PreferencesTab(isLight: isLight);
      default:
        return _SecurityTab(isLight: isLight);
    }
  }
}

