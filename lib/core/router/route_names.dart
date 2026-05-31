// ════════════════════════════════════════════════════════════════════════════
// route_names.dart
//
// كل مسارات التنقل في المشروع كثوابت.
// ممنوع كتابة '/login' أو '/lab/dashboard' مباشرة في الكود — استخدم الثوابت.
// ════════════════════════════════════════════════════════════════════════════

class RouteNames {
  RouteNames._();

  // ── المسار الجذر ────────────────────────────────────────────────────────
  static const String initial = '/';
  static const String splash = '/splash';

  // ── المصادقة (Phase 3 — Email + OTP + Password Flow) ───────────────────
  /// الشاشة الأولى بعد Splash — المستخدم يدخل بريده.
  static const String authEmail = '/auth/email';

  /// شاشة التحقق من كود OTP الذي أُرسل للإيميل.
  static const String authVerifyCode = '/auth/verify-code';

  /// شاشة إنشاء كلمة المرور (بعد نجاح التحقق).
  static const String authSetPassword = '/auth/set-password';

  /// تسجيل الدخول لمستخدم موجود (password fallback — لاحقاً).
  static const String login = '/login';

  /// أول دخول — legacy، سيُحذف في Phase 3.6.
  static const String firstLogin = '/first-login';

  /// شاشة اختيار النظام (Lab / Warehouse) بعد إكمال Auth Flow.
  /// مؤقّتة حتى جاهزية الـ Backend — حينها يأتي الدور من JWT.
  static const String systemSelection = '/system-selection';

  // ── نظام المخبر (Lab) ───────────────────────────────────────────────────
  static const String labRoot = '/lab';
  static const String labDashboard = '/lab/dashboard';
  static const String labProfile = '/lab/profile';
  static const String labOrders = '/lab/orders';
  static const String labTechnicians = '/lab/technicians';
  static const String labReports = '/lab/reports';
  static const String labNotifications = '/lab/notifications';
  static const String labSettings = '/lab/settings';
  static const String labMaterialRequests = '/lab/material-requests';

  // ── نظام المستودع (Warehouse) ───────────────────────────────────────────
  static const String warehouseRoot = '/warehouse';
  static const String warehouseDashboard = '/warehouse/dashboard';
  static const String warehouseProfile = '/warehouse/profile';
  static const String warehouseMaterials = '/warehouse/materials';
  static const String warehouseOrders = '/warehouse/orders';
  static const String warehouseInvoices = '/warehouse/invoices';
  static const String warehouseReports = '/warehouse/reports';
  static const String warehouseNotifications = '/warehouse/notifications';
  static const String warehouseSettings = '/warehouse/settings';
  static const String warehouseSuppliers = '/warehouse/suppliers';

  // ── صفحات الخطأ ────────────────────────────────────────────────────────
  static const String notFound = '/404';
  static const String unauthorized = '/401';
  static const String serverError = '/500';
}
