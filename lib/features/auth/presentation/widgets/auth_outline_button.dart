// ════════════════════════════════════════════════════════════════════════════
// auth_outline_button.dart
//
// زر Auth بشكل pill مع تعبئة تدرّجية ثابتة (#1a1a2e → #5959B3) ونص أبيض —
// مطابق لحالة التعبئة النهائية في مرجع React، بدون انيميشن hover.
// نبض التوهج الدوري يبقى اختيارياً عبر withPulseAnimation.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';

const Duration _kAuthTapCooldown = Duration(milliseconds: 600);
const double _kButtonHeight = 50.0;

class AuthOutlineButton extends StatefulWidget {
  const AuthOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.withPulseAnimation = true,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;

  /// `true` = نبض توهج دوري (email, verify, set_password).
  /// `false` = بدون نبض (login).
  final bool withPulseAnimation;

  final IconData? icon;

  @override
  State<AuthOutlineButton> createState() => _AuthOutlineButtonState();
}

class _AuthOutlineButtonState extends State<AuthOutlineButton>
    with SingleTickerProviderStateMixin {
  DateTime? _lastTapAt;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTapAt != null && now.difference(_lastTapAt!) < _kAuthTapCooldown) {
      return;
    }
    _lastTapAt = now;
    widget.onPressed();
  }

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _pulseAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 8),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 37,
      ),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 55),
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
    final Listenable pulse = widget.withPulseAnimation
        ? _pulseAnim
        : const AlwaysStoppedAnimation<double>(0.0);
    final Color fg = active
        ? Colors.white
        : Colors.white.withValues(alpha: 0.55);
    final Color borderColor = active
        ? AppColors.authBorderBlue
        : AppColors.authBorderBlue.withValues(alpha: 0.35);

    return Semantics(
      button: true,
      enabled: active,
      label: widget.label,
      child: Focus(
        canRequestFocus: active,
        onKeyEvent: (node, event) {
          if (active &&
              event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.space)) {
            _handleTap();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: MouseRegion(
          cursor: active ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: active ? _handleTap : null,
            child: AnimatedBuilder(
              animation: pulse,
              builder: (context, _) {
                final double glow = (active && widget.withPulseAnimation)
                    ? _pulseAnim.value
                    : 0.0;

                return Container(
                  height: _kButtonHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_kButtonHeight / 2),
                    border: Border.all(color: borderColor, width: 2),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: active
                          ? const [
                              AppColors.authHoverFillStart,
                              AppColors.authGlowBlue,
                            ]
                          : [
                              AppColors.authHoverFillStart
                                  .withValues(alpha: 0.45),
                              AppColors.authGlowBlue.withValues(alpha: 0.45),
                            ],
                    ),
                    boxShadow:
                        (active && widget.withPulseAnimation && glow > 0)
                            ? [
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
