// ════════════════════════════════════════════════════════════════════════════
// auth_animated_background.dart
//
// 🎬 أنيميشن الخلفية لشاشات الـ Auth — مستوحى من الفيديو المرجعي.
//
// يحتوي على:
//   1. AuthRadialPulseWidget  — نبضة توهج مزدوجة (double heartbeat)
//   2. AuthParticlesWidget    — جزيئات تعوم للأعلى ببطء
//
// كلا الـ widgets مستقلّان — لكل منهما AnimationController خاص.
// يُضافان كطبقات في الـ Stack خلف الـ white panel → يظهران فقط
// في الجزء الداكن من الشاشة.
//
// الألوان من التحليل البصري للفيديو:
//   - Pulse peak  : Color(0xFF1C6377) — teal عميق
//   - Pulse rest  : Color(0xFF090D1B) — navy داكن
//   - Particles   : Color(0xFFB8BCC8) — رمادي-أزرق محايد
// ════════════════════════════════════════════════════════════════════════════

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// ══════════════════════════════════════════════════════════════════════════
//   PART 1 — RADIAL PULSE WIDGET
// ══════════════════════════════════════════════════════════════════════════

/// نبضة radial glow مزدوجة تشبه ضربة قلب.
///
/// الدورة (2400ms):
///   0%–8%   : ارتفاع سريع إلى ذروة (200ms)
///   8%–45%  : تلاشي بطيء إلى 10%  (900ms)
///   45%–50% : انخفاض لصفر          (100ms)
///   50%–58% : نبضة ثانوية (60%)   (200ms)
///   58%–85% : تلاشي تدريجي         (650ms)
///   85%–100%: راحة                 (350ms)
class AuthRadialPulseWidget extends StatefulWidget {
  const AuthRadialPulseWidget({
    super.key,
    this.centerAlignment = const Alignment(-0.35, -0.15),
    this.peakColor = const Color(0xFF1C6377),
  });

  /// مركز النبضة (على الجانب الداكن).
  final Alignment centerAlignment;

  /// لون الذروة.
  final Color peakColor;

  @override
  State<AuthRadialPulseWidget> createState() => _AuthRadialPulseState();
}

class _AuthRadialPulseState extends State<AuthRadialPulseWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _intensity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _intensity = TweenSequence<double>([
      // 0%–8%: ذروة أولى سريعة
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 8,
      ),
      // 8%–45%: تلاشي بطيء
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.08)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 37,
      ),
      // 45%–50%: انخفاض لصفر
      TweenSequenceItem(
        tween: Tween(begin: 0.08, end: 0.0),
        weight: 5,
      ),
      // 50%–58%: نبضة ثانوية
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.62)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 8,
      ),
      // 58%–85%: تلاشي ثانوي
      TweenSequenceItem(
        tween: Tween(begin: 0.62, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 27,
      ),
      // 85%–100%: راحة
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.0),
        weight: 15,
      ),
    ]).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _intensity,
      builder: (_, __) {
        final double v = _intensity.value;
        if (v <= 0.005) return const SizedBox.expand();
        return CustomPaint(
          painter: _RadialPulsePainter(
            centerAlignment: widget.centerAlignment,
            peakColor: widget.peakColor,
            intensity: v,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _RadialPulsePainter extends CustomPainter {
  const _RadialPulsePainter({
    required this.centerAlignment,
    required this.peakColor,
    required this.intensity,
  });

  final Alignment centerAlignment;
  final Color peakColor;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = centerAlignment.withinRect(Offset.zero & size);
    final double radius = math.max(size.width, size.height) * 0.75;

    // طبقة outer — ناعمة جداً
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            peakColor.withValues(alpha: 0.16 * intensity),
            peakColor.withValues(alpha: 0.06 * intensity),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    // طبقة inner — أكثر كثافة
    final double innerR = radius * 0.45;
    canvas.drawCircle(
      center,
      innerR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            peakColor.withValues(alpha: 0.22 * intensity),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: innerR)),
    );

    // halo صغير في المركز
    canvas.drawCircle(
      center,
      innerR * 0.25,
      Paint()
        ..color = peakColor.withValues(alpha: 0.18 * intensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
  }

  @override
  bool shouldRepaint(covariant _RadialPulsePainter old) =>
      old.intensity != intensity;
}

// ══════════════════════════════════════════════════════════════════════════
//   PART 2 — FLOATING PARTICLES WIDGET
// ══════════════════════════════════════════════════════════════════════════

/// جزيئات صغيرة تعوم للأعلى ببطء على الجانب الداكن.
///
/// مواصفات من الفيديو:
///   - عدد: ~25 جزيء
///   - حجم: 1–4 px
///   - لون: رمادي-أزرق محايد rgb(180–195)
///   - opacity: 0.25–0.65
///   - سرعة: بطيئة جداً (0.3–1.0 px/frame)
class AuthParticlesWidget extends StatefulWidget {
  const AuthParticlesWidget({super.key, this.count = 18});

  final int count;

  @override
  State<AuthParticlesWidget> createState() => _AuthParticlesState();
}

class _AuthParticlesState extends State<AuthParticlesWidget>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final List<_Particle> _particles = [];
  final math.Random _rng = math.Random(42);
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _initParticles(Size size) {
    if (_particles.isNotEmpty) return;
    for (int i = 0; i < widget.count; i++) {
      _particles.add(_Particle.random(_rng, size, spreadAcrossHeight: true));
    }
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    final double dt =
        (_last == Duration.zero ? 0 : (elapsed - _last).inMicroseconds / 1e6)
            .clamp(0.0, 0.05).toDouble();
    _last = elapsed;
    setState(() {
      for (final p in _particles) {
        p.update(dt);
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      _initParticles(size);
      for (final p in _particles) {
        p.boundsSize = size;
      }
      return CustomPaint(
        painter: _ParticlesPainter(particles: _particles),
        child: const SizedBox.expand(),
      );
    });
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speed,
    required this.driftX,
  });

  factory _Particle.random(
    math.Random rng,
    Size size, {
    bool spreadAcrossHeight = false,
  }) {
    return _Particle(
      x: rng.nextDouble() * size.width,
      y: spreadAcrossHeight
          ? rng.nextDouble() * size.height
          : size.height + rng.nextDouble() * 120,
      size: 1.0 + rng.nextDouble() * 3.0,
      opacity: 0.12 + rng.nextDouble() * 0.22,
      speed: 15.0 + rng.nextDouble() * 35.0, // px/sec
      driftX: (rng.nextDouble() - 0.5) * 10.0,
    );
  }

  double x, y;
  double size;
  double opacity;
  double speed;
  double driftX;
  Size boundsSize = Size.zero;

  void update(double dt) {
    y -= speed * dt;
    x += driftX * dt;
    // إعادة توليد الجزيء عند الوصول للأعلى
    if (y < -size * 2) {
      y = boundsSize.height + size * 2;
      x = math.Random().nextDouble() * boundsSize.width;
    }
    // الحد الأفقي
    if (x < 0) x = boundsSize.width;
    if (x > boundsSize.width) x = 0;
  }
}

class _ParticlesPainter extends CustomPainter {
  const _ParticlesPainter({required this.particles});

  final List<_Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // core
      canvas.drawCircle(
        Offset(p.x, p.y),
        p.size,
        Paint()
          ..color = const Color(0xFFB8BCC8).withValues(alpha: p.opacity),
      );
      // glow خفيف
      if (p.size > 2.0) {
        canvas.drawCircle(
          Offset(p.x, p.y),
          p.size * 2.2,
          Paint()
            ..color = const Color(0xFFBED8FA).withValues(alpha: p.opacity * 0.18)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter _) => true;
}
