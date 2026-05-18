// ════════════════════════════════════════════════════════════════════════════
// mock_dashboard_page.dart
//
// صفحات Dashboard مؤقّتة لاختبار الـ navigation flow.
// سيتم استبدالها بالـ Dashboards الفعلية في Feature 4 و Feature 5.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../shared/bloc/locale_cubit.dart';
import '../../shared/bloc/mock_system_cubit.dart';
import '../../shared/bloc/theme_cubit.dart';
import '../../shared/widgets/brand/app_logo.dart';

/// صفحة Dashboard مؤقّتة (Lab أو Warehouse).
class MockDashboardPage extends StatelessWidget {
  const MockDashboardPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  /// Lab dashboard preset.
  factory MockDashboardPage.lab() {
    return const MockDashboardPage(
      title: 'لوحة المخبر',
      subtitle: 'مرحباً بك في نظام المخبر',
      color: AppColors.labSystem,
      icon: Icons.science_outlined,
    );
  }

  /// Warehouse dashboard preset.
  factory MockDashboardPage.warehouse() {
    return const MockDashboardPage(
      title: 'لوحة المستودع',
      subtitle: 'مرحباً بك في نظام المستودع',
      color: AppColors.warehouseSystem,
      icon: Icons.inventory_2_outlined,
    );
  }

  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight ? AppColors.lightBg : AppColors.darkBg,
      body: SafeArea(
        child: Stack(
          children: [
            // ── خلفية decorative ──
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 1.5,
                    colors: [
                      color.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── المحتوى المركزي ──
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── أيقونة كبيرة ──
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withValues(alpha: 0.2),
                              color.withValues(alpha: 0.05),
                            ],
                          ),
                          border: Border.all(
                            color: color.withValues(alpha: 0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.2),
                              blurRadius: 30,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(icon, size: 56, color: color),
                      ),

                      const SizedBox(height: 32),

                      // ── الـ Logo + Brand ──
                      const AppLogo(size: 48, variant: AppLogoVariant.auto),

                      const SizedBox(height: 24),

                      // ── العنوان ──
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [color, AppColors.secondary],
                        ).createShader(bounds),
                        blendMode: BlendMode.srcIn,
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          color: isLight
                              ? AppColors.lightText3
                              : AppColors.darkText3,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ── Status pill ──
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          border: Border.all(
                            color: color.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.6),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '✅ تم تسجيل الدخول بنجاح',
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Info banner ──
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.05),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.2),
                          ),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusLG,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.construction_rounded,
                              size: 32,
                              color: AppColors.accent,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'هذه صفحة مؤقّتة لاختبار الـ Navigation',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isLight
                                    ? AppColors.lightText1
                                    : AppColors.darkText1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'الـ Dashboard الفعلي سيُبنى في Feature 4-5',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                                color: isLight
                                    ? AppColors.lightText3
                                    : AppColors.darkText3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── أزرار للتنقّل ──
                      // كل ضغطة تحدّث MockSystemCubit ليعكس الاختيار الجديد،
                      // فيبقى الـ state متناغم مع الشاشة المعروضة.
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          _NavChip(
                            label: 'تغيير النظام',
                            icon: Icons.swap_horiz_rounded,
                            onTap: () =>
                                context.go(RouteNames.systemSelection),
                          ),
                          _NavChip(
                            label: 'تجربة المستودع',
                            icon: Icons.inventory_2_outlined,
                            onTap: () async {
                              await context
                                  .read<MockSystemCubit>()
                                  .selectSystem(SystemRole.warehouse);
                              if (!context.mounted) return;
                              context.go(RouteNames.warehouseDashboard);
                            },
                          ),
                          _NavChip(
                            label: 'تجربة المخبر',
                            icon: Icons.science_outlined,
                            onTap: () async {
                              await context
                                  .read<MockSystemCubit>()
                                  .selectSystem(SystemRole.lab);
                              if (!context.mounted) return;
                              context.go(RouteNames.labDashboard);
                            },
                          ),
                          _NavChip(
                            label: 'العودة للبداية',
                            icon: Icons.refresh_rounded,
                            onTap: () => context.go(RouteNames.splash),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Toggles top right ──
            const PositionedDirectional(
              top: 16,
              end: 16,
              child: _TopToggles(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavChip extends StatefulWidget {
  const _NavChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_NavChip> createState() => _NavChipState();
}

class _NavChipState extends State<_NavChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.accent.withValues(alpha: 0.15)
                : (isLight
                    ? AppColors.lightSurface
                    : AppColors.darkSurface),
            border: Border.all(
              color: _isHovered
                  ? AppColors.accent
                  : (isLight
                      ? AppColors.lightBorder
                      : AppColors.darkBorder),
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 14,
                color: _isHovered
                    ? AppColors.accent
                    : (isLight
                        ? AppColors.lightText2
                        : AppColors.darkText2),
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _isHovered
                      ? AppColors.accent
                      : (isLight
                          ? AppColors.lightText2
                          : AppColors.darkText2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopToggles extends StatelessWidget {
  const _TopToggles();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final bool isLight = !isDark;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lang toggle
            GestureDetector(
              onTap: () => context.read<LocaleCubit>().toggle(),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(
                      alpha: isLight ? 0.12 : 0.06,
                    ),
                    border: Border.all(
                      color: isLight
                          ? AppColors.lightBorder
                          : AppColors.darkBorder,
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                  child: Center(
                    child: BlocBuilder<LocaleCubit, Locale>(
                      builder: (context, locale) {
                        return Text(
                          locale.languageCode == 'ar' ? 'EN' : 'AR',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isLight
                                ? AppColors.lightText2
                                : AppColors.darkText2,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Theme toggle
            GestureDetector(
              onTap: () => context.read<ThemeCubit>().toggle(),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(
                      alpha: isLight ? 0.12 : 0.06,
                    ),
                    border: Border.all(
                      color: isLight
                          ? AppColors.lightBorder
                          : AppColors.darkBorder,
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                  child: Icon(
                    isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    size: 18,
                    color: isLight
                        ? AppColors.lightText2
                        : AppColors.darkText2,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
