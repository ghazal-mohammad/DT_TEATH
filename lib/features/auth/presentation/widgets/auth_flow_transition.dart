// ════════════════════════════════════════════════════════════════════════════
// auth_flow_transition.dart
//
// انيميشن انتقال بين صفحات Auth (email → verify → password / login).
//
// مطابق حرفياً لتسلسل الفيديو المرجعي (AuthScreen → style.css):
//   التوقيت (منسوب لكامل المدة، مأخوذ من transition-delay بالـ CSS):
//     • المحتوى الصادر ينزلق ويتلاشى      :  0%  → 40%
//     • background-shape يدور skewY(40→0)  : 18% → 71%
//     • secondary-shape يدور skewY(0→-41)  : 43% → 96%
//     • المحتوى الوارد ينزلق + يزول blur   : 60% → 100%
//
//   ← الشكل القطري يدور (skewY + rotate) بالمنتصف بعد ما يطلع المحتوى القديم
//     وقبل ما يدخل الجديد — تماماً مثل دوران الـ shapes بالفيديو.
//
// الألوان: AppColors.authNavyGradient + AppColors.accent فقط (صفر تغيير تصميم).
// المدة الإجمالية: 1900ms.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

/// إنشاء CustomTransitionPage بانيميشن الـ auth flow.
///
/// [direction] = 1: الصفحة الجديدة تدخل من اليمين البصري (forward)
/// [direction] = -1: تدخل من اليسار البصري (back)
CustomTransitionPage<void> authFlowPage({
  required LocalKey key,
  required Widget child,
  int direction = 1,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 1900),
    reverseTransitionDuration: const Duration(milliseconds: 1900),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return _AuthFlowTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        direction: direction,
        child: child,
      );
    },
  );
}

class _AuthFlowTransition extends StatelessWidget {
  const _AuthFlowTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.direction,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final int direction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final dir = (isRtl ? -1 : 1) * direction.toDouble();

    // ════════════════════════════════════════════════════════════════════════
    // ثلاث مراحل بلا أي لحظة مكشوفة — بدون "حيط" يطمس الشاشة:
    //   1) 0%  → 40% : الصفحة الصادرة تنزلق وتتلاشى، وتحتها بتظهر تدريجياً
    //                  خلفية كحلية وسيطة (نفس خلفية صفحات الـ auth) — فما في
    //                  أبداً فراغ/أسود بين الصفحتين.
    //   2) ~30%→ ~75%: الشكل القطري المتوهّج يكتسح فوق الخلفية الوسيطة —
    //                  مرئي كشكل (مش غطاء مصمت) تماماً مثل الفيديو.
    //   3) 64% → 100%: الصفحة الواردة تنكشف (انزلاق + إزالة blur).
    // ════════════════════════════════════════════════════════════════════════

    // ── الصفحة الصادرة (secondaryAnimation) ─────────────────────────────────
    final outgoingSlide = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-0.30 * dir, 0),
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.0, 0.42, curve: Curves.easeInCubic),
    ));

    final outgoingOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: secondaryAnimation,
        curve: const Interval(0.08, 0.40, curve: Curves.easeIn),
      ),
    );

    // ── الصفحة الواردة (animation) ───────────────────────────────────────────
    // مخفية تماماً حتى 64% — تنكشف فقط بعد ما يكون الغطاء غطّى التبديل.
    final incomingSlide = Tween<Offset>(
      begin: Offset(0.22 * dir, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.64, 1.0, curve: Curves.easeOutCubic),
    ));

    final incomingOpacity = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.64, 0.92, curve: Curves.easeOut),
    );

    final incomingBlur = Tween<double>(begin: 10, end: 0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.64, 0.96, curve: Curves.easeOut),
      ),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([animation, secondaryAnimation]),
      builder: (context, _) {
        final bool isOutgoing = secondaryAnimation.value > 0 &&
            secondaryAnimation.status != AnimationStatus.dismissed;

        // ════ هذه الصفحة هي الصادرة ════════════════════════════════════════
        if (isOutgoing) {
          return Opacity(
            opacity: outgoingOpacity.value.clamp(0.0, 1.0),
            child: FractionalTranslation(
              translation: outgoingSlide.value,
              child: child,
            ),
          );
        }

        // ════ هذه الصفحة هي الواردة ════════════════════════════════════════
        final double u = animation.value;
        final double blur = incomingBlur.value;

        Widget content = TickerMode(
          enabled: u >= 0.62,
          child: child,
        );

        if (blur > 0.05) {
          content = ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: content,
          );
        }

        content = Opacity(
          opacity: incomingOpacity.value.clamp(0.0, 1.0),
          child: FractionalTranslation(
            translation: incomingSlide.value,
            child: content,
          ),
        );

        // ترتيب الطبقات: خلفية كحلية وسيطة (تمنع أي فراغ) ← المحتوى الوارد
        // ← الشكل القطري الكاسح فوقهما.
        return Stack(
          fit: StackFit.expand,
          children: [
            // الخلفية الوسيطة — تظهر مبكراً تحت الصفحة الصادرة وتختفي
            // تلقائياً لما يكتمل الانتقال (المحتوى فوقها مصمت).
            // ملاحظة: DecoratedBox مباشرة (ممنوع AuthNavyBackground هنا لأنه
            // Positioned.fill — لفّه بـ Opacity يكسر الـ Stack: ParentDataWidget).
            if (u < 0.995)
              Opacity(
                opacity: const Interval(0.10, 0.32, curve: Curves.easeOut)
                    .transform(u),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.authNavyGradient,
                  ),
                ),
              ),
            content,
            IgnorePointer(
              child: _RotatingShapes(progress: u, dir: dir),
            ),
          ],
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//   الشكلان القطريان الدوّاران — محاكاة background-shape + secondary-shape
// ════════════════════════════════════════════════════════════════════════════
//
// شكلان كحليان أكبر من الشاشة يدوران (rotate + skewY) ويُترجمان أفقياً عبر
// الشاشة. الأول (secondary) يقود الحركة، والثاني (background) يتبعه بفارق طور —
// تماماً مثل تتابع الـ shapes بالفيديو. الحافة الأمامية تتوهّج accent.
//
// زوايا التسليم عند الحواف تساوي ميل القاطع الثابت بالصفحات (≈35°) ليبدو
// الشكل وكأنه القاطع نفسه ينفصل ويدور ثم يستقر بالصفحة الجديدة.
class _RotatingShapes extends StatelessWidget {
  const _RotatingShapes({required this.progress, required this.dir});

  /// 0 → 1 خلال كامل الانتقال.
  final double progress;

  /// اتجاه الحركة (1 للأمام، -1 للخلف).
  final double dir;

  // ميل القاطع الثابت بالصفحات (الخط من 0.75W,0 إلى 0.25W,H) ≈ 35°.
  static const double _handoffTilt = 0.62; // راديان

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final double w = c.maxWidth;
        final double h = c.maxHeight;

        return Stack(
          fit: StackFit.expand,
          children: [
            // background-shape — صدى خلفي يقود الحركة (طبقة عمق بلا توهّج).
            _buildShape(
              w: w,
              h: h,
              phase: _remap(progress, 0.10, 0.80),
              fill: AppColors.authNavyGradient,
              edgeAlpha: 0.0,
              skewScale: 1.0,
            ),
            // secondary-shape — الشكل الأمامي المتوهّج المرئي (الخلفية
            // الوسيطة تحته هي اللي تمنع الفراغ — مش حجمه).
            _buildShape(
              w: w,
              h: h,
              phase: _remap(progress, 0.26, 0.96),
              fill: AppColors.authNavyGradient,
              edgeAlpha: 0.9,
              skewScale: 1.15,
            ),
          ],
        );
      },
    );
  }

  /// يعيد تموضع p من المجال [a,b] إلى [0,1] (مع قصّ خارج المجال).
  double _remap(double p, double a, double b) =>
      ((p - a) / (b - a)).clamp(0.0, 1.0);

  Widget _buildShape({
    required double w,
    required double h,
    required double phase,
    required Gradient fill,
    required double edgeAlpha,
    required double skewScale,
  }) {
    // منحنى ناعم — يبطئ بالمنتصف ليُظهر الدوران.
    final double e = Curves.easeInOutCubic.transform(phase);

    // التوهّج يبلغ ذروته بالمنتصف.
    final double glow = (1.0 - (2.0 * phase - 1.0).abs()).clamp(0.0, 1.0);

    // خارج الشاشة تماماً → لا رسم.
    if (phase <= 0.0 || phase >= 1.0) return const SizedBox.shrink();

    // عرض الكاسح 2.2w — شريط قطري مرئي يمرّ عبر الشاشة (مثل الفيديو)؛
    // الخلفية الوسيطة تحته تتكفّل بعدم انكشاف أي فراغ.
    final double sweepW = w * 2.2;

    // الترجمة: من خارج جهة الدخول إلى خارج الجهة المقابلة.
    final double tx = lerpDouble(2.3 * w * dir, -2.3 * w * dir, e)!;

    // الدوران: يمرّ من ميل القاطع (+tilt) عبر العمودي إلى الميل المعاكس.
    final double angle = lerpDouble(_handoffTilt * dir, -_handoffTilt * dir, e)!;

    // skewY إضافي (مثل CSS) يقوّي إحساس الدوران؛ يتلاشى عند المنتصف.
    final double skew = math.tan(lerpDouble(0.45, -0.45, e)! * skewScale) * 0.6;

    if (tx.abs() > 2.25 * w) return const SizedBox.shrink();

    final Matrix4 m = Matrix4.translationValues(tx, 0, 0)
      ..rotateZ(angle)
      ..setEntry(1, 0, skew); // skewY

    return Transform(
      transform: m,
      alignment: Alignment.center,
      child: OverflowBox(
        minWidth: 0,
        maxWidth: double.infinity,
        minHeight: 0,
        maxHeight: double.infinity,
        child: Container(
          width: sweepW,
          height: h * 3,
          decoration: BoxDecoration(
            gradient: fill,
            border: edgeAlpha <= 0
                ? null
                : Border(
                    left: BorderSide(
                      color: AppColors.accent
                          .withValues(alpha: edgeAlpha * glow),
                      width: 3,
                    ),
                    right: BorderSide(
                      color: AppColors.accent
                          .withValues(alpha: edgeAlpha * glow),
                      width: 3,
                    ),
                  ),
            boxShadow: edgeAlpha <= 0
                ? null
                : [
                    BoxShadow(
                      color:
                          AppColors.accent.withValues(alpha: 0.55 * glow),
                      blurRadius: 64,
                      spreadRadius: 4,
                    ),
                  ],
          ),
          // لمعة تركواز شفافة بعرض الشريط — تميّزه بوضوح فوق الخلفية
          // الكحلية الوسيطة (وإلا كان كحلي-فوق-كحلي بالكاد يبان).
          child: edgeAlpha <= 0
              ? null
              : DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.accent.withValues(alpha: 0.16 * glow),
                        AppColors.accent.withValues(alpha: 0.04 * glow),
                        Colors.transparent,
                        AppColors.accent.withValues(alpha: 0.04 * glow),
                        AppColors.accent.withValues(alpha: 0.16 * glow),
                      ],
                      stops: const [0.0, 0.12, 0.5, 0.88, 1.0],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
