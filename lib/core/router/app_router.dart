// ════════════════════════════════════════════════════════════════════════════
// app_router.dart — GoRouter الرئيسي
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/email_entry_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/set_password_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/system_selection_page.dart';
import '../../features/auth/presentation/pages/verify_code_page.dart';
import '../../features/auth/presentation/widgets/auth_flow_transition.dart';
import '../../features/lab/presentation/pages/lab_pages.dart';
import '../../features/warehouse/presentation/pages/warehouse_pages.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text_styles.dart';
import 'route_guards.dart';
import 'route_names.dart';

// ══════════════════════════════════════════════════════════════════════════
//  TRANSITIONS
// ══════════════════════════════════════════════════════════════════════════

/// Fade — للـ Splash فقط
CustomTransitionPage<void> _fadeRoute({
  required LocalKey key,
  required Widget child,
  Duration duration = const Duration(milliseconds: 350),
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (_, animation, __, child) => FadeTransition(
      opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
      child: child,
    ),
  );
}

/// Auth transition — slide أفقي بسيط وموثوق بين شاشات Auth.
/// direction:  1 = الصفحة الجديدة تدخل من اليمين (forward)
/// direction: -1 = الصفحة الجديدة تدخل من اليسار (back)
CustomTransitionPage<void> _authSlide({
  required LocalKey key,
  required Widget child,
  int direction = 1,
  Duration duration = const Duration(milliseconds: 500),
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (_, animation, secondaryAnimation, child) {
      // الصفحة الجديدة تدخل
      final slideIn = Tween<Offset>(
        begin: Offset(0.06 * direction, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ));

      final fadeIn = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      );

      // الصفحة القديمة تخرج
      final slideOut = Tween<Offset>(
        begin: Offset.zero,
        end: Offset(-0.05 * direction, 0),
      ).animate(CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeInCubic,
      ));

      final fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: secondaryAnimation,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
        ),
      );

      return SlideTransition(
        position: slideOut,
        child: FadeTransition(
          opacity: fadeOut,
          child: SlideTransition(
            position: slideIn,
            child: FadeTransition(opacity: fadeIn, child: child),
          ),
        ),
      );
    },
  );
}

// ══════════════════════════════════════════════════════════════════════════
//  ROUTER
// ══════════════════════════════════════════════════════════════════════════

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) => RouteGuards.guard(state),
    errorBuilder: (context, state) => _ErrorScreen(
      error: state.error?.toString() ?? 'صفحة غير موجودة',
    ),
    routes: [

      // ── Splash ───────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        pageBuilder: (context, state) => _fadeRoute(
          key: state.pageKey,
          child: const SplashPage(),
        ),
      ),

      // ── Auth Flow ─────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.authEmail,
        name: 'authEmail',
        pageBuilder: (context, state) => _authSlide(
          key: state.pageKey,
          child: const EmailEntryPage(),
          direction: 1,
        ),
      ),

      GoRoute(
        path: RouteNames.authVerifyCode,
        name: 'authVerifyCode',
        pageBuilder: (context, state) {
          // ✅ FIX: تحقق من نوع extra بأمان
          final email = (state.extra is String) ? state.extra as String : '';
          return authFlowPage(
            key: state.pageKey,
            direction: 1,
            child: VerifyCodePage(email: email),
          );
        },
      ),

      GoRoute(
        path: RouteNames.authSetPassword,
        name: 'authSetPassword',
        pageBuilder: (context, state) {
          String email = '';
          String code = '';
          final extra = state.extra;
          if (extra is Map) {
            email = (extra['email'] ?? '') as String;
            code = (extra['code'] ?? '') as String;
          } else if (extra is String) {
            email = extra; // توافق رجعي
          }
          return authFlowPage(
            key: state.pageKey,
            direction: 1,
            child: SetPasswordPage(email: email, verificationCode: code),
          );
        },
      ),

      GoRoute(
        path: RouteNames.systemSelection,
        name: 'systemSelection',
        pageBuilder: (context, state) => _authSlide(
          key: state.pageKey,
          child: const SystemSelectionPage(),
          direction: 1,
        ),
      ),

      GoRoute(
        path: RouteNames.login,
        name: 'login',
        pageBuilder: (context, state) => authFlowPage(
          key: state.pageKey,
          child: const LoginPage(),
          direction: -1,
        ),
      ),

      GoRoute(
        path: RouteNames.firstLogin,
        name: 'firstLogin',
        builder: (context, state) => const _PlaceholderScreen(
          title: AppStrings.firstLogin,
          subtitle: 'Legacy — سيُحذف في Phase 3.6',
          icon: Icons.person_add,
        ),
      ),

      // ── Lab ───────────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.labDashboard,
        name: 'labDashboard',
        builder: (context, state) => const LabDashboardPage(),
      ),
      GoRoute(
        path: RouteNames.labProfile,
        name: 'labProfile',
        builder: (context, state) => const LabProfilePage(),
      ),
      GoRoute(
        path: RouteNames.labOrders,
        name: 'labOrders',
        builder: (context, state) => const LabOrdersPage(),
      ),
      GoRoute(
        path: RouteNames.labTechnicians,
        name: 'labTechnicians',
        builder: (context, state) => const LabTechniciansPage(),
      ),
      GoRoute(
        path: RouteNames.labReports,
        name: 'labReports',
        builder: (context, state) => const LabReportsPage(),
      ),
      GoRoute(
        path: RouteNames.labNotifications,
        name: 'labNotifications',
        builder: (context, state) => const LabNotificationsPage(),
      ),
      GoRoute(
        path: RouteNames.labSettings,
        name: 'labSettings',
        builder: (context, state) => const LabSettingsPage(),
      ),
      GoRoute(
        path: RouteNames.labMaterialRequests,
        name: 'labMaterialRequests',
        builder: (context, state) => const LabMaterialRequestsPage(),
      ),
      GoRoute(
        path: RouteNames.labInventory,
        name: 'labInventory',
        builder: (context, state) => const LabInventoryPage(),
      ),
      GoRoute(
        path: RouteNames.labProducts,
        name: 'labProducts',
        builder: (context, state) => const LabProductsPage(),
      ),

      // ── Warehouse ─────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.warehouseDashboard,
        name: 'warehouseDashboard',
        builder: (context, state) => const WarehouseDashboardPage(),
      ),
      GoRoute(
        path: RouteNames.warehouseProfile,
        name: 'warehouseProfile',
        builder: (context, state) => const WarehouseProfilePage(),
      ),
      GoRoute(
        path: RouteNames.warehouseMaterials,
        name: 'warehouseMaterials',
        builder: (context, state) => const WarehouseMaterialsPage(),
      ),
      GoRoute(
        path: RouteNames.warehouseOrders,
        name: 'warehouseOrders',
        builder: (context, state) => const WarehouseOrdersPage(),
      ),
      GoRoute(
        path: RouteNames.warehouseInvoices,
        name: 'warehouseInvoices',
        builder: (context, state) => const WarehouseInvoicesPage(),
      ),
      GoRoute(
        path: RouteNames.warehouseReports,
        name: 'warehouseReports',
        builder: (context, state) => const WarehouseReportsPage(),
      ),
      GoRoute(
        path: RouteNames.warehouseNotifications,
        name: 'warehouseNotifications',
        builder: (context, state) => const WarehouseNotificationsPage(),
      ),
      GoRoute(
        path: RouteNames.warehouseSettings,
        name: 'warehouseSettings',
        builder: (context, state) => const WarehouseSettingsPage(),
      ),

      // ── Error pages ───────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.unauthorized,
        name: 'unauthorized',
        builder: (context, state) => const _ErrorScreen(
          error: AppStrings.errorForbidden,
          code: '401',
        ),
      ),
      GoRoute(
        path: RouteNames.notFound,
        name: 'notFound',
        builder: (context, state) => const _ErrorScreen(
          error: AppStrings.errorNotFound,
          code: '404',
        ),
      ),
      GoRoute(
        path: RouteNames.serverError,
        name: 'serverError',
        builder: (context, state) => const _ErrorScreen(
          error: AppStrings.errorServer,
          code: '500',
        ),
      ),
    ],
  );
}

// ══════════════════════════════════════════════════════════════════════════
//  PLACEHOLDER & ERROR SCREENS
// ══════════════════════════════════════════════════════════════════════════

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    const Color accentColor = AppColors.accent;
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(AppSizes.space3XL),
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: AppSizes.borderMedium,
                  ),
                ),
                child: Icon(icon, size: 48, color: accentColor),
              ),
              const SizedBox(height: AppSizes.space2XL),
              Text(title,
                  style: AppTextStyles.headlineLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSizes.spaceMD),
              Text(subtitle,
                  style: AppTextStyles.bodyLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSizes.space3XL),
              const Text('${AppStrings.appName} · ${AppStrings.appVersion}',
                  style: AppTextStyles.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.error, this.code});
  final String error;
  final String? code;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.space3XL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (code != null)
                Text(code!,
                    style: AppTextStyles.displayLarge
                        .copyWith(color: AppColors.error)),
              const SizedBox(height: AppSizes.spaceMD),
              Text(error,
                  style: AppTextStyles.headlineMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSizes.space2XL),
              ElevatedButton.icon(
                onPressed: () => GoRouter.of(context).go(RouteNames.labDashboard),
                icon: const Icon(Icons.home),
                label: const Text('العودة للرئيسية'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
