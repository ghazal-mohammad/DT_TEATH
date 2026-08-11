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
import '../widgets/auth_outline_button.dart';
import '../widgets/auth_underline_field.dart';

part '../widgets/login/login_branding_panel.dart';
part '../widgets/login/login_form_side.dart';

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

  /// Entry stagger — مرة واحدة عند mount
  late final AnimationController _entryCtrl;

  bool _loading  = false;
  String? _error;

  final LoginCubit _cubit = sl<LoginCubit>();

  @override
  void initState() {
    super.initState();
    // الخلفية القطرية والتوهّج يوفّرهما AuthFlowShell — هنا فقط دخول المحتوى.
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
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
      // الخروج السلس يتكفّل به انتقال الراوت.
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
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (ctx, box) => box.maxWidth < 750
            ? _buildMobile()
            : _buildDesktop(ctx, box.maxWidth, box.maxHeight),
      ),
    );
  }

  // ── DESKTOP ──────────────────────────────────────────────────────────────
  // الخلفية القطرية الدوّارة (الأبيض على اليمين) يوفّرها AuthFlowShell.

  Widget _buildDesktop(BuildContext ctx, double W, double H) {
    return Stack(
      children: [
        // Branding (جهة البداية — يمين في RTL، فوق الكحلي)
        PositionedDirectional(
          start: 0, width: W * 0.40,
          top: 0, bottom: 0,
          child: _BrandingPanel(entryCtrl: _entryCtrl),
        ),

        // Form (جهة النهاية — يسار في RTL، فوق الأبيض)
        PositionedDirectional(
          start: W * 0.67, end: 0,
          top: 0, bottom: 0,
          child: _FormSide(
            emailCtrl: _emailCtrl,
            passCtrl:  _passCtrl,
            loading:   _loading,
            error:     _error,
            isMobile:  false,
            entryCtrl: _entryCtrl,
            onSubmit: _submit,
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
              loading:   _loading,
              error:     _error,
              isMobile:  true,
              entryCtrl: _entryCtrl,
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

