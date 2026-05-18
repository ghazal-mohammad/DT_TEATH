// ════════════════════════════════════════════════════════════════════════════
// auth_page_transition.dart
//
// يحتوي على:
//   1. AuthCardGlowBorder  — كارت بـ glow سماوي نابض (مستخدم في كل صفحات Auth)
//   2. AuthPanelEntryTransition — انيميشن دخول panel اختياري
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════════════════
//   AUTH CARD GLOW BORDER
// ══════════════════════════════════════════════════════════════════════════

/// يُغلّف أي widget بـ glow سماوي نابض على الحدود — مستوحى من الفيديو.
///
/// الاستخدام:
/// ```dart
/// AuthCardGlowBorder(
///   glowColor: AppColors.accent,
///   child: myPage,
/// )
/// ```
class AuthCardGlowBorder extends StatefulWidget {
  const AuthCardGlowBorder({
    super.key,
    required this.child,
    this.glowColor = AppColors.accent,
    this.borderRadius = 0.0,
  });

  final Widget child;
  final Color glowColor;

  /// 0 للصفحات الـ full-screen، وقيمة موجبة للكروت الداخلية.
  final double borderRadius;

  @override
  State<AuthCardGlowBorder> createState() => _AuthCardGlowBorderState();
}

class _AuthCardGlowBorderState extends State<AuthCardGlowBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) {
        final double v = _anim.value;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              // توهج خارجي واسع
              BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.12 + 0.10 * v),
                blurRadius: 24 + 16 * v,
                spreadRadius: 2 + 4 * v,
              ),
              // توهج حاد داخلي
              BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.06 + 0.06 * v),
                blurRadius: 8,
              ),
            ],
          ),
          child: widget.borderRadius > 0
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: child,
                )
              : child,
        );
      },
      child: widget.child,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//   AUTH PANEL ENTRY TRANSITION — اختياري للاستخدام المستقبلي
// ══════════════════════════════════════════════════════════════════════════

/// يُحرّك child بـ slide + fade عند دخوله.
///
/// [controller] يبدأ من 0→1 عند mount، و1→0 قبل التنقل.
/// [fromRight]  true = يدخل من اليمين، false = من اليسار.
class AuthPanelEntryTransition extends StatelessWidget {
  const AuthPanelEntryTransition({
    super.key,
    required this.controller,
    required this.child,
    this.fromRight = true,
  });

  final AnimationController controller;
  final Widget child;
  final bool fromRight;

  @override
  Widget build(BuildContext context) {
    final Animation<Offset> slide = Tween<Offset>(
      begin: fromRight ? const Offset(0.15, 0) : const Offset(-0.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    ));

    final Animation<double> fade = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    return SlideTransition(
      position: slide,
      child: FadeTransition(opacity: fade, child: child),
    );
  }
}
