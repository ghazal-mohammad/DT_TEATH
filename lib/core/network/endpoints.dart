// ════════════════════════════════════════════════════════════════════════════
// endpoints.dart
//
// عناوين الـ API الفعلية المطابقة لـ routes/api.php في باك Laravel.
//
// القاعدة: كل endpoint له ثابت واحد هنا — لا تكتبه يدوياً في الكود.
// ════════════════════════════════════════════════════════════════════════════

class ApiEndpoints {
  ApiEndpoints._();

  // ── Employee Auth (المخبري + المستودع + باقي الموظفين) ─────────────────
  /// إرسال كود التحقق للبريد عند التسجيل لأول مرة.
  static const String employeeSendVerification =
      '/api/employee/sendVerification';

  /// تعيين كلمة المرور بعد التحقق من الكود.
  /// يأخذ: email, verification_code, password.
  static const String employeeSetPassword = '/api/employee/setPassword';

  /// تسجيل الدخول بالإيميل وكلمة المرور.
  /// يرجع: token + user.role (نستعملها للتوجيه لـ Lab/Warehouse).
  static const String employeeLogin = '/api/employee/login';

  /// تسجيل الخروج (محمي بـ Bearer token).
  static const String employeeLogout = '/api/employee/logout';
}
