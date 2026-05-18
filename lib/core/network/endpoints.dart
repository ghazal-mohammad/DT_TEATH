// ════════════════════════════════════════════════════════════════════════════
// endpoints.dart
//
// عناوين الـ API — فارغة حالياً، تُملأ عند جاهزية الباك Laravel.
//
// القاعدة: كل endpoint له ثابت واحد هنا — لا تكتبه يدوياً في الكود.
// ════════════════════════════════════════════════════════════════════════════

class ApiEndpoints {
  ApiEndpoints._();

  // ── Base URLs ───────────────────────────────────────────────────────────
  /// Base URL للـ API — سيُملأ من app_urls.dart لاحقاً.
  static const String baseUrl = '';

  // ── Auth ────────────────────────────────────────────────────────────────
  static const String login = '/api/auth/login';
  static const String firstLogin = '/api/auth/first-login';
  static const String logout = '/api/auth/logout';
  static const String refreshToken = '/api/auth/refresh';
  static const String currentUser = '/api/auth/me';

  // ── Lab ─────────────────────────────────────────────────────────────────
  static const String labOrders = '/api/lab/orders';
  static const String labTechnicians = '/api/lab/technicians';
  static const String labReports = '/api/lab/reports';
  static const String labMaterialRequests = '/api/lab/material-requests';
  static const String labStats = '/api/lab/stats';

  // ── Warehouse ───────────────────────────────────────────────────────────
  static const String warehouseMaterials = '/api/warehouse/materials';
  static const String warehouseOrders = '/api/warehouse/orders';
  static const String warehouseInvoices = '/api/warehouse/invoices';
  static const String warehouseSuppliers = '/api/warehouse/suppliers';
  static const String warehouseReports = '/api/warehouse/reports';
  static const String warehouseStats = '/api/warehouse/stats';

  // ── Shared ──────────────────────────────────────────────────────────────
  static const String notifications = '/api/notifications';
  static const String auditLog = '/api/audit-log';
}
