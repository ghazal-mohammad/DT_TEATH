// ════════════════════════════════════════════════════════════════════════════
// password_strength_meter.dart
//
// Widget يعرض قوة كلمة المرور بصرياً.
// 3 مستويات: ضعيفة (أحمر), متوسطة (أصفر), قوية (أخضر cyan)
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';

class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({
    super.key,
    required this.password,
  });

  final String password;

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      // حتى لما الحقل فاضي، نعرض الـ checklist (كلها رمادية) عشان
      // المستخدم يعرف الشروط من البداية.
      return _buildRequirementsList(context, password);
    }

    final PasswordStrength strength = Validators.passwordStrength(password);
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    final Color color = _resolveColor(strength);
    final String label = _resolveLabel(context, strength);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Bars ──
          Row(
            children: List.generate(3, (i) {
              final bool isActive = _isBarActive(i, strength);
              return Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: i < 2 ? 4 : 0,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 5,
                    decoration: BoxDecoration(
                      color: isActive
                          ? color
                          : (isLight
                              ? AppColors.lightBorder
                              : AppColors.darkBorder),
                      borderRadius: BorderRadius.circular(2.5),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 8),

          // ── Label ──
          Text(
            '${Localizations.localeOf(context).languageCode == 'ar' ? 'القوة' : 'Strength'}: $label',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),

          // ── Requirements checklist ──
          _buildRequirementsList(context, password),
        ],
      ),
    );
  }

  /// قائمة شروط كلمة المرور — كل شرط له أيقونة (✓ أخضر / ○ رمادي).
  /// تعكس فعلياً منطق Validators.passwordStrength: طول، حالة كبيرة،
  /// حالة صغيرة، رقم، رمز.
  Widget _buildRequirementsList(BuildContext context, String pwd) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    // أخضر للشروط المحققة — كحلي فاتح للشروط الناقصة
    final Color metColor = AppColors.success;
    final Color unmetColor = isLight
        ? AppColors.primary.withValues(alpha: 0.30)
        : AppColors.darkText3.withValues(alpha: 0.40);

    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    final List<({String label, bool met})> rules = [
      (
        label: isAr ? '٨ أحرف على الأقل' : 'At least 8 characters',
        met: pwd.length >= Validators.minPasswordLength,
      ),
      (
        label: isAr ? 'حرف كبير (A-Z)' : 'Uppercase letter (A-Z)',
        met: pwd.contains(RegExp(r'[A-Z]')),
      ),
      (
        label: isAr ? 'حرف صغير (a-z)' : 'Lowercase letter (a-z)',
        met: pwd.contains(RegExp(r'[a-z]')),
      ),
      (
        label: isAr ? 'رقم (0-9)' : 'Number (0-9)',
        met: pwd.contains(RegExp(r'[0-9]')),
      ),
      (
        label: isAr ? 'رمز خاص (! @ # \$ %)' : 'Special character (! @ # \$ %)',
        met: pwd.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=/\\]')),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final rule in rules)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 6),
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      rule.met
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      key: ValueKey(rule.met),
                      size: 16,
                      color: rule.met ? metColor : unmetColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    rule.label,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: rule.met
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: rule.met ? metColor : unmetColor,
                      decoration: rule.met
                          ? TextDecoration.none
                          : TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _isBarActive(int index, PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return index == 0;
      case PasswordStrength.medium:
        return index <= 1;
      case PasswordStrength.strong:
        return true;
    }
  }

  Color _resolveColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        // أحمر واضح من الباليت
        return AppColors.alertRed;
      case PasswordStrength.medium:
        // أصفر تحذيري
        return AppColors.warning;
      case PasswordStrength.strong:
        // أخضر من الباليت
        return AppColors.success;
    }
  }

  String _resolveLabel(BuildContext context, PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return context.l10n.passwordWeak;   // ضعيفة / Weak
      case PasswordStrength.medium:
        return context.l10n.passwordMedium; // متوسطة / Medium
      case PasswordStrength.strong:
        return context.l10n.passwordStrong; // قوية / Strong
    }
  }
}
