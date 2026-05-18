// ════════════════════════════════════════════════════════════════════════════
// app_logo.dart
//
// Widget يعرض لوغو DT.Teeth ويختار النسخة المناسبة تلقائياً حسب الثيم:
//
//   4 نسخ متاحة (كلهم PNG بخلفية شفّافة):
//   - logo_light_no_text.png   → سن كحلي، بدون نص  (للثيم الفاتح)
//   - logo_dark_no_text.png    → سن أبيض، بدون نص  (للثيم الغامق)
//   - logo_light_with_text.png → سن+نص كحلي          (للثيم الفاتح)
//   - logo_dark_with_text.png  → سن+نص أبيض          (للثيم الغامق)
//
// استخدامات:
//   1. السايدبار (size: 22, showText: false) — الأيقونة الدائرية
//   2. صفحات Auth (size: 80-120, showText: true)
//   3. السبلاش سكرين (size: 140, variant: darkTheme)
//   4. Headers في الصفحات الرئيسية
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';

/// نسخ اللوغو المتاحة.
enum AppLogoVariant {
  /// اختيار تلقائي حسب الثيم — الافتراضي والموصى به.
  auto,

  /// فرض نسخة الثيم الغامق (أبيض) — مفيد للـ splash والـ hero sections.
  darkTheme,

  /// فرض نسخة الثيم الفاتح (navy) — مفيد على خلفيات فاتحة ثابتة.
  lightTheme,
}

/// Widget يعرض لوغو DT.Teeth — يختار النسخة حسب الثيم تلقائياً.
///
/// ## أمثلة استخدام
///
/// ### السايدبار (بدون نص)
/// ```dart
/// AppLogo(size: 22)
/// ```
///
/// ### صفحة Auth (مع نص)
/// ```dart
/// AppLogo(size: 80, showText: true)
/// ```
///
/// ### السبلاش (مع Hero animation)
/// ```dart
/// AppLogo(
///   size: 140,
///   variant: AppLogoVariant.darkTheme,
///   showText: true,
///   heroTag: 'app_logo',
/// )
/// ```
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 48,
    this.variant = AppLogoVariant.auto,
    this.showText = false,
    this.heroTag,
    this.semanticLabel = 'DT.Teeth',
  });

  /// حجم اللوغو (عرض = ارتفاع للنسخة بدون نص، أو عرض فقط للنسخة مع نص).
  final double size;

  /// أي نسخة نعرض (auto للاختيار من الثيم).
  final AppLogoVariant variant;

  /// إذا true، يُعرض اللوغو مع نص "DT_Teeth" أسفله.
  /// إذا false (الافتراضي)، يُعرض الأيقونة فقط بدون نص.
  final bool showText;

  /// لو مُحدّد، يغلّف الصورة بـ [Hero] لإنيمايشن انتقال بين الصفحات.
  final String? heroTag;

  /// نص للـ screen readers.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final String assetPath = _resolveAssetPath(context);

    Widget image = Image.asset(
      assetPath,
      width: size,
      fit: BoxFit.contain,
      filterQuality: size > 100 ? FilterQuality.high : FilterQuality.medium,
      semanticLabel: semanticLabel,
      errorBuilder: (context, error, stackTrace) {
        assert(() {
          debugPrint('⚠️ AppLogo: Failed to load $assetPath');
          return true;
        }());
        return _buildFallback(context, size);
      },
    );

    // تغليف بـ Hero لو مطلوب
    if (heroTag != null) {
      image = Hero(
        tag: heroTag!,
        flightShuttleBuilder: (_, __, ___, ____, toHeroContext) {
          return Material(
            color: Colors.transparent,
            child: toHeroContext.widget,
          );
        },
        child: image,
      );
    }

    return image;
  }

  /// يحدّد مسار الأصل حسب الـ variant والثيم والـ showText.
  String _resolveAssetPath(BuildContext context) {
    final bool isDark = variant == AppLogoVariant.darkTheme ||
        (variant == AppLogoVariant.auto &&
            Theme.of(context).brightness == Brightness.dark);

    if (showText) {
      return isDark ? AppAssets.logoDarkWithText : AppAssets.logoLightWithText;
    } else {
      return isDark ? AppAssets.logoDarkNoText : AppAssets.logoLightNoText;
    }
  }

  /// Fallback إذا فشل تحميل الصورة.
  Widget _buildFallback(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.medical_services_outlined,
        size: size * 0.6,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
