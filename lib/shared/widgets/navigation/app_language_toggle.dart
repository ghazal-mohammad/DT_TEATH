// ════════════════════════════════════════════════════════════════════════════
// app_language_toggle.dart
//
// زر تبديل لغة التطبيق (عربي ↔ إنجليزي).
// يُعرض عادةً في:
//   - أعلى واجهة Email Entry (أول واجهة يراها المستخدم — Phase 3.3)
//   - شريط الإعدادات
//   - التوب بار (اختيارياً)
//
// التصميم:
//   - زر مضغوط يعرض رمز اللغة الحالية (AR / EN)
//   - hover state مع scale خفيف + glow
//   - عند الضغط: تبدّل فوري + انيميشن خفيف
//   - يدعم Light/Dark تلقائياً
//
// API:
//   AppLanguageToggle()                 → زر بالحجم الافتراضي
//   AppLanguageToggle(variant: .pill)   → شكل pill
//   AppLanguageToggle(variant: .icon)   → مربع مع أيقونة
//
// المرجع:
//   - Material 3 Toggle: https://m3.material.io/components/buttons
//   - BlocBuilder: https://bloclibrary.dev/flutter-bloc-concepts/#blocbuilder
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/build_context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../bloc/locale_cubit.dart';

/// أنواع تصميم زر تبديل اللغة.
enum AppLanguageToggleVariant {
  /// مربع مضغوط 36×36 مع حرفين (AR/EN). للتوب بار.
  compact,

  /// شكل pill مستطيل مع اسم اللغة الكامل. للإعدادات.
  pill,

  /// أيقونة كرة أرضية مع tooltip.
  icon,
}

/// زر تبديل لغة التطبيق.
///
/// يعرض اللغة الحالية ويسمح بالتبديل بنقرة واحدة.
/// يستخدم [LocaleCubit] المسجّل في الـ DI/BlocProvider.
///
/// مثال الاستخدام:
/// ```dart
/// // في التوب بار
/// AppLanguageToggle()
///
/// // في صفحة Email Entry — شكل مستطيل أوضح
/// AppLanguageToggle(variant: AppLanguageToggleVariant.pill)
/// ```
class AppLanguageToggle extends StatefulWidget {
  const AppLanguageToggle({
    super.key,
    this.variant = AppLanguageToggleVariant.compact,
    this.onChanged,
  });

  /// نوع التصميم.
  final AppLanguageToggleVariant variant;

  /// callback اختياري يُستدعى بعد التبديل — للـ analytics أو effects.
  final ValueChanged<Locale>? onChanged;

  @override
  State<AppLanguageToggle> createState() => _AppLanguageToggleState();
}

class _AppLanguageToggleState extends State<AppLanguageToggle> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        final bool isArabic = locale.languageCode == 'ar';

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: () async {
              await context.read<LocaleCubit>().toggle();
              if (widget.onChanged != null && context.mounted) {
                widget.onChanged!(context.read<LocaleCubit>().state);
              }
            },
            child: _buildVariant(context, isArabic),
          ),
        );
      },
    );
  }

  Widget _buildVariant(BuildContext context, bool isArabic) {
    switch (widget.variant) {
      case AppLanguageToggleVariant.compact:
        return _buildCompact(context, isArabic);
      case AppLanguageToggleVariant.pill:
        return _buildPill(context, isArabic);
      case AppLanguageToggleVariant.icon:
        return _buildIcon(context, isArabic);
    }
  }

  // ────────────────────────────────────────────────────────────────────
  //                      VARIANT BUILDERS
  // ────────────────────────────────────────────────────────────────────

  /// Compact: مربع 36×36 مع "AR" أو "EN".
  Widget _buildCompact(BuildContext context, bool isArabic) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final String label = isArabic ? 'EN' : 'AR'; // يعرض اللغة التي سيتبدّل إليها
    // يعرض اللغة "القادمة" ليفهم المستخدم إنه الضغط سيحولها.

    final Color hot = isLight ? AppColors.primary : AppColors.brand;
    final Color bgColor = _isHovered
        ? hot.withValues(alpha: 0.14)
        : hot.withValues(alpha: isLight ? 0.12 : 0.06);

    final Color borderColor = _isHovered
        ? hot
        : (isLight ? AppColors.lightBorder : AppColors.darkBorder);

    final Color textColor = _isHovered
        ? (isLight ? AppColors.primary : hot)
        : (isLight ? AppColors.lightText2 : AppColors.darkText2);

    return Tooltip(
      message: isArabic ? 'Switch to English' : 'التبديل إلى العربية',
      child: AnimatedContainer(
        duration: AppSizes.animationMedium,
        curve: Curves.easeOut,
        width: 36,
        height: 36,
        transform: _isHovered
            ? (Matrix4.identity()..scale(1.06))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              // font ثابت Latin لأنه رموز لغة — ما يتأثر بالـ locale
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1,
              letterSpacing: 0.5,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  /// Pill: شكل مستطيل مع اسم اللغة الكامل.
  Widget _buildPill(BuildContext context, bool isArabic) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    // نعرض اسم اللغة الحالية (ما يقلبها المستخدم)
    // مع أيقونة صغيرة للإشارة للتبديل.
    final String currentLanguage = isArabic
        ? context.l10n.languageArabic
        : context.l10n.languageEnglish;

    final Color bgColor = _isHovered
        ? AppColors.accent.withValues(alpha: 0.12)
        : (isLight
            ? AppColors.lightSurface
            : AppColors.darkSurface);

    final Color borderColor = _isHovered
        ? AppColors.accent
        : (isLight ? AppColors.lightBorder : AppColors.darkBorder);

    final Color textColor =
        isLight ? AppColors.lightText1 : AppColors.darkText1;

    return AnimatedContainer(
      duration: AppSizes.animationMedium,
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.language_rounded,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            currentLanguage,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Icon: زر دائري مع أيقونة globe فقط.
  Widget _buildIcon(BuildContext context, bool isArabic) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final Color hot = isLight ? AppColors.primary : AppColors.brand;
    final Color bgColor = _isHovered
        ? hot.withValues(alpha: 0.14)
        : hot.withValues(alpha: isLight ? 0.12 : 0.06);

    final Color borderColor = _isHovered
        ? hot
        : (isLight ? AppColors.lightBorder : AppColors.darkBorder);

    final Color iconColor = _isHovered
        ? (isLight ? AppColors.primary : hot)
        : (isLight ? AppColors.lightText2 : AppColors.darkText2);

    return Tooltip(
      message: isArabic ? 'English' : 'العربية',
      child: AnimatedContainer(
        duration: AppSizes.animationMedium,
        curve: Curves.easeOut,
        width: 36,
        height: 36,
        transform: _isHovered
            ? (Matrix4.identity()..scale(1.06))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        child: Icon(
          Icons.language_rounded,
          size: 18,
          color: iconColor,
        ),
      ),
    );
  }
}
