// ════════════════════════════════════════════════════════════════════════════
// materializing_text.dart
//
// Phase 4 من الـ Splash: "Brand Materialization" (Simplified Approach).
//
// النص "DT.Teeth" يظهر كنص واحد (whole-word animation):
//   - fade-in تدريجي
//   - scale من 0.6 → 1.0 مع elasticOut bounce خفيف
//   - slide من تحت لفوق (vertical offset)
//   - gradient shader (cyan → magenta)
//
// ثم الـ subtitle يكتب نفسه typewriter style.
//
// ⚠️ ملاحظة هندسية مهمة:
//   كان فيه نسخة سابقة بـ per-character animation (8 widgets منفصلة).
//   تم استبدالها بنص واحد لأن:
//   1. Per-character في سياق RTL (locale عربي) كان يسبب ترتيب معكوس
//      رغم استخدام Directionality.ltr — بسبب inheritance معقّد.
//   2. النص الواحد يضمن سلوك ترميز محدد ومُختبر.
//   3. أنعم بصرياً وأخف على الـ rendering.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/theme/app_colors.dart';

/// النص الرئيسي اللي يظهر بـ animation موحّدة (fade + scale + slide).
class MaterializingText extends StatelessWidget {
  const MaterializingText({
    super.key,
    required this.progress,
  });

  /// تقدّم الـ animation من 0.0 إلى 1.0.
  final double progress;

  /// النص الرئيسي (constant).
  static const String _brandName = 'DT.Teeth';

  @override
  Widget build(BuildContext context) {
    if (progress <= 0) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ═════════════════════════════════════════════════════════════
        //                BRAND NAME (whole-word animation)
        // ═════════════════════════════════════════════════════════════
        _buildAnimatedBrandName(),

        const SizedBox(height: 16),

        // ═════════════════════════════════════════════════════════════
        //                SUBTITLE (typewriter effect)
        // ═════════════════════════════════════════════════════════════
        _buildAnimatedSubtitle(context),
      ],
    );
  }

  /// النص الرئيسي مع animation موحّدة (fade + scale + slide).
  Widget _buildAnimatedBrandName() {
    // الـ name animation تأخذ من 0.0 إلى 0.65 من الـ progress
    final double nameProgress = (progress / 0.65).clamp(0.0, 1.0);

    // ─── الحركات الموحّدة على النص ───
    // Scale: 0.6 → 1.0 (elasticOut للـ bounce الخفيف)
    final double scaleValue =
        0.6 + Curves.elasticOut.transform(nameProgress) * 0.4;

    // Vertical offset: -30 → 0 (easeOutCubic للـ landing الأنيق)
    final double verticalOffset =
        (1.0 - Curves.easeOutCubic.transform(nameProgress)) * -30;

    // Opacity: 0 → 1 (easeOut)
    final double opacity = Curves.easeOut.transform(nameProgress);

    // ⚠️ Directionality.ltr صريحة لضمان عرض النص بترتيبه الصحيح
    // حتى ضمن سياق RTL (locale عربي).
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Transform.translate(
        offset: Offset(0, verticalOffset),
        child: Transform.scale(
          scale: scaleValue.clamp(0.0, 1.2),
          child: Opacity(
            opacity: opacity,
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accent, // #9EFBEC
                    AppColors.secondary, // #ED8BFA
                  ],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: const Text(
                _brandName,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  letterSpacing: -1.5,
                  // اللون أبيض ليأخذ الـ gradient shader.
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// الـ subtitle بـ typewriter effect.
  ///
  /// يحترم لغة المستخدم (RTL للعربية، LTR للإنجليزية) عبر فحص الـ Locale،
  /// لأن الـ subtitle نص قابل للترجمة بعكس الـ brand name الثابت.
  Widget _buildAnimatedSubtitle(BuildContext context) {
    // الـ subtitle يبدأ بعد 0.5 من الـ progress
    final double subtitleProgress =
        ((progress - 0.5) / 0.5).clamp(0.0, 1.0);

    if (subtitleProgress <= 0) return const SizedBox(height: 24);

    final String fullText = context.l10n.appSubtitle;
    // عدد الحروف اللي ظاهرة الآن (typewriter)
    final int visibleChars =
        (fullText.length * subtitleProgress).floor();
    final String visibleText =
        fullText.substring(0, visibleChars.clamp(0, fullText.length));

    // cursor blinking في النهاية (لو الـ animation ما خلصت)
    final bool showCursor = subtitleProgress < 1.0;

    // اتجاه الـ subtitle حسب لغة المستخدم
    final Locale currentLocale = Localizations.localeOf(context);
    final TextDirection subtitleDir = currentLocale.languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;

    return Directionality(
      textDirection: subtitleDir,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                visibleText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  letterSpacing: 0.3,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ),
            if (showCursor)
              Container(
                margin: const EdgeInsetsDirectional.only(start: 2),
                width: 2,
                height: 16,
                color: AppColors.accent.withValues(alpha: 0.8),
              ),
          ],
        ),
      ),
    );
  }
}
