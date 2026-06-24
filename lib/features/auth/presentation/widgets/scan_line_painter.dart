// ════════════════════════════════════════════════════════════════════════════
// scan_line_painter.dart
//
// Phase 1 من الـ Splash: "X-Ray Scan Effect"
//
// يرسم شريط ضوئي أفقي ينزل من فوق الشاشة لتحت — يكشف بصرياً عن وجود
// المحتوى تحته (اللوغو + النصوص).
//
// الفكرة: محاكاة جهاز الأشعة الذي يفحص السن — استعارة قوية لمشروع طبّي.
//
// التفاصيل التقنية:
//   - شريط بـ gradient متدرّج (شفاف → cyan ساطع → شفاف)
//   - ارتفاع الشريط ~80px لإعطاء توهّج بصري كبير
//   - ينزل بسرعة ثابتة عبر كامل الشاشة
//   - بعد الشريط: lines رفيعة تظهر (يعطي شعور "scan progressive")
// ════════════════════════════════════════════════════════════════════════════

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// CustomPainter للـ scan line + scan grid lines.
class ScanLinePainter extends CustomPainter {
  ScanLinePainter({
    required this.progress,
  });

  /// تقدّم الـ scan من 0.0 (فوق) إلى 1.0 (تحت).
  final double progress;

  /// ارتفاع الشريط الضوئي.
  static const double _beamHeight = 100.0;

  /// عدد الـ horizontal grid lines المكشوفة.
  static const int _gridLineCount = 14;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    // ═══════════════════════════════════════════════════════════════
    //   1. الـ Grid Lines المكشوفة (تظهر تدريجياً تحت الشريط)
    // ═══════════════════════════════════════════════════════════════
    _drawScanGrid(canvas, size);

    // ═══════════════════════════════════════════════════════════════
    //   2. الشريط الضوئي الرئيسي (إذا لسه ينزل)
    // ═══════════════════════════════════════════════════════════════
    if (progress < 1.0) {
      _drawScanBeam(canvas, size);
    }
  }

  /// رسم الشبكة الأفقية اللي بتكشفها الـ scan.
  void _drawScanGrid(Canvas canvas, Size size) {
    final double scanY = progress * size.height;

    for (int i = 0; i < _gridLineCount; i++) {
      // كل خط على ارتفاع نسبي من الشاشة
      final double lineY = (size.height / _gridLineCount) * (i + 0.5);

      // الخط يظهر فقط إذا الـ scan وصلله
      if (lineY > scanY) continue;

      // كلما ابتعدنا عن الـ scan beam الحالي، الخط يصير أوضح وأقل توهّج
      final double distanceFromBeam = (scanY - lineY) / size.height;
      final double opacity = math.min(0.35, distanceFromBeam * 2.5);

      // الخطوط تكون أوضح في وسط الشاشة، أخف على الحواف
      final Paint linePaint = Paint()
        ..strokeWidth = 0.6
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.accent.withValues(alpha: opacity),
            AppColors.accent.withValues(alpha: opacity),
            Colors.transparent,
          ],
          stops: const [0.0, 0.2, 0.8, 1.0],
        ).createShader(
          Rect.fromLTWH(0, lineY - 0.5, size.width, 1),
        );

      canvas.drawLine(
        Offset(0, lineY),
        Offset(size.width, lineY),
        linePaint,
      );
    }

    // ═══════════════════════════════════════════════════════════════
    //   Vertical center line (يعطي depth)
    // ═══════════════════════════════════════════════════════════════
    if (progress > 0.1) {
      final double centerOpacity = math.min(0.2, (progress - 0.1) * 1.5);
      final Paint vLinePaint = Paint()
        ..strokeWidth = 0.5
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.accent.withValues(alpha: centerOpacity),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(size.width / 2, 0, 1, size.height));

      canvas.drawLine(
        Offset(size.width / 2, 0),
        Offset(size.width / 2, scanY),
        vLinePaint,
      );
    }
  }

  /// رسم الشريط الضوئي الرئيسي.
  void _drawScanBeam(Canvas canvas, Size size) {
    final double beamCenterY = progress * size.height;
    final double beamTop = beamCenterY - _beamHeight / 2;

    // ═══════════════════════════════════════════════════════════════
    //   1. الـ Glow الكبير (طبقة سفلية)
    // ═══════════════════════════════════════════════════════════════
    final Rect glowRect =
        Rect.fromLTWH(0, beamTop, size.width, _beamHeight);
    final Paint glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          AppColors.accent.withValues(alpha: 0.3),
          AppColors.accent.withValues(alpha: 0.6),
          AppColors.accent.withValues(alpha: 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      ).createShader(glowRect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawRect(glowRect, glowPaint);

    // ═══════════════════════════════════════════════════════════════
    //   2. الخط الساطع الرفيع في المنتصف
    // ═══════════════════════════════════════════════════════════════
    final Paint coreLine = Paint()
      ..strokeWidth = 2.0
      ..shader = const LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.accent,
          Colors.white,
          AppColors.accent,
          Colors.transparent,
        ],
        stops: [0.0, 0.2, 0.5, 0.8, 1.0],
      ).createShader(
        Rect.fromLTWH(0, beamCenterY - 1, size.width, 2),
      );

    canvas.drawLine(
      Offset(0, beamCenterY),
      Offset(size.width, beamCenterY),
      coreLine,
    );

    // ═══════════════════════════════════════════════════════════════
    //   3. Trailing particles خلف الشريط
    // ═══════════════════════════════════════════════════════════════
    _drawTrailingParticles(canvas, size, beamCenterY);
  }

  /// particles صغيرة تتساقط خلف الشريط — تعطي شعور "energy trail".
  void _drawTrailingParticles(Canvas canvas, Size size, double beamY) {
    // 12 particle موزعة عرضياً
    const int particleCount = 12;
    final math.Random rng = math.Random(42); // seed ثابت لنفس النتيجة

    for (int i = 0; i < particleCount; i++) {
      // الـ x موزع على عرض الشاشة (مع شوية randomness)
      final double xRatio = (i + 0.5) / particleCount;
      final double x = size.width * xRatio + (rng.nextDouble() - 0.5) * 20;

      // الـ y فوق الـ beam بمسافة عشوائية
      final double yOffset = rng.nextDouble() * 40 + 5;
      final double y = beamY - yOffset;

      // opacity يخف كلما ابتعدنا عن الـ beam
      final double particleOpacity = (1.0 - yOffset / 50) * 0.7;

      final Paint particlePaint = Paint()
        ..color = AppColors.accent.withValues(alpha: particleOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

      canvas.drawCircle(Offset(x, y), 1.5, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant ScanLinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
