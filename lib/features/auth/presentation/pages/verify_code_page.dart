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
//   ✅ AuthSubmitButton      ← بدل _B/_BS الخاص
//   ✅ AppTextStyles.authXxx ← بدل fontFamily: AppTextStyles.fontFamily يدوي
//   ✅ AppColors.authXxx     ← بدل Color hardcoded
//   ✅ AppSizes.spaceXxx     ← بدل SizedBox يدوية
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/brand/app_logo.dart';
import '../../../../shared/widgets/feedback/glass_toast.dart';
import '../../../../shared/widgets/navigation/app_language_toggle.dart';
import '../widgets/auth_entry_animator.dart';
import '../widgets/auth_layout_painters.dart';
import '../widgets/auth_page_transition.dart';
import '../widgets/auth_submit_button.dart';
import '../widgets/otp_input.dart';

// ══════════════════════════════════════════════════════════════════════════
//  PAGE
// ══════════════════════════════════════════════════════════════════════════

class VerifyCodePage extends StatefulWidget {
  const VerifyCodePage({super.key, required this.email});

  final String email;

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage>
    with TickerProviderStateMixin {
  final GlobalKey<OtpInputState> _otpKey = GlobalKey<OtpInputState>();

  late final AnimationController _glowCtrl;
  late final AnimationController _entryCtrl;

  String _code = '';
  bool _verifying = false, _hasError = false;
  String? _errMsg;
  Timer? _timer;
  int _secs = 60;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glowCtrl.dispose();
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
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _verifying = false);

    await _entryCtrl.reverse();
    if (!mounted) return;
    context.go(RouteNames.authSetPassword, extra: widget.email);
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
      body: LayoutBuilder(
        builder: (ctx, box) => box.maxWidth < 750
            ? _buildMobile()
            : _buildDesktop(box.maxWidth, box.maxHeight),
      ),
    );
  }

  // ── DESKTOP — layout معكوس (form يسار، branding يمين) ────────────────────

  Widget _buildDesktop(double W, double H) {
    final double topX = W * 0.75;
    final double botX = W * 0.25;

    return AuthCardGlowBorder(
      glowColor: AppColors.accent,
      borderRadius: 0,
      child: Stack(
        children: [
          // 1 ─ خلفية Navy (مشتركة)
          const AuthNavyBackground(),

          // 2 ─ الجانب الأبيض على اليسار (معكوس عن باقي الصفحات)
          Positioned.fill(
            child: ClipPath(
              clipper: AuthDiagLeftClipper(
                topX: topX, botX: botX, W: W, H: H,
              ),
              child: const ColoredBox(color: Colors.white),
            ),
          ),

          // 3 ─ خط التوهج (التوهج محصور بجهة الكحلي — اليمين هنا)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glowCtrl,
              builder: (_, __) => CustomPaint(
                painter: AuthGlowLinePainter(
                  start: Offset(topX, 0),
                  end: Offset(botX, H),
                  phase: _glowCtrl.value * 2 * math.pi,
                  glowColor: AppColors.accent,
                  glowClipPath: Path()
                    ..moveTo(topX, 0)
                    ..lineTo(W, 0)
                    ..lineTo(W, H)
                    ..lineTo(botX, H)
                    ..close(),
                ),
              ),
            ),
          ),

          // 4 ─ Branding (يمين — داكن)
          Positioned(
            right: 0, width: W * 0.40,
            top: 0, bottom: 0,
            child: _BrandingPanel(entryCtrl: _entryCtrl),
          ),

          // 5 ─ Form (يسار — أبيض)
          Positioned(
            left: 0, right: W * 0.67,
            top: 0, bottom: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.space3XL + AppSizes.spaceMD,
                vertical:   AppSizes.space3XL + AppSizes.spaceMD,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: _FormContent(
                      otpKey: _otpKey,
                      email: widget.email,
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
          ),
        ],
      ),
    );
  }

  // ── MOBILE ────────────────────────────────────────────────────────────────

  Widget _buildMobile() {
    return AuthCardGlowBorder(
      glowColor: AppColors.accent,
      borderRadius: 0,
      child: Stack(
        children: [
          const AuthNavyBackground(),
          Positioned.fill(
            child: SafeArea(
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
            ),
          ),
        ],
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
      // padding معكوس (left/right) لأن الـ branding على اليمين هنا
      padding: const EdgeInsets.only(
        right: 28, left: 160, top: 28, bottom: 40,
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
              padding: const EdgeInsets.only(left: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
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
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.space2XL),
                child: const AppLanguageToggle(
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

        // Submit button (مشترك — AuthSubmitButton)
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.button,
          child: AuthSubmitButton(
            label: context.l10n.authContinue,
            onPressed: onVerify,
            isLoading: verifying,
            isEnabled: code.length == 6 && !verifying,
            darkMode: isMobile,
            withPulseAnimation: true,
          ),
        ),
        const SizedBox(height: AppSizes.spaceXL),

        // Resend code
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.footer,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isAr ? 'لم يصلك الكود؟' : "Didn't receive it?",
                  style: AppTextStyles.authFormSubtitle.copyWith(
                    fontSize: 13,
                    color: sub,
                  ),
                ),
                const SizedBox(width: 6),
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
              onPressed: () => context.go(RouteNames.authEmail),
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
