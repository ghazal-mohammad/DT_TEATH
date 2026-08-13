// ════════════════════════════════════════════════════════════════════════════
// verify_code_page.dart — F3.3 (Refactored: Clean Architecture Edition)
//
// Layout معكوس: الأبيض على اليسار (form)، الداكن على اليمين (branding).
//
// 🎬 الانيميشن (مستوحى من الفيديو المرجعي):
//   • AuthCardGlowBorder: توهج سماوي نابض على حدود الكارت
//   • AuthDiagLeftClipper: نفس الـ diagonal لكن معكوس
//   • Entry Stagger: icon → title → subtitle → OTP → button → resend
//   • Exit: _entryCtrl.reverse() قبل التنقل
//
// إصلاحات Code Quality:
//   ✅ AuthNavyBackground    ← بدل gradient مكرر (كان مرتين)
//   ✅ AuthGlowLinePainter   ← بدل _GL الخاص
//   ✅ AuthDiagLeftClipper   ← بدل _DCLeft الخاص
//   ✅ AuthDiagRightClipper  ← بدل _DC الخاص الزائد
//   ✅ AuthOutlineButton     ← بدل _B/_BS الخاص
//   ✅ AppTextStyles.authXxx ← بدل fontFamily: AppTextStyles.fontFamily يدوي
//   ✅ AppColors.authXxx     ← بدل Color hardcoded
//   ✅ AppSizes.spaceXxx     ← بدل SizedBox يدوية
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/network/failure.dart';
import '../../../../core/router/route_names.dart';
import '../../domain/auth_flow_mode.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/brand/app_logo.dart';
import '../../../../shared/widgets/feedback/glass_toast.dart';
import '../../../../shared/widgets/navigation/app_language_toggle.dart';
import '../widgets/auth_entry_animator.dart';
import '../widgets/auth_outline_button.dart';
import '../widgets/otp_input.dart';

// ══════════════════════════════════════════════════════════════════════════
//  PAGE
// ══════════════════════════════════════════════════════════════════════════

class VerifyCodePage extends StatefulWidget {
  const VerifyCodePage({
    super.key,
    required this.email,
    this.mode = AuthFlowMode.activation,
  });

  final String email;

  /// نوع التدفّق: تفعيل أول مرة أو "نسيت كلمة السر".
  final AuthFlowMode mode;

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage>
    with TickerProviderStateMixin {
  final GlobalKey<OtpInputState> _otpKey = GlobalKey<OtpInputState>();

  late final AnimationController _entryCtrl;

  final AuthRepository _repo = sl<AuthRepository>();

  String _code = '';
  bool _verifying = false, _hasError = false;
  String? _errMsg;
  Timer? _timer;
  int _secs = 60;

  @override
  void initState() {
    super.initState();
    // الخلفية القطرية والتوهّج يوفّرهما AuthFlowShell — هنا فقط دخول المحتوى.
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _entryCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _secs = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _secs--;
        if (_secs <= 0) t.cancel();
      });
    });
  }

  Future<void> _verify() async {
    if (_code.length != 6) return;
    setState(() {
      _verifying = true;
      _hasError  = false;
      _errMsg    = null;
    });

    // التحقق الفعلي من الكود عبر الباك — لازم يصير قبل setPassword وإلا
    // الباك بيرفض تعيين كلمة المرور بـ"you have not verified your email yet".
    try {
      if (widget.mode == AuthFlowMode.reset) {
        await _repo.verifyResetCode(
          email: widget.email,
          verificationCode: _code,
        );
      } else {
        await _repo.verifyCode(
          email: widget.email,
          verificationCode: _code,
        );
      }
    } on Failure catch (f) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _hasError  = true;
        _errMsg    = f.message;
      });
      _otpKey.currentState?.clear();
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _hasError  = true;
        _errMsg    = context.l10n.authVerifyCodeError;
      });
      _otpKey.currentState?.clear();
      return;
    }

    if (!mounted) return;
    setState(() => _verifying = false);

    // الخروج السلس يتكفّل به انتقال الراوت.
    context.go(
      RouteNames.authSetPassword,
      extra: {'email': widget.email, 'code': _code, 'mode': widget.mode},
    );
  }

  void _resend() {
    if (_secs > 0) return;
    _otpKey.currentState?.clear();
    setState(() { _code = ''; _hasError = false; });
    _startTimer();
    GlassToast.show(
      context,
      message: context.l10n.authCheckEmailSent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final bool isMobile = MediaQuery.sizeOf(ctx).width < 750;
          return isMobile
              ? _buildMobile()
              : _buildDesktop(box.maxWidth, box.maxHeight);
        },
      ),
    );
  }

  // ── DESKTOP — layout معكوس (form يسار، branding يمين) ────────────────────
  // الخلفية القطرية الدوّارة (الأبيض على اليسار هنا) يوفّرها AuthFlowShell.

  Widget _buildDesktop(double W, double H) {
    return Stack(
      children: [
        // Branding (جهة النهاية — يسار في RTL، فوق الكحلي)
        PositionedDirectional(
          end: 0, width: W * 0.40,
          top: 0, bottom: 0,
          child: _BrandingPanel(entryCtrl: _entryCtrl),
        ),

        // Form (جهة البداية — يمين في RTL، فوق الأبيض)
        PositionedDirectional(
          start: 0, end: W * 0.67,
          top: 0, bottom: 0,
          child: LayoutBuilder(
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
                          otpKey: _otpKey,
                          email: widget.email,
                          mode: widget.mode,
                          code: _code,
                          verifying: _verifying,
                          hasError: _hasError,
                          errMsg: _errMsg,
                          secs: _secs,
                          isMobile: false,
                          entryCtrl: _entryCtrl,
                          onCodeChanged: (v) => setState(() {
                            _code = v;
                            if (_hasError) _hasError = false;
                          }),
                          onVerify: _verify,
                          onResend: _resend,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── MOBILE ────────────────────────────────────────────────────────────────

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
              child: const AppLogo(
                size: 140,
                variant: AppLogoVariant.darkTheme,
                showText: true,
                semanticLabel: 'DT.Teeth',
              ),
            ),
            const SizedBox(height: 16),
            AuthEntryAnimator(
              controller: _entryCtrl,
              delay: AuthStaggerDelays.title,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'WELCOME BACK!',
                  textDirection: TextDirection.ltr,
                  maxLines: 1,
                  softWrap: false,
                  style: AppTextStyles.authHeroTitleMobile.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _FormContent(
              otpKey: _otpKey,
              email: widget.email,
              mode: widget.mode,
              code: _code,
              verifying: _verifying,
              hasError: _hasError,
              errMsg: _errMsg,
              secs: _secs,
              isMobile: true,
              entryCtrl: _entryCtrl,
              onCodeChanged: (v) => setState(() {
                _code = v;
                if (_hasError) _hasError = false;
              }),
              onVerify: _verify,
              onResend: _resend,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  BRANDING PANEL — يمين داكن (verify page — layout معكوس)
// ══════════════════════════════════════════════════════════════════════════

class _BrandingPanel extends StatelessWidget {
  const _BrandingPanel({required this.entryCtrl});

  final AnimationController entryCtrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // padding معكوس (start/end) لأن الـ branding على جهة النهاية هنا
      padding: const EdgeInsetsDirectional.only(
        end: 28, start: 160, top: 28, bottom: 40,
      ),
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
                  'WELCOME BACK!',
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
//  FORM CONTENT — مشترك بين Desktop و Mobile
// ══════════════════════════════════════════════════════════════════════════

class _FormContent extends StatelessWidget {
  const _FormContent({
    required this.otpKey,
    required this.email,
    required this.mode,
    required this.code,
    required this.verifying,
    required this.hasError,
    required this.errMsg,
    required this.secs,
    required this.isMobile,
    required this.entryCtrl,
    required this.onCodeChanged,
    required this.onVerify,
    required this.onResend,
  });

  final GlobalKey<OtpInputState> otpKey;
  final AuthFlowMode mode;
  final String email, code;
  final bool verifying, hasError, isMobile;
  final String? errMsg;
  final int secs;
  final AnimationController entryCtrl;
  final ValueChanged<String> onCodeChanged;
  final VoidCallback onVerify, onResend;

  @override
  Widget build(BuildContext context) {
    final bool isAr   = Localizations.localeOf(context).languageCode == 'ar';
    final Color title = isMobile ? Colors.white : AppColors.authFormTitleLight;
    final Color sub   = isMobile
        ? AppColors.authFormTextMobile(alpha: 0.65)
        : AppColors.authFormSubLight;
    final Color accent = isMobile ? AppColors.reservedBg : AppColors.primary;

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
                padding: EdgeInsets.only(bottom: AppSizes.space2XL),
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
              width: 60, height: 60,
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
                Icons.mark_email_read_rounded,
                size: 28,
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
            context.l10n.authVerifyCodeTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.authFormTitle.copyWith(
              fontSize: isMobile
                  ? AppSizes.fontAuth20
                  : AppSizes.fontAuth22,
              color: title,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spaceXS + 4),

        // Subtitle مع email highlighted
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.subtitle,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: context.l10n
                      .authVerifyCodeSubtitle(email)
                      .replaceAll(email, ''),
                  style: AppTextStyles.authFormSubtitle.copyWith(color: sub),
                ),
                TextSpan(
                  text: email,
                  style: AppTextStyles.authFormSubtitle.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSizes.space2XL),

        // OTP Input
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.field1,
          child: Theme(
            data: Theme.of(context).copyWith(
              brightness: isMobile ? Brightness.dark : Brightness.light,
            ),
            child: OtpInput(
              key: otpKey,
              enabled: !verifying,
              hasError: hasError,
              onChanged: onCodeChanged,
              onCompleted: (_) => onVerify(),
            ),
          ),
        ),

        // Error message
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: hasError && errMsg != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Center(
                    child: Text(
                      errMsg!,
                      style: AppTextStyles.authFooterNote.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: AppSizes.spaceXL),

        // Submit button (مشترك — AuthOutlineButton)
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.button,
          child: AuthOutlineButton(
            label: context.l10n.authContinue,
            onPressed: onVerify,
            isLoading: verifying,
            isEnabled: code.length == 6 && !verifying,
            withPulseAnimation: true,
          ),
        ),
        const SizedBox(height: AppSizes.spaceXL),

        // Resend code
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.footer,
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              children: [
                Text(
                  isAr ? 'لم يصلك الكود؟' : "Didn't receive it?",
                  style: AppTextStyles.authFormSubtitle.copyWith(
                    fontSize: 13,
                    color: sub,
                  ),
                ),
                if (secs <= 0)
                  GestureDetector(
                    onTap: onResend,
                    child: Text(
                      context.l10n.authResendCode,
                      style: AppTextStyles.authLink.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: accent,
                      ),
                    ),
                  )
                else
                  Text(
                    context.l10n.authResendCodeIn(secs),
                    style: AppTextStyles.authFormSubtitle.copyWith(
                      fontSize: 13,
                      color: sub,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Back button
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.footer,
          child: Center(
            child: TextButton(
              onPressed: () => context.go(
                mode == AuthFlowMode.reset
                    ? RouteNames.login
                    : RouteNames.authEmail,
              ),
              child: Text(
                '← ${context.l10n.authBack}',
                style: AppTextStyles.authLink.copyWith(color: sub),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
