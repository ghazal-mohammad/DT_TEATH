// ════════════════════════════════════════════════════════════════════════════
// auth_entry_animator.dart
//
// 🎬 Staggered Entry Animation لعناصر الـ Auth form.
//
// يُغلّف أي عنصر بـ Slide + Blur + Fade مع stagger متتالي.
// مطابق للأنيميشن المرجعي بالفيديو: translateX + blur(10→0) + opacity(0→1).
//
// الاستخدام:
//   AuthEntryAnimator(
//     controller: _entryCtrl,
//     delay: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
//     child: MyWidget(),
//   )
// ════════════════════════════════════════════════════════════════════════════

import 'dart:ui';

import 'package:flutter/material.dart';

/// يُحرّك child بـ slide + blur + fade.
///
/// [controller] : AnimationController الخارجي (يمتد من 0→1 مرة واحدة).
/// [delay]      : Interval يحدد متى يبدأ ومتى ينتهي هذا العنصر.
/// [slideOffset]: مقدار الإزاحة البدائية (الافتراضي: 60px أفقي).
/// [maxBlur]    : أقصى blur بـ pixels (الافتراضي: 10 — مطابق CSS).
class AuthEntryAnimator extends StatelessWidget {
  const AuthEntryAnimator({
    super.key,
    required this.controller,
    required this.delay,
    required this.child,
    this.slideOffset = const Offset(60, 0),
    this.maxBlur = 10,
  });

  final AnimationController controller;
  final Interval delay;
  final Widget child;
  final Offset slideOffset;
  final double maxBlur;

  @override
  Widget build(BuildContext context) {
    final Animation<double> driven = CurvedAnimation(
      parent: controller,
      curve: delay,
    );
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final Offset effectiveOffset =
        Offset(isRtl ? -slideOffset.dx : slideOffset.dx, slideOffset.dy);

    return AnimatedBuilder(
      animation: driven,
      child: child,
      builder: (_, c) {
        final double t = driven.value;
        final double inv = 1.0 - t;
        final double blur = maxBlur * inv;

        Widget result = Transform.translate(
          offset: Offset(effectiveOffset.dx * inv, effectiveOffset.dy * inv),
          child: Opacity(opacity: t.clamp(0.0, 1.0), child: c),
        );

        // blur ينطفئ تماماً عند t≈1 لتجنّب تكلفة الـ ImageFilter وقت السكون
        if (blur > 0.05) {
          result = ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: result,
          );
        }
        return result;
      },
    );
  }
}

/// عدة مؤقتات stagger جاهزة للاستخدام.
class AuthStaggerDelays {
  AuthStaggerDelays._();

  static const Interval logo = Interval(0.00, 0.35, curve: Curves.easeOutCubic);
  static const Interval icon = Interval(0.10, 0.45, curve: Curves.easeOutCubic);
  static const Interval title = Interval(0.18, 0.52, curve: Curves.easeOutCubic);
  static const Interval subtitle = Interval(0.26, 0.58, curve: Curves.easeOutCubic);
  static const Interval field1 = Interval(0.34, 0.64, curve: Curves.easeOutCubic);
  static const Interval field2 = Interval(0.40, 0.70, curve: Curves.easeOutCubic);
  static const Interval button = Interval(0.50, 0.78, curve: Curves.easeOutCubic);
  static const Interval footer = Interval(0.58, 0.85, curve: Curves.easeOutCubic);
}
