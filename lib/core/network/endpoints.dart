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

  // ════════════════════════════════════════════════════════════════════════
  //  Lab Manager — كامل سطح الـ API (تحت /api/labManager، محمي Bearer + active)
  //  مرجع كامل مطابق لـ routes/api.php؛ المسارات بمعرّف تُبنى عبر دوال.
  // ════════════════════════════════════════════════════════════════════════

  // ── لوحة التحكم (عدّادات) ──────────────────────────────────────────────
  static const String labManagerCountOrders = '/api/labManager/countOrders';
  static const String labManagerCountTechnicians =
      '/api/labManager/countTechnicians';
  static const String labManagerCountStock = '/api/labManager/countStock';

  /// GET /api/labManager/reports?period={daily|weekly|monthly|yearly}&date?
  static const String labManagerReports = '/api/labManager/reports';

  // ── فئات الأصناف ───────────────────────────────────────────────────────
  static const String labManagerShowAllItemsCategories =
      '/api/labManager/showAllItemsCategories';

  // ── أصناف المخبر (= منتجات المخبر / lab items) ─────────────────────────
  static const String labManagerShowAllLabItems =
      '/api/labManager/showAllLabItems';
  static const String labManagerAddLabItem = '/api/labManager/addLabItem';
  static String labManagerUpdateLabItem(Object id) =>
      '/api/labManager/updateLabItem/$id';
  static String labManagerDeleteLabItem(Object id) =>
      '/api/labManager/deleteLabItem/$id';
  static String labManagerUpdateLabItemStatus(Object id) =>
      '/api/labManager/updateLabItemStatus/$id';

  // ── طلبات المخبر ───────────────────────────────────────────────────────
  static const String labManagerShowAllLabOrders =
      '/api/labManager/showAllLabOrders';
  static const String labManagerShowAllTodayLabOrders =
      '/api/labManager/showAllTodayLabOrders';
  static String labManagerShowLabOrder(Object id) =>
      '/api/labManager/showLabOrder/$id';
  static String labManagerSetOrderInProgress(Object id) =>
      '/api/labManager/setStatusInProgress/$id';
  static String labManagerSetOrderCompleted(Object id) =>
      '/api/labManager/setStatusCompleted/$id';
  static String labManagerSetOrderCancelled(Object id) =>
      '/api/labManager/setStatusCancelled/$id';

  // ── الفنّيون (showAllTechnicians معرّف أعلاه) ──────────────────────────
  static const String labManagerShowTechniciansPerformance =
      '/api/labManager/showTechniciansPerformance';
  static String labManagerShowTechnician(Object id) =>
      '/api/labManager/showTechnician/$id';
  static String labManagerUpdateTechnicianWorkSchedule(Object id) =>
      '/api/labManager/updateTechnicianWorkSchedule/$id';

  // ── مخزون المخبر ───────────────────────────────────────────────────────
  static const String labManagerShowLabStock = '/api/labManager/showLabStock';
  static const String labManagerShowLabStockLogs =
      '/api/labManager/showLabStockLogs';
  static String labManagerShowStock(Object id) =>
      '/api/labManager/showStock/$id';
  static String labManagerAddToStock(Object id) =>
      '/api/labManager/addToStock/$id';
  static String labManagerSubtractFromStock(Object id) =>
      '/api/labManager/subtractFromStock/$id';
  static const String labManagerNotifyLowStock =
      '/api/labManager/notifyLowStock';

  // ── مواد المستودع (قراءة فقط من جهة المخبر) ────────────────────────────
  static const String labManagerShowAllWarehouseMaterials =
      '/api/labManager/showAllWarehouseMaterials';
  static String labManagerShowWarehouseMaterial(Object id) =>
      '/api/labManager/showWarehouseMaterial/$id';

  // ── طلبات المواد ───────────────────────────────────────────────────────
  static const String labManagerShowAllMaterialRequests =
      '/api/labManager/showAllMaterialRequests';
  static String labManagerShowMaterialRequest(Object id) =>
      '/api/labManager/showMaterialRequest/$id';
  static const String labManagerAddMaterialRequest =
      '/api/labManager/addMaterialRequest';
  static String labManagerDeleteMaterialRequest(Object id) =>
      '/api/labManager/deleteMaterialRequest/$id';

  // ── الإشعارات ──────────────────────────────────────────────────────────
  static const String labManagerNotifications =
      '/api/labManager/notifications';
  static String labManagerMarkNotificationRead(Object id) =>
      '/api/labManager/notifications/$id/read';

  // ── Warehouse Manager — المواد (فُعِّلت 2026-08) ─────────────────────────
  static const String warehouseShowAllMaterials =
      '/api/warehouseManager/showALLMaterials';
  static String warehouseShowMaterial(Object id) =>
      '/api/warehouseManager/showMaterialDetails/$id';
  static const String warehouseAddMaterial =
      '/api/warehouseManager/addMaterial';
  static String warehouseUpdateMaterial(Object id) =>
      '/api/warehouseManager/updateMaterial/$id';
  static String warehouseDeleteMaterial(Object id) =>
      '/api/warehouseManager/materials/$id';
}
