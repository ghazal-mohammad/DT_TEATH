// ════════════════════════════════════════════════════════════════════════════
// system_selection_page.dart (Refactored: Clean Architecture Edition)
//
// شاشة اختيار النظام — تظهر بعد تأكيد كلمة المرور.
// المستخدم يختار: نظام المخبر 🧪 أو نظام المستودع 📦
//
// 🎬 الانيميشن (مستوحى من الفيديو المرجعي):
//   • AuthCardGlowBorder: توهج سماوي نابض على حدود الكارت
//   • AuthGlowLinePainter: خط التوهج على الخط المائل (لون بلوري مختلف)
//   • Entry Stagger: branding → cards
//   • Cards: hover = lift + glow
//
// إصلاحات Code Quality:
//   ✅ AuthNavyBackground    ← بدل gradient مكرر (كان مرتين)
//   ✅ AuthGlowLinePainter   ← بدل _GlowLine الخاص (glowColor مختلف)
//   ✅ AuthDiagRightClipper  ← بدل _DiagClipper الخاص
//   ✅ AppTextStyles.authXxx ← بدل fontFamily: AppTextStyles.fontFamily يدوي
//   ✅ AppColors.authXxx     ← بدل Color hardcoded
//   ✅ AppSizes.spaceXxx     ← بدل SizedBox يدوية
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/bloc/mock_system_cubit.dart';
import '../widgets/auth_entry_animator.dart';
import '../widgets/auth_layout_painters.dart';
import '../widgets/auth_page_transition.dart';

// ══════════════════════════════════════════════════════════════════════════
//  PAGE
// ══════════════════════════════════════════════════════════════════════════

class SystemSelectionPage extends StatefulWidget {
  const SystemSelectionPage({super.key});

  @override
  State<SystemSelectionPage> createState() => _SystemSelectionPageState();
}

class _SystemSelectionPageState extends State<SystemSelectionPage>
    with TickerProviderStateMixin {
  late final AnimationController _glowCtrl;
  late final AnimationController _entryCtrl;
  late final AnimationController _shapeCtrl;

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
      duration: const Duration(milliseconds: 750),
    )..forward();
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _shapeCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
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
    const double topXRatio = 0.40;
    const double botXRatio = 0.26;
    final double topX = W * topXRatio;
    final double botX = W * botXRatio;

    return AuthCardGlowBorder(
      // system_selection يستخدم لون بلوري (مختلف عن أخضر Auth)
      glowColor: const Color(0xFFBED8FA),
      borderRadius: 0,
      child: Stack(
        children: [
          // 1-3: خلفية متحركة — نسب مختلفة ولون بلوري خاص بـ system_selection
          Positioned.fill(
            child: AuthShapeBackground(
              shapeCtrl: _shapeCtrl,
              glowCtrl: _glowCtrl,
              topRatio: topXRatio,
              botRatio: botXRatio,
              glowColor: const Color(0xFFBED8FA),
            ),
          ),

          // 4 ─ Branding (يسار داكن)
          Positioned(
            left: 0, width: botX - 24,
            top: 0, bottom: 0,
            child: _BrandingPanel(entryCtrl: _entryCtrl),
          ),

          // 5 ─ Cards panel (يمين أبيض)
          Positioned(
            left: topX + 16, right: 0,
            top: 0, bottom: 0,
            child: _CardsPanel(entryCtrl: _entryCtrl),
          ),
        ],
      ),
    );
  }

  // ── MOBILE ────────────────────────────────────────────────────────────────

  Widget _buildMobile() {
    return AuthCardGlowBorder(
      glowColor: const Color(0xFFBED8FA),
      borderRadius: 0,
      child: Stack(
        children: [
          const AuthNavyBackground(),
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.space2XL,
                  vertical: 48,
                ),
                child: Column(
                  children: [
                    AuthEntryAnimator(
                      controller: _entryCtrl,
                      delay: AuthStaggerDelays.logo,
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          'DT.Teeth',
                          style: AppTextStyles.authHeroTitle.copyWith(
                            fontSize: 28,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.space2XL),

                    AuthEntryAnimator(
                      controller: _entryCtrl,
                      delay: AuthStaggerDelays.title,
                      child: Text(
                        'اختر النظام',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.authFormTitle.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceXS + 2),

                    AuthEntryAnimator(
                      controller: _entryCtrl,
                      delay: AuthStaggerDelays.subtitle,
                      child: Text(
                        'حدد النظام الذي تريد العمل عليه',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.authFormSubtitle.copyWith(
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.space3XL),

                    AuthEntryAnimator(
                      controller: _entryCtrl,
                      delay: AuthStaggerDelays.field1,
                      child: _SystemCard(
                        role: SystemRole.lab,
                        icon: Icons.science_outlined,
                        color: AppColors.labSystem,
                        title: 'نظام المخبر',
                        description:
                            'إدارة طلبات التعويضات والمخبريين والتقارير',
                        destination: RouteNames.labDashboard,
                        darkMode: true,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceLG),

                    AuthEntryAnimator(
                      controller: _entryCtrl,
                      delay: AuthStaggerDelays.field2,
                      child: _SystemCard(
                        role: SystemRole.warehouse,
                        icon: Icons.inventory_2_outlined,
                        color: AppColors.warehouseSystem,
                        title: 'نظام المستودع',
                        description:
                            'إدارة المخزون والمواد والفواتير وطلبيات العيادات',
                        destination: RouteNames.warehouseDashboard,
                        darkMode: true,
                      ),
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
        left: 52, right: 16, top: 40, bottom: 40,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthEntryAnimator(
            controller: entryCtrl,
            delay: AuthStaggerDelays.logo,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                'DT.Teeth',
                style: AppTextStyles.authHeroTitle.copyWith(
                  fontSize: 28,
                  color: AppColors.accent,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.space3XL),

          AuthEntryAnimator(
            controller: entryCtrl,
            delay: AuthStaggerDelays.title,
            child: Text(
              'CHOOSE\nYOUR SYSTEM',
              textDirection: TextDirection.ltr,
              style: AppTextStyles.authHeroTitle.copyWith(
                fontSize: 40,
                letterSpacing: 2.0,
                color: Colors.white,
                height: 1.1,
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
                // لون بلوري لـ system_selection (مختلف عن أخضر Auth)
                color: const Color(0xFFBED8FA).withValues(alpha: 0.80),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.space3XL),

          // شارة "وضع معاينة"
          AuthEntryAnimator(
            controller: entryCtrl,
            delay: AuthStaggerDelays.footer,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.25),
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.accent.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'وضع المعاينة — يمكنك التبديل في أي وقت',
                    style: AppTextStyles.authFooterNote.copyWith(
                      color: Colors.white.withValues(alpha: 0.55),
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
}

// ══════════════════════════════════════════════════════════════════════════
//  CARDS PANEL — يمين أبيض
// ══════════════════════════════════════════════════════════════════════════

class _CardsPanel extends StatelessWidget {
  const _CardsPanel({required this.entryCtrl});

  final AnimationController entryCtrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 44, vertical: 40,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // عنوان
          AuthEntryAnimator(
            controller: entryCtrl,
            delay: AuthStaggerDelays.title,
            child: Text(
              'اختر النظام',
              style: AppTextStyles.authFormTitle.copyWith(
                color: AppColors.authCardTitleLight,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spaceXS + 2),

          AuthEntryAnimator(
            controller: entryCtrl,
            delay: AuthStaggerDelays.subtitle,
            child: Text(
              'حدد النظام الذي تريد العمل عليه اليوم',
              style: AppTextStyles.authFormSubtitle.copyWith(
                color: AppColors.authCardSubLight,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.space3XL),

          // بطاقة المخبر
          AuthEntryAnimator(
            controller: entryCtrl,
            delay: AuthStaggerDelays.field1,
            child: _SystemCard(
              role: SystemRole.lab,
              icon: Icons.science_outlined,
              color: AppColors.labSystem,
              title: 'نظام المخبر',
              description: 'إدارة طلبات التعويضات السنية والمخبريين والتقارير',
              destination: RouteNames.labDashboard,
              darkMode: false,
            ),
          ),
          const SizedBox(height: AppSizes.spaceLG),

          // بطاقة المستودع
          AuthEntryAnimator(
            controller: entryCtrl,
            delay: AuthStaggerDelays.field2,
            child: _SystemCard(
              role: SystemRole.warehouse,
              icon: Icons.inventory_2_outlined,
              color: AppColors.warehouseSystem,
              title: 'نظام المستودع',
              description: 'إدارة المخزون والمواد والفواتير وطلبيات العيادات',
              destination: RouteNames.warehouseDashboard,
              darkMode: false,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  SYSTEM CARD — بطاقة النظام مع hover animation
// ══════════════════════════════════════════════════════════════════════════

class _SystemCard extends StatefulWidget {
  const _SystemCard({
    required this.role,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.destination,
    required this.darkMode,
  });

  final SystemRole role;
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String destination;
  final bool darkMode;

  @override
  State<_SystemCard> createState() => _SystemCardState();
}

class _SystemCardState extends State<_SystemCard> {
  bool _hovered = false;

  Future<void> _onTap() async {
    await context.read<MockSystemCubit>().selectSystem(widget.role);
    if (!mounted) return;
    context.go(widget.destination);
  }

  @override
  Widget build(BuildContext context) {
    final Color titleColor =
        widget.darkMode ? Colors.white : AppColors.authCardTitleLight;
    final Color descColor = widget.darkMode
        ? Colors.white.withValues(alpha: 0.60)
        : AppColors.authCardSubLight;
    final Color cardBg = widget.darkMode
        ? widget.color.withValues(alpha: _hovered ? 0.12 : 0.06)
        : Colors.white;
    final Color borderColor = widget.darkMode
        ? widget.color.withValues(alpha: _hovered ? 0.50 : 0.20)
        : widget.color.withValues(alpha: _hovered ? 0.70 : 0.30);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, _hovered ? -4.0 : 0.0, 0.0),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border.all(color: borderColor, width: _hovered ? 2 : 1.5),
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.22),
                      blurRadius: 24,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // أيقونة
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(
                    alpha: _hovered ? 0.22 : 0.12,
                  ),
                  border: Border.all(
                    color: widget.color.withValues(alpha: 0.40),
                    width: 1.5,
                  ),
                ),
                child: Icon(widget.icon, size: 30, color: widget.color),
              ),
              const SizedBox(width: 18),

              // نص
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spaceXS),
                    Text(
                      widget.description,
                      style: AppTextStyles.authFormSubtitle.copyWith(
                        color: descColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSizes.spaceXS + 2),

              // سهم
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 36, height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _hovered
                      ? widget.color
                      : widget.color.withValues(alpha: 0.10),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: _hovered
                      ? (widget.darkMode ? AppColors.primary : Colors.white)
                      : widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
