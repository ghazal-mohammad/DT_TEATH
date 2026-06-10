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

  /// التحقق من كود البريد وتعليم الإيميل كـ"مؤكَّد".
  /// يأخذ: email, verification_code. لازم تُستدعى قبل setPassword.
  static const String employeeVerifyCode = '/api/employee/verifyCode';

  /// تعيين كلمة المرور بعد التحقق من الكود.
  /// يأخذ: email, verification_code, password.
  static const String employeeSetPassword = '/api/employee/setPassword';

  /// تسجيل الدخول بالإيميل وكلمة المرور.
  /// يرجع: token + user.role (نستعملها للتوجيه لـ Lab/Warehouse).
  static const String employeeLogin = '/api/employee/login';

  // ── Forgot Password (إعادة تعيين كلمة سر لحساب مُفعَّل — عام، بدون توكن) ──
  /// إرسال كود إعادة التعيين للبريد. body: {email}. 200 · 429 (>3/يوم).
  static const String forgotPasswordSendCode = '/api/forgotPassword/sendCode';

  /// التحقق من كود إعادة التعيين. body: {email, verification_code}. 200 · 422.
  static const String forgotPasswordVerifyCode =
      '/api/forgotPassword/verifyCode';

  /// تعيين كلمة سر جديدة بعد التحقق. body: {email, password}.
  /// لا يرجّع توكن؛ يلغي كل التوكنات → لازم تسجيل دخول جديد.
  static const String forgotPasswordReset = '/api/forgotPassword/resetPassword';

  /// تسجيل الخروج (محمي بـ Bearer token).
  static const String employeeLogout = '/api/employee/logout';

  // ── Employee Profile (المخبري + المستودع — نفس الـ endpoints) ───────────
  /// جلب بيانات الملف الشخصي للموظف الحالي (محمي بـ Bearer).
  /// يرجع: { data: { id, name, email, phone, gender, role, is_active,
  ///                 secondary_phone, marital_status, salary, hire_date,
  ///                 educations[], experiences[], trainings[], skills[] } }
  static const String employeeShowProfile = '/api/employee/showProfile';

  /// تعديل الملف الشخصي (multipart/form-data، محمي بـ Bearer).
  /// يقبل: name, phone, date_of_birth, address, gender(1|2),
  ///        profile_picture(ملف), secondary_phone, marital_status.
  static const String employeeEditProfile = '/api/employee/editProfile';

  // ── Lab Manager (محمي بـ Bearer — صلاحية مدير المخبر أو الأدمن) ──────────
  /// جلب كل فنيي المخبر (role=فني). محمي، صلاحية show-technicians.
  /// يرجع: { success, data:[ { id, user_id, name, email, role,
  ///                           profile_picture } ] }.
  /// ملاحظة: ما في حقول دوام/عدد مخابر بالباك — غير متوفّرة بالداتا.
  static const String labManagerShowAllTechnicians =
      '/api/labManager/showAllTechnicians';
}
