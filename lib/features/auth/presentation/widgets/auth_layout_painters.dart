// ════════════════════════════════════════════════════════════════════════════
// auth_layout_painters.dart
//
// Painters و Clippers المشتركة بين جميع صفحات Auth.
// مصدر حقيقة واحد — أي تعديل بصري ينعكس فوراً على كل الصفحات.
//
// يستبدل الكلاسات المكررة:
//   _GlowLine / _GL  → AuthGlowLinePainter
//   _DiagClipper / _DC → AuthDiagRightClipper
//   _DCLeft           → AuthDiagLeftClipper
//   Container navy gradient → AuthNavyBackground
// ════════════════════════════════════════════════════════════════════════════

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════════════════
//   GLOW LINE PAINTER
// ══════════════════════════════════════════════════════════════════════════

/// خط التوهج المتحرك — الخط الفاصل بين الجانب الداكن والأبيض.
///
/// يُستخدم في: email_entry, login, set_password, verify_code, system_selection.
/// يُنشأ داخل [AnimatedBuilder] مع controller يعطي [phase] = value * 2π.
class AuthGlowLinePainter extends CustomPainter {
  const AuthGlowLinePainter({
    required this.start,
    required this.end,
    required this.phase,

    this.glowColor = AppColors.reservedBg,
    this.glowClipPath,
  });

  final Offset start;
  final Offset end;
  final double phase;

  /// لون التوهج.
  /// - صفحات Auth العادية: `AppColors.reservedBg` (أخضر فاتح).
  /// - system_selection: `AppColors.tableHeader` (أزرق فاتح).
  final Color glowColor;

  /// مسار قص اختياري للطبقات الضبابية فقط — يبقي التوهج محصوراً على جهة معينة
  /// (مثلاً جهة اللوحة الكحلية) بدون أن يتسرّب إلى الجهة البيضاء.
  /// الخط الحاد النابض (core line) يُرسم بدون قص ليبقى مرئياً على الجهتين.
  final Path? glowClipPath;

  @override
  void paint(Canvas canvas, Size size) {
    void drawBlurLayers() {
      // طبقة التوهج الخارجية الواسعة
      canvas.drawLine(
        start,
        end,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 100
          ..color = glowColor.withValues(alpha: 0.09)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60),
      );
      // طبقة التوهج المتوسطة
      canvas.drawLine(
        start,
        end,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 35
          ..color = glowColor.withValues(alpha: 0.30)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
      );
      // الطبقة الداخلية الناعمة
      canvas.drawLine(
        start,
        end,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..color = Colors.white.withValues(alpha: 0.70)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    if (glowClipPath != null) {
      canvas.save();
      canvas.clipPath(glowClipPath!);
      drawBlurLayers();
      canvas.restore();
    } else {
      drawBlurLayers();
    }

    // الخط الحاد النابض — لون تركواز يتنفس حسب الـ phase
    canvas.drawLine(
      start,
      end,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color =
            glowColor.withValues(alpha: 0.92 + 0.08 * math.sin(phase)),
    );
  }

  @override
  bool shouldRepaint(covariant AuthGlowLinePainter old) =>
      old.phase != phase ||
      old.glowColor != glowColor ||
      old.glowClipPath != glowClipPath;
}

// ══════════════════════════════════════════════════════════════════════════
//   DIAGONAL CLIPPERS
// ══════════════════════════════════════════════════════════════════════════

/// الجانب الأيمن الأبيض — يقطع الشاشة قطعاً مائلاً.
/// يُستخدم في: email_entry, login, set_password, system_selection.
class AuthDiagRightClipper extends CustomClipper<Path> {
  const AuthDiagRightClipper({
    required this.topX,
    required this.botX,
    required this.W,
    required this.H,
  });

  final double topX, botX, W, H;

  @override
  Path getClip(Size size) => Path()
    ..moveTo(topX, 0)
    ..lineTo(W, 0)
    ..lineTo(W, H)
    ..lineTo(botX, H)
    ..close();

  @override
  bool shouldReclip(covariant AuthDiagRightClipper old) =>
      old.topX != topX || old.botX != botX || old.W != W || old.H != H;
}

/// الجانب الأيسر الأبيض — الـ form على اليسار والـ branding على اليمين.
/// يُستخدم في: verify_code_page (layout معكوس).
class AuthDiagLeftClipper extends CustomClipper<Path> {
  const AuthDiagLeftClipper({
    required this.topX,
    required this.botX,
    required this.W,
    required this.H,
  });

  final double topX, botX, W, H;

  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, 0)
    ..lineTo(topX, 0)
    ..lineTo(botX, H)
    ..lineTo(0, H)
    ..close();

  @override
  bool shouldReclip(covariant AuthDiagLeftClipper old) =>
      old.topX != topX || old.botX != botX || old.W != W || old.H != H;
}

// ══════════════════════════════════════════════════════════════════════════
//   AUTH NAVY BACKGROUND
// ══════════════════════════════════════════════════════════════════════════

/// خلفية Navy المتدرجة المشتركة بين كل صفحات Auth.
///
/// تستخدم [AppColors.authNavyGradient] — تغيير الـ gradient يتم من ملف
/// واحد فقط وينعكس فوراً على كل الصفحات.
class AuthNavyBackground extends StatelessWidget {
  const AuthNavyBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.authNavyGradient,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//   AUTH SHAPE BACKGROUND — Animated diagonal (مستوحى من HTML المرجعي)
// ══════════════════════════════════════════════════════════════════════════

/// خلفية Auth المتحركة — تحاكي انيميشن background-shape من الـ HTML.
///
/// عند تحميل كل شاشة auth، اللوحة القطرية (البيضاء) تبرز من حافة الشاشة
/// إلى موقعها النهائي. هذا يحاكي حركة `rotate(10deg) skewY(40deg)` من HTML.
///
/// الاستخدام:
/// ```dart
/// Positioned.fill(
///   child: AuthShapeBackground(
///     shapeCtrl: _shapeCtrl,  // 0→1 عند تحميل الصفحة
///     glowCtrl: _glowCtrl,    // repeating للخط النابض
///   ),
/// )
/// ```
///
/// [whiteOnRight]  : true = البيضاء على اليمين (email/login/setPassword).
///                   false = البيضاء على اليسار (verify_code).
/// [topRatio]      : نسبة بداية الخط القطري من الأعلى (افتراضي 0.75).
/// [botRatio]      : نسبة نهاية الخط القطري من الأسفل (افتراضي 0.25).
/// [glowColor]     : لون خط التوهج (null = AppColors.accent).
class AuthShapeBackground extends StatelessWidget {
  const AuthShapeBackground({
    super.key,
    required this.shapeCtrl,
    required this.glowCtrl,
    this.whiteOnRight = true,
    this.topRatio = 0.75,
    this.botRatio = 0.25,
    this.glowColor,
  });

  final AnimationController shapeCtrl;
  final AnimationController glowCtrl;
  final bool whiteOnRight;
  final double topRatio;
  final double botRatio;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final Color effectiveGlow = glowColor ?? AppColors.accent;

    return LayoutBuilder(builder: (_, box) {
      final double W = box.maxWidth;
      final double H = box.maxHeight;

      return AnimatedBuilder(
        animation: shapeCtrl,
        builder: (_, __) {
          // easeOutCubic — نفس timing الـ HTML (1.5s ease)
          final double t = CurvedAnimation(
            parent: shapeCtrl,
            curve: Curves.easeOutCubic,
          ).value;

          final double topXFinal = W * topRatio;
          final double botXFinal = W * botRatio;

          // اللوحة البيضاء تبدأ مختبئة خارج الشاشة ثم تنزلق للموقع النهائي
          final double topX, botX;
          if (whiteOnRight) {
            // يبدأ من الحافة اليمنى (W) ← يتحرك لـ topRatio
            topX = W + (topXFinal - W) * t;
            botX = W + (botXFinal - W) * t;
          } else {
            // معكوس — يبدأ من الحافة اليسرى (0) ← يتحرك لـ topRatio
            topX = topXFinal * t;
            botX = botXFinal * t;
          }

          // مسار قص التوهج على الجانب الداكن فقط
          final Path glowClip = whiteOnRight
              ? (Path()
                ..moveTo(0, 0)
                ..lineTo(topX, 0)
                ..lineTo(botX, H)
                ..lineTo(0, H)
                ..close())
              : (Path()
                ..moveTo(topX, 0)
                ..lineTo(W, 0)
                ..lineTo(W, H)
                ..lineTo(botX, H)
                ..close());

          return Stack(children: [
            // 1 ─ خلفية Navy (بدون تغيير)
            const AuthNavyBackground(),

            // 2 ─ اللوحة البيضاء المتحركة
            Positioned.fill(
              child: ClipPath(
                clipper: whiteOnRight
                    ? AuthDiagRightClipper(topX: topX, botX: botX, W: W, H: H)
                    : AuthDiagLeftClipper(topX: topX, botX: botX, W: W, H: H),
                child: const ColoredBox(color: Colors.white),
              ),
            ),

            // 3 ─ خط التوهج المتحرك (بنفس الألوان الأصلية)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: glowCtrl,
                builder: (_, __) => CustomPaint(
                  painter: AuthGlowLinePainter(
                    start: Offset(topX, 0),
                    end: Offset(botX, H),
                    phase: glowCtrl.value * 2 * math.pi,
                    glowColor: effectiveGlow,
                    glowClipPath: glowClip,
                  ),
                ),
              ),
            ),
          ]);
        },
      );
    });
  }
}
