// splash_page.dart
//
// خلفية بيضاء/فاتحة + لوغو navy + شريط تحميل كحلي
// مطابق للصورة المرجعية تماماً

import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/brand/app_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  static const String logoHeroTag = 'app_logo';
  static const Duration totalDuration = Duration(milliseconds: 2800);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _navigated = false;

  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _textOpacity;
  late final Animation<double> _lineProgress;
  late final Animation<double> _exitOpacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: SplashPage.totalDuration);

    _logoOpacity = CurvedAnimation(parent: _ctrl,
        curve: const Interval(0.00, 0.28, curve: Curves.easeOut));
    _logoScale = Tween<double>(begin: 0.82, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl,
            curve: const Interval(0.00, 0.32, curve: Curves.easeOutBack)));
    _textOpacity = CurvedAnimation(parent: _ctrl,
        curve: const Interval(0.18, 0.46, curve: Curves.easeOut));
    _lineProgress = CurvedAnimation(parent: _ctrl,
        curve: const Interval(0.38, 0.87, curve: Curves.easeInOut));
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _ctrl,
            curve: const Interval(0.87, 1.0, curve: Curves.easeIn)));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.of(context).disableAnimations) { _go(); return; }
      _ctrl.forward().whenComplete(_go);
    });
  }

  void _go() {
    if (_navigated || !mounted) return;
    _navigated = true;
    context.go(RouteNames.authEmail);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    // خلفية فاتحة: #E9ECFB من الباليت (lightBg)
    return Scaffold(
      backgroundColor: const Color(0xFFEFF0F7),
      body: GestureDetector(
        onTap: () { _ctrl.stop(); _go(); },
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => SizedBox.expand(
            child: FadeTransition(
              opacity: _exitOpacity,
              child: Stack(
                children: [
                  // ── "DT.Teeth" في أعلى اليسار ──────────────────────────
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Opacity(
                      opacity: _textOpacity.value.clamp(0.0, 1.0),
                      child: const Text(
                        'DT.Teeth',
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  // ── المحتوى المركزي ────────────────────────────────────
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo — navy (lightTheme = logo بألوان navy على خلفية فاتحة)
                        Transform.scale(
                          scale: _logoScale.value,
                          child: Opacity(
                            opacity: _logoOpacity.value.clamp(0.0, 1.0),
                            child: const AppLogo(
                              size: 130,
                              variant: AppLogoVariant.lightTheme,
                              heroTag: SplashPage.logoHeroTag,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ── شريط التحميل ──────────────────────────────────
                        Opacity(
                          opacity: _ctrl.value >= 0.36 ? 1.0 : 0.0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 60),
                            child: LayoutBuilder(
                              builder: (_, box) {
                                final double W = box.maxWidth;
                                final double fill =
                                    _lineProgress.value.clamp(0.0, 1.0);

                                return Column(
                                  children: [
                                    // نص "يتم التحميل"
                                    Opacity(
                                      opacity: _textOpacity.value.clamp(0.0, 1.0),
                                      child: Text(
                                        'يتم التحميل...',
                                        style: TextStyle(
                                          fontFamily: AppTextStyles.fontFamily,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.primary
                                              .withValues(alpha: 0.60),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // الشريط
                                    SizedBox(
                                      height: 4,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          // Track
                                          Container(
                                            width: W,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),

                                          // Fill — primary (كحلي)
                                          Directionality(
                                            textDirection: TextDirection.ltr,
                                            child: FractionallySizedBox(
                                              alignment: Alignment.centerLeft,
                                              widthFactor: fill,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // النسبة %
                                    Opacity(
                                      opacity: _textOpacity.value.clamp(0.0, 1.0),
                                      child: Text(
                                        '${(fill * 100).toInt()}%',
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                          fontFamily: AppTextStyles.fontFamily,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary
                                              .withValues(alpha: 0.55),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
