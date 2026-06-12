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
import '../../../../shared/widgets/primitives/app_theme_option.dart';
import '../../../../shared/bloc/locale_cubit.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/core/mock_user_data.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../navigation/lab_sidebar_sections.dart';

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
      searchPlaceholder: context.l10n.settingsSearchHint,
      userName: MockUserData.labUserName,
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

// ══════════════════════════════════════════════════════════════════════════
//  TAB NAV
// ══════════════════════════════════════════════════════════════════════════

class _TabNav extends StatelessWidget {
  const _TabNav({
    required this.selectedIndex,
    required this.onTap,
    required this.isLight,
    this.horizontal = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool isLight;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.lock_outline, context.l10n.settingsTabSecurity),
      (Icons.notifications_none, context.l10n.notifications),
      (Icons.tune, context.l10n.settingsTabPreferences),
    ];

    Widget buildItem(int i, IconData icon, String label) {
      final isSelected = selectedIndex == i;
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            margin: horizontal
                ? const EdgeInsetsDirectional.only(end: AppSizes.spaceSM)
                : const EdgeInsetsDirectional.only(bottom: AppSizes.spaceSM),
            padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : (isLight
                      ? AppColors.lightSurface
                      : AppColors.darkSurface),
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              border: isSelected
                  ? null
                  : Border.all(
                      color: isLight
                          ? AppColors.lightBorder
                          : AppColors.darkBorder,
                    ),
            ),
            child: Row(
              mainAxisSize: horizontal ? MainAxisSize.min : MainAxisSize.max,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : (isLight
                          ? AppColors.lightText2
                          : AppColors.darkText2),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : (isLight
                            ? AppColors.lightText1
                            : AppColors.darkText1),
                  ),
                ),
              ],
            ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < items.length; i++)
          buildItem(i, items[i].$1, items[i].$2),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  SECURITY TAB — الأمان
// ══════════════════════════════════════════════════════════════════════════

class _SecurityTab extends StatefulWidget {
  const _SecurityTab({required this.isLight});
  final bool isLight;

  @override
  State<_SecurityTab> createState() => _SecurityTabState();
}

class _SecurityTabState extends State<_SecurityTab> {
  final TextEditingController _currentPwd = TextEditingController();
  final TextEditingController _newPwd = TextEditingController();
  final TextEditingController _confirmPwd = TextEditingController();
  bool _twoFA = true;

  @override
  void dispose() {
    _currentPwd.dispose();
    _newPwd.dispose();
    _confirmPwd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 1) تغيير كلمة المرور ─────────────────────────────────
        _SettingCard(
          isLight: widget.isLight,
          title: context.l10n.settingsChangePassword,
          subtitle: context.l10n.settingsChangePasswordDesc,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PasswordField(
                label: context.l10n.settingsCurrentPassword,
                controller: _currentPwd,
                isLight: widget.isLight,
              ),
              const SizedBox(height: AppSizes.spaceLG),
              LayoutBuilder(builder: (ctx, c) {
                final wide = c.maxWidth > 520;
                final f1 = _PasswordField(
                  label: context.l10n.settingsNewPassword,
                  controller: _newPwd,
                  isLight: widget.isLight,
                );
                final f2 = _PasswordField(
                  label: context.l10n.settingsConfirmPassword,
                  controller: _confirmPwd,
                  isLight: widget.isLight,
                );
                if (wide) {
                  return Row(children: [
                    Expanded(child: f1),
                    const SizedBox(width: AppSizes.spaceLG),
                    Expanded(child: f2),
                  ]);
                }
                return Column(children: [
                  f1,
                  const SizedBox(height: AppSizes.spaceLG),
                  f2,
                ]);
              }),
              const SizedBox(height: AppSizes.spaceLG),
              // RTL convention: primary (تحديث) في الأقصى يسار، secondary (إلغاء) يمينه.
              // → في الكود: primary ثم secondary بحيث Row first child = يمين بصرياً.
              // المطلوب: primary يسار، فالـ Row يبدأ بـ primary أوّلاً يخلّيه يمين — غلط.
              // الصحيح: secondary أوّل (يصير يمين)، primary آخر (يصير يسار).
              Row(
                children: [
                  _SecondaryButton(
                    label: context.l10n.cancel,
                    isLight: widget.isLight,
                    onTap: () {
                      _currentPwd.clear();
                      _newPwd.clear();
                      _confirmPwd.clear();
                    },
                  ),
                  const SizedBox(width: AppSizes.spaceSM),
                  _PrimaryButton(
                    label: context.l10n.settingsUpdatePassword,
                    icon: Icons.check_rounded,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.spaceLG),

        // ── 2) المصادقة الثنائية ─────────────────────────────────
        _SettingCard(
          isLight: widget.isLight,
          title: context.l10n.settings2FA,
          subtitle: context.l10n.settings2FADesc,
          child: Column(
            children: [
              _ToggleRow(
                title: context.l10n.settings2FAOtpTitle,
                subtitle: context.l10n.settings2FAOtpDesc,
                value: _twoFA,
                onChanged: (v) => setState(() => _twoFA = v),
                isLight: widget.isLight,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.spaceLG),

        // ── 3) تسجيل الخروج من كل الأجهزة ───────────────────────
        _SettingCard(
          isLight: widget.isLight,
          tint: const Color(0xFFFEF2F2),
          tintBorder: const Color(0xFFFCA5A5),
          title: context.l10n.settingsLogoutAll,
          subtitle: context.l10n.settingsLogoutAllDesc,
          trailing: _SecondaryButton(
            label: context.l10n.logout,
            isLight: widget.isLight,
            danger: true,
            onTap: () => performLogout(context),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  NOTIFICATIONS TAB — الإشعارات
// ══════════════════════════════════════════════════════════════════════════

class _NotificationsTab extends StatefulWidget {
  const _NotificationsTab({required this.isLight});
  final bool isLight;

  @override
  State<_NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<_NotificationsTab> {
  bool _urgent = true;
  bool _newOrders = true;
  bool _lowStock = true;
  bool _warehouse = true;
  bool _team = false;
  bool _emailSummary = true;
  bool _sounds = false;

  @override
  Widget build(BuildContext context) {
    final divider = Divider(
      height: 1,
      color: widget.isLight ? AppColors.lightBorder : AppColors.darkBorder,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SettingCard(
          isLight: widget.isLight,
          title: context.l10n.settingsNotifPrefs,
          subtitle: context.l10n.settingsNotifPrefsDesc,
          child: Column(children: [
            _ToggleRow(
              title: context.l10n.labSettingsNotifUrgentOrders,
              subtitle: context.l10n.labSettingsNotifUrgentOrdersDesc,
              value: _urgent,
              onChanged: (v) => setState(() => _urgent = v),
              isLight: widget.isLight,
            ),
            divider,
            _ToggleRow(
              title: context.l10n.labSettingsNotifNewFromDoctors,
              subtitle: context.l10n.labSettingsNotifNewFromDoctorsDesc,
              value: _newOrders,
              onChanged: (v) => setState(() => _newOrders = v),
              isLight: widget.isLight,
            ),
            divider,
            _ToggleRow(
              title: context.l10n.settingsNotifLowMaterials,
              subtitle: context.l10n.settingsNotifLowMaterialsDesc,
              value: _lowStock,
              onChanged: (v) => setState(() => _lowStock = v),
              isLight: widget.isLight,
            ),
            divider,
            _ToggleRow(
              title: context.l10n.labSettingsNotifWarehouseUpdates,
              subtitle: context.l10n.labSettingsNotifWarehouseUpdatesDesc,
              value: _warehouse,
              onChanged: (v) => setState(() => _warehouse = v),
              isLight: widget.isLight,
            ),
            divider,
            _ToggleRow(
              title: context.l10n.labSettingsNotifTeamUpdates,
              subtitle: context.l10n.labSettingsNotifTeamUpdatesDesc,
              value: _team,
              onChanged: (v) => setState(() => _team = v),
              isLight: widget.isLight,
            ),
          ]),
        ),

        const SizedBox(height: AppSizes.spaceLG),

        _SettingCard(
          isLight: widget.isLight,
          title: context.l10n.settingsNotifChannels,
          subtitle: context.l10n.settingsNotifChannelsDesc,
          child: Column(children: [
            _ToggleRow(
              title: context.l10n.settingsNotifDailyEmail,
              subtitle: context.l10n.settingsNotifDailyEmailDesc,
              value: _emailSummary,
              onChanged: (v) => setState(() => _emailSummary = v),
              isLight: widget.isLight,
            ),
            divider,
            _ToggleRow(
              title: context.l10n.settingsNotifSound,
              subtitle: context.l10n.settingsNotifSoundDesc,
              value: _sounds,
              onChanged: (v) => setState(() => _sounds = v),
              isLight: widget.isLight,
            ),
          ]),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  PREFERENCES TAB — التفضيلات
// ══════════════════════════════════════════════════════════════════════════

class _PreferencesTab extends StatefulWidget {
  const _PreferencesTab({required this.isLight});
  final bool isLight;

  @override
  State<_PreferencesTab> createState() => _PreferencesTabState();
}

class _PreferencesTabState extends State<_PreferencesTab> {
  bool _compact = false;
  bool _autosave = true;


  @override
  Widget build(BuildContext context) {
    final divider = Divider(
      height: 1,
      color: widget.isLight ? AppColors.lightBorder : AppColors.darkBorder,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── السمة ──────────────────────────────────────────────
        _SettingCard(
          isLight: widget.isLight,
          title: context.l10n.theme,
          subtitle: context.l10n.settingsThemeDesc,
          child: LayoutBuilder(builder: (ctx, c) {
            final wide = c.maxWidth > 520;
            // الاختيار يُشتق من الحالة الفعلية لـ ThemeCubit (مصدر الحقيقة).
            final currentMode = context.watch<ThemeCubit>().state;
            final widgets = [
              for (final (label, mode) in [
                (context.l10n.settingsThemeDark, ThemeMode.dark),
                (context.l10n.settingsThemeLight, ThemeMode.light),
              ])
                AppThemeOption(
                  label: label,
                  mode: mode,
                  selected: mode == currentMode,
                  onTap: () => context.read<ThemeCubit>().setMode(mode),
                ),
            ];
            if (wide) {
              return Row(children: [
                for (int i = 0; i < widgets.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSizes.spaceMD),
                  Expanded(child: widgets[i]),
                ],
              ]);
            }
            return Column(children: [
              for (int i = 0; i < widgets.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSizes.spaceMD),
                widgets[i],
              ],
            ]);
          }),
        ),

        const SizedBox(height: AppSizes.spaceLG),

        // ── اللغة ──────────────────────────────────────────────
        _SettingCard(
          isLight: widget.isLight,
          title: context.l10n.language,
          subtitle: context.l10n.settingsLanguageDesc,
          child: LayoutBuilder(builder: (ctx, c) {
            final wide = c.maxWidth > 520;
            // الاختيار يُشتق من LocaleCubit (مصدر الحقيقة).
            final isArabic =
                context.watch<LocaleCubit>().state.languageCode == 'ar';
            final widgets = [
              _LanguageOption(
                title: 'English',
                badge: 'EN',
                hint: context.l10n.settingsLangEnglishHint,
                selected: !isArabic,
                onTap: () => context
                    .read<LocaleCubit>()
                    .setLocale(SupportedLocale.english),
                isLight: widget.isLight,
              ),
              _LanguageOption(
                title: context.l10n.languageArabic,
                badge: 'ع',
                hint: context.l10n.settingsLangArabicHint,
                selected: isArabic,
                onTap: () => context
                    .read<LocaleCubit>()
                    .setLocale(SupportedLocale.arabic),
                isLight: widget.isLight,
              ),
            ];
            if (wide) {
              return Row(children: [
                Expanded(child: widgets[0]),
                const SizedBox(width: AppSizes.spaceMD),
                Expanded(child: widgets[1]),
              ]);
            }
            return Column(children: [
              widgets[0],
              const SizedBox(height: AppSizes.spaceMD),
              widgets[1],
            ]);
          }),
        ),

        const SizedBox(height: AppSizes.spaceLG),

        // ── العرض والأداء ──────────────────────────────────────
        _SettingCard(
          isLight: widget.isLight,
          title: context.l10n.settingsDisplayPerf,
          subtitle: null,
          child: Column(children: [
            _ToggleRow(
              title: context.l10n.settingsCompactView,
              subtitle: context.l10n.settingsCompactViewDesc,
              value: _compact,
              onChanged: (v) => setState(() => _compact = v),
              isLight: widget.isLight,
            ),
            divider,
            _ToggleRow(
              title: context.l10n.settingsAutoSave,
              subtitle: context.l10n.settingsAutoSaveDesc,
              value: _autosave,
              onChanged: (v) => setState(() => _autosave = v),
              isLight: widget.isLight,
            ),
          ]),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  REUSABLE — SETTING CARD
// ══════════════════════════════════════════════════════════════════════════

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.isLight,
    required this.title,
    this.subtitle,
    this.child,
    this.trailing,
    this.tint,
    this.tintBorder,
  });

  final bool isLight;
  final String title;
  final String? subtitle;
  final Widget? child;
  final Widget? trailing;
  final Color? tint;
  final Color? tintBorder;

  @override
  Widget build(BuildContext context) {
    final bg = tint ??
        (isLight ? AppColors.lightSurface : AppColors.darkSurface);
    final border = tintBorder ??
        (isLight ? AppColors.lightBorder : AppColors.darkBorder);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: title + subtitle ← يمين (start) | trailing ← يسار (end)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isLight
                            ? AppColors.lightText1
                            : AppColors.darkText1,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isLight
                              ? AppColors.lightText3
                              : AppColors.darkText3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSizes.spaceMD),
                trailing!,
              ],
            ],
          ),
          if (child != null) ...[
            const SizedBox(height: AppSizes.spaceLG),
            child!,
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  REUSABLE — TOGGLE ROW
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // النص ← start (يمين بـ RTL)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isLight
                        ? AppColors.lightText1
                        : AppColors.darkText1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isLight
                        ? AppColors.lightText4
                        : AppColors.darkText3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.spaceMD),
          // الـ Switch ← end (يسار بـ RTL)
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  REUSABLE — PASSWORD FIELD
// ══════════════════════════════════════════════════════════════════════════

class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.isLight,
  });

  final String label;
  final TextEditingController controller;
  final bool isLight;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: widget.isLight
                ? AppColors.lightText2
                : AppColors.darkText2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: widget.isLight ? Colors.white : AppColors.darkGlass2,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: Border.all(
              color: widget.isLight
                  ? AppColors.lightBorder
                  : AppColors.darkBorder,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: _obscure,
            autofillHints: const [AutofillHints.password],
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: widget.isLight
                  ? AppColors.lightText1
                  : AppColors.darkText1,
            ),
            decoration: InputDecoration(
              hintText: '••••••••',
              contentPadding: const EdgeInsetsDirectional.fromSTEB(
                14, 12, 8, 12,
              ),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: widget.isLight
                      ? AppColors.lightText3
                      : AppColors.darkText3,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  REUSABLE — LANGUAGE OPTION
// ══════════════════════════════════════════════════════════════════════════

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.title,
    required this.badge,
    required this.hint,
    required this.selected,
    required this.onTap,
    required this.isLight,
  });

  final String title;
  final String badge;
  final String hint;
  final bool selected;
  final VoidCallback onTap;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(AppSizes.spaceMD),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.08)
                : (isLight ? Colors.white : AppColors.darkSurface),
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.lightBorder,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Radio circle (يسار بـ RTL = end)
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : AppColors.lightBorder,
                    width: 2,
                  ),
                  color: selected ? AppColors.primary : Colors.transparent,
                ),
                child: selected
                    ? const Icon(Icons.circle, size: 6, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              // Title + hint
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isLight
                            ? AppColors.lightText1
                            : AppColors.darkText1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hint,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isLight
                            ? AppColors.lightText3
                            : AppColors.darkText3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Badge (end)
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9ECFB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  REUSABLE — BUTTONS
// ══════════════════════════════════════════════════════════════════════════

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 11, 16, 11),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: Colors.white),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.onTap,
    required this.isLight,
    this.danger = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isLight;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final fg = danger
        ? const Color(0xFFDC2626)
        : (isLight ? AppColors.lightText1 : AppColors.darkText1);
    final border = danger
        ? const Color(0xFFFCA5A5)
        : (isLight ? AppColors.lightBorder : AppColors.darkBorder);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 11, 16, 11),
          decoration: BoxDecoration(
            color: danger ? const Color(0xFFFEF2F2) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: Border.all(color: border),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
