// ════════════════════════════════════════════════════════════════════════════
// auth_flow_transition.dart
//
// انيميشن انتقال بين صفحات Auth (email → verify → password / login).
//
// مستوحى من مرجع HTML AuthScreen — slide + fade + blur متداخل بين البانلات
// مع لمسة تدوير خفيفة (rotation) لمحاكاة إحساس "دوران" العناصر.
//
// لا overlay يغطي الشاشة — يعتمد كلياً على تحويلات الصفحات نفسها.
// المدة الإجمالية: 1400ms. الصفحات نفسها لا تتغير محتوياتها.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    transitionDuration: const Duration(milliseconds: 1400),
    reverseTransitionDuration: const Duration(milliseconds: 1400),
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

    // ── الصفحة الصادرة (عبر secondaryAnimation) ────────────────────────
    // تنزلق لليسار + تخف + تدور قليلاً  — كل المدة (0% → 55%)
    final outgoingSlide = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-1.1 * dir, 0),
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.0, 0.55, curve: Curves.easeInCubic),
    ));

    final outgoingOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: secondaryAnimation,
        curve: const Interval(0.05, 0.45, curve: Curves.easeIn),
      ),
    );

    final outgoingRotate = Tween<double>(begin: 0, end: -0.08).animate(
      CurvedAnimation(
        parent: secondaryAnimation,
        curve: const Interval(0.0, 0.55, curve: Curves.easeIn),
      ),
    );

    // ── الصفحة الواردة (عبر animation) ──────────────────────────────────
    // تبدأ بالدخول قبل ما تخلص الصادرة (overlap بين 40%-95%) لتفادي الفراغ
    final incomingSlide = Tween<Offset>(
      begin: Offset(1.1 * dir, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.4, 0.95, curve: Curves.easeOutCubic),
    ));

    final incomingOpacity = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
    );

    final incomingBlur = Tween<double>(begin: 8, end: 0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.4, 0.85, curve: Curves.easeOut),
      ),
    );

    final incomingRotate = Tween<double>(begin: 0.08, end: 0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.4, 0.95, curve: Curves.easeOut),
      ),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([animation, secondaryAnimation]),
      builder: (context, _) {
        // الانيميشن السائد على الصفحة: إما هي الواردة (animation < 1)
        // أو هي الصادرة (secondaryAnimation > 0).
        final isOutgoing = secondaryAnimation.value > 0 &&
            secondaryAnimation.status != AnimationStatus.dismissed;

        final slide = isOutgoing ? outgoingSlide.value : incomingSlide.value;
        final opacity = isOutgoing
            ? outgoingOpacity.value
            : incomingOpacity.value;
        final rotate = isOutgoing ? outgoingRotate.value : incomingRotate.value;
        final blur = isOutgoing ? 0.0 : incomingBlur.value;

        Widget content = TickerMode(
          // أوقف الـ tickers الداخلية للصفحة الواردة حتى تبدأ بالظهور فعلياً
          enabled: isOutgoing || animation.value >= 0.4,
          child: child,
        );

        if (blur > 0.01) {
          content = ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: content,
          );
        }

        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: FractionalTranslation(
            translation: slide,
            child: Transform.rotate(
              angle: rotate,
              alignment: Alignment.center,
              child: content,
            ),
          ),
        );
      },
    );
  }
}
