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

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';

// ══════════════════════════════════════════════════════════════════════════
//  CONSTANTS
// ══════════════════════════════════════════════════════════════════════════

const double _kSidebarWidth = 220;
const double _kSidebarGap = 18;
const double _kCardGap = 18;

enum _SettingsTab { security, notifications, preferences }

extension on _SettingsTab {
  String get label {
    switch (this) {
      case _SettingsTab.security:
        return 'الأمان';
      case _SettingsTab.notifications:
        return 'الإشعارات';
      case _SettingsTab.preferences:
        return 'التفضيلات';
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
  Widget _buildWideLayout(bool isLight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildTabContent(isLight)),
        const SizedBox(width: _kSidebarGap),
        SizedBox(
          width: _kSidebarWidth,
          child: _Sidebar(
            isLight: isLight,
            active: _activeTab,
            onSelect: (t) => setState(() => _activeTab = t),
          ),
        ),
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
                  tab.label,
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
                title: 'تغيير كلمة المرور',
                subtitle: 'يفضّل تغيير كلمة المرور كل 90 يوماً لزيادة الأمان',
              ),
              const SizedBox(height: 20),
              AppFormField(
                label: 'كلمة المرور الحالية',
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
                            label: 'كلمة المرور الجديدة',
                            controller: _newPass,
                            obscureText: true),
                        const SizedBox(height: 14),
                        AppFormField(
                            label: 'تأكيد كلمة المرور',
                            controller: _confirmPass,
                            obscureText: true),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: AppFormField(
                            label: 'كلمة المرور الجديدة',
                            controller: _newPass,
                            obscureText: true),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AppFormField(
                            label: 'تأكيد كلمة المرور',
                            controller: _confirmPass,
                            obscureText: true),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  AppButton(
                    label: 'تحديث كلمة المرور',
                    onPressed: () {},
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.small,
                  ),
                  const SizedBox(width: 10),
                  AppButton(
                    label: 'إلغاء',
                    onPressed: () {
                      _currentPass.clear();
                      _newPass.clear();
                      _confirmPass.clear();
                    },
                    variant: AppButtonVariant.secondary,
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
                title: 'المصادقة الثنائية',
                subtitle: 'حماية إضافية لحسابك عبر رمز OTP',
              ),
              const SizedBox(height: 4),
              _TogglePref(
                isLight: widget.isLight,
                label: 'طلب رمز OTP عند تسجيل الدخول',
                description:
                    'يصلك رمز عبر البريد الإلكتروني في كل مرة تدخل من جهاز جديد',
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تسجيل الخروج من كل الأجهزة',
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
                      'إنهاء جميع الجلسات النشطة على الأجهزة الأخرى',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12.5,
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
                label: 'تسجيل الخروج',
                onPressed: () {},
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
                title: 'تفضيلات الإشعارات',
                subtitle: 'حدد أنواع الإشعارات التي تريد استقبالها',
              ),
              const SizedBox(height: 4),
              _TogglePref(
                isLight: widget.isLight,
                label: 'نقص المواد',
                description: 'عند وصول مادة للحد الأدنى',
                value: _lowStock,
                onChanged: (v) => setState(() => _lowStock = v),
              ),
              _PrefDivider(isLight: widget.isLight),
              _TogglePref(
                isLight: widget.isLight,
                label: 'انتهاء الصلاحية',
                description: 'قبل انتهاء الصلاحية بـ 30 يوم',
                value: _expiry,
                onChanged: (v) => setState(() => _expiry = v),
              ),
              _PrefDivider(isLight: widget.isLight),
              _TogglePref(
                isLight: widget.isLight,
                label: 'طلبيات توريد جديدة',
                description: 'عند وصول طلبية من المخبر/العيادة',
                value: _newOrders,
                onChanged: (v) => setState(() => _newOrders = v),
              ),
              _PrefDivider(isLight: widget.isLight),
              _TogglePref(
                isLight: widget.isLight,
                label: 'تأخر الموردين',
                description: 'عند تأخر مورد عن موعد التسليم',
                value: _supplierDelay,
                onChanged: (v) => setState(() => _supplierDelay = v),
              ),
              _PrefDivider(isLight: widget.isLight),
              _TogglePref(
                isLight: widget.isLight,
                label: 'فواتير بانتظار الدفع',
                description: 'تذكير قبل تاريخ الاستحقاق',
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
                title: 'قنوات الإشعار',
                subtitle: 'اختر أين تصلك التنبيهات',
              ),
              const SizedBox(height: 4),
              _TogglePref(
                isLight: widget.isLight,
                label: 'ملخص يومي عبر البريد الإلكتروني',
                description: 'يصلك في الساعة 8:00 صباحاً كل يوم',
                value: _dailyEmail,
                onChanged: (v) => setState(() => _dailyEmail = v),
              ),
              _PrefDivider(isLight: widget.isLight),
              _TogglePref(
                isLight: widget.isLight,
                label: 'صوت الإشعارات داخل النظام',
                description: 'تشغيل نغمة عند وصول إشعار جديد',
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

enum _ThemeChoice { auto, dark, light }

extension on _ThemeChoice {
  String get label => switch (this) {
        _ThemeChoice.auto => 'تلقائي',
        _ThemeChoice.dark => 'داكن',
        _ThemeChoice.light => 'فاتح',
      };
}

enum _LangChoice { ar, en }

class _PreferencesTabContent extends StatefulWidget {
  const _PreferencesTabContent({required this.isLight});
  final bool isLight;

  @override
  State<_PreferencesTabContent> createState() => _PreferencesTabContentState();
}

class _PreferencesTabContentState extends State<_PreferencesTabContent> {
  _ThemeChoice _theme = _ThemeChoice.light;
  _LangChoice _lang = _LangChoice.ar;
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
                title: 'السمة',
                subtitle: 'اختر مظهر النظام',
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, c) {
                  final isNarrow = c.maxWidth < 520;
                  final children = _ThemeChoice.values
                      .map((t) => _ThemeOptionCard(
                            isLight: widget.isLight,
                            choice: t,
                            selected: _theme == t,
                            onTap: () => setState(() => _theme = t),
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
                title: 'اللغة',
                subtitle: 'لغة عرض النظام',
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, c) {
                  final isNarrow = c.maxWidth < 520;
                  final ar = _LangOptionCard(
                    isLight: widget.isLight,
                    badge: 'ع',
                    title: 'العربية',
                    sub: 'RTL · الافتراضي',
                    selected: _lang == _LangChoice.ar,
                    onTap: () => setState(() => _lang = _LangChoice.ar),
                  );
                  final en = _LangOptionCard(
                    isLight: widget.isLight,
                    badge: 'EN',
                    title: 'English',
                    sub: 'LTR',
                    selected: _lang == _LangChoice.en,
                    onTap: () => setState(() => _lang = _LangChoice.en),
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
                title: 'العرض والأداء',
              ),
              const SizedBox(height: 4),
              _TogglePref(
                isLight: widget.isLight,
                label: 'العرض المضغوط',
                description: 'إظهار مزيد من البيانات في الشاشة الواحدة',
                value: _compactView,
                onChanged: (v) => setState(() => _compactView = v),
              ),
              _PrefDivider(isLight: widget.isLight),
              _TogglePref(
                isLight: widget.isLight,
                label: 'الحفظ التلقائي',
                description: 'حفظ التعديلات تلقائياً كل دقيقة',
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
              fontSize: 12.5,
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
                    fontSize: 12.5,
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

/// بطاقة اختيار السمة (3 خيارات بصرية).
class _ThemeOptionCard extends StatelessWidget {
  const _ThemeOptionCard({
    required this.isLight,
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  final bool isLight;
  final _ThemeChoice choice;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // معاينة بصرية
            Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                border: Border.all(
                  color: isLight
                      ? AppColors.lightBorder
                      : AppColors.darkBorder,
                ),
                gradient: _previewGradient(),
              ),
              child: selected
                  ? const Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: Padding(
                        padding: EdgeInsets.all(6),
                        child: _SelectedDot(),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 10),
            Text(
              choice.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isLight ? AppColors.lightText1 : AppColors.darkText1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _previewGradient() {
    switch (choice) {
      case _ThemeChoice.auto:
        return const LinearGradient(
          colors: [Color(0xFFF6F7FB), Color(0xFF1A1C4E)],
          stops: [0.5, 0.5],
        );
      case _ThemeChoice.dark:
        return const LinearGradient(
          colors: [Color(0xFF1A1C4E), Color(0xFF1A1C4E)],
        );
      case _ThemeChoice.light:
        return const LinearGradient(
          colors: [Color(0xFFF6F7FB), Color(0xFFF6F7FB)],
        );
    }
  }
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

class _SelectedDot extends StatelessWidget {
  const _SelectedDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
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
    const dangerTint = Color(0xFFFFF4EC);
    const dangerBorder = Color(0xFFF7C6A8);
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
