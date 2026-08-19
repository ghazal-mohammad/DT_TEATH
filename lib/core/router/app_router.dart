// ════════════════════════════════════════════════════════════════════════════
// app_router.dart — GoRouter الرئيسي
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/auth_flow_mode.dart';
import '../../features/auth/presentation/pages/email_entry_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/set_password_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/system_selection_page.dart';
import '../../features/auth/presentation/pages/verify_code_page.dart';
import '../../features/auth/presentation/widgets/auth_flow_shell.dart';
import '../../features/auth/presentation/widgets/auth_flow_transition.dart';
import '../../features/lab/presentation/pages/lab_pages.dart';
import '../../features/warehouse/presentation/pages/warehouse_pages.dart';
import '../l10n/build_context_l10n.dart';
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
      // ShellRoute يوفّر خلفية قطرية **دائمة** تدور بين الخطوات (الشِل الواحد).
      // الأبيض على اليسار في شاشة التحقق فقط (flipped)، وعلى اليمين في البقية.
      ShellRoute(
        builder: (context, state, child) {
          final bool flipped =
              state.matchedLocation == RouteNames.authVerifyCode;
          return AuthFlowShell(flipped: flipped, child: child);
        },
        routes: [
          GoRoute(
            path: RouteNames.authEmail,
            name: 'authEmail',
            pageBuilder: (context, state) {
              // extra اختياري: {mode} — لتمييز تدفّق "نسيت كلمة السر".
              final extra = state.extra;
              final mode = (extra is Map && extra['mode'] is AuthFlowMode)
                  ? extra['mode'] as AuthFlowMode
                  : AuthFlowMode.activation;
              return authFlowPage(
                key: state.pageKey,
                child: EmailEntryPage(mode: mode),
                direction: 1,
              );
            },
          ),

          GoRoute(
            path: RouteNames.authVerifyCode,
            name: 'authVerifyCode',
            pageBuilder: (context, state) {
              // extra: {email, mode} — أو String (توافق رجعي) = email فقط.
              String email = '';
              AuthFlowMode mode = AuthFlowMode.activation;
              final extra = state.extra;
              if (extra is Map) {
                email = (extra['email'] ?? '') as String;
                if (extra['mode'] is AuthFlowMode) {
                  mode = extra['mode'] as AuthFlowMode;
                }
              } else if (extra is String) {
                email = extra;
              }
              return authFlowPage(
                key: state.pageKey,
                direction: 1,
                child: VerifyCodePage(email: email, mode: mode),
              );
            },
          ),

          GoRoute(
            path: RouteNames.authSetPassword,
            name: 'authSetPassword',
            pageBuilder: (context, state) {
              String email = '';
              String code = '';
              AuthFlowMode mode = AuthFlowMode.activation;
              final extra = state.extra;
              if (extra is Map) {
                email = (extra['email'] ?? '') as String;
                code = (extra['code'] ?? '') as String;
                if (extra['mode'] is AuthFlowMode) {
                  mode = extra['mode'] as AuthFlowMode;
                }
              } else if (extra is String) {
                email = extra; // توافق رجعي
              }
              return authFlowPage(
                key: state.pageKey,
                direction: 1,
                child: SetPasswordPage(
                  email: email,
                  verificationCode: code,
                  mode: mode,
                ),
              );
            },
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
        ],
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
        path: RouteNames.firstLogin,
        name: 'firstLogin',
        builder: (context, state) => _PlaceholderScreen(
          title: context.l10n.firstLogin,
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
        // الملف الشخصي صار تبويباً داخل الإعدادات (راجع LabSettingsPage) —
        // هالمسار يبقى صالح لأي رابط قديم، بس يوجّه فوراً للتبويب الجديد
        // بدل صفحة مستقلة.
        redirect: (context, state) => '${RouteNames.labSettings}?tab=profile',
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
        builder: (context, state) => LabSettingsPage(
          initialTab: labSettingsTabFromQuery(state.uri.queryParameters['tab']),
        ),
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
        // الملف الشخصي صار تبويباً داخل الإعدادات (راجع WarehouseSettingsPage)
        // — هالمسار يبقى صالح لأي رابط قديم، بس يوجّه فوراً للتبويب الجديد.
        redirect: (context, state) =>
            '${RouteNames.warehouseSettings}?tab=profile',
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
        builder: (context, state) =>
            WarehouseSettingsPage(initialTab: state.uri.queryParameters['tab']),
      ),

      // ── Error pages ───────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.unauthorized,
        name: 'unauthorized',
        builder: (context, state) => _ErrorScreen(
          error: context.l10n.errorForbidden,
          code: '401',
        ),
      ),
      GoRoute(
        path: RouteNames.notFound,
        name: 'notFound',
        builder: (context, state) => _ErrorScreen(
          error: context.l10n.errorNotFound,
          code: '404',
        ),
      ),
      GoRoute(
        path: RouteNames.serverError,
        name: 'serverError',
        builder: (context, state) => _ErrorScreen(
          error: context.l10n.errorServer,
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
              const Text('DT.Teeth · v1.0 · Flutter Web',
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
