// ════════════════════════════════════════════════════════════════════════════
// login_form_side.dart
//
// جانب النموذج + الحقول — part of login_page.dart (تقسيم الصفحات العملاقة).
// ════════════════════════════════════════════════════════════════════════════

part of '../../pages/login_page.dart';

// ══════════════════════════════════════════════════════════════════════════
//  FORM SIDE — Desktop wrapper
// ══════════════════════════════════════════════════════════════════════════

class _FormSide extends StatelessWidget {
  const _FormSide({
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.loading,
    required this.error,
    required this.isMobile,
    required this.entryCtrl,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final TextEditingController emailCtrl, passCtrl;
  final bool obscure, loading, isMobile;
  final String? error;
  final AnimationController entryCtrl;
  final VoidCallback onToggleObscure, onSubmit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.space3XL + AppSizes.spaceMD,
            vertical: AppSizes.space3XL + AppSizes.spaceMD,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: _FormContent(
                    emailCtrl: emailCtrl,
                    passCtrl:  passCtrl,
                    obscure:   obscure,
                    loading:   loading,
                    error:     error,
                    isMobile:  false,
                    entryCtrl: entryCtrl,
                    onToggleObscure: onToggleObscure,
                    onSubmit: onSubmit,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  FORM CONTENT — مشترك بين Desktop و Mobile
// ══════════════════════════════════════════════════════════════════════════

class _FormContent extends StatelessWidget {
  const _FormContent({
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.loading,
    required this.error,
    required this.isMobile,
    required this.entryCtrl,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final TextEditingController emailCtrl, passCtrl;
  final bool obscure, loading, isMobile;
  final String? error;
  final AnimationController entryCtrl;
  final VoidCallback onToggleObscure, onSubmit;

  @override
  Widget build(BuildContext context) {
    final bool isAr    = Localizations.localeOf(context).languageCode == 'ar';
    final Color title  = isMobile ? Colors.white : AppColors.authFormTitleLight;
    final Color sub    = isMobile
        ? AppColors.authFormTextMobile(alpha: 0.65)
        : AppColors.authFormSubLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Language toggle (desktop only)
        if (!isMobile)
          AuthEntryAnimator(
            controller: entryCtrl,
            delay: AuthStaggerDelays.logo,
            child: const Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: EdgeInsets.only(bottom: AppSizes.spaceXXL),
                child: AppLanguageToggle(
                  variant: AppLanguageToggleVariant.compact,
                ),
              ),
            ),
          ),

        // Icon
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.icon,
          child: Center(
            child: Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: isMobile ? 0.18 : 0.06,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(
                    alpha: isMobile ? 0.30 : 0.14,
                  ),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.lock_open_rounded,
                size: 26,
                color: isMobile ? AppColors.reservedBg : AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spaceLG),

        // Title
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.title,
          child: Text(
            context.l10n.loginTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.authFormTitle.copyWith(
              fontSize: isMobile
                  ? AppSizes.fontAuth22
                  : AppSizes.fontLG + AppSizes.fontSM,
              color: title,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spaceXS + 2),

        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.subtitle,
          child: Text(
            context.l10n.loginSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.authFormSubtitle.copyWith(color: sub),
          ),
        ),
        const SizedBox(height: AppSizes.space2XL),

        // Error box
        if (error != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: AppColors.statusUrgent.withValues(alpha: 0.08),
              border:
                  Border.all(color: AppColors.statusUrgent.withValues(alpha: 0.30)),
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 15,
                  color: AppColors.statusUrgent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    error!,
                    style: AppTextStyles.authFooterNote.copyWith(
                      color: AppColors.loginErrorText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Email field
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.field1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel(
                label: isAr ? 'البريد الإلكتروني' : 'Email',
                dark: isMobile,
              ),
              const SizedBox(height: AppSizes.spaceXS),
              _InputField(
                controller: emailCtrl,
                hint: 'example@dtteeth.com',
                icon: Icons.alternate_email_rounded,
                dark: isMobile,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.username],
              ),
            ],
          ),
        ),

        // Password field
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.field2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel(
                label: isAr ? 'كلمة المرور' : 'Password',
                dark: isMobile,
              ),
              const SizedBox(height: AppSizes.spaceXS),
              _InputField(
                controller: passCtrl,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                dark: isMobile,
                obscureText: obscure,
                onSubmitted: (_) => onSubmit(),
                autofillHints: const [AutofillHints.password],
                suffix: GestureDetector(
                  onTap: onToggleObscure,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 4),
                    child: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: isMobile
                          ? AppColors.authInputIconMobile()
                          : AppColors.authInputIconLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.spaceXS),

        // Forgot password link — يفتح تدفّق إعادة التعيين (reset mode)
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.field2,
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: GestureDetector(
              onTap: () => context.go(
                RouteNames.authEmail,
                extra: {'mode': AuthFlowMode.reset},
              ),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Text(
                  isAr ? 'نسيت كلمة المرور؟' : 'Forgot password?',
                  style: AppTextStyles.authLink.copyWith(
                    color: isMobile ? AppColors.reservedBg : AppColors.primary,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor:
                        isMobile ? AppColors.reservedBg : AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spaceLG),

        // Submit button (مشترك — AuthSubmitButton بدون pulse)
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.button,
          child: AuthSubmitButton(
            label: isAr ? 'تسجيل الدخول' : 'Sign In',
            onPressed: onSubmit,
            isLoading: loading,
            darkMode: isMobile,
            withPulseAnimation: false, // login بدون pulse (كما في الفيديو)
            icon: Icons.login_rounded,
          ),
        ),
        const SizedBox(height: AppSizes.spaceXL),

        // First time link
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.footer,
          child: _FirstTimeLink(isMobile: isMobile),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  FIELD LABEL — label فوق حقول الـ Input
// ══════════════════════════════════════════════════════════════════════════

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.dark});

  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.authFieldLabel.copyWith(
        color: dark
            ? AppColors.authFormTextMobile(alpha: 0.85)
            : AppColors.authLabelLight,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  INPUT FIELD — حقل الإدخال الموحّد لـ login_page
// ══════════════════════════════════════════════════════════════════════════

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.dark,
    this.obscureText = false,
    this.keyboardType,
    this.onSubmitted,
    this.suffix,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool dark;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceMD),
      decoration: BoxDecoration(
        color: dark
            ? AppColors.authInputBgMobile()
            : AppColors.authInputBgLight,
        border: Border.all(
          color: dark
              ? AppColors.authInputBorderMobile()
              : AppColors.authInputBorderLight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
      ),
      child: Row(
        children: [
          const SizedBox(width: 13),
          Icon(
            icon,
            size: 16,
            color: dark
                ? AppColors.authInputIconMobile()
                : AppColors.authInputIconLight,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              textDirection: TextDirection.ltr,
              onSubmitted: onSubmitted,
              autofillHints: autofillHints,
              autocorrect: false,
              enableSuggestions: false,
              style: AppTextStyles.authFieldInput.copyWith(
                color: dark
                    ? AppColors.authFormTextMobile()
                    : AppColors.authInputTextLight,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.authFieldHint.copyWith(
                  color: dark
                      ? AppColors.authInputBgMobile(alpha: 0.28)
                      : AppColors.authInputHintLight,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
          if (suffix != null) suffix!,
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  FIRST TIME LINK — "أول مرة؟ سجّل عبر البريد"
// ══════════════════════════════════════════════════════════════════════════

class _FirstTimeLink extends StatelessWidget {
  const _FirstTimeLink({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    final Color lineColor = isMobile
        ? AppColors.authInputBorderMobile()
        : AppColors.authDividerLight;
    final Color textColor = isMobile
        ? AppColors.authFormTextMobile(alpha: 0.55)
        : AppColors.authLinkTextLight;
    final Color linkColor =
        isMobile ? AppColors.reservedBg : AppColors.primary;

    return Column(
      children: [
        // OR divider
        Row(
          children: [
            Expanded(child: Container(height: 1, color: lineColor)),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spaceMD - 2,
              ),
              child: Text(
                isAr ? 'أو' : 'OR',
                style: AppTextStyles.authDividerText.copyWith(color: textColor),
              ),
            ),
            Expanded(child: Container(height: 1, color: lineColor)),
          ],
        ),
        const SizedBox(height: AppSizes.spaceMD),

        GestureDetector(
          onTap: () => context.go(RouteNames.authEmail),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTextStyles.authLink.copyWith(color: textColor),
                children: [
                  TextSpan(
                    text: isAr ? 'أول مرة هنا؟ ' : 'First time? ',
                  ),
                  TextSpan(
                    text: isAr
                        ? 'سجّل عبر البريد الإلكتروني'
                        : 'Register via Email',
                    style: AppTextStyles.authLink.copyWith(
                      color: linkColor,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                      decorationColor: linkColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
