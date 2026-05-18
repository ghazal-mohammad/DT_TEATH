// ════════════════════════════════════════════════════════════════════════════
// auth_branding_panel.dart
//
// لوحة الـ Branding الموحّدة لجميع صفحات Auth (الجانب الداكن).
//
// يستبدل:
//   _BrandingAnimated في email_entry_page.dart  (WELCOME!)
//   _Branding         في login_page.dart         (WELCOME BACK!)
//   _BrandingAnimated في set_password_page.dart  (ALMOST THERE!)
//   _BrandingAnimated في verify_code_page.dart   (WELCOME BACK!)
//   _Branding         في system_selection_page.dart (CHOOSE YOUR SYSTEM)
//
// الاختلاف الوحيد بين النسخ الخمس = heroText فقط.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/brand/app_logo.dart';
import 'auth_entry_animator.dart';

/// لوحة الـ Branding الموحّدة — تظهر على الجانب الداكن في كل صفحات Auth.
///
/// مثال:
/// ```dart
/// AuthBrandingPanel(
///   heroText: 'WELCOME!',
///   entryCtrl: _entryCtrl,
/// )
///
/// // في verify_code (layout معكوس — branding على اليمين)
/// AuthBrandingPanel(
///   heroText: 'WELCOME BACK!',
///   entryCtrl: _entryCtrl,
///   alignRight: true,
/// )
/// ```
class AuthBrandingPanel extends StatelessWidget {
  const AuthBrandingPanel({
    super.key,
    required this.heroText,
    required this.entryCtrl,
    this.alignRight = false,
    this.extraContent,
  });

  /// النص الكبير (WELCOME! / ALMOST THERE! / CHOOSE YOUR SYSTEM...).
  final String heroText;

  /// AnimationController الخاص بالـ stagger entry.
  final AnimationController entryCtrl;

  /// `true` إذا كانت اللوحة على اليمين (verify_code) — يعكس الـ padding.
  final bool alignRight;

  /// محتوى إضافي اختياري يظهر أسفل الـ subtitle (مثل شارة وضع المعاينة).
  final Widget? extraContent;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = alignRight
        ? const EdgeInsets.only(
            right: 32, left: 80, top: 28, bottom: 40)
        : const EdgeInsets.only(
            left: 32, right: 80, top: 28, bottom: 40);

    return Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo ────────────────────────────────────────────────────
          AuthEntryAnimator(
            controller: entryCtrl,
            delay: AuthStaggerDelays.logo,
            child: const AppLogo(
              size: 235,
              variant: AppLogoVariant.darkTheme,
              showText: true,
            ),
          ),
          const SizedBox(height: AppSizes.space2XL),

          // ── Hero Text ─────────────────────────────────────────────
          AuthEntryAnimator(
            controller: entryCtrl,
            delay: AuthStaggerDelays.title,
            child: Text(
              heroText,
              textDirection: TextDirection.ltr,
              style: AppTextStyles.authHeroTitle.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ── System Subtitle ────────────────────────────────────────
          AuthEntryAnimator(
            controller: entryCtrl,
            delay: AuthStaggerDelays.subtitle,
            child: Text(
              'DENTAL CLINIC MANAGEMENT SYSTEM',
              textDirection: TextDirection.ltr,
              style: AppTextStyles.authSystemSubtitle.copyWith(
                color: AppColors.reservedBg.withValues(alpha: 0.80),
              ),
            ),
          ),

          // ── محتوى إضافي (اختياري) ────────────────────────────────
          if (extraContent != null) ...[
            const SizedBox(height: AppSizes.space3XL),
            AuthEntryAnimator(
              controller: entryCtrl,
              delay: AuthStaggerDelays.footer,
              child: extraContent!,
            ),
          ],
        ],
      ),
    );
  }
}
