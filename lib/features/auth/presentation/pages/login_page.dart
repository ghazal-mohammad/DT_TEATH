// ════════════════════════════════════════════════════════════════════════════
// login_page.dart — F3.x (Refactored: Clean Architecture Edition)
//
// شاشة تسجيل الدخول بكلمة المرور — للمستخدمين العائدين.
//
// 🎬 الانيميشن (مستوحى من الفيديو المرجعي):
//   • AuthCardGlowBorder: توهج سماوي نابض على حدود الكارت الكامل
//   • AuthGlowLinePainter: خط التوهج على الخط المائل (بدون pulse للزر هنا)
//   • Entry Stagger: icon → title → subtitle → fields → button → link
//   • Exit: _entryCtrl.reverse() قبل التنقل → انيميشن خروج سلس
//
// إصلاحات Code Quality:
//   ✅ AuthNavyBackground    ← بدل gradient مكرر (كان 2 مرة في نفس الملف)
//   ✅ AuthGlowLinePainter   ← بدل _GlowLine الخاص
//   ✅ AuthDiagRightClipper  ← بدل _DiagClipper الخاص
//   ✅ AuthSubmitButton      ← بدل _SubmitBtn الخاص (withPulseAnimation: false)
//   ✅ AppTextStyles.authXxx ← بدل fontFamily: AppTextStyles.fontFamily يدوي
//   ✅ AppColors.authXxx     ← بدل AppColors.authFormTitleLight hardcoded
//   ✅ AppSizes.spaceXxx     ← بدل SizedBox يدوية
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_models.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/auth_flow_mode.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/brand/app_logo.dart';
import '../../../../shared/widgets/navigation/app_language_toggle.dart';
import '../bloc/login_cubit.dart';
import '../widgets/auth_entry_animator.dart';
import '../widgets/auth_layout_painters.dart';
import '../widgets/auth_page_transition.dart';
import '../widgets/auth_submit_button.dart';

// ══════════════════════════════════════════════════════════════════════════
//  PAGE
// ══════════════════════════════════════════════════════════════════════════

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl  = TextEditingController();

  /// Glow Line pulse — تكرار لا نهائي
  late final AnimationController _glowCtrl;

  /// Entry stagger — مرة واحدة عند mount
  late final AnimationController _entryCtrl;

  /// Shape entry — الـ diagonal يبرز من الحافة عند تحميل الصفحة
  late final AnimationController _shapeCtrl;

  bool _loading  = false;
  bool _obscure  = true;
  String? _error;

  final LoginCubit _cubit = sl<LoginCubit>();

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _shapeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _glowCtrl.dispose();
    _shapeCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String email = _emailCtrl.text.trim();
    final String pass  = _passCtrl.text;
    final bool isAr    = Localizations.localeOf(context).languageCode == 'ar';

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = isAr
          ? 'يرجى إدخال البريد وكلمة المرور'
          : 'Please enter email and password');
      return;
    }

    setState(() { _error = null; _loading = true; });

    await _cubit.login(email: email, password: pass);
    if (!mounted) return;

    final state = _cubit.state;
    setState(() => _loading = false);

    if (state.status == LoginStatus.success) {
      // 🔍 DEBUG: نطبع المستخدم لنشوف الـ role الفعلي.
      // ignore: avoid_print
      print('[DT.Teeth][login] user=${state.user} role=${state.user?.role}');

      await Future.wait([_entryCtrl.reverse(), _shapeCtrl.reverse()]);
      if (!mounted) return;
      context.go(_dashboardForRole(state.user?.role));
    } else {
      setState(() => _error = state.errorMessage ?? (isAr
          ? 'فشل تسجيل الدخول'
          : 'Login failed'));
    }
  }

  /// يحدّد لوحة التحكم المناسبة حسب دور الموظف.
  /// إذا unknown/null → Lab Dashboard كـ fallback (المستخدم عندو توكن صالح).
  String _dashboardForRole(EmployeeRole? role) {
    switch (role) {
      case EmployeeRole.labManager:
        return RouteNames.labDashboard;
      case EmployeeRole.warehouseManager:
        return RouteNames.warehouseDashboard;
      case EmployeeRole.admin:
        return RouteNames.systemSelection;
      default:
        return RouteNames.labDashboard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (ctx, box) => box.maxWidth < 750
            ? _buildMobile()
            : _buildDesktop(ctx, box.maxWidth, box.maxHeight),
      ),
    );
  }

  // ── DESKTOP ──────────────────────────────────────────────────────────────

  Widget _buildDesktop(BuildContext ctx, double W, double H) {
    return AuthCardGlowBorder(
      glowColor: AppColors.accent,
      borderRadius: 0,
      child: Stack(
        children: [
          // 1-3: خلفية متحركة (navy + diagonal + glow) — الانيميشن من الـ HTML
          Positioned.fill(
            child: AuthShapeBackground(
              shapeCtrl: _shapeCtrl,
              glowCtrl: _glowCtrl,
            ),
          ),

          // 4 ─ Branding (يسار داكن)
          Positioned(
            left: 0, width: W * 0.40,
            top: 0, bottom: 0,
            child: _BrandingPanel(entryCtrl: _entryCtrl),
          ),

          // 5 ─ Form (يمين أبيض)
          Positioned(
            left: W * 0.67, right: 0,
            top: 0, bottom: 0,
            child: _FormSide(
              emailCtrl: _emailCtrl,
              passCtrl:  _passCtrl,
              obscure:   _obscure,
              loading:   _loading,
              error:     _error,
              isMobile:  false,
              entryCtrl: _entryCtrl,
              onToggleObscure: () => setState(() => _obscure = !_obscure),
              onSubmit: _submit,
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
                  vertical: 48,
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
                    const SizedBox(height: 40),
                    _FormContent(
                      emailCtrl: _emailCtrl,
                      passCtrl:  _passCtrl,
                      obscure:   _obscure,
                      loading:   _loading,
                      error:     _error,
                      isMobile:  true,
                      entryCtrl: _entryCtrl,
                      onToggleObscure: () => setState(() => _obscure = !_obscure),
                      onSubmit: _submit,
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
//  BRANDING PANEL — يسار داكن
// ══════════════════════════════════════════════════════════════════════════

class _BrandingPanel extends StatelessWidget {
  const _BrandingPanel({required this.entryCtrl});

  final AnimationController entryCtrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 28, right: 160, top: 28, bottom: 40,
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
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.spaceXXL),
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
