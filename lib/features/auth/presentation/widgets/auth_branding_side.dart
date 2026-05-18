// ════════════════════════════════════════════════════════════════════════════
// auth_branding_side.dart
//
// الجانب الترويجي في شاشات Auth (يظهر على الشاشات الكبيرة > 900px فقط).
//
// التصميم (نسخة نظيفة — مرجع: شاشة Login المرسلة):
//   - خلفية primary صلبة + قطر neon (من AuthBackgroundPainter)
//   - لوغو كبير بارز فوق
//   - كلمة "Welcome" بخط ضخم
//   - subtitle قصير
//   - بدون pills، بدون gradients، بدون tagline pills.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/brand/app_logo.dart';
import '../pages/splash_page.dart';
import 'auth_background_painter.dart';

/// الجانب الترويجي في شاشات Auth.
class AuthBrandingSide extends StatefulWidget {
  const AuthBrandingSide({
    super.key,
    this.welcomeText,
  });

  /// نص الترحيب الكبير. لو null — يستخدم القيمة من l10n.
  /// (يفيد في صفحات مختلفة لاستخدام نص مختلف، مثل "Welcome Back!")
  final String? welcomeText;

  @override
  State<AuthBrandingSide> createState() => _AuthBrandingSideState();
}

class _AuthBrandingSideState extends State<AuthBrandingSide>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final String welcome = widget.welcomeText ?? 'Welcome!';

    return Stack(
      children: [
        // ═══════════════════════════════════════════════════════════
        //   الخلفية الثابتة
        // ═══════════════════════════════════════════════════════════
        const Positioned.fill(
          child: CustomPaint(
            painter: AuthBackgroundPainter(phase: 0.0),
          ),
        ),

        // ═══════════════════════════════════════════════════════════
        //   المحتوى المركزي: لوغو كبير + Welcome
        // ═══════════════════════════════════════════════════════════
        Center(
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── اللوغو الكبير (Hero من Splash) ──
                const AppLogo(
                  size: 240,
                  variant: AppLogoVariant.darkTheme,
                  heroTag: SplashPage.logoHeroTag,
                ),

                const SizedBox(height: 36),

                // ── "WELCOME!" بخط ضخم — solid أبيض من الباليت ──
                Text(
                  welcome.toUpperCase(),
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    letterSpacing: 2.0,
                    color: AppColors.darkText1,

                  ),
                ),

                const SizedBox(height: 18),

                // ── subtitle رفيع ──
                Text(
                  context.l10n.appSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    letterSpacing: 0.5,
                    color: AppColors.darkText2.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
