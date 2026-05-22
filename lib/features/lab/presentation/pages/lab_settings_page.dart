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

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
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
      pageTitle: 'الإعدادات',
      pageSubtitle: null,
      userName: MockUserData.labUserName,
      userRole: 'رئيس المخبر',
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
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // المحتوى — يساراً (يطلع يميناً بـ RTL تلقائياً)
                Expanded(
                  child: _buildContent(context, isLight),
                ),
                const SizedBox(width: AppSizes.spaceLG),
                // Sidebar تبويبات — يميناً (يطلع يساراً بـ RTL = للأعلى يميناً بالـ Stack)
                SizedBox(
                  width: 220,
                  child: _TabNav(
                    selectedIndex: selectedTab,
                    onTap: onTabChanged,
                    isLight: isLight,
                  ),
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
    final items = const [
      (Icons.lock_outline, 'الأمان'),
      (Icons.notifications_none, 'الإشعارات'),
      (Icons.tune, 'التفضيلات'),
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
          title: 'تغيير كلمة المرور',
          subtitle: 'يفضّل تغيير كلمة المرور كل 90 يوماً لزيادة الأمان',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PasswordField(
                label: 'كلمة المرور الحالية',
                controller: _currentPwd,
                isLight: widget.isLight,
              ),
              const SizedBox(height: AppSizes.spaceLG),
              LayoutBuilder(builder: (ctx, c) {
                final wide = c.maxWidth > 520;
                final f1 = _PasswordField(
                  label: 'كلمة المرور الجديدة',
                  controller: _newPwd,
                  isLight: widget.isLight,
                );
                final f2 = _PasswordField(
                  label: 'تأكيد كلمة المرور',
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
              Row(
                children: [
                  _PrimaryButton(
                    label: 'تحديث كلمة المرور',
                    icon: Icons.check_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(width: AppSizes.spaceSM),
                  _SecondaryButton(
                    label: 'إلغاء',
                    isLight: widget.isLight,
                    onTap: () {
                      _currentPwd.clear();
                      _newPwd.clear();
                      _confirmPwd.clear();
                    },
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
          title: 'المصادقة الثنائية',
          subtitle: 'حماية إضافية لحسابك عبر رمز OTP',
          child: Column(
            children: [
              _ToggleRow(
                title: 'طلب رمز OTP عند تسجيل الدخول',
                subtitle: 'يصلك رمز عبر البريد الإلكتروني في كل مرة تدخل من جهاز جديد',
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
          title: 'تسجيل الخروج من كل الأجهزة',
          subtitle: 'إنهاء جميع الجلسات النشطة على الأجهزة الأخرى',
          trailing: _SecondaryButton(
            label: 'تسجيل الخروج',
            isLight: widget.isLight,
            danger: true,
            onTap: () {},
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
          title: 'تفضيلات الإشعارات',
          subtitle: 'حدد أنواع الإشعارات التي تريد استقبالها',
          child: Column(children: [
            _ToggleRow(
              title: 'الطلبات العاجلة',
              subtitle: 'الطلبات اللي يجب إنهاؤها اليوم',
              value: _urgent,
              onChanged: (v) => setState(() => _urgent = v),
              isLight: widget.isLight,
            ),
            divider,
            _ToggleRow(
              title: 'طلبيات جديدة من الأطباء',
              subtitle: 'عند وصول طلبية جديدة',
              value: _newOrders,
              onChanged: (v) => setState(() => _newOrders = v),
              isLight: widget.isLight,
            ),
            divider,
            _ToggleRow(
              title: 'نقص المواد',
              subtitle: 'عند وصول مادة للحد الأدنى',
              value: _lowStock,
              onChanged: (v) => setState(() => _lowStock = v),
              isLight: widget.isLight,
            ),
            divider,
            _ToggleRow(
              title: 'تحديثات المستودع',
              subtitle: 'حالة طلبات التوريد المرسلة',
              value: _warehouse,
              onChanged: (v) => setState(() => _warehouse = v),
              isLight: widget.isLight,
            ),
            divider,
            _ToggleRow(
              title: 'تحديثات الفريق',
              subtitle: 'إضافة أو تغيير دوام مخبري',
              value: _team,
              onChanged: (v) => setState(() => _team = v),
              isLight: widget.isLight,
            ),
          ]),
        ),

        const SizedBox(height: AppSizes.spaceLG),

        _SettingCard(
          isLight: widget.isLight,
          title: 'قنوات الإشعار',
          subtitle: 'اختر أين تصلك التنبيهات',
          child: Column(children: [
            _ToggleRow(
              title: 'ملخص يومي عبر البريد الإلكتروني',
              subtitle: 'يصلك في الساعة 8:00 صباحاً كل يوم',
              value: _emailSummary,
              onChanged: (v) => setState(() => _emailSummary = v),
              isLight: widget.isLight,
            ),
            divider,
            _ToggleRow(
              title: 'صوت الإشعارات داخل النظام',
              subtitle: 'تشغيل نغمة عند وصول إشعار جديد',
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
  int _themeIndex = 0; // 0=auto 1=dark 2=light
  int _langIndex = 1;  // 0=English 1=العربية
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
          title: 'السمة',
          subtitle: 'اختر مظهر النظام',
          child: LayoutBuilder(builder: (ctx, c) {
            final wide = c.maxWidth > 520;
            final options = [
              _ThemePreviewData(label: 'تلقائي', mode: _ThemeMode.auto),
              _ThemePreviewData(label: 'داكن', mode: _ThemeMode.dark),
              _ThemePreviewData(label: 'فاتح', mode: _ThemeMode.light),
            ];
            final widgets = [
              for (int i = 0; i < options.length; i++)
                _ThemeOption(
                  data: options[i],
                  selected: _themeIndex == i,
                  onTap: () => setState(() => _themeIndex = i),
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
          title: 'اللغة',
          subtitle: 'لغة عرض النظام',
          child: LayoutBuilder(builder: (ctx, c) {
            final wide = c.maxWidth > 520;
            final widgets = [
              _LanguageOption(
                title: 'English',
                badge: 'EN',
                hint: 'LTR',
                selected: _langIndex == 0,
                onTap: () => setState(() => _langIndex = 0),
                isLight: widget.isLight,
              ),
              _LanguageOption(
                title: 'العربية',
                badge: 'ع',
                hint: 'RTL · الافتراضي',
                selected: _langIndex == 1,
                onTap: () => setState(() => _langIndex = 1),
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
          title: 'العرض والأداء',
          subtitle: null,
          child: Column(children: [
            _ToggleRow(
              title: 'العرض المضغوط',
              subtitle: 'إظهار مزيد من البيانات في الشاشة الواحدة',
              value: _compact,
              onChanged: (v) => setState(() => _compact = v),
              isLight: widget.isLight,
            ),
            divider,
            _ToggleRow(
              title: 'الحفظ التلقائي',
              subtitle: 'حفظ التعديلات تلقائياً كل دقيقة',
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
//  REUSABLE — THEME OPTION
// ══════════════════════════════════════════════════════════════════════════

enum _ThemeMode { auto, dark, light }

class _ThemePreviewData {
  const _ThemePreviewData({required this.label, required this.mode});
  final String label;
  final _ThemeMode mode;
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _ThemePreviewData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(AppSizes.spaceSM),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.lightBorder,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              // Preview swatch
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    child: SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: _buildPreview(data.mode),
                    ),
                  ),
                  if (selected)
                    PositionedDirectional(
                      top: 6,
                      end: 6,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                data.label,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightText1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(_ThemeMode mode) {
    switch (mode) {
      case _ThemeMode.auto:
        // نصف فاتح / نصف داكن
        return Row(
          children: [
            Expanded(
              child: Container(color: const Color(0xFFE9ECFB)),
            ),
            Expanded(
              child: Container(color: AppColors.primary),
            ),
            Expanded(
              child: Container(color: const Color(0xFFE9ECFB)),
            ),
          ],
        );
      case _ThemeMode.dark:
        return Row(
          children: [
            Expanded(child: Container(color: AppColors.primary)),
            Expanded(child: Container(color: const Color(0xFF2A2D6E))),
          ],
        );
      case _ThemeMode.light:
        return Row(
          children: [
            Expanded(child: Container(color: const Color(0xFFE9ECFB))),
            Expanded(child: Container(color: const Color(0xFFF8F9FF))),
          ],
        );
    }
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
