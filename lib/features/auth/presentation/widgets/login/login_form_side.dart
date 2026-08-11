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
    required this.loading,
    required this.error,
    required this.isMobile,
    required this.entryCtrl,
    required this.onSubmit,
  });

  final TextEditingController emailCtrl, passCtrl;
  final bool loading, isMobile;
  final String? error;
  final AnimationController entryCtrl;
  final VoidCallback onSubmit;

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
                    loading:   loading,
                    error:     error,
                    isMobile:  false,
                    entryCtrl: entryCtrl,
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
    required this.loading,
    required this.error,
    required this.isMobile,
    required this.entryCtrl,
    required this.onSubmit,
  });

  final TextEditingController emailCtrl, passCtrl;
  final bool loading, isMobile;
  final String? error;
  final AnimationController entryCtrl;
  final VoidCallback onSubmit;

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
          child: AuthUnderlineField(
            controller: emailCtrl,
            label: isAr ? 'البريد الإلكتروني' : 'Email',
            icon: Icons.alternate_email_rounded,
            dark: isMobile,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.username],
          ),
        ),
        const SizedBox(height: AppSizes.spaceMD),

        // Password field
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.field2,
          child: AuthUnderlineField(
            controller: passCtrl,
            label: isAr ? 'كلمة المرور' : 'Password',
            icon: Icons.lock_outline_rounded,
            dark: isMobile,
            obscureText: true,
            showObscureToggle: true,
            onSubmitted: (_) => onSubmit(),
            autofillHints: const [AutofillHints.password],
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

        // Submit button (مشترك — AuthOutlineButton بدون pulse)
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.button,
          child: AuthOutlineButton(
            label: isAr ? 'تسجيل الدخول' : 'Sign In',
            onPressed: onSubmit,
            isLoading: loading,
            withPulseAnimation: false, // login بدون pulse (كما سابقاً)
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
