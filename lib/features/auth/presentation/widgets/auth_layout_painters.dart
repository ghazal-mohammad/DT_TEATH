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
    this.glowColor = const Color(0xFFD0FBD7),
    this.glowClipPath,
  });

  final Offset start;
  final Offset end;
  final double phase;

  /// لون التوهج.
  /// - صفحات Auth العادية: `Color(0xFFD0FBD7)` (أخضر فاتح).
  /// - system_selection: `Color(0xFFBED8FA)` (أزرق فاتح).
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
      old.topX != topX || old.botX != botX;
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
      old.topX != topX || old.botX != botX;
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
        decoration: BoxDecoration(
          gradient: AppColors.authNavyGradient,
        ),
      ),
    );
  }
}
