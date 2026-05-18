// ════════════════════════════════════════════════════════════════════════════
// sparkle_particles_painter.dart
//
// Phase 3 من الـ Splash: "Crystallization"
//
// عند اكتمال الـ liquid fill، اللوغو "يتبلور" ويتحوّل من cyan لأبيض.
// نضيف بصرياً:
//   1. Sparkle particles تتطاير من اللوغو في كل الاتجاهات
//   2. Shockwave rings تخرج من المركز (3 موجات متتابعة)
//   3. Magnetic dust: نقاط صغيرة تنجذب للوغو ثم تختفي
//
// كل هذا في pass واحد على الـ canvas — أداء عالي.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// CustomPainter للـ sparkle effect عند تبلور اللوغو.
class SparkleParticlesPainter extends CustomPainter {
  SparkleParticlesPainter({
    required this.progress,
  });

  /// تقدّم الـ effect من 0.0 إلى 1.0.
  final double progress;

  /// عدد الـ sparkles الكلي.
  static const int _sparkleCount = 24;

  /// عدد shockwave rings.
  static const int _shockwaveCount = 3;

  /// random seed ثابت ليكون التوزيع دائماً نفسه.
  static final math.Random _rng = math.Random(7);

  /// قائمة angles + speeds مولّدة مسبقاً (constants فعلياً).
  static final List<_SparkleSpec> _sparkleSpecs = List.generate(
    _sparkleCount,
    (i) => _SparkleSpec(
      angle: (i / _sparkleCount) * 2 * math.pi +
          (_rng.nextDouble() - 0.5) * 0.3,
      // speedFactor: كم سيبتعد عن المركز (نسبة من radius)
      speedFactor: 0.8 + _rng.nextDouble() * 0.6,
      // delay: متى يبدأ هذا الـ sparkle (0.0 - 0.4)
      delay: _rng.nextDouble() * 0.4,
      // size: 2-5 px
      size: 2.0 + _rng.nextDouble() * 3.0,
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double maxRadius = math.min(size.width, size.height) * 0.35;

    // ═══════════════════════════════════════════════════════════════
    //   1. Shockwave Rings (تخرج من المركز)
    // ═══════════════════════════════════════════════════════════════
    _drawShockwaves(canvas, center, maxRadius);

    // ═══════════════════════════════════════════════════════════════
    //   2. Sparkle Particles (تتطاير في كل الاتجاهات)
    // ═══════════════════════════════════════════════════════════════
    _drawSparkles(canvas, center, maxRadius);

    // ═══════════════════════════════════════════════════════════════
    //   3. Center Flash (وميض أبيض في أول 0.2)
    // ═══════════════════════════════════════════════════════════════
    if (progress < 0.2) {
      _drawCenterFlash(canvas, center, size);
    }
  }

  /// رسم 3 shockwave rings تتباعد من المركز.
  void _drawShockwaves(Canvas canvas, Offset center, double maxRadius) {
    for (int i = 0; i < _shockwaveCount; i++) {
      // كل shockwave له delay مختلف
      final double delay = i * 0.15;
      final double waveProgress = ((progress - delay) / 0.7).clamp(0.0, 1.0);

      if (waveProgress <= 0) continue;

      // نصف قطر الموجة الحالية
      final double waveRadius = maxRadius * waveProgress;

      // opacity يخف كلما اتسعت الموجة
      final double opacity = (1.0 - waveProgress) * 0.6;

      // ring رئيسي
      final Paint ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 * (1.0 - waveProgress * 0.7)
        ..color = AppColors.accent.withValues(alpha: opacity);

      canvas.drawCircle(center, waveRadius, ringPaint);

      // glow حول الـ ring
      final Paint glowRing = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0 * (1.0 - waveProgress * 0.5)
        ..color = AppColors.accent.withValues(alpha: opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawCircle(center, waveRadius, glowRing);
    }
  }

  /// رسم الـ particles اللي تتطاير.
  void _drawSparkles(Canvas canvas, Offset center, double maxRadius) {
    for (final spec in _sparkleSpecs) {
      // كل sparkle له delay مختلف
      final double sparkleProgress =
          ((progress - spec.delay) / (1.0 - spec.delay)).clamp(0.0, 1.0);

      if (sparkleProgress <= 0) continue;

      // المسافة الحالية من المركز
      // easing: easeOut — تتسارع في البداية ثم تبطئ
      final double eased = Curves.easeOutQuart.transform(sparkleProgress);
      final double distance = maxRadius * spec.speedFactor * eased;

      // الموقع الحالي
      final Offset position = Offset(
        center.dx + distance * math.cos(spec.angle),
        center.dy + distance * math.sin(spec.angle),
      );

      // opacity: يبدأ كامل ثم يخف في النهاية
      // alpha = 1 في البداية، 0 في النهاية بـ smooth curve
      final double opacity = sparkleProgress < 0.7
          ? 1.0
          : (1.0 - (sparkleProgress - 0.7) / 0.3);

      // الحجم: يتقلّص شوي في النهاية
      final double currentSize =
          spec.size * (1.0 - sparkleProgress * 0.3);

      // ─── Sparkle core ───
      final Paint sparkleCore = Paint()
        ..color = Colors.white.withValues(alpha: opacity * 0.95);
      canvas.drawCircle(position, currentSize, sparkleCore);

      // ─── Sparkle glow ───
      final Paint sparkleGlow = Paint()
        ..color = AppColors.accent.withValues(alpha: opacity * 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(position, currentSize * 2.5, sparkleGlow);

      // ─── Trail behind the sparkle (ذيل خفيف) ───
      if (sparkleProgress > 0.1 && sparkleProgress < 0.8) {
        final double trailDistance = distance - currentSize * 4;
        if (trailDistance > 0) {
          final Offset trailPos = Offset(
            center.dx + trailDistance * math.cos(spec.angle),
            center.dy + trailDistance * math.sin(spec.angle),
          );

          final Paint trailPaint = Paint()
            ..strokeWidth = currentSize * 0.5
            ..strokeCap = StrokeCap.round
            ..color = AppColors.accent.withValues(alpha: opacity * 0.3);

          canvas.drawLine(trailPos, position, trailPaint);
        }
      }
    }
  }

  /// رسم وميض أبيض كبير في المركز (يومض في أول لحظة).
  void _drawCenterFlash(Canvas canvas, Offset center, Size size) {
    final double flashProgress = progress / 0.2;
    // يومض ثم يخفت
    final double flashAlpha = math.sin(flashProgress * math.pi) * 0.3;

    final double flashRadius = math.min(size.width, size.height) * 0.4;

    final Paint flashPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: flashAlpha),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: flashRadius),
      );

    canvas.drawCircle(center, flashRadius, flashPaint);
  }

  @override
  bool shouldRepaint(covariant SparkleParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                        SPARKLE SPEC (data class)
// ══════════════════════════════════════════════════════════════════════════

/// مواصفات sparkle واحد.
class _SparkleSpec {
  const _SparkleSpec({
    required this.angle,
    required this.speedFactor,
    required this.delay,
    required this.size,
  });

  /// الزاوية اللي يتجه إليها (بالـ radian).
  final double angle;

  /// نسبة السرعة (0.8-1.4) — يحدد مدى ابتعاده عن المركز.
  final double speedFactor;

  /// متى يبدأ هذا الـ sparkle (0.0 - 0.4 من progress).
  final double delay;

  /// حجم الـ particle (2-5 px).
  final double size;
}
