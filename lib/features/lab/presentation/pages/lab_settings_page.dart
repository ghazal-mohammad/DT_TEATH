// ════════════════════════════════════════════════════════════════════════════
// lab_settings_page.dart  — Phase 5.6 ✅
//
// شاشة الإعدادات — مطابقة 100% لـ HTML المرجعي (pg-ls).
//
// الهيكل:
//   - set-layout: sidebar تبويبات (الملف / الإشعارات / عن التطبيق) + محتوى
//   - lp1 (الملف الشخصي): Avatar دائري بـ gradient + حقلا الاسم والبريد + زر حفظ
//   - lp2 (الإشعارات): 3 Toggles (طلبات جديدة / تنبيه عاجل / إشعار الطبيب)
//   - lp3 (عن التطبيق): أيقونة 🧪 + اسم النظام + الإصدار
//
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — pg-ls
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/core/mock_user_data.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../../../shared/widgets/primitives/app_button.dart';
import '../navigation/lab_sidebar_sections.dart';

// ══════════════════════════════════════════════════════════════════════════
//  PAGE
// ══════════════════════════════════════════════════════════════════════════

/// صفحة الإعدادات — نظام المخبر.
class LabSettingsPage extends StatefulWidget {
  const LabSettingsPage({super.key});

  @override
  State<LabSettingsPage> createState() => _LabSettingsPageState();
}

class _LabSettingsPageState extends State<LabSettingsPage> {
  int _selectedTab = 0; // 0=الملف 1=الإشعارات 2=عن التطبيق

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppShellLayout(
      system: AppSystemType.lab,
      currentRoute: RouteNames.labSettings,
      sections: LabSidebarSections.build(context),
      pageTitle: l10n.settings,
      pageSubtitle: l10n.labTopbarSubtitle,
      userName: MockUserData.labUserName,
      userRole: l10n.roleLabManager,
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
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sidebar تبويبات
                SizedBox(
                  width: 160,
                  child: _TabNav(
                    selectedIndex: selectedTab,
                    onTap: onTabChanged,
                    isLight: isLight,
                    l10n: l10n,
                  ),
                ),
                const SizedBox(width: AppSizes.spaceLG),
                // المحتوى
                Expanded(
                  child: _buildContent(context, isLight, l10n),
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
                l10n: l10n,
                horizontal: true,
              ),
              const SizedBox(height: AppSizes.spaceLG),
              _buildContent(context, isLight, l10n),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isLight, AppLocalizations l10n) {
    switch (selectedTab) {
      case 1:
        return _NotificationsTab(isLight: isLight, l10n: l10n);
      case 2:
        return _AboutTab(isLight: isLight, l10n: l10n);
      default:
        return _ProfileTab(isLight: isLight, l10n: l10n);
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  TAB NAV
// ══════════════════════════════════════════════════════════════════════════

class _TabNav extends StatelessWidget {
  const _TabNav({
    required this.selectedIndex,
    required this.onTap,
    required this.isLight,
    required this.l10n,
    this.horizontal = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool isLight;
  final AppLocalizations l10n;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('👤', l10n.labSettingsTabProfile),
      ('🔔', l10n.labSettingsTabNotifications),
      ('ℹ️', l10n.labSettingsTabAbout),
    ];

    Widget buildItem(int i, String icon, String label) {
      final isSelected = selectedIndex == i;
      return GestureDetector(
        onTap: () => onTap(i),
        child: Container(
          margin: horizontal
              ? const EdgeInsets.only(left: AppSizes.spaceSM)
              : const EdgeInsets.only(bottom: AppSizes.spaceSM),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spaceMD, vertical: AppSizes.spaceSM),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.secondary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: isSelected
                ? Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: horizontal ? MainAxisSize.min : MainAxisSize.max,
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: AppSizes.spaceSM),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.secondary
                      : (isLight ? AppColors.lightText2 : AppColors.darkText2),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (horizontal) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < items.length; i++)
              buildItem(i, items[i].$1, items[i].$2),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSM),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++)
            buildItem(i, items[i].$1, items[i].$2),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  PROFILE TAB
// ══════════════════════════════════════════════════════════════════════════

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.isLight, required this.l10n});
  final bool isLight;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الملف الشخصي',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSizes.spaceLG),

          // Avatar + info card
          Container(
            padding: const EdgeInsets.all(AppSizes.spaceLG),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                // Avatar دائري بـ gradient
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.dashViolet,
                        AppColors.secondary,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'ر',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spaceMD),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رامي الصالح',
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontSize: 18,
                        color: isLight
                            ? AppColors.lightText1
                            : AppColors.darkText1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'رئيس المخبر · LAB-001',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isLight
                            ? AppColors.lightText3
                            : AppColors.darkText3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.spaceLG),

          // Form fields (2 columns)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;
              final nameField = _SettingsTextField(
                label: 'الاسم',
                value: 'رامي الصالح',
                isLight: isLight,
              );
              final emailField = _SettingsTextField(
                label: 'البريد',
                value: 'lab@dtteeth.com',
                isLight: isLight,
              );

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: nameField),
                    const SizedBox(width: AppSizes.spaceLG),
                    Expanded(child: emailField),
                  ],
                );
              }
              return Column(
                children: [
                  nameField,
                  const SizedBox(height: AppSizes.spaceLG),
                  emailField,
                ],
              );
            },
          ),

          const SizedBox(height: AppSizes.spaceLG),

          AppButton.primary(
            label: l10n.save,
            onPressed: () {},
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  NOTIFICATIONS TAB
// ══════════════════════════════════════════════════════════════════════════

class _NotificationsTab extends StatefulWidget {
  const _NotificationsTab({required this.isLight, required this.l10n});
  final bool isLight;
  final AppLocalizations l10n;

  @override
  State<_NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<_NotificationsTab> {
  bool _newOrders = true;
  bool _urgent = true;
  bool _doctorReady = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      decoration: BoxDecoration(
        color: widget.isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
          color: widget.isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.l10n.labSettingsTabNotifications,
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSizes.spaceLG),

          _ToggleRow(
            title: widget.l10n.labSettingsNotifNewOrders,
            subtitle: widget.l10n.labSettingsNotifNewOrdersDesc,
            value: _newOrders,
            onChanged: (v) => setState(() => _newOrders = v),
            isLight: widget.isLight,
          ),
          const Divider(height: 1),
          _ToggleRow(
            title: widget.l10n.labSettingsNotifUrgent,
            subtitle: widget.l10n.labSettingsNotifUrgentDesc,
            value: _urgent,
            onChanged: (v) => setState(() => _urgent = v),
            isLight: widget.isLight,
          ),
          const Divider(height: 1),
          _ToggleRow(
            title: widget.l10n.labSettingsNotifDoctorReady,
            subtitle: widget.l10n.labSettingsNotifDoctorReadyDesc,
            value: _doctorReady,
            onChanged: (v) => setState(() => _doctorReady = v),
            isLight: widget.isLight,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  ABOUT TAB
// ══════════════════════════════════════════════════════════════════════════

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.isLight, required this.l10n});
  final bool isLight;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSizes.spaceXL, horizontal: AppSizes.spaceLG),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: Column(
        children: [
          const Text('🧪', style: TextStyle(fontSize: 34)),
          const SizedBox(height: AppSizes.spaceMD),
          Text(
            l10n.labSettingsAboutTitle,
            style: AppTextStyles.headlineSmall.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: isLight ? AppColors.lightText1 : AppColors.darkText1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.labSettingsAboutVersion,
            style: AppTextStyles.bodySmall.copyWith(
              color: isLight ? AppColors.lightText3 : AppColors.darkText3,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  HELPERS
// ══════════════════════════════════════════════════════════════════════════

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isLight,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceMD),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color:
                      isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isLight
                      ? AppColors.lightText4
                      : AppColors.darkText3,
                ),
              ),
            ],
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.secondary,
            activeTrackColor: AppColors.secondary.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

class _SettingsTextField extends StatelessWidget {
  const _SettingsTextField({
    required this.label,
    required this.value,
    required this.isLight,
  });

  final String label;
  final String value;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isLight ? AppColors.lightText4 : AppColors.darkText4,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isLight
                ? AppColors.lightGlass2
                : AppColors.darkGlass2,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: Border.all(
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
            ),
          ),
          child: TextField(
            controller: TextEditingController(text: value),
            style: AppTextStyles.bodyMedium.copyWith(
              color: isLight ? AppColors.lightText1 : AppColors.darkText1,
            ),
            decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
