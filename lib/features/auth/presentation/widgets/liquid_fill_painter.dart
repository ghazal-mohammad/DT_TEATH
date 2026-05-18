// ════════════════════════════════════════════════════════════════════════════
// liquid_fill_painter.dart
//
// Phase 2 من الـ Splash: "Liquid Fill"
//
// يرسم سائل cyan يملأ مساحة دائرية في الوسط (خلف اللوغو) من تحت لفوق.
// السطح يتموّج بـ sine wave يشبه ماء حقيقي.
//
// الفكرة: محاكاة "حقن مادة تباينية" - مرجع طبّي قوي.
//
// التفاصيل التقنية:
//   - دائرة clipping تحدد منطقة السائل (خلف اللوغو)
//   - السطح موجة sine ناعمة (amplitude 8px)
//   - الموجة تتحرك أفقياً مع pulsePhase
//   - 2 طبقات: السائل الرئيسي + reflection فوقه
// ════════════════════════════════════════════════════════════════════════════

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// CustomPainter للسائل اللي يملأ خلف اللوغو.
class LiquidFillPainter extends CustomPainter {
  LiquidFillPainter({
    required this.fillProgress,
    required this.wavePhase,
    required this.transitionToWhite,
  });

  /// مدى الامتلاء من 0.0 (فارغ) إلى 1.0 (ممتلئ كامل).
  final double fillProgress;

  /// phase الموجة المستمر (0 → 2π).
  final double wavePhase;

  /// تحوّل اللون من cyan إلى أبيض (Phase 3 من الـ splash).
  /// 0.0 = cyan كامل، 1.0 = أبيض كامل.
  final double transitionToWhite;

  /// نصف قطر المنطقة الدائرية (نسبة من أصغر بعد).
  static const double _circleRadiusFactor = 0.16;

  /// amplitude الموجة (بالبكسل).
  static const double _waveAmplitude = 6.0;

  /// عدد الموجات على عرض الدائرة.
  static const double _waveFrequency = 2.5;

  @override
  void paint(Canvas canvas, Size size) {
    if (fillProgress <= 0) return;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius =
        math.min(size.width, size.height) * _circleRadiusFactor;

    // ═══════════════════════════════════════════════════════════════
    //   Clipping: نقصّ كل شي خارج الدائرة
    // ═══════════════════════════════════════════════════════════════
    canvas.save();
    final Path clipPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.clipPath(clipPath);

    // ═══════════════════════════════════════════════════════════════
    //   حساب مستوى السطح
    // ═══════════════════════════════════════════════════════════════
    // الـ y الأعلى للسطح (فوق المنطقة المملوءة)
    final double surfaceY = center.dy + radius - (fillProgress * radius * 2);

    // ═══════════════════════════════════════════════════════════════
    //   1. السائل الرئيسي
    // ═══════════════════════════════════════════════════════════════
    _drawLiquidBody(canvas, center, radius, surfaceY);

    // ═══════════════════════════════════════════════════════════════
    //   2. السطح الموجي الواضح
    // ═══════════════════════════════════════════════════════════════
    _drawWaveSurface(canvas, center, radius, surfaceY);

    // ═══════════════════════════════════════════════════════════════
    //   3. Highlight على السطح (يعطي إحساس reflection)
    // ═══════════════════════════════════════════════════════════════
    _drawSurfaceHighlight(canvas, center, radius, surfaceY);

    canvas.restore();

    // ═══════════════════════════════════════════════════════════════
    //   4. Border ring حول الدائرة (خارج clip)
    // ═══════════════════════════════════════════════════════════════
    _drawBorderRing(canvas, center, radius);
  }

  /// رسم الجسم الرئيسي للسائل.
  void _drawLiquidBody(
    Canvas canvas,
    Offset center,
    double radius,
    double surfaceY,
  ) {
    // اللون الحالي = mix بين cyan والأبيض حسب transitionToWhite
    final Color liquidColor = Color.lerp(
      AppColors.accent,
      Colors.white,
      transitionToWhite,
    )!;

    // ─── Body fill ───
    // نرسم مستطيل من الـ surfaceY لتحت الدائرة
    final Rect bodyRect = Rect.fromLTRB(
      center.dx - radius - 5,
      surfaceY,
      center.dx + radius + 5,
      center.dy + radius + 5,
    );

    final Paint bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          liquidColor.withValues(alpha: 0.45),
          liquidColor.withValues(alpha: 0.7),
        ],
      ).createShader(bodyRect);

    canvas.drawRect(bodyRect, bodyPaint);
  }

  /// رسم السطح الموجي الواضح.
  void _drawWaveSurface(
    Canvas canvas,
    Offset center,
    double radius,
    double surfaceY,
  ) {
    final Color liquidColor = Color.lerp(
      AppColors.accent,
      Colors.white,
      transitionToWhite,
    )!;

    final Path wavePath = Path()..moveTo(center.dx - radius - 5, surfaceY + 100);

    // نرسم الموجة من الشمال للجنوب
    final double startX = center.dx - radius - 5;
    final double endX = center.dx + radius + 5;
    const int sampleCount = 60;

    for (int i = 0; i <= sampleCount; i++) {
      final double t = i / sampleCount;
      final double x = startX + (endX - startX) * t;
      // sine wave مع phase
      final double waveOffset = math.sin(
            t * _waveFrequency * 2 * math.pi + wavePhase,
          ) *
          _waveAmplitude;
      // wave ثاني (frequency أعلى) لإعطاء تعقيد طبيعي
      final double secondaryWave = math.sin(
            t * _waveFrequency * 4 * math.pi + wavePhase * 1.5,
          ) *
          _waveAmplitude *
          0.3;

      wavePath.lineTo(x, surfaceY + waveOffset + secondaryWave);
    }

    wavePath.lineTo(endX, surfaceY + 100);
    wavePath.close();

    final Paint surfacePaint = Paint()
      ..color = liquidColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    canvas.drawPath(wavePath, surfacePaint);

    // ─── خط ساطع على السطح ───
    final Path waveLine = Path();
    bool isFirst = true;
    for (int i = 0; i <= sampleCount; i++) {
      final double t = i / sampleCount;
      final double x = startX + (endX - startX) * t;
      final double waveOffset = math.sin(
            t * _waveFrequency * 2 * math.pi + wavePhase,
          ) *
          _waveAmplitude;
      final double secondaryWave = math.sin(
            t * _waveFrequency * 4 * math.pi + wavePhase * 1.5,
          ) *
          _waveAmplitude *
          0.3;

      final double y = surfaceY + waveOffset + secondaryWave;
      if (isFirst) {
        waveLine.moveTo(x, y);
        isFirst = false;
      } else {
        waveLine.lineTo(x, y);
      }
    }

    final Paint highlightLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(waveLine, highlightLine);
  }

  /// رسم highlight ناعم فوق السطح.
  void _drawSurfaceHighlight(
    Canvas canvas,
    Offset center,
    double radius,
    double surfaceY,
  ) {
    // قطعة أوبية صغيرة تحت السطح للإحساس reflection
    final Rect highlightRect = Rect.fromLTWH(
      center.dx - radius * 0.5,
      surfaceY,
      radius,
      8,
    );

    final Paint highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.4),
          Colors.transparent,
        ],
      ).createShader(highlightRect);

    canvas.drawRect(highlightRect, highlightPaint);
  }

  /// رسم الحلقة الخارجية حول الدائرة.
  void _drawBorderRing(Canvas canvas, Offset center, double radius) {
    final Color ringColor = Color.lerp(
      AppColors.accent,
      Colors.white,
      transitionToWhite,
    )!;

    // ring 1: outer thin
    final Paint outerRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = ringColor.withValues(alpha: 0.4);

    canvas.drawCircle(center, radius + 3, outerRing);

    // ring 2: inner softer (for glow)
    final Paint innerGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..color = ringColor.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(center, radius + 3, innerGlow);
  }

  @override
  bool shouldRepaint(covariant LiquidFillPainter oldDelegate) {
    return oldDelegate.fillProgress != fillProgress ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.transitionToWhite != transitionToWhite;
  }
}
