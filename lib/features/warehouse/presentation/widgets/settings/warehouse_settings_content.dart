// ════════════════════════════════════════════════════════════════════════════
// warehouse_settings_content.dart
//
// محتوى صفحة إعدادات المستودع — مطابقة كاملة لـ mockup التصميم.
//
// 🎯 البنية:
//   - Sidebar عمودي يميناً (RTL) بـ 3 تابات: الأمان / الإشعارات / التفضيلات
//   - محتوى التاب في العمود الأيسر (Expanded) كبطاقات متعددة
//
// التابات:
//   1. الأمان        → تغيير كلمة المرور + المصادقة الثنائية + الخروج من كل الأجهزة
//   2. الإشعارات     → تفضيلات الإشعارات (5 toggles) + قنوات الإشعار (2 toggles)
//   3. التفضيلات    → السمة (3 خيارات) + اللغة (خياران) + العرض والأداء (toggles)
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../shared/bloc/theme_cubit.dart';
import '../../../../../shared/widgets/primitives/app_theme_option.dart';
import '../../../../../shared/bloc/locale_cubit.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../../auth/presentation/logout_action.dart';

// ══════════════════════════════════════════════════════════════════════════
//  CONSTANTS
// ══════════════════════════════════════════════════════════════════════════

const double _kSidebarWidth = 220;
const double _kSidebarGap = 18;
const double _kCardGap = 18;

enum _SettingsTab { security, notifications, preferences }

extension on _SettingsTab {
  String label(BuildContext context) {
    switch (this) {
      case _SettingsTab.security:
        return context.l10n.settingsTabSecurity;
      case _SettingsTab.notifications:
        return context.l10n.notifications;
      case _SettingsTab.preferences:
        return context.l10n.settingsTabPreferences;
    }
  }

  IconData get icon {
    switch (this) {
      case _SettingsTab.security:
        return Icons.lock_outline_rounded;
      case _SettingsTab.notifications:
        return Icons.notifications_outlined;
      case _SettingsTab.preferences:
        return Icons.tune_rounded;
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  MAIN CONTENT
// ══════════════════════════════════════════════════════════════════════════

class WarehouseSettingsContent extends StatefulWidget {
  const WarehouseSettingsContent({super.key});

  @override
  State<WarehouseSettingsContent> createState() =>
      _WarehouseSettingsContentState();
}

class _WarehouseSettingsContentState extends State<WarehouseSettingsContent> {
  _SettingsTab _activeTab = _SettingsTab.security;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 760;
        if (isNarrow) {
          return _buildNarrowLayout(isLight);
        }
        return _buildWideLayout(isLight);
      },
    );
  }

  // ── Wide layout: sidebar + content ───────────────────────────────────
  // RTL: أوّل child=يمين، آخر=يسار.
  // المطلوب: Sidebar يمين، Content يسار → [Sidebar, Gap, Content].
  Widget _buildWideLayout(bool isLight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _kSidebarWidth,
          child: _Sidebar(
            isLight: isLight,
            active: _activeTab,
            onSelect: (t) => setState(() => _activeTab = t),
          ),
        ),
        const SizedBox(width: _kSidebarGap),
        Expanded(child: _buildTabContent(isLight)),
      ],
    );
  }

  // ── Narrow layout: top tab bar + content ─────────────────────────────
  Widget _buildNarrowLayout(bool isLight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _NarrowTabBar(
          isLight: isLight,
          active: _activeTab,
          onSelect: (t) => setState(() => _activeTab = t),
        ),
        const SizedBox(height: 16),
        Expanded(child: _buildTabContent(isLight)),
      ],
    );
  }

  Widget _buildTabContent(bool isLight) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: switch (_activeTab) {
        _SettingsTab.security => _SecurityTabContent(isLight: isLight),
        _SettingsTab.notifications =>
          _NotificationsPrefsTabContent(isLight: isLight),
        _SettingsTab.preferences => _PreferencesTabContent(isLight: isLight),
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  SIDEBAR (wide)
// ══════════════════════════════════════════════════════════════════════════

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.isLight,
    required this.active,
    required this.onSelect,
  });

  final bool isLight;
  final _SettingsTab active;
  final ValueChanged<_SettingsTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      isLight: isLight,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _SettingsTab.values
            .map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _SidebarItem(
                  isLight: isLight,
                  tab: t,
                  selected: active == t,
                  onTap: () => onSelect(t),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.isLight,
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final bool isLight;
  final _SettingsTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const selectedBg = AppColors.primary;
    final unselectedColor =
        isLight ? AppColors.lightText1 : AppColors.darkText1;
    return Material(
      color: selected ? selectedBg : Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                tab.icon,
                size: 18,
                color: selected ? Colors.white : unselectedColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tab.label(context),
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : unselectedColor,
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

// ── Narrow tab bar (mobile/tablet portrait) ──────────────────────────────
class _NarrowTabBar extends StatelessWidget {
  const _NarrowTabBar({
    required this.isLight,
    required this.active,
    required this.onSelect,
  });

  final bool isLight;
  final _SettingsTab active;
  final ValueChanged<_SettingsTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      isLight: isLight,
      padding: const EdgeInsets.all(6),
      child: Row(
        children: _SettingsTab.values
            .map((t) => Expanded(
                  child: _SidebarItem(
                    isLight: isLight,
                    tab: t,
                    selected: active == t,
                    onTap: () => onSelect(t),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  TAB 1 — الأمان
// ══════════════════════════════════════════════════════════════════════════

class _SecurityTabContent extends StatefulWidget {
  const _SecurityTabContent({required this.isLight});
  final bool isLight;

  @override
  State<_SecurityTabContent> createState() => _SecurityTabContentState();
}

class _SecurityTabContentState extends State<_SecurityTabContent> {
  final _currentPass = TextEditingController();
  final _newPass = TextEditingController();
  final _confirmPass = TextEditingController();
  bool _otpEnabled = true;

  @override
  void dispose() {
    _currentPass.dispose();
    _newPass.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── بطاقة 1: تغيير كلمة المرور ─────────────────────────────────
        _SettingsCard(
          isLight: widget.isLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardHeader(
                isLight: widget.isLight,
                title: context.l10n.settingsChangePassword,
                subtitle: context.l10n.settingsChangePasswordDesc,
              ),
              const SizedBox(height: 20),
              AppFormField(
                label: context.l10n.settingsCurrentPassword,
                controller: _currentPass,
                obscureText: true,
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, c) {
                  if (c.maxWidth < 460) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppFormField(
                            label: context.l10n.settingsNewPassword,
                            controller: _newPass,
                            obscureText: true),
                        const SizedBox(height: 14),
                        AppFormField(
                            label: context.l10n.settingsConfirmPassword,
                            controller: _confirmPass,
                            obscureText: true),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: AppFormField(
                            label: context.l10n.settingsNewPassword,
                            controller: _newPass,
                            obscureText: true),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AppFormField(
                            label: context.l10n.settingsConfirmPassword,
                            controller: _confirmPass,
                            obscureText: true),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              // RTL: للنسخة المطلوبة (الأساسي أقصى يسار، الثانوي يمينه)
              // نضع الأساسي آخر child والثانوي قبله.
              Row(
                children: [
                  AppButton(
                    label: context.l10n.cancel,
                    onPressed: () {
                      _currentPass.clear();
                      _newPass.clear();
                      _confirmPass.clear();
                    },
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.small,
                  ),
                  const SizedBox(width: 10),
                  AppButton(
                    label: context.l10n.settingsUpdatePassword,
                    onPressed: () {},
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.small,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: _kCardGap),

        // ── بطاقة 2: المصادقة الثنائية ─────────────────────────────────
        _SettingsCard(
          isLight: widget.isLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardHeader(
                isLight: widget.isLight,
                title: context.l10n.settings2FA,
                subtitle: context.l10n.settings2FADesc,
              ),
              const SizedBox(height: 4),
              _TogglePref(
                isLight: widget.isLight,
                label: context.l10n.settings2FAOtpTitle,
                description: context.l10n.settings2FAOtpDesc,
                value: _otpEnabled,
                onChanged: (v) => setState(() => _otpEnabled = v),
              ),
            ],
          ),
        ),

        const SizedBox(height: _kCardGap),

        // ── بطاقة 3: تسجيل الخروج من كل الأجهزة ─────────────────────────
        _DangerCard(
          isLight: widget.isLight,
          // RTL: text أوّل=يمين، الزر آخر=يسار.
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.settingsLogoutAll,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: widget.isLight
                            ? AppColors.lightText1
                            : AppColors.darkText1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.settingsLogoutAllDesc,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13,
                        color: widget.isLight
                            ? AppColors.lightText3
                            : AppColors.darkText3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AppButton(
                label: context.l10n.logout,
                onPressed: () => performLogout(context),
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.small,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  TAB 2 — الإشعارات
// ══════════════════════════════════════════════════════════════════════════

class _NotificationsPrefsTabContent extends StatefulWidget {
  const _NotificationsPrefsTabContent({required this.isLight});
  final bool isLight;

  @override
  State<_NotificationsPrefsTabContent> createState() =>
      _NotificationsPrefsTabContentState();
}

class _NotificationsPrefsTabContentState
    extends State<_NotificationsPrefsTabContent> {
  bool _lowStock = true;
  bool _expiry = true;
  bool _newOrders = true;
  bool _supplierDelay = false;
  bool _invoicesDue = true;
  bool _dailyEmail = true;
  bool _systemSound = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── تفضيلات الإشعارات ───────────────────────────────────────
        _SettingsCard(
          isLight: widget.isLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardHeader(
                isLight: widget.isLight,
                title: context.l10n.settingsNotifPrefs,
                subtitle: context.l10n.settingsNotifPrefsDesc,
              ),
              const SizedBox(height: 4),
              _TogglePref(
                isLight: widget.isLight,
                label: context.l10n.settingsNotifLowMaterials,
                description: context.l10n.settingsNotifLowMaterialsDesc,
                value: _lowStock,
                onChanged: (v) => setState(() => _lowStock = v),
              ),
              _PrefDivider(isLight: widget.isLight),
              _TogglePref(
                isLight: widget.isLight,
                label: context.l10n.whNotifExpiry,
                description: context.l10n.whNotifExpiryDesc,
                value: _expiry,
                onChanged: (v) => setState(() => _expiry = v),
              ),
              _PrefDivider(isLight: widget.isLight),
              _TogglePref(
                isLight: widget.isLight,
                label: context.l10n.whNotifNewSupply,
                description: context.l10n.whNotifNewSupplyDesc,
                value: _newOrders,
                onChanged: (v) => setState(() => _newOrders = v),
              ),
              _PrefDivider(isLight: widget.isLight),
              _TogglePref(
                isLight: widget.isLight,
                label: context.l10n.whNotifSupplierDelay,
                description: context.l10n.whNotifSupplierDelayDesc,
                value: _supplierDelay,
                onChanged: (v) => setState(() => _supplierDelay = v),
              ),
              _PrefDivider(isLight: widget.isLight),
              _TogglePref(
                isLight: widget.isLight,
                label: context.l10n.whNotifInvoicesDue,
                description: context.l10n.whNotifInvoicesDueDesc,
                value: _invoicesDue,
                onChanged: (v) => setState(() => _invoicesDue = v),
              ),
            ],
          ),
        ),

        const SizedBox(height: _kCardGap),

        // ── قنوات الإشعار ───────────────────────────────────────────
        _SettingsCard(
          isLight: widget.isLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardHeader(
                isLight: widget.isLight,
                title: context.l10n.settingsNotifChannels,
                subtitle: context.l10n.settingsNotifChannelsDesc,
              ),
              const SizedBox(height: 4),
              _TogglePref(
                isLight: widget.isLight,
                label: context.l10n.settingsNotifDailyEmail,
                description: context.l10n.settingsNotifDailyEmailDesc,
                value: _dailyEmail,
                onChanged: (v) => setState(() => _dailyEmail = v),
              ),
              _PrefDivider(isLight: widget.isLight),
              _TogglePref(
                isLight: widget.isLight,
                label: context.l10n.settingsNotifSound,
                description: context.l10n.settingsNotifSoundDesc,
                value: _systemSound,
                onChanged: (v) => setState(() => _systemSound = v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  TAB 3 — التفضيلات
// ══════════════════════════════════════════════════════════════════════════

enum _ThemeChoice { dark, light }

extension on _ThemeChoice {
  String label(BuildContext context) => switch (this) {
        _ThemeChoice.dark => context.l10n.settingsThemeDark,
        _ThemeChoice.light => context.l10n.settingsThemeLight,
      };
}

class _PreferencesTabContent extends StatefulWidget {
  const _PreferencesTabContent({required this.isLight});
  final bool isLight;

  @override
  State<_PreferencesTabContent> createState() => _PreferencesTabContentState();
}

class _PreferencesTabContentState extends State<_PreferencesTabContent> {
  /// يحوّل خيار السمة المحلي إلى [ThemeMode] الخاص بـ Flutter.
  ThemeMode _flutterMode(_ThemeChoice c) => switch (c) {
        _ThemeChoice.dark => ThemeMode.dark,
        _ThemeChoice.light => ThemeMode.light,
      };
  bool _compactView = false;
  bool _autoSave = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── السمة ───────────────────────────────────────────────────
        _SettingsCard(
          isLight: widget.isLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardHeader(
                isLight: widget.isLight,
                title: context.l10n.theme,
                subtitle: context.l10n.settingsThemeDesc,
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, c) {
                  final isNarrow = c.maxWidth < 520;
                  final currentMode = context.watch<ThemeCubit>().state;
                  // بطاقة السمة الموحّدة (تصميم المخبر المعتمد).
                  final children = _ThemeChoice.values
                      .map((t) => AppThemeOption(
                            label: t.label(context),
                            mode: _flutterMode(t),
                            selected: _flutterMode(t) == currentMode,
                            onTap: () => context
                                .read<ThemeCubit>()
                                .setMode(_flutterMode(t)),
                          ))
                      .toList();
                  if (isNarrow) {
                    return Column(
                      children: [
                        for (var i = 0; i < children.length; i++) ...[
                          children[i],
                          if (i != children.length - 1)
                            const SizedBox(height: 10),
                        ],
                      ],
                    );
                  }
                  return Row(
                    children: [
                      for (var i = 0; i < children.length; i++) ...[
                        Expanded(child: children[i]),
                        if (i != children.length - 1)
                          const SizedBox(width: 12),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: _kCardGap),

        // ── اللغة ───────────────────────────────────────────────────
        _SettingsCard(
          isLight: widget.isLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardHeader(
                isLight: widget.isLight,
                title: context.l10n.language,
                subtitle: context.l10n.settingsLanguageDesc,
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, c) {
                  final isNarrow = c.maxWidth < 520;
                  final isArabic =
                      context.watch<LocaleCubit>().state.languageCode == 'ar';
                  final ar = _LangOptionCard(
                    isLight: widget.isLight,
                    badge: 'ع',
                    title: 'العربية',
                    sub: context.l10n.settingsLangArabicHint,
                    selected: isArabic,
                    onTap: () => context
                        .read<LocaleCubit>()
                        .setLocale(SupportedLocale.arabic),
                  );
                  final en = _LangOptionCard(
                    isLight: widget.isLight,
                    badge: 'EN',
                    title: 'English',
                    sub: context.l10n.settingsLangEnglishHint,
                    selected: !isArabic,
                    onTap: () => context
                        .read<LocaleCubit>()
                        .setLocale(SupportedLocale.english),
                  );
                  if (isNarrow) {
                    return Column(
                      children: [
                        ar,
                        const SizedBox(height: 10),
                        en,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: ar),
                      const SizedBox(width: 12),
                      Expanded(child: en),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: _kCardGap),

        // ── العرض والأداء ───────────────────────────────────────────
        _SettingsCard(
          isLight: widget.isLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardHeader(
                isLight: widget.isLight,
                title: context.l10n.settingsDisplayPerf,
              ),
              const SizedBox(height: 4),
              _TogglePref(
                isLight: widget.isLight,
                label: context.l10n.settingsCompactView,
                description: context.l10n.settingsCompactViewDesc,
                value: _compactView,
                onChanged: (v) => setState(() => _compactView = v),
              ),
              _PrefDivider(isLight: widget.isLight),
              _TogglePref(
                isLight: widget.isLight,
                label: context.l10n.settingsAutoSave,
                description: context.l10n.settingsAutoSaveDesc,
                value: _autoSave,
                onChanged: (v) => setState(() => _autoSave = v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  REUSABLE PIECES
// ══════════════════════════════════════════════════════════════════════════

/// ترويسة بطاقة (عنوان + وصف اختياري).
class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.isLight,
    required this.title,
    this.subtitle,
  });

  final bool isLight;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isLight ? AppColors.lightText1 : AppColors.darkText1,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              color: isLight ? AppColors.lightText3 : AppColors.darkText3,
            ),
          ),
        ],
      ],
    );
  }
}

/// صفّ توضّع فيه: نص رئيسي + وصف + Switch.
class _TogglePref extends StatelessWidget {
  const _TogglePref({
    required this.isLight,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final bool isLight;
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    color: isLight ? AppColors.lightText3 : AppColors.darkText3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }
}

class _PrefDivider extends StatelessWidget {
  const _PrefDivider({required this.isLight});
  final bool isLight;

  @override
  Widget build(BuildContext context) => Divider(
        height: 1,
        thickness: 1,
        color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
      );
}
/// بطاقة اختيار اللغة.
class _LangOptionCard extends StatelessWidget {
  const _LangOptionCard({
    required this.isLight,
    required this.badge,
    required this.title,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  final bool isLight;
  final String badge;
  final String title;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? AppColors.primary
        : (isLight ? AppColors.lightBorder : AppColors.darkBorder);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isLight ? AppColors.lightBg : AppColors.darkBg,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
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
                    sub,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      color: isLight
                          ? AppColors.lightText3
                          : AppColors.darkText3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _RadioDot(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.lightText4,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
// ══════════════════════════════════════════════════════════════════════════
//  CARDS
// ══════════════════════════════════════════════════════════════════════════

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.isLight,
    required this.child,
    this.padding,
  });

  final bool isLight;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSizes.spaceLG),
      decoration: BoxDecoration(
        color: isLight ? AppColors.baseComponent : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: child,
    );
  }
}

class _DangerCard extends StatelessWidget {
  const _DangerCard({required this.isLight, required this.child});
  final bool isLight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // لون برتقالي/تحذير خفيف يطابق الـ mockup
    const dangerTint = AppColors.warnTintLight2;
    const dangerBorder = AppColors.warnBorderLight2;
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      decoration: BoxDecoration(
        color: isLight ? dangerTint : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(
          color: isLight ? dangerBorder : AppColors.darkBorder,
        ),
      ),
      child: child,
    );
  }
}
