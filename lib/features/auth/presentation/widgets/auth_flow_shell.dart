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

/// موضعا طرفي الفاصل القطري (كنسبة من العرض): الطرف الأبعد والأقرب للمنتصف.
/// الفرق بينهما = حدّة ميل القطر (~0.20w) — يبقى مائلًا بحدّة قريبًا من العمودي.
const double _kSeamLeanHi = 0.60; // الطرف المائل بعيدًا عن المنتصف
const double _kSeamLeanLo = 0.40; // الطرف المائل نحو المنتصف

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
//   ROTATING BACKGROUND — قطر مائل ينزلق (skew sweep) لا يدور كالمروحة
// ══════════════════════════════════════════════════════════════════════════

/// خلفية الدخول: كحلي متدرّج + لوحة بيضاء بقطر **مائل بحدّة** ينزلق أفقياً
/// وينعكس ميله بين الخطوتين — مطابقةً لحركة مرجع AuthScreen (skewY على الأشكال)
/// لا دورانًا كاملاً يمرّ بالوضع الأفقي (windmill) الذي كان يبدو خاطئاً.
///
/// [progress] 0 = الأبيض على اليمين (email/login/setPassword)،
///            1 = الأبيض على اليسار (verify).
/// القطر يبقى قريبًا من العمودي طوال الحركة (لا يصبح أفقيًا أبدًا)، والأبيض
/// يتبادل جهته عبر تلاشٍ متقاطع قصير عند المنتصف حيث يكون الفاصل عموديًا.
class AuthRotatingBackground extends StatelessWidget {
  const AuthRotatingBackground({
    super.key,
    required this.progress,
    required this.glowPhase,
  });

  final double progress;
  final double glowPhase;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, box) {
        final double w = box.maxWidth, h = box.maxHeight;
        final double p = progress;

        // طرفا الفاصل ينزلقان أفقيًا مع انعكاس الميل (top ↔ bottom) — القطر
        // يبقى مائلًا بحدّة (±0.10w حول المنتصف) ولا يمرّ بالوضع الأفقي.
        final double topX = _lerp(w * _kSeamLeanHi, w * _kSeamLeanLo, p);
        final double botX = _lerp(w * _kSeamLeanLo, w * _kSeamLeanHi, p);

        // تبديل جهة الأبيض بتلاشٍ متقاطع قصير حول المنتصف (نافذة 0.42→0.58).
        final double rightOp =
            (1 - (p - 0.42) / 0.16).clamp(0.0, 1.0);
        final double leftOp = ((p - 0.42) / 0.16).clamp(0.0, 1.0);

        return Stack(
          fit: StackFit.expand,
          children: [
            // الكحلي المتدرّج الأصلي — أساس دائم.
            const AuthNavyBackground(),

            // الأبيض على اليمين (يتلاشى قرب المنتصف).
            if (rightOp > 0.001)
              Opacity(
                opacity: rightOp,
                child: ClipPath(
                  clipper:
                      AuthDiagRightClipper(topX: topX, botX: botX, W: w, H: h),
                  child: const ColoredBox(color: Colors.white),
                ),
              ),

            // الأبيض على اليسار (يظهر بعد المنتصف).
            if (leftOp > 0.001)
              Opacity(
                opacity: leftOp,
                child: ClipPath(
                  clipper:
                      AuthDiagLeftClipper(topX: topX, botX: botX, W: w, H: h),
                  child: const ColoredBox(color: Colors.white),
                ),
              ),

            // خط التوهج النابض على الفاصل.
            Positioned.fill(
              child: CustomPaint(
                painter: AuthGlowLinePainter(
                  start: Offset(topX, 0),
                  end: Offset(botX, h),
                  phase: glowPhase,
                  glowColor: AppColors.accent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}
