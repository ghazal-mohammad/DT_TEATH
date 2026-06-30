// ════════════════════════════════════════════════════════════════════════════
// auth_flow_transition.dart
//
// انتقال نظيف وسريع بين صفحات Auth (login ↔ email ↔ verify ↔ password):
//   fade + انزلاق أفقي خفيف، بلا blur ولا أشكال ثقيلة.
//
// لماذا بسيط؟ الإصدار السابق (1.9s + ImageFilter blur + أشكال قطرية دوّارة
// ضخمة + skew) كان بطيئاً ومتقطّعاً (jank) ويُحدث قفزة بصرية. هذا الإصدار
// خفيف على الإطار (transform/opacity فقط) فيكون ناعماً وسريعاً.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// مدّة الانتقال للأمام/للخلف — سريعة وأنيقة.
const Duration _kForward = Duration(milliseconds: 420);
const Duration _kReverse = Duration(milliseconds: 360);

/// إنشاء CustomTransitionPage بانتقال الـ auth flow.
///
/// [direction] = 1: الصفحة الجديدة تدخل من جهة الاتجاه (forward)
/// [direction] = -1: تدخل من الجهة المقابلة (back)
CustomTransitionPage<void> authFlowPage({
  required LocalKey key,
  required Widget child,
  int direction = 1,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: _kForward,
    reverseTransitionDuration: _kReverse,
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

    // الصفحة الواردة (animation): تنزلق قليلاً من جهة الاتجاه + تظهر.
    final inSlide = Tween<Offset>(
      begin: Offset(0.06 * dir, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
    final inFade = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    // الصفحة الصادرة (secondaryAnimation): تنزلق قليلاً للجهة المقابلة + تتلاشى.
    final outSlide = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-0.04 * dir, 0),
    ).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInCubic));
    final outFade = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // الترتيب: حالة الخروج (الخارجية) ثم حالة الدخول (الداخلية) — كل صفحة تدير
    // دخولها (animation) وخروجها (secondaryAnimation) على نفس الـ child.
    return FadeTransition(
      opacity: outFade,
      child: SlideTransition(
        position: outSlide,
        child: FadeTransition(
          opacity: inFade,
          child: SlideTransition(
            position: inSlide,
            child: child,
          ),
        ),
      ),
    );
  }
}
