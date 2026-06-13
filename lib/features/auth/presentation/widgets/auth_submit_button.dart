// ════════════════════════════════════════════════════════════════════════════
// auth_submit_button.dart
//
// زر الإجراء الموحّد لجميع صفحات Auth.
//
// يستبدل:
//   _Btn       في email_entry_page.dart
//   _SubmitBtn في login_page.dart
//   _SB        في set_password_page.dart
//   _B         في verify_code_page.dart
//
// الاختلاف الوحيد بين الأربعة كان:
//   - darkMode: يعكس الألوان (mobile/dark bg)
//   - withPulseAnimation: يُفعّل نبض التوهج
//   - icon: أيقونة مختلفة لكل صفحة
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';

/// زر Auth الموحّد — يدعم dark/light mode، pulse animation، وأيقونة اختيارية.
class AuthSubmitButton extends StatefulWidget {
  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.darkMode = false,
    this.withPulseAnimation = true,
    this.icon,
  });

  /// نص الزر.
  final String label;

  /// callback عند النقر.
  final VoidCallback onPressed;

  /// يعرض CircularProgressIndicator بدل النص.
  final bool isLoading;

  /// `false` = الزر معطّل (شفّاف).
  final bool isEnabled;

  /// `true` = خلفية بيضاء ونص كحلي (mobile/dark bg).
  /// `false` = خلفية كحلية ونص أبيض (desktop/light bg).
  final bool darkMode;

  /// `true` = أنيميشن نبض التوهج يعمل (email, verify, set_password).
  /// `false` = بدون pulse (login).
  final bool withPulseAnimation;

  /// أيقونة اختيارية تظهر يسار النص.
  final IconData? icon;

  @override
  State<AuthSubmitButton> createState() => _AuthSubmitButtonState();
}

class _AuthSubmitButtonState extends State<AuthSubmitButton>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // TweenSequence: نبضة سريعة ثم انحدار ثم فترة هدوء
    _pulseAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 8,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 37,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.0),
        weight: 55,
      ),
    ]).animate(_pulseCtrl);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool active = widget.isEnabled && !widget.isLoading;
    final Color bg = widget.darkMode ? Colors.white : AppColors.primary;
    final Color bgDisabled = widget.darkMode
        ? Colors.white.withValues(alpha: 0.25)
        : AppColors.primary.withValues(alpha: 0.25);
    final Color fg = widget.darkMode ? AppColors.primary : Colors.white;

    // إذا pulse معطّل، نستخدم const animation بدون rebuild
    final Listenable animation =
        widget.withPulseAnimation ? _pulseAnim : const AlwaysStoppedAnimation<double>(0.0);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final double glow =
            (active && widget.withPulseAnimation) ? _pulseAnim.value : 0.0;

        return MouseRegion(
          cursor:
              active ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: active ? widget.onPressed : null,
            child: AnimatedContainer(
              duration: AppSizes.animationFast,
              height: 50,
              decoration: BoxDecoration(
                color: active ? bg : bgDisabled,
                borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                boxShadow: active
                    ? [
                        if (_hovered)
                          BoxShadow(
                            color:
                                AppColors.primary.withValues(alpha: 0.22),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        if (widget.withPulseAnimation && glow > 0)
                          BoxShadow(
                            color: AppColors.authPulsePeak
                                .withValues(alpha: 0.45 * glow),
                            blurRadius: 20 + 10 * glow,
                            spreadRadius: 2 * glow,
                          ),
                      ]
                    : null,
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: fg,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.label,
                            style: AppTextStyles.buttonText.copyWith(
                              fontSize: AppSizes.fontLG,
                              fontWeight: FontWeight.w800,
                              color: fg,
                            ),
                          ),
                          if (widget.icon != null) ...[
                            const SizedBox(width: AppSizes.spaceSM),
                            Icon(
                              widget.icon,
                              size: AppSizes.iconMD,
                              color: fg,
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
