// ════════════════════════════════════════════════════════════════════════════
// route_guards.dart
//
// حماية المسارات حسب الصلاحيات (Role-based Routing) — تستخدم الدور **الحقيقي**
// من [CurrentUser] (مُعبَّأ من رد الباك عند login/setPassword). أمين المستودع
// ما بيدخل على شاشات المخبر، والعكس؛ admin يدخل للاثنين.
//
// ملاحظة نطاق: ما زلنا لا نفرض "لازم تسجّل دخول" هون (لو [CurrentUser] فارغ
// نسمح بالتنقّل كما كان) — لأن الجلسة لا تُستعاد بعد بعد تحديث الصفحة (F5) على
// الويب (CurrentUser في الذاكرة فقط)، ففرض الشرط الآن كان رح يطلّع كل مستخدم
// لصفحة الدخول عند أي refresh رغم امتلاكه توكن صالح. هاي فجوة منفصلة (استعادة
// الجلسة من SecureStorage عند الإقلاع) — مش ضمن هذا الإصلاح.
// ════════════════════════════════════════════════════════════════════════════

import 'package:go_router/go_router.dart';

import '../auth/auth_models.dart';
import '../auth/current_user.dart';
import 'route_names.dart';

class RouteGuards {
  RouteGuards._();

  /// الـ redirect الرئيسي لكل مسارات التطبيق.
  ///
  /// يرجع [null] إذا التنقل مسموح، ومسار إعادة توجيه إذا مرفوض.
  static String? guard(GoRouterState state) {
    final path = state.matchedLocation;

    // 0. المسار الجذر `/` → splash دائماً.
    if (path == RouteNames.initial) {
      return RouteNames.splash;
    }

    // ١. صفحات عامة لا تحتاج تسجيل دخول.
    if (_isPublicRoute(path)) return null;

    final role = CurrentUser.instance.role;

    // ٢. الدور غير معروف بعد (لا جلسة مُستعادة على هالويب-تاب) — نسمح كما كان
    //    (راجع ملاحظة النطاق بالأعلى).
    if (role == null) return null;

    // ٣. RBAC: مخبر/مستودع/اختيار النظام — كل واحد يشوف نطاقه فقط.
    final home = _homeFor(role);

    if (path.startsWith(RouteNames.labRoot)) {
      return _canAccessLab(role) ? null : home;
    }
    if (path.startsWith(RouteNames.warehouseRoot)) {
      return _canAccessWarehouse(role) ? null : home;
    }
    if (path == RouteNames.systemSelection) {
      // اختيار النظام مخصّص للأدمن فقط (وحده يملك أكثر من نظام يختار بينه).
      return role == EmployeeRole.admin ? null : home;
    }

    return null;
  }

  static bool _canAccessLab(EmployeeRole role) =>
      role == EmployeeRole.labManager || role == EmployeeRole.admin;

  static bool _canAccessWarehouse(EmployeeRole role) =>
      role == EmployeeRole.warehouseManager || role == EmployeeRole.admin;

  /// المسار الافتراضي لكل دور — يُستخدم كوجهة عند رفض دخول مسار غير مسموح.
  static String _homeFor(EmployeeRole role) => switch (role) {
        EmployeeRole.labManager => RouteNames.labDashboard,
        EmployeeRole.warehouseManager => RouteNames.warehouseDashboard,
        EmployeeRole.admin => RouteNames.systemSelection,
        _ => RouteNames.unauthorized,
      };

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
      // Error pages
      RouteNames.notFound,
      RouteNames.unauthorized,
      RouteNames.serverError,
    };
    return publicRoutes.contains(path);
  }
}
