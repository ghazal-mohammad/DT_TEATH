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

