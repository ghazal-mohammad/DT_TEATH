// ════════════════════════════════════════════════════════════════════════════
// auth_flow_shell.dart
//
// شِل واحد دائم يلفّ كل خطوات الدخول (login / email / verify / setPassword)
// عبر ShellRoute. يحمل خلفية قطرية **دائمة** لا تُهدَم بين الخطوات، فتدور نصف
// دورة عند الانتقال — يتبادل الأبيض/الكحلي جانبيهما بسلاسة (مطابق للمرجع
// AuthScreen: حاوية واحدة + شكل قطري يدور عند .toggled).
//
// المحتوى (شعار + نموذج) لكل خطوة يبقى في صفحته ويتلاشى عبر انتقال الراوت
// (authFlowPage)، بينما الخلفية تدور تحته — فيبدو كأن كل شيء يدور للخطوة التالية.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'auth_layout_painters.dart';

/// زاوية الميل القطري للفاصل (راديان) — الحالة الأساسية (الأبيض على اليمين).
/// سالبة = ميل مطابق لاتجاه القطر في التصميم الأصلي.
const double _kDiagLean = -0.18;

/// مدّة دوران الخلفية بين الخطوات — مطابِقة لمرجع AuthScreen تماماً:
/// `.background-shape { transition: 1.5s ease }`. مُزامَنة مع انتقال المحتوى.
const Duration _kRotationDuration = Duration(milliseconds: 1500);

/// الشِل الدائم لخطوات الدخول. [flipped] = true يعني الأبيض على اليسار
/// (شاشة التحقق)، false = الأبيض على اليمين (email/login/setPassword).
class AuthFlowShell extends StatefulWidget {
  const AuthFlowShell({
    super.key,
    required this.flipped,
    required this.child,
  });

  final bool flipped;
  final Widget child;

  @override
  State<AuthFlowShell> createState() => _AuthFlowShellState();
}

class _AuthFlowShellState extends State<AuthFlowShell>
    with TickerProviderStateMixin {
  // تقدّم الدوران: 0 = الأبيض يمين، 1 = الأبيض يسار. دائم طوال عمر الشِل.
  late final AnimationController _rot;
  // نبض خط التوهج — تكرار لا نهائي، دائم (لا يُعاد تشغيله كل خطوة = أنعم).
  late final AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _rot = AnimationController(
      vsync: this,
      duration: _kRotationDuration,
      value: widget.flipped ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant AuthFlowShell old) {
    super.didUpdateWidget(old);
    // عند تغيّر الخطوة (الجانب)، ندوّر الخلفية نحو الحالة الجديدة.
    if (old.flipped != widget.flipped) {
      widget.flipped ? _rot.forward() : _rot.reverse();
    }
  }

  @override
  void dispose() {
    _rot.dispose();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: LayoutBuilder(
        builder: (_, box) {
          final bool isMobile = box.maxWidth < 750;
          return Stack(
            children: [
              // الخلفية الدائمة — تدور على سطح المكتب، ثابتة كحلية على الموبايل.
              Positioned.fill(
                child: isMobile
                    ? const AuthNavyBackground()
                    : AnimatedBuilder(
                        animation: Listenable.merge([_rot, _glow]),
                        builder: (_, __) => AuthRotatingBackground(
                          // Curves.ease = cubic-bezier(0.25,0.1,0.25,1) = CSS `ease`
                          // (نفس منحنى انتقال المرجع تماماً).
                          progress: Curves.ease.transform(_rot.value),
                          glowPhase: _glow.value * 2 * math.pi,
                        ),
                      ),
              ),
              // محتوى الخطوة الحالية (شفّاف) فوق الخلفية.
              Positioned.fill(child: widget.child),
            ],
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//   ROTATING BACKGROUND — نصف مستوٍ أبيض يدور حول مركز الشاشة
// ══════════════════════════════════════════════════════════════════════════

/// خلفية الدخول الدائرة: خلفية كحلية + نصف مستوٍ أبيض يدور حول مركز الشاشة.
///
/// [progress] 0→1: الفاصل يدور نصف دورة (π) فيتبادل الأبيض جانبه من اليمين
/// لليسار. لأن الفاصل يمرّ دائماً بمركز الشاشة، تبقى النسبة ~50/50 طوال الدوران
/// (لا غسيل ولا تغطية كاملة في المنتصف).
class AuthRotatingBackground extends StatelessWidget {
  const AuthRotatingBackground({
    super.key,
    required this.progress,
    required this.glowPhase,
  });

  /// 0 = الأبيض على اليمين، 1 = الأبيض على اليسار.
  final double progress;

  /// طور نبض خط التوهج (value * 2π).
  final double glowPhase;

  @override
  Widget build(BuildContext context) {
    // زاوية الفاصل: تبدأ بالميل الأساسي وتزيد π (نصف دورة) مع التقدّم.
    final double theta = _kDiagLean + progress * math.pi;

    return Stack(
      fit: StackFit.expand,
      children: [
        // الخلفية الكحلية المتدرّجة (نفس authNavyGradient الأصلي) — أساس دائم
        // تحت النصف الأبيض الدوّار. بدونها يظهر darkBg المسطّح فيبدو الكحلي مختلفاً.
        const AuthNavyBackground(),
        CustomPaint(
          painter: _RotatingDividerPainter(
            theta: theta,
            glowPhase: glowPhase,
            glowColor: AppColors.accent,
          ),
          child: const SizedBox.expand(),
        ),
      ],
    );
  }
}

/// يرسم النصف المستوي الأبيض (مقصوصاً نصف-مستوٍ يدور حول المركز) + خط التوهج
/// النابض على الفاصل. يعيد استخدام طبقات التوهج عبر [AuthGlowLinePainter].
class _RotatingDividerPainter extends CustomPainter {
  const _RotatingDividerPainter({
    required this.theta,
    required this.glowPhase,
    required this.glowColor,
  });

  final double theta;
  final double glowPhase;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2);
    // أبعد من قطر الشاشة لضمان تغطية النصف بالكامل بعد الدوران.
    final double big = (size.width + size.height) * 2;

    // ── النصف المستوي الأبيض ───────────────────────────────────────────────
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(theta);
    // في الإطار المُدوَّر: النصف x ≥ 0 (يمين المركز) أبيض. عند theta=0 = يمين
    // الشاشة؛ عند theta=π = يسارها.
    final Rect half = Rect.fromLTWH(0, -big, big, 2 * big);
    canvas.clipRect(half);
    canvas.drawRect(half, Paint()..color = Colors.white);
    canvas.restore();

    // ── خط التوهج على الفاصل (x=0 في الإطار المُدوَّر) ──────────────────────
    // نقطتا طرفه على بُعد كبير على جانبي المركز.
    final double s = math.sin(theta), co = math.cos(theta);
    final double L = size.width + size.height;
    final Offset p1 = Offset(c.dx - L * s, c.dy + L * co);
    final Offset p2 = Offset(c.dx + L * s, c.dy - L * co);

    AuthGlowLinePainter(
      start: p1,
      end: p2,
      phase: glowPhase,
      glowColor: glowColor,
    ).paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant _RotatingDividerPainter old) =>
      old.theta != theta ||
      old.glowPhase != glowPhase ||
      old.glowColor != glowColor;
}
