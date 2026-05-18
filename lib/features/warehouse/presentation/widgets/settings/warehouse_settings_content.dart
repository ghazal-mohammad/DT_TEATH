// ════════════════════════════════════════════════════════════════════════════
// warehouse_settings_content.dart
//
// المحتوى الكامل لصفحة الإعدادات — Phase 4.8 مكتملة.
//
// 🎯 الهدف:
//   - 4 tabs: الملف الشخصي / الإشعارات / الأمان / عن التطبيق
//   - Tab الملف الشخصي: avatar + اسم + بريد + حفظ
//   - Tab الإشعارات: toggles لكل نوع تنبيه
//   - Tab الأمان: تغيير كلمة المرور
//   - Tab عن التطبيق: معلومات النظام
//
// المرجع: DT_Teeth_Warehouse_v6_Enhanced.html — pg-set
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';

// ══════════════════════════════════════════════════════════════════════════
//                          MAIN CONTENT
// ══════════════════════════════════════════════════════════════════════════

class WarehouseSettingsContent extends StatefulWidget {
  const WarehouseSettingsContent({super.key});

  @override
  State<WarehouseSettingsContent> createState() =>
      _WarehouseSettingsContentState();
}

class _WarehouseSettingsContentState extends State<WarehouseSettingsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Tab Bar ──────────────────────────────────────────────────
        _buildTabBar(context, isLight),
        const SizedBox(height: 24),

        // ── Tab Content ──────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _ProfileTab(isLight: isLight),
              _NotificationsTab(isLight: isLight),
              _SecurityTab(isLight: isLight),
              _AboutTab(isLight: isLight),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context, bool isLight) {
    final borderColor = isLight ? AppColors.lightBorder : AppColors.darkBorder;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        color: isLight ? AppColors.baseComponent : AppColors.darkSurface,
      ),
      child: TabBar(
        controller: _tabController,
        labelStyle: const TextStyle(
            fontFamily: AppTextStyles.fontFamily, fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
            fontFamily: AppTextStyles.fontFamily, fontSize: 13, fontWeight: FontWeight.w500),
        labelColor:
            isLight ? AppColors.lightText1 : AppColors.darkText1,
        unselectedLabelColor:
            isLight ? AppColors.lightText3 : AppColors.darkText3,
        indicator: BoxDecoration(
          color: isLight
              ? const Color(0x1ABED8FA)
              : const Color(0x1A9EFBEC),
          borderRadius: BorderRadius.circular(AppSizes.radiusMD - 2),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: context.l10n.whSettingsTabProfile),
          Tab(text: context.l10n.whSettingsTabNotifications),
          Tab(text: context.l10n.whSettingsTabSecurity),
          Tab(text: context.l10n.whSettingsTabAbout),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  TAB 1 — الملف الشخصي
// ════════════════════════════════════════════════════════════════════════════

class _ProfileTab extends StatefulWidget {
  const _ProfileTab({required this.isLight});

  final bool isLight;

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  final _firstName = TextEditingController(text: 'أحمد');
  final _lastName = TextEditingController(text: 'محمود');
  final _email = TextEditingController(text: 'admin@dtteeth.com');

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        return Container(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAvatarSection(context),
              const SizedBox(height: 24),
              _buildFormCard(context, isWide),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    return _SettingsCard(
      isLight: widget.isLight,
      child: Row(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.warehouseSystem, AppColors.primary],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.warehouseSystem.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Center(
              child: Text(
                'أ',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),

          // معلومات
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أحمد محمود',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: widget.isLight
                        ? AppColors.lightText1
                        : AppColors.darkText1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.roleWarehouseManager,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    color: AppColors.warehouseSystem,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'WH-001 · DT.Teeth',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    color: widget.isLight
                        ? AppColors.lightText4
                        : AppColors.darkText4,
                  ),
                ),
              ],
            ),
          ),

          // زر تغيير الصورة
          AppButton(
            label: 'تغيير الصورة',
            onPressed: () {},
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, bool isWide) {
    return _SettingsCard(
      isLight: widget.isLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isWide)
            Row(
              children: [
                Expanded(
                  child: AppFormField(
                    label: context.l10n.whSettingsFirstName,
                    controller: _firstName,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: AppFormField(
                    label: context.l10n.whSettingsLastName,
                    controller: _lastName,
                  ),
                ),
              ],
            )
          else ...[
            AppFormField(
                label: context.l10n.whSettingsFirstName,
                controller: _firstName),
            const SizedBox(height: 14),
            AppFormField(
                label: context.l10n.whSettingsLastName,
                controller: _lastName),
          ],
          const SizedBox(height: 14),
          AppFormField(
            label: context.l10n.whSettingsEmail,
            controller: _email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: AppButton(
              label: context.l10n.whSettingsSaveChanges,
              onPressed: () {},
              variant: AppButtonVariant.primary,
              size: AppButtonSize.small,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  TAB 2 — الإشعارات
// ════════════════════════════════════════════════════════════════════════════

class _NotificationsTab extends StatefulWidget {
  const _NotificationsTab({required this.isLight});

  final bool isLight;

  @override
  State<_NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<_NotificationsTab> {
  bool _lowStock = true;
  bool _expiry = true;
  bool _orders = true;
  bool _weekly = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 540),
      child: _SettingsCard(
        isLight: widget.isLight,
        child: Column(
          children: [
            _NotifToggle(
              isLight: widget.isLight,
              label: context.l10n.whSettingsNotifLowStock,
              description: context.l10n.whSettingsNotifLowStockDesc,
              icon: Icons.inventory_2_outlined,
              color: AppColors.dashPink,
              value: _lowStock,
              onChanged: (v) => setState(() => _lowStock = v),
            ),
            _buildDivider(),
            _NotifToggle(
              isLight: widget.isLight,
              label: context.l10n.whSettingsNotifExpiry,
              description: context.l10n.whSettingsNotifExpiryDesc,
              icon: Icons.timer_outlined,
              color: AppColors.dashAmber,
              value: _expiry,
              onChanged: (v) => setState(() => _expiry = v),
            ),
            _buildDivider(),
            _NotifToggle(
              isLight: widget.isLight,
              label: context.l10n.whSettingsNotifOrders,
              description: context.l10n.whSettingsNotifOrdersDesc,
              icon: Icons.shopping_bag_outlined,
              color: AppColors.dashCyan,
              value: _orders,
              onChanged: (v) => setState(() => _orders = v),
            ),
            _buildDivider(),
            _NotifToggle(
              isLight: widget.isLight,
              label: context.l10n.whSettingsNotifWeekly,
              description: context.l10n.whSettingsNotifWeeklyDesc,
              icon: Icons.bar_chart_outlined,
              color: AppColors.warehouseSystem,
              value: _weekly,
              onChanged: (v) => setState(() => _weekly = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: widget.isLight ? AppColors.lightBorder : AppColors.darkBorder,
    );
  }
}

class _NotifToggle extends StatelessWidget {
  const _NotifToggle({
    required this.isLight,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  final bool isLight;
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
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
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    color: isLight ? AppColors.lightText3 : AppColors.darkText3,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.warehouseSystem,
            activeTrackColor:
                AppColors.warehouseSystem.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  TAB 3 — الأمان
// ════════════════════════════════════════════════════════════════════════════

class _SecurityTab extends StatefulWidget {
  const _SecurityTab({required this.isLight});

  final bool isLight;

  @override
  State<_SecurityTab> createState() => _SecurityTabState();
}

class _SecurityTabState extends State<_SecurityTab> {
  final _currentPass = TextEditingController();
  final _newPass = TextEditingController();
  final _confirmPass = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPass.dispose();
    _newPass.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 460),
      child: _SettingsCard(
        isLight: widget.isLight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppFormField(
              label: context.l10n.whSettingsCurrentPassword,
              controller: _currentPass,
              obscureText: _obscureCurrent,
              suffixIcon: _toggleIcon(
                  _obscureCurrent, () => setState(() => _obscureCurrent = !_obscureCurrent)),
            ),
            const SizedBox(height: 14),
            AppFormField(
              label: context.l10n.whSettingsNewPassword,
              controller: _newPass,
              obscureText: _obscureNew,
              suffixIcon: _toggleIcon(
                  _obscureNew, () => setState(() => _obscureNew = !_obscureNew)),
            ),
            const SizedBox(height: 14),
            AppFormField(
              label: context.l10n.whSettingsConfirmPassword,
              controller: _confirmPass,
              obscureText: _obscureConfirm,
              suffixIcon: _toggleIcon(
                  _obscureConfirm,
                  () => setState(
                      () => _obscureConfirm = !_obscureConfirm)),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: context.l10n.whSettingsUpdatePassword,
              onPressed: () {},
              variant: AppButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleIcon(bool obscure, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 18,
        color: widget.isLight ? AppColors.lightText3 : AppColors.darkText3,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  TAB 4 — عن التطبيق
// ════════════════════════════════════════════════════════════════════════════

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.isLight});

  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 540),
      child: _SettingsCard(
        isLight: isLight,
        child: Column(
          children: [
            // لوغو
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF2A2E6A)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'DT',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              context.l10n.whSettingsAboutTitle,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isLight ? AppColors.lightText1 : AppColors.darkText1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.whSettingsAboutVersion,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                color: isLight ? AppColors.lightText3 : AppColors.darkText3,
              ),
            ),

            const SizedBox(height: 24),

            // معلومات
            _aboutRow(
                context, 'النظام', 'نظام إدارة المستودع', isLight),
            _divider(),
            _aboutRow(context, 'الإطار', 'Flutter Web 3.x', isLight),
            _divider(),
            _aboutRow(context, 'المعمارية', 'Clean Architecture + BLoC', isLight),
            _divider(),
            _aboutRow(context, 'الباك اند', 'Laravel (قيد التطوير)', isLight),
          ],
        ),
      ),
    );
  }

  Widget _aboutRow(
      BuildContext context, String label, String value, bool isLight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                color: isLight ? AppColors.lightText3 : AppColors.darkText3,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isLight ? AppColors.lightText1 : AppColors.darkText1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  SETTINGS CARD — بطاقة موحّدة للإعدادات
// ════════════════════════════════════════════════════════════════════════════

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
