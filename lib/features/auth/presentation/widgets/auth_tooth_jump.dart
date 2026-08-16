// ════════════════════════════════════════════════════════════════════════════
// auth_tooth_jump.dart
//
// انيميشن قفزة السن مطابق لـ React `@keyframes toothJump` (6s ease-in-out
// infinite، transform-origin: center bottom). يغلّف أي ويدجت (عادةً AppLogo)
// دون المساس بدوران الخلفية القطري في AuthFlowShell.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

/// يطبّق قفزة دورية على [child] بنفس توقيت مرجع React:
/// 0/100% → راحة، 30% → −28px + scale 1.05، 50% → راحة،
/// 65% → −12px + scale 1.02، 80% → راحة.
class AuthToothJump extends StatefulWidget {
  const AuthToothJump({super.key, required this.child});

  final Widget child;

  @override
  State<AuthToothJump> createState() => _AuthToothJumpState();
}

class _AuthToothJumpState extends State<AuthToothJump>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _ty;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // translateY: 0 → -28 → 0 → -12 → 0 → 0
    _ty = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -28.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -28.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -12.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -12.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: 20,
      ),
    ]).animate(_ctrl);

    // scale: 1 → 1.05 → 1 → 1.02 → 1 → 1
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.02)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.02, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 20,
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
      animation: _ctrl,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _ty.value),
          child: Transform.scale(
            scale: _scale.value,
            alignment: Alignment.bottomCenter,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
