// ════════════════════════════════════════════════════════════════════════════
// set_password_page.dart — F3.4 (Refactored: Clean Architecture Edition)
//
// 🎬 الانيميشن (مستوحى من الفيديو المرجعي):
//   • AuthCardGlowBorder: توهج سماوي نابض على حدود الكارت
//   • AuthGlowLinePainter: خط التوهج على الخط المائل
//   • Entry Stagger: logo → title → subtitle → field1 → field2 → button → footer
//   • Exit: _entryCtrl.reverse() قبل التنقل
//
// إصلاحات Code Quality:
//   ✅ AuthNavyBackground    ← بدل gradient مكرر (كان مرتين في نفس الملف)
//   ✅ AuthGlowLinePainter   ← بدل _GL الخاص
//   ✅ AuthDiagRightClipper  ← بدل _DC الخاص
//   ✅ AuthSubmitButton      ← بدل _SB/_SBS الخاص
//   ✅ AppTextStyles.authXxx ← بدل fontFamily: AppTextStyles.fontFamily يدوي
//   ✅ AppColors.authXxx     ← بدل Color(0xFF111111) hardcoded
//   ✅ AppSizes.spaceXxx     ← بدل SizedBox يدوية
// ════════════════════════════════════════════════════════════════════════════

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_models.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/set_password_cubit.dart';
import '../../../../shared/widgets/brand/app_logo.dart';
import '../../../../shared/widgets/navigation/app_language_toggle.dart';
import '../widgets/auth_entry_animator.dart';
import '../widgets/auth_layout_painters.dart';
import '../widgets/auth_page_transition.dart';
import '../widgets/auth_submit_button.dart';
import '../widgets/password_form_field.dart';
import '../widgets/password_strength_meter.dart';

// ══════════════════════════════════════════════════════════════════════════
//  PAGE
// ══════════════════════════════════════════════════════════════════════════

class SetPasswordPage extends StatefulWidget {
  const SetPasswordPage({
    super.key,
    required this.email,
    this.verificationCode = '',
  });

  final String email;
  final String verificationCode;

  @override
  State<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage>
    with TickerProviderStateMixin {
  final TextEditingController _pwdCtrl = TextEditingController();
  final TextEditingController _cfmCtrl = TextEditingController();

  late final AnimationController _glowCtrl;
  late final AnimationController _entryCtrl;

  String _pwd = '', _cfm = '';
  bool _submitting = false;
  String? _errPwd, _errCfm;

  bool get _valid =>
      _pwd.length >= Validators.minPasswordLength && _pwd == _cfm;

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
  }

  @override
  void dispose() {
    _pwdCtrl.dispose();
    _cfmCtrl.dispose();
    _glowCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  final SetPasswordCubit _cubit = sl<SetPasswordCubit>();

  Future<void> _submit() async {
    setState(() { _errPwd = null; _errCfm = null; });

    if (_pwd.length < Validators.minPasswordLength) {
      setState(() => _errPwd = context.l10n.passwordTooShort);
      return;
    }
    if (_pwd != _cfm) {
      setState(() => _errCfm = context.l10n.passwordMismatch);
      return;
    }
    if (widget.verificationCode.isEmpty) {
      setState(() => _errPwd = 'كود التحقق مفقود — ارجع لشاشة الإيميل');
      return;
    }

    setState(() => _submitting = true);

    await _cubit.submit(
      email: widget.email,
      verificationCode: widget.verificationCode,
      password: _pwd,
    );
    if (!mounted) return;

    final state = _cubit.state;
    setState(() => _submitting = false);

    if (state.status == SetPasswordStatus.success) {
      // 🔍 DEBUG: نطبع المستخدم اللي رجع من الباك لمعرفة الـ role الفعلي.
      // ignore: avoid_print
      print('[DT.Teeth][setPassword] user=${state.user} role=${state.user?.role}');

      await _entryCtrl.reverse();
      if (!mounted) return;
      // الباك بيرجع توكن جاهز + role — ندخّل المستخدم مباشرة لنظامه.
      context.go(_dashboardForRole(state.user?.role));
    } else {
      setState(() => _errPwd = state.errorMessage ?? 'فشل تعيين كلمة المرور');
    }
  }

  /// يحدّد لوحة التحكم المناسبة حسب دور الموظف.
  /// Admin → systemSelection. Lab Manager → Lab Dashboard.
  /// Warehouse Manager → Warehouse Dashboard.
  /// إذا الـ role unknown/null → Lab Dashboard كـ fallback آمن
  /// (لأن المستخدم نجح بـ setPassword وعندو توكن صالح).
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
            : _buildDesktop(box.maxWidth, box.maxHeight),
      ),
    );
  }

  // ── DESKTOP ──────────────────────────────────────────────────────────────

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

          // 2 ─ الجانب الأبيض (diagonal)
          Positioned.fill(
            child: ClipPath(
              clipper: AuthDiagRightClipper(
                topX: topX, botX: botX, W: W, H: H,
              ),
              child: const ColoredBox(color: Colors.white),
            ),
          ),

          // 3 ─ خط التوهج المتحرك (التوهج محصور بجهة الكحلي)
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
                    ..moveTo(0, 0)
                    ..lineTo(topX, 0)
                    ..lineTo(botX, H)
                    ..lineTo(0, H)
                    ..close(),
                ),
              ),
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
                            pwdCtrl: _pwdCtrl,
                            cfmCtrl: _cfmCtrl,
                            pwd: _pwd,
                            valid: _valid,
                            submitting: _submitting,
                            errPwd: _errPwd,
                            errCfm: _errCfm,
                            isMobile: false,
                            entryCtrl: _entryCtrl,
                            onPwdChanged: (v) => setState(() {
                              _pwd = v; _errPwd = null;
                            }),
                            onCfmChanged: (v) => setState(() {
                              _cfm = v; _errCfm = null;
                            }),
                            onSubmit: _submit,
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
                          'ALMOST THERE!',
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
                      pwdCtrl: _pwdCtrl,
                      cfmCtrl: _cfmCtrl,
                      pwd: _pwd,
                      valid: _valid,
                      submitting: _submitting,
                      errPwd: _errPwd,
                      errCfm: _errCfm,
                      isMobile: true,
                      entryCtrl: _entryCtrl,
                      onPwdChanged: (v) => setState(() {
                        _pwd = v; _errPwd = null;
                      }),
                      onCfmChanged: (v) => setState(() {
                        _cfm = v; _errCfm = null;
                      }),
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
                  'ALMOST THERE!',
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
    required this.pwdCtrl,
    required this.cfmCtrl,
    required this.pwd,
    required this.valid,
    required this.submitting,
    required this.errPwd,
    required this.errCfm,
    required this.isMobile,
    required this.entryCtrl,
    required this.onPwdChanged,
    required this.onCfmChanged,
    required this.onSubmit,
  });

  final TextEditingController pwdCtrl, cfmCtrl;
  final String pwd;
  final bool valid, submitting, isMobile;
  final String? errPwd, errCfm;
  final AnimationController entryCtrl;
  final ValueChanged<String> onPwdChanged, onCfmChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final Color titleColor =
        isMobile ? Colors.white : AppColors.authFormTitleLight;
    final Color subColor = isMobile
        ? AppColors.authFormTextMobile(alpha: 0.65)
        : AppColors.authFormSubLight;
    final Brightness fieldBrightness =
        isMobile ? Brightness.dark : Brightness.light;

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
                padding: const EdgeInsets.only(bottom: AppSizes.spaceXL),
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
                Icons.shield_outlined,
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
            context.l10n.authSetPasswordTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.authFormTitle.copyWith(
              fontSize: isMobile
                  ? AppSizes.fontAuth20
                  : AppSizes.fontAuth22,
              color: titleColor,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spaceXS + 2),

        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.subtitle,
          child: Text(
            context.l10n.authSetPasswordSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.authFormSubtitle.copyWith(color: subColor),
          ),
        ),
        const SizedBox(height: AppSizes.spaceXL - 2),

        // Password field
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.field1,
          child: Theme(
            data: Theme.of(context).copyWith(brightness: fieldBrightness),
            child: PasswordFormField(
              controller: pwdCtrl,
              label: context.l10n.password,
              hint: context.l10n.passwordHint,
              enabled: !submitting,
              errorText: errPwd,
              onChanged: onPwdChanged,
            ),
          ),
        ),

        // Strength meter
        Theme(
          data: Theme.of(context).copyWith(brightness: fieldBrightness),
          child: PasswordStrengthMeter(password: pwd),
        ),
        const SizedBox(height: 10),

        // Confirm field
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.field2,
          child: Theme(
            data: Theme.of(context).copyWith(brightness: fieldBrightness),
            child: PasswordFormField(
              controller: cfmCtrl,
              label: context.l10n.passwordConfirm,
              hint: context.l10n.passwordHint,
              enabled: !submitting,
              errorText: errCfm,
              onChanged: onCfmChanged,
              onSubmitted: (_) => valid ? onSubmit() : null,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spaceXL),

        // Submit button (مشترك — AuthSubmitButton)
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.button,
          child: AuthSubmitButton(
            label: context.l10n.authSaveAndLogin,
            onPressed: onSubmit,
            isLoading: submitting,
            isEnabled: valid && !submitting,
            darkMode: isMobile,
            withPulseAnimation: true,
            icon: Icons.check_rounded,
          ),
        ),
        const SizedBox(height: 12),

        // Footer hint
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.footer,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: AppSizes.iconXS + 1,
                color: subColor,
              ),
              const SizedBox(width: AppSizes.spaceXS + 2),
              Expanded(
                child: Text(
                  Localizations.localeOf(context).languageCode == 'ar'
                      ? '8 أحرف على الأقل، يُفضّل خلط أحرف وأرقام ورموز'
                      : 'At least 8 characters with uppercase, numbers & symbols',
                  style: AppTextStyles.authFooterNote
                      .copyWith(color: subColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
