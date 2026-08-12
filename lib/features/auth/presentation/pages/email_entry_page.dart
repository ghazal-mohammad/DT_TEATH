// ════════════════════════════════════════════════════════════════════════════
// email_entry_page.dart — F3.2
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/brand/app_logo.dart';
import '../../../../shared/widgets/navigation/app_language_toggle.dart';
import '../../domain/auth_flow_mode.dart';
import '../bloc/email_entry_cubit.dart';
import '../widgets/auth_entry_animator.dart';
import '../widgets/auth_outline_button.dart';
import '../widgets/auth_underline_field.dart';
import '../widgets/email_suggestion_engine.dart';

class EmailEntryPage extends StatelessWidget {
  const EmailEntryPage({super.key, this.mode = AuthFlowMode.activation});

  /// نوع التدفّق: تفعيل أول مرة أو "نسيت كلمة السر".
  final AuthFlowMode mode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EmailEntryCubit>()..setMode(mode),
      child: _View(mode: mode),
    );
  }
}

class _View extends StatefulWidget {
  const _View({required this.mode});
  final AuthFlowMode mode;
  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> with TickerProviderStateMixin {
  final TextEditingController _emailCtrl = TextEditingController();
  late final AnimationController _entryCtrl;

  @override
  void initState() {
    super.initState();
    // الخلفية القطرية والتوهّج يوفّرهما AuthFlowShell (دائمان عبر ShellRoute)؛
    // هنا فقط أنيميشن دخول المحتوى المتدرّج.
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  // ✅ FIX 1: استخدم context من الـ State مباشرة — مو من BlocListener closure
  // ctx من BlocListener يصير stale بعد await
  void _onSuccess(String email) {
    _playExitAndNavigate(email);
  }

  void _playExitAndNavigate(String email) {
    if (!mounted) return;
    // الخروج السلس يتكفّل به انتقال الراوت (لا حاجة لعكس أنيميشن الدخول يدوياً).
    context.go(
      RouteNames.authVerifyCode,
      extra: {'email': email.trim(), 'mode': widget.mode},
    );
  }

  void _submit() {
    // ✅ FIX 3: _submit بدون BuildContext parameter — يستخدم context من State
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    context.read<EmailEntryCubit>().submit();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EmailEntryCubit, EmailEntryState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      // ✅ FIX 4: لا نمرر ctx للدالة — نستخدم email من state مباشرة
      listener: (_, state) {
        if (state.status == EmailEntryStatus.success) {
          _onSuccess(state.email);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(
          builder: (_, box) => box.maxWidth < 750
              ? _buildMobile()
              : _buildDesktop(box.maxWidth, box.maxHeight),
        ),
      ),
    );
  }

  Widget _buildDesktop(double W, double H) {
    // الخلفية القطرية الدوّارة يوفّرها AuthFlowShell — هنا المحتوى فقط.
    return Stack(
      children: [
        // Branding panel — على اليسار (فوق الكحلي)
        PositionedDirectional(
          start: 0, width: W * 0.40,
          top: 0, bottom: 0,
          child: _BrandingPanel(entryCtrl: _entryCtrl),
        ),

        // Form panel — على اليمين (فوق الأبيض)
        PositionedDirectional(
          start: W * 0.67, end: 0,
          top: 0, bottom: 0,
          child: _DesktopForm(
            emailCtrl: _emailCtrl,
            entryCtrl: _entryCtrl,
            mode: widget.mode,
            onSubmit: _submit,
          ),
        ),
      ],
    );
  }

  Widget _buildMobile() {
    // الخلفية الكحلية يوفّرها AuthFlowShell — هنا المحتوى فقط.
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.space3XL,
          vertical: 56,
        ),
        child: Column(
          children: [
            AuthEntryAnimator(
              controller: _entryCtrl,
              delay: AuthStaggerDelays.logo,
              child: Text(
                'WELCOME!',
                textDirection: TextDirection.ltr,
                style: AppTextStyles.authHeroTitleMobile.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 48),
            _MobileForm(
              emailCtrl: _emailCtrl,
              entryCtrl: _entryCtrl,
              mode: widget.mode,
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  BRANDING PANEL
// ══════════════════════════════════════════════════════════════════════════
class _BrandingPanel extends StatelessWidget {
  const _BrandingPanel({required this.entryCtrl});
  final AnimationController entryCtrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 28, end: 160, top: 28, bottom: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthEntryAnimator(
            controller: entryCtrl,
            delay: AuthStaggerDelays.logo,
            child: const AppLogo(
              size: 280,
              variant: AppLogoVariant.darkTheme,
              showText: true,
              semanticLabel: 'DT.Teeth',
            ),
          ),
          const SizedBox(height: AppSizes.space2XL),
          AuthEntryAnimator(
            controller: entryCtrl,
            delay: AuthStaggerDelays.title,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'WELCOME!',
                  textDirection: TextDirection.ltr,
                  maxLines: 1,
                  softWrap: false,
                  style: AppTextStyles.authHeroTitle.copyWith(
                    fontSize: AppSizes.fontAuth58,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
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
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  DESKTOP FORM — يستخدم BlocBuilder للحصول على state محدّث
// ══════════════════════════════════════════════════════════════════════════
class _DesktopForm extends StatelessWidget {
  const _DesktopForm({
    required this.emailCtrl,
    required this.entryCtrl,
    required this.mode,
    required this.onSubmit,
  });
  final TextEditingController emailCtrl;
  final AnimationController entryCtrl;
  final AuthFlowMode mode;
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: _FormContent(
                    emailCtrl: emailCtrl,
                    entryCtrl: entryCtrl,
                    mode: mode,
                    isMobile: false,
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
//  MOBILE FORM
// ══════════════════════════════════════════════════════════════════════════
class _MobileForm extends StatelessWidget {
  const _MobileForm({
    required this.emailCtrl,
    required this.entryCtrl,
    required this.mode,
    required this.onSubmit,
  });
  final TextEditingController emailCtrl;
  final AnimationController entryCtrl;
  final AuthFlowMode mode;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return _FormContent(
      emailCtrl: emailCtrl,
      entryCtrl: entryCtrl,
      mode: mode,
      isMobile: true,
      onSubmit: onSubmit,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  FORM CONTENT — StatelessWidget يستخدم BlocBuilder داخله
// ══════════════════════════════════════════════════════════════════════════
class _FormContent extends StatelessWidget {
  const _FormContent({
    required this.emailCtrl,
    required this.entryCtrl,
    required this.mode,
    required this.isMobile,
    required this.onSubmit,
  });

  final TextEditingController emailCtrl;
  final AnimationController entryCtrl;
  final AuthFlowMode mode;
  final bool isMobile;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    // ✅ BlocBuilder هون — context صالح دائماً لأن _FormContent داخل Scaffold
    return BlocBuilder<EmailEntryCubit, EmailEntryState>(
      builder: (context, state) {
        final Color titleColor =
            isMobile ? Colors.white : AppColors.authFormTitleLight;
        final Color subColor = isMobile
            ? Colors.white.withValues(alpha: 0.65)
            : AppColors.authFormSubLight;

        // وضع reset: عنوان/شرح واضح إنها "إعادة تعيين" مش تسجيل أول مرة.
        final bool isReset = mode == AuthFlowMode.reset;
        final bool isAr =
            Localizations.localeOf(context).languageCode == 'ar';
        final String titleText = isReset
            ? (isAr ? 'إعادة تعيين كلمة المرور' : 'Reset Password')
            : context.l10n.authEnterEmailTitle;
        final String subtitleText = isReset
            ? (isAr
                ? 'أدخل بريدك المسجَّل ونرسل لك كود التحقق'
                : 'Enter your registered email to receive a verification code')
            : context.l10n.authEnterEmailSubtitle;

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

            AuthEntryAnimator(
              controller: entryCtrl,
              delay: AuthStaggerDelays.title,
              child: Text(
                titleText,
                style: AppTextStyles.authFormTitle.copyWith(color: titleColor),
              ),
            ),
            const SizedBox(height: AppSizes.spaceXS + 2),

            AuthEntryAnimator(
              controller: entryCtrl,
              delay: AuthStaggerDelays.subtitle,
              child: Text(
                subtitleText,
                style: AppTextStyles.authFormSubtitle.copyWith(color: subColor),
              ),
            ),
            const SizedBox(height: AppSizes.space2XL),

            AuthEntryAnimator(
              controller: entryCtrl,
              delay: AuthStaggerDelays.field1,
              child: AuthUnderlineField(
                controller: emailCtrl,
                label: context.l10n.email,
                icon: Icons.alternate_email_rounded,
                dark: isMobile,
                enabled: state.status != EmailEntryStatus.submitting,
                onChanged: (v) => context.read<EmailEntryCubit>().emailChanged(v),
                onSubmitted: (_) => onSubmit(),
                errorText: _resolveError(state, context),
                suggestionDomains: kDefaultAuthEmailDomains,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(height: AppSizes.spaceLG),

            AuthEntryAnimator(
              controller: entryCtrl,
              delay: AuthStaggerDelays.button,
              child: AuthOutlineButton(
                label: context.l10n.authNext,
                onPressed: onSubmit,
                isLoading: state.status == EmailEntryStatus.submitting,
                isEnabled: !state.isSubmitDisabled,
                withPulseAnimation: true,
                icon: Icons.arrow_forward_rounded,
              ),
            ),
            const SizedBox(height: AppSizes.spaceLG),

            AuthEntryAnimator(
              controller: entryCtrl,
              delay: AuthStaggerDelays.footer,
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: AppSizes.iconXS + 1, color: subColor),
                  const SizedBox(width: AppSizes.spaceXS + 2),
                  Expanded(
                    child: Text(
                      context.l10n.authEnterEmailSubtitle,
                      style: AppTextStyles.authFooterNote
                          .copyWith(color: subColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spaceXL),

            AuthEntryAnimator(
              controller: entryCtrl,
              delay: AuthStaggerDelays.footer,
              child: _AuthDividerLink(isMobile: isMobile),
            ),
          ],
        );
      },
    );
  }

  String? _resolveError(EmailEntryState state, BuildContext ctx) {
    if (state.errorMessage == null) return null;
    switch (state.errorMessage) {
      case 'email_required': return ctx.l10n.emailRequired;
      case 'invalid_email':  return ctx.l10n.emailInvalid;
      case 'network_error':  return ctx.l10n.errorNetwork;
      default:               return ctx.l10n.error;
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  DIVIDER + LINK
// ══════════════════════════════════════════════════════════════════════════
class _AuthDividerLink extends StatelessWidget {
  const _AuthDividerLink({required this.isMobile});
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
    final Color linkColor = isMobile ? AppColors.reservedBg : AppColors.primary;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Container(height: 1, color: lineColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceMD - 2),
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
          onTap: () => context.go(RouteNames.login),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTextStyles.authLink.copyWith(color: textColor),
                children: [
                  TextSpan(
                    text: isAr ? 'لديك كلمة مرور؟ ' : 'Already have a password? ',
                  ),
                  TextSpan(
                    text: isAr ? 'سجّل دخولك' : 'Sign In',
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
