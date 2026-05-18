// ════════════════════════════════════════════════════════════════════════════
// lab_profile_page.dart  — Phase 5.x ✅
//
// صفحة الملف الشخصي لمدير/مخبري المخبر.
//
// الهيكل:
//   - بطاقة المعلومات الشخصية (الاسم / الدور / الإيميل / الانضمام)
//   - إحصائيات الأداء (طلبات منجزة / نسبة الإنجاز / تقييم الرضا)
//   - زر تغيير كلمة المرور
//
// المرجع: DT_Teeth_Lab_v12_Enhanced.html
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
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

class LabProfilePage extends StatelessWidget {
  const LabProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShellLayout(
      system: AppSystemType.lab,
      currentRoute: RouteNames.labProfile,
      sections: LabSidebarSections.build(context),
      pageTitle: context.l10n.labProfile,
      pageSubtitle: context.l10n.labTopbarSubtitle,
      userName: MockUserData.labUserName,
      userRole: context.l10n.roleLabManager,
      body: const _LabProfileBody(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  BODY
// ══════════════════════════════════════════════════════════════════════════

class _LabProfileBody extends StatelessWidget {
  const _LabProfileBody();

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Profile Card ──────────────────────────────────────
              _ProfileCard(isLight: isLight),
              const SizedBox(height: AppSizes.spaceLG),

              // ── Stats Row ─────────────────────────────────────────
              _StatsRow(isLight: isLight),
              const SizedBox(height: AppSizes.spaceLG),

              // ── Security Section ──────────────────────────────────
              _SecuritySection(isLight: isLight),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  PROFILE CARD
// ══════════════════════════════════════════════════════════════════════════

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.isLight});
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceXL),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withValues(alpha: 0.8),
                  AppColors.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'أ',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spaceLG),

          // Name
          Text(
            MockUserData.labUserName,
            style: AppTextStyles.displaySmall,
          ),
          const SizedBox(height: AppSizes.spaceXS),

          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
            ),
            child: Text(
              context.l10n.roleLabManager,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spaceLG),

          // Info fields
          _InfoRow(
            isLight: isLight,
            icon: AppIcons.email,
            label: 'البريد الإلكتروني',
            value: 'ahmed@dtteeth.com',
          ),
          const SizedBox(height: AppSizes.spaceMD),
          _InfoRow(
            isLight: isLight,
            icon: AppIcons.phone,
            label: 'رقم الهاتف',
            value: '+963 912 345 678',
          ),
          const SizedBox(height: AppSizes.spaceMD),
          _InfoRow(
            isLight: isLight,
            icon: AppIcons.calendar,
            label: 'تاريخ الانضمام',
            value: 'يناير 2024',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.isLight,
    required this.icon,
    required this.label,
    required this.value,
  });
  final bool isLight;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isLight ? AppColors.lightBgAlt : AppColors.darkBgAlt,
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            border: Border.all(
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isLight ? AppColors.lightText3 : AppColors.darkText3,
          ),
        ),
        const SizedBox(width: AppSizes.spaceMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isLight ? AppColors.lightText4 : AppColors.darkText4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  STATS ROW
// ══════════════════════════════════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.isLight});
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(isLight: isLight, value: '286', label: 'طلبات منجزة', icon: AppIcons.check, color: AppColors.success)),
        const SizedBox(width: AppSizes.spaceMD),
        Expanded(child: _StatCard(isLight: isLight, value: '96%', label: 'نسبة الإنجاز', icon: AppIcons.chart, color: AppColors.accent)),
        const SizedBox(width: AppSizes.spaceMD),
        Expanded(child: _StatCard(isLight: isLight, value: '4.8★', label: 'تقييم الأطباء', icon: AppIcons.star, color: AppColors.warning)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.isLight,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
  final bool isLight;
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSizes.spaceSM),
          Text(value, style: TextStyle(fontFamily: AppTextStyles.fontFamily, fontSize: 22, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  SECURITY SECTION
// ══════════════════════════════════════════════════════════════════════════

class _SecuritySection extends StatelessWidget {
  const _SecuritySection({required this.isLight});
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🔒 الأمان', style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppSizes.spaceLG),
          const Divider(height: 1),
          const SizedBox(height: AppSizes.spaceLG),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('كلمة المرور', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('آخر تغيير: منذ 3 أشهر', style: AppTextStyles.bodySmall.copyWith(color: isLight ? AppColors.lightText4 : AppColors.darkText4)),
                ],
              ),
              AppButton.secondary(
                label: 'تغيير كلمة المرور',
                icon: AppIcons.lock,
                onPressed: () {},
                size: AppButtonSize.small,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
