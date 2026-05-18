// ════════════════════════════════════════════════════════════════════════════
// app_strings.dart
//
// كل النصوص الثابتة في مكان واحد — لتسهيل الترجمة لاحقاً (القرار 14).
//
// ⚠️ ملاحظة مهمة (Phase 2.7.2):
//   هذا الملف الآن في حالة **هجرة تدريجية** نحو نظام .arb / AppLocalizations.
//   الاستخدام الموصى به للكود الجديد:
//
//     import 'package:dt_teeth/core/l10n/build_context_l10n.dart';
//     Text(context.l10n.dashboard)   // ← استخدم هذا
//     Text(AppStrings.dashboard)     // ← ما زال يعمل، لكن ما بيدعم اللغة
//
//   الملف يُحتفظ به للوقت الحالي لأن بعض الـ widgets (في Phase 2.5) تعتمد عليه.
//   في Phase 3 سنعمل هجرة تدريجية لكل الـ widgets إلى context.l10n.
//
// قاعدة الاستخدام (القديمة):
//   - ممنوع كتابة نص عربي مباشر في الشاشات (hardcoded strings).
//   - كل نص يُعرّف هنا أو في .arb files.
// ════════════════════════════════════════════════════════════════════════════

class AppStrings {
  AppStrings._();

  // ── اسم التطبيق ────────────────────────────────────────────────────────
  static const String appName = 'DT.Teeth';
  static const String appSubtitle = 'نظام إدارة مركز طب الأسنان الشامل';
  static const String appVersion = 'v1.0 · Flutter Web';

  // ── المصادقة (Auth) ─────────────────────────────────────────────────────
  static const String login = 'تسجيل الدخول';
  static const String loginTitle = 'أهلاً بعودتك';
  static const String loginSubtitle = 'سجّل دخولك للمتابعة';
  static const String email = 'البريد / رقم الموظف';
  static const String password = 'كلمة المرور';
  static const String firstLogin = 'أول مرة';
  static const String rememberMe = 'تذكرني';
  static const String forgotPassword = 'نسيت كلمة المرور؟';
  static const String logout = 'تسجيل الخروج';

  // ── الأنظمة الفرعية ────────────────────────────────────────────────────
  static const String labSystem = 'نظام المخبر';
  static const String warehouseSystem = 'نظام المستودع';
  static const String switchSystem = 'تبديل النظام';

  // ── عناوين الصفحات المشتركة ─────────────────────────────────────────────
  static const String dashboard = 'لوحة التحكم';
  static const String reports = 'التقارير';
  static const String notifications = 'الإشعارات';
  static const String settings = 'الإعدادات';

  // ── المخبر ─────────────────────────────────────────────────────────────
  static const String doctorOrders = 'طلبات الأطباء';
  static const String technicians = 'إدارة المخبريين';
  static const String labReports = 'تقارير المخبر';
  static const String materialRequests = 'طلبات المستودع';

  // ── المستودع ───────────────────────────────────────────────────────────
  static const String materials = 'المواد';
  static const String orders = 'الطلبيات';
  static const String invoices = 'الفواتير';
  static const String suppliers = 'الموردون';
  static const String inventory = 'المخزون';

  // ── أقسام السايدبار ────────────────────────────────────────────────────
  static const String sectionMain = 'الرئيسية';
  static const String sectionInventory = 'المخزون';
  static const String sectionFinance = 'المالية';
  static const String sectionSystem = 'النظام';
  static const String sectionTeam = 'الفريق';
  static const String sectionOrdersSec = 'الطلبات';

  // ── الإجراءات العامة ────────────────────────────────────────────────────
  static const String search = 'بحث في النظام...';
  static const String save = 'حفظ';
  static const String cancel = 'إلغاء';
  static const String delete = 'حذف';
  static const String edit = 'تعديل';
  static const String add = 'إضافة';
  static const String confirm = 'تأكيد';
  static const String apply = 'تطبيق';
  static const String reset = 'إعادة تعيين';
  static const String close = 'إغلاق';
  static const String viewAll = 'عرض الكل';
  static const String viewDetails = 'عرض التفاصيل';
  static const String retry = 'إعادة المحاولة';

  // ── الحالات (States) ────────────────────────────────────────────────────
  static const String loading = 'جاري التحميل...';
  static const String noData = 'لا توجد بيانات';
  static const String noResults = 'لا توجد نتائج';
  static const String error = 'حدث خطأ';
  static const String success = 'تمت العملية بنجاح';

  // ── حالات الطلبيات (Lab Orders) ─────────────────────────────────────────
  static const String statusNew = 'جديد';
  static const String statusPendingMaterials = 'معلّق — بانتظار مواد';
  static const String statusManufacturing = 'قيد التصنيع';
  static const String statusReady = 'جاهز';
  static const String statusDelivered = 'تم التسليم';
  static const String statusRejected = 'مرفوض';

  // ── رسائل الأخطاء (القرار 16) ──────────────────────────────────────────
  static const String errorNetwork = 'لا يوجد اتصال بالإنترنت — تحقق من الشبكة';
  static const String errorServer = 'خطأ في السيرفر — حاول مرة أخرى بعد قليل';
  static const String errorTimeout = 'انتهت مهلة الانتظار — السيرفر لا يستجيب';
  static const String errorUnauthorized =
      'انتهت صلاحية الجلسة — سجّل دخولك مجدداً';
  static const String errorForbidden = 'ليس لديك صلاحية للوصول لهذه الصفحة';
  static const String errorNotFound = 'العنصر المطلوب غير موجود';
  static const String errorValidation = 'تحقق من الحقول المطلوبة';
  static const String errorMaintenance = 'السيرفر في صيانة — عد لاحقاً';
  static const String errorCache = 'خطأ في البيانات المحلية — حاول مجدداً';

  // ── الإعدادات ──────────────────────────────────────────────────────────
  static const String theme = 'الوضع';
  static const String darkMode = 'داكن';
  static const String lightMode = 'فاتح';
  static const String language = 'اللغة';
  static const String fontSize = 'حجم الخط';
  static const String fontSmall = 'صغير';
  static const String fontMedium = 'متوسط';
  static const String fontNormal = 'عادي';
  static const String fontLarge = 'كبير';
  static const String fontXLarge = 'كبير جداً';

  // ── التحية ─────────────────────────────────────────────────────────────
  static const String welcomeWarehouse = 'مرحباً بك في نظام المستودع 📦';
  static const String welcomeLab = 'مرحباً بك في نظام المخبر 🧪';
  static const String welcomeClinic = 'مرحباً بك في نظام العيادة 🦷';
  static const String systemStatusOk =
      'آخر تحديث: اليوم — جميع الأنظمة تعمل بشكل طبيعي';

  // ── Phase 2.5 — Sidebar & Topbar ──────────────────────────────────────
  /// أدوار المستخدمين (من الملف التقني — القرار 5)
  static const String roleLabManager = 'مدير المخبر';
  static const String roleWarehouseManager = 'مدير المستودع';
  static const String roleDentist = 'طبيب أسنان';
  static const String roleSecretary = 'السكرتيرة';
  static const String roleAdmin = 'المدير العام';

  /// شارة النظام في السايدبار
  static const String labSystemBadge = 'نظام المخبر';
  static const String warehouseSystemBadge = 'نظام المستودع';
  static const String clinicSystem = 'نظام العيادة';
  static const String clinicSystemBadge = 'نظام العيادة';

  /// السايدبار — أقسام إضافية
  static const String sectionOperations = 'العمليات';
  static const String sectionAccount = 'الحساب';
  static const String menu = 'القائمة';

  // ── Phase 2.5 — Empty States ──────────────────────────────────────────
  /// العناوين
  static const String emptyNoOrdersTitle = 'لا توجد طلبات';
  static const String emptyNoOrdersMessage = 'ستظهر الطلبات هنا عند إضافتها';
  static const String emptyNoMaterialsTitle = 'لا توجد مواد';
  static const String emptyNoMaterialsMessage =
      'لم تتم إضافة أي مواد إلى المخزون بعد';
  static const String emptyNoInvoicesTitle = 'لا توجد فواتير';
  static const String emptyNoInvoicesMessage = 'سجل الفواتير فارغ حالياً';
  static const String emptyNoNotificationsTitle = 'لا إشعارات جديدة';
  static const String emptyNoNotificationsMessage =
      'سنُعلمك عند وصول إشعار جديد';
  static const String emptyNoSearchResultsTitle = 'لا توجد نتائج';
  static const String emptyNoSearchResultsMessage =
      'حاول استخدام كلمات بحث أخرى';
  static const String emptyNoTechniciansTitle = 'لا يوجد مخبريون';
  static const String emptyNoTechniciansMessage =
      'ابدأ بإضافة أول مخبري إلى الفريق';
  static const String emptyNoReportsTitle = 'لا تتوفر تقارير';
  static const String emptyNoReportsMessage =
      'ستظهر التقارير بعد اكتمال البيانات';
  static const String emptyErrorTitle = 'تعذّر تحميل البيانات';
  static const String emptyErrorMessage = 'حدث خطأ أثناء الاتصال بالسيرفر';

  /// CTA Buttons
  static const String actionAddFirst = 'إضافة أول عنصر';
  static const String actionClearFilters = 'إزالة الفلاتر';

  // ── Phase 2.5 — Loading States ────────────────────────────────────────
  static const String loadingData = 'جاري تحميل البيانات...';
  static const String loadingPleaseWait = 'الرجاء الانتظار...';
}
