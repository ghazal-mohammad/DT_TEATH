// ════════════════════════════════════════════════════════════════════════════
// route_guards.dart
//
// حماية المسارات حسب الصلاحيات (Role-based Routing).
// القرار 4: GoRouter يدعم Guards.
//
// المنطق:
//   - المستخدم لازم يكون مسجل دخول قبل ما يوصل لأي صفحة داخلية.
//   - أمين المستودع ما بيدخل على شاشات المخبر، والعكس.
//   - Admin يدخل للاثنين.
//
// المرجع: الملف التقني — القرار 4 (GoRouter).
// ════════════════════════════════════════════════════════════════════════════

import 'package:go_router/go_router.dart';

import 'route_names.dart';

/// أدوار المستخدمين المدعومة في النظام.
///
/// مستخرجة من الملف التقني — الجزء الثالث (User Roles).
enum UserRole {
  admin,
  labManager,
  labTechnician,
  warehouseManager,
  warehouseKeeper,
  doctor,
  secretary,
  guest,
}

/// حالة الجلسة الحالية (مؤقت — يُستبدل بـ AuthBloc في Feature 3).
///
/// في Feature 3 (Auth) سنحقن هذه الحالة عبر GetIt + AuthBloc.
/// حالياً نستخدم قيم ثابتة لبناء البنية الأساسية.
class SessionState {
  SessionState._();

  static bool isLoggedIn = false;
  static UserRole currentRole = UserRole.guest;

  /// هل المستخدم الحالي يحق له الدخول لنظام المخبر؟
  static bool get canAccessLab =>
      currentRole == UserRole.admin ||
      currentRole == UserRole.labManager ||
      currentRole == UserRole.labTechnician;

  /// هل المستخدم الحالي يحق له الدخول لنظام المستودع؟
  static bool get canAccessWarehouse =>
      currentRole == UserRole.admin ||
      currentRole == UserRole.warehouseManager ||
      currentRole == UserRole.warehouseKeeper;
}

/// الـ Guard الرئيسي — يُستدعى قبل كل تنقل في GoRouter.
///
/// يرجع [null] إذا التنقل مسموح، ومسار إعادة توجيه إذا مرفوض.
class RouteGuards {
  RouteGuards._();

  /// الـ redirect الرئيسي لكل مسارات التطبيق.
  ///
  /// حالياً (Phase 4.1): لا يفرض isLoggedIn check لأن SessionState مؤقت
  /// والـ Auth الحقيقي لسه ما اتطبّق. Phase 3 استبدله بـ MockSystemCubit
  /// للـ "اختيار نظام". عند Phase 6 (الـ Backend)، نعيد تفعيل isLoggedIn
  /// check ونحذف هذا التساهل.
  static String? guard(GoRouterState state) {
    final path = state.matchedLocation;

    // 0. المسار الجذر `/` → splash دائماً.
    if (path == RouteNames.initial) {
      return RouteNames.splash;
    }

    // ١. صفحات عامة لا تحتاج تسجيل دخول.
    if (_isPublicRoute(path)) return null;

    // ٢. (مؤقّتاً معطّل) — في غياب AuthCubit، نسمح بكل التنقلات الداخلية.
    //    سيُعاد تفعيل هذا الفحص في Phase 6 عند ربط الـ Backend.
    // if (!SessionState.isLoggedIn) return RouteNames.splash;

    // ٣. (مؤقّتاً معطّل) — RBAC checks لمسارات المخبر/المستودع.
    //    في Phase 4.1 نخلّي MockSystemCubit يدير الـ navigation logic بدلاً
    //    من فرض role-based redirection. سيُعاد تفعيل في Phase 6.
    // if (path.startsWith(RouteNames.labRoot) && !SessionState.canAccessLab) {
    //   return RouteNames.unauthorized;
    // }
    // if (path.startsWith(RouteNames.warehouseRoot) &&
    //     !SessionState.canAccessWarehouse) {
    //   return RouteNames.unauthorized;
    // }

    return null;
  }

  static bool _isPublicRoute(String path) {
    const publicRoutes = {
      // Legacy routes
      RouteNames.login,
      RouteNames.firstLogin,
      // New Auth Flow (Phase 3)
      RouteNames.splash,
      RouteNames.authEmail,
      RouteNames.authVerifyCode,
      RouteNames.authSetPassword,
      // System selection (mock — Phase 3.6)
      RouteNames.systemSelection,
      // Error pages
      RouteNames.notFound,
      RouteNames.unauthorized,
      RouteNames.serverError,
    };
    return publicRoutes.contains(path);
  }
}
