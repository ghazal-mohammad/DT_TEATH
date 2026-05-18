// ════════════════════════════════════════════════════════════════════════════
// coming_soon_content.dart
//
// محتوى placeholder لصفحات قيد البناء — يُستخدم في Phase 4.1 كـ skeleton
// لكل صفحات Warehouse قبل بنائها فعلياً في Phases 4.2–4.7.
//
// 🎯 الهدف:
//   نضيف الـ routing و الـ Sidebar navigation أولاً، ثم نبني المحتوى الفعلي
//   صفحة بصفحة. هذا الـ widget يضمن أن المستخدم يقدر يتنقل بين الصفحات
//   ويرى أنها موجودة، حتى لو محتواها لسه ما اكتمل.
//
// التصميم:
//   - أيقونة كبيرة بلون النظام الحالي (من AppSystemType)
//   - عنوان "قريباً"
//   - نص توضيحي
//   - شارة "Phase 4.X" تبيّن متى ستكتمل الصفحة (اختياري)
//
// مثال:
//   ComingSoonContent(
//     icon: AppIcons.materials,
//     title: context.l10n.whMaterialsTitle,
//     phaseLabel: 'Phase 4.3',
//     accentColor: AppSystemType.warehouse.primaryColor,
//   )
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/l10n/build_context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';

/// محتوى placeholder لصفحة قيد البناء.
class ComingSoonContent extends StatelessWidget {
  const ComingSoonContent({
    super.key,
    required this.icon,
    required this.title,
    required this.accentColor,
    this.phaseLabel,
  });

  /// أيقونة الصفحة الكبيرة (من AppIcons).
  final IconData icon;

  /// عنوان الصفحة (من l10n).
  final String title;

  /// لون أكسنت الصفحة (عادة لون النظام).
  final Color accentColor;

  /// تسمية الـ phase اللي رح تكتمل فيها الصفحة (اختياري).
  /// مثال: "Phase 4.3"
  final String? phaseLabel;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.space3XL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── أيقونة كبيرة دائرية ───────────────────────────────────
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.18),
                      accentColor.withValues(alpha: 0.04),
                    ],
                  ),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.32),
                    width: AppSizes.borderMedium,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.12),
                      blurRadius: 32,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 56,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: AppSizes.space2XL),

              // ── عنوان الصفحة ───────────────────────────────────────────
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: AppSizes.font24,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spaceSM),

              // ── شارة "قريباً" ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spaceLG,
                  vertical: AppSizes.spaceSM,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.10),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.24),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  context.l10n.comingSoonTitle,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: AppSizes.fontMD,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: accentColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceLG),

              // ── نص توضيحي ─────────────────────────────────────────────
              Text(
                context.l10n.comingSoonSubtitle,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: AppSizes.fontMD,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                  color: isLight ? AppColors.lightText3 : AppColors.darkText3,
                ),
                textAlign: TextAlign.center,
              ),

              // ── علامة الـ Phase (اختياري) ─────────────────────────────
              if (phaseLabel != null) ...[
                const SizedBox(height: AppSizes.space2XL),
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSizes.spaceMD,
                    vertical: AppSizes.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    // نستخدم خلفية مستقلة بدل ملون من البوردر (تجنّب
                    // double-alpha في الألوان اللي أصلاً عندها alpha).
                    color: accentColor.withValues(alpha: 0.06),
                    border: Border.all(
                      color: isLight
                          ? AppColors.lightBorder
                          : AppColors.darkBorder,
                      width: AppSizes.borderThin,
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  ),
                  child: Text(
                    phaseLabel!,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: AppSizes.fontSM,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: isLight
                          ? AppColors.lightText4
                          : AppColors.darkText4,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
