// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'DT.Teeth';

  @override
  String get appSubtitle => 'نظام إدارة مركز طب الأسنان الشامل';

  @override
  String get appVersion => 'v1.0 · Flutter Web';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get loginTitle => 'أهلاً بعودتك';

  @override
  String get loginSubtitle => 'سجّل دخولك للمتابعة';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get emailHint => 'example@dtteeth.com';

  @override
  String get emailInvalid => 'الرجاء إدخال بريد إلكتروني صحيح';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get password => 'كلمة المرور';

  @override
  String get passwordHint => 'أدخل كلمة المرور';

  @override
  String get passwordConfirm => 'تأكيد كلمة المرور';

  @override
  String get passwordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get passwordTooShort => 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';

  @override
  String get passwordWeak => 'ضعيفة';

  @override
  String get passwordMedium => 'متوسطة';

  @override
  String get passwordStrong => 'قوية';

  @override
  String get firstLogin => 'أول مرة';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get authEnterEmailTitle => 'لنبدأ رحلتك معنا';

  @override
  String get authEnterEmailSubtitle =>
      'أدخل البريد الإلكتروني الذي سجّله المدير لك';

  @override
  String get authNext => 'التالي';

  @override
  String get authBack => 'رجوع';

  @override
  String get authContinue => 'متابعة';

  @override
  String get authVerifyCodeTitle => 'تحقّق من هويتك';

  @override
  String authVerifyCodeSubtitle(String email) {
    return 'أرسلنا كوداً من 6 أرقام إلى $email';
  }

  @override
  String get authResendCode => 'إعادة إرسال الكود';

  @override
  String authResendCodeIn(int seconds) {
    return 'إعادة الإرسال خلال $seconds ثانية';
  }

  @override
  String get authCodeExpired => 'انتهت صلاحية الكود. الرجاء طلب كود جديد.';

  @override
  String get authCodeInvalid => 'الكود غير صحيح. يرجى التحقق والمحاولة مجدداً.';

  @override
  String get authSetPasswordTitle => 'أنشئ كلمة المرور';

  @override
  String get authSetPasswordSubtitle => 'اختر كلمة مرور قوية لحماية حسابك';

  @override
  String get authSaveAndLogin => 'حفظ وتسجيل الدخول';

  @override
  String get authCheckEmailSent =>
      'إذا كان هذا البريد مسجّلاً، فقد تم إرسال كود التحقق';

  @override
  String get labSystem => 'نظام المخبر';

  @override
  String get warehouseSystem => 'نظام المستودع';

  @override
  String get switchSystem => 'تبديل النظام';

  @override
  String get dashboard => 'الصفحة الرئيسية';

  @override
  String get reports => 'التقارير';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get doctorOrders => 'طلبات الأطباء';

  @override
  String get technicians => 'إدارة المخبريين';

  @override
  String get labReports => 'تقارير المخبر';

  @override
  String get materialRequests => 'طلبات المستودع';

  @override
  String get materials => 'المواد';

  @override
  String get orders => 'الطلبيات';

  @override
  String get invoices => 'الفواتير';

  @override
  String get suppliers => 'الموردون';

  @override
  String get inventory => 'المخزون';

  @override
  String get sectionMain => 'الرئيسية';

  @override
  String get sectionInventory => 'المخزون';

  @override
  String get sectionFinance => 'المالية';

  @override
  String get sectionSystem => 'النظام';

  @override
  String get sectionTeam => 'الفريق';

  @override
  String get sectionOrders => 'الطلبات';

  @override
  String get sectionOperations => 'العمليات';

  @override
  String get sectionAccount => 'الحساب';

  @override
  String get menu => 'القائمة';

  @override
  String get search => 'بحث في النظام...';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get add => 'إضافة';

  @override
  String get confirm => 'تأكيد';

  @override
  String get apply => 'تطبيق';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get close => 'إغلاق';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get error => 'حدث خطأ';

  @override
  String get success => 'تمت العملية بنجاح';

  @override
  String get statusNew => 'جديد';

  @override
  String get statusPendingMaterials => 'معلّق — بانتظار مواد';

  @override
  String get statusManufacturing => 'قيد التصنيع';

  @override
  String get statusReady => 'جاهز';

  @override
  String get statusDelivered => 'تم التسليم';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get statusReserved => 'محجوز';

  @override
  String get statusEmpty => 'فارغ';

  @override
  String get statusOccupied => 'مشغول';

  @override
  String get statusMaintenance => 'صيانة';

  @override
  String get errorNetwork => 'لا يوجد اتصال بالإنترنت — تحقق من الشبكة';

  @override
  String get errorServer => 'خطأ في السيرفر — حاول مرة أخرى بعد قليل';

  @override
  String get errorTimeout => 'انتهت مهلة الانتظار — السيرفر لا يستجيب';

  @override
  String get errorUnauthorized => 'انتهت صلاحية الجلسة — سجّل دخولك مجدداً';

  @override
  String get errorForbidden => 'ليس لديك صلاحية للوصول لهذه الصفحة';

  @override
  String get errorNotFound => 'العنصر المطلوب غير موجود';

  @override
  String get errorValidation => 'تحقق من الحقول المطلوبة';

  @override
  String get errorMaintenance => 'السيرفر في صيانة — عد لاحقاً';

  @override
  String get errorCache => 'خطأ في البيانات المحلية — حاول مجدداً';

  @override
  String get theme => 'الوضع';

  @override
  String get darkMode => 'داكن';

  @override
  String get lightMode => 'فاتح';

  @override
  String get language => 'اللغة';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get fontSize => 'حجم الخط';

  @override
  String get fontSmall => 'صغير';

  @override
  String get fontMedium => 'متوسط';

  @override
  String get fontNormal => 'عادي';

  @override
  String get fontLarge => 'كبير';

  @override
  String get fontXLarge => 'كبير جداً';

  @override
  String get welcomeWarehouse => 'مرحباً بك في نظام المستودع 📦';

  @override
  String get welcomeLab => 'مرحباً بك في نظام المخبر 🧪';

  @override
  String get systemStatusOk =>
      'آخر تحديث: اليوم — جميع الأنظمة تعمل بشكل طبيعي';

  @override
  String get roleLabManager => 'مدير المخبر';

  @override
  String get roleWarehouseManager => 'مدير المستودع';

  @override
  String get roleDentist => 'طبيب أسنان';

  @override
  String get roleSecretary => 'السكرتيرة';

  @override
  String get roleAdmin => 'المدير العام';

  @override
  String get labSystemBadge => 'نظام المخبر';

  @override
  String get warehouseSystemBadge => 'نظام المستودع';

  @override
  String get emptyNoOrdersTitle => 'لا توجد طلبات';

  @override
  String get emptyNoOrdersMessage => 'ستظهر الطلبات هنا عند إضافتها';

  @override
  String get emptyNoMaterialsTitle => 'لا توجد مواد';

  @override
  String get emptyNoMaterialsMessage => 'لم تتم إضافة أي مواد إلى المخزون بعد';

  @override
  String get emptyNoInvoicesTitle => 'لا توجد فواتير';

  @override
  String get emptyNoInvoicesMessage => 'سجل الفواتير فارغ حالياً';

  @override
  String get emptyNoNotificationsTitle => 'لا إشعارات جديدة';

  @override
  String get emptyNoNotificationsMessage => 'سنُعلمك عند وصول إشعار جديد';

  @override
  String get emptyNoSearchResultsTitle => 'لا توجد نتائج';

  @override
  String get emptyNoSearchResultsMessage => 'حاول استخدام كلمات بحث أخرى';

  @override
  String get emptyNoTechniciansTitle => 'لا يوجد مخبريون';

  @override
  String get emptyNoTechniciansMessage => 'ابدأ بإضافة أول مخبري إلى الفريق';

  @override
  String get emptyNoReportsTitle => 'لا تتوفر تقارير';

  @override
  String get emptyNoReportsMessage => 'ستظهر التقارير بعد اكتمال البيانات';

  @override
  String get emptyErrorTitle => 'تعذّر تحميل البيانات';

  @override
  String get emptyErrorMessage => 'حدث خطأ أثناء الاتصال بالسيرفر';

  @override
  String get actionAddFirst => 'إضافة أول عنصر';

  @override
  String get actionClearFilters => 'إزالة الفلاتر';

  @override
  String get loadingData => 'جاري تحميل البيانات...';

  @override
  String get loadingPleaseWait => 'الرجاء الانتظار...';

  @override
  String get systemSelectionTitle => 'اختر النظام';

  @override
  String get systemSelectionSubtitle => 'حدد النظام الذي تريد العمل عليه';

  @override
  String get systemSelectionLabTitle => 'نظام المخبر';

  @override
  String get systemSelectionLabDescription =>
      'إدارة طلبات التعويضات السنية والمخبريين والتقارير';

  @override
  String get systemSelectionWarehouseTitle => 'نظام المستودع';

  @override
  String get systemSelectionWarehouseDescription =>
      'إدارة المخزون والمواد والفواتير وطلبيات العيادات';

  @override
  String get systemSelectionEnterButton => 'الدخول';

  @override
  String get systemSelectionDemoNotice =>
      'وضع المعاينة — يمكنك التبديل بين النظامين في أي وقت';

  @override
  String get systemSwitcherSwitchTo => 'التبديل إلى';

  @override
  String get systemSwitcherCurrentSystem => 'النظام الحالي';

  @override
  String get f4TopbarSubtitles => '─── عناوين فرعية للتوب بار ───';

  @override
  String get warehouseTopbarSubtitle => 'نظام إدارة المستودع · DT.Teeth';

  @override
  String get labTopbarSubtitle => 'نظام إدارة المخبر · DT.Teeth';

  @override
  String get f4Dashboard => '─── لوحة التحكم — مستودع ───';

  @override
  String get whDashboardTitle => 'لوحة التحكم';

  @override
  String get whDashboardHeroSubtitle =>
      'آخر تحديث: اليوم — جميع الأنظمة تعمل بشكل طبيعي';

  @override
  String get whHeroStatRegisteredMaterials => 'مادة مسجلة';

  @override
  String get whHeroStatPendingOrders => 'طلب معلق';

  @override
  String get whHeroStatActiveAlerts => 'تنبيه نشط';

  @override
  String get whStatCurrentInventory => 'المخزون الحالي';

  @override
  String get whStatLowStockMaterials => 'مواد قاربت النفاد';

  @override
  String get whStatIncomingOrders => 'طلبات واردة';

  @override
  String get whStatExpiringMaterials => 'مواد منتهية الصلاحية';

  @override
  String get whSectionTopRequested => 'المواد الأكثر طلباً';

  @override
  String get whSectionExpiringSoon => 'مواد ستنتهي صلاحيتها';

  @override
  String get whSectionTopRequestedCaption => 'هذا الشهر';

  @override
  String get whSectionExpiringCaption => 'خلال 30 يوماً';

  @override
  String get whAlertLowStockTitle => 'نفاد مخزون';

  @override
  String whAlertLowStockSubtitle(int count) {
    return '$count مواد حرجة';
  }

  @override
  String get whAlertNewOrdersTitle => 'طلبيات جديدة';

  @override
  String whAlertNewOrdersSubtitle(int count) {
    return '$count تنتظر';
  }

  @override
  String get whQuickActions => 'إجراءات سريعة';

  @override
  String get whQuickActionAddMaterial => 'مادة';

  @override
  String get whQuickActionAddInvoice => 'فاتورة';

  @override
  String get whQuickActionReports => 'تقارير';

  @override
  String get whQuickActionOrders => 'طلبيات';

  @override
  String get whInventoryDistribution => 'توزيع المخزون';

  @override
  String get whCategoryConsumables => 'مستهلكات';

  @override
  String get whCategoryMedicines => 'أدوية';

  @override
  String get whCategoryMedical => 'طبية';

  @override
  String get whCategoryEquipment => 'معدات';

  @override
  String get whExpiryDaysLeft => 'أيام متبقية';

  @override
  String get errorRequired => 'هذا الحقل مطلوب';

  @override
  String get errorInvalidNumber => 'يجب إدخال رقم صحيح';

  @override
  String get whFullReport => 'التقرير الكامل';

  @override
  String get f4Materials => '─── إدارة المواد ───';

  @override
  String get whMaterialsTitle => 'المواد';

  @override
  String get whMaterialsAdd => 'إضافة مادة';

  @override
  String get whFilterAll => 'الكل';

  @override
  String get whFilterLowStock => 'ينفد';

  @override
  String get whFilterExpiring => 'صلاحية';

  @override
  String get whFilterConsumables => 'مستهلكات';

  @override
  String get whFilterMedicines => 'أدوية';

  @override
  String get whFilterMedical => 'طبية';

  @override
  String get whMaterialName => 'اسم المادة';

  @override
  String get whMaterialCategory => 'الفئة';

  @override
  String get whMaterialQuantity => 'الكمية';

  @override
  String get whMaterialUnit => 'الوحدة';

  @override
  String get whMaterialMinStock => 'الحد الأدنى';

  @override
  String get whMaterialExpiryDate => 'تاريخ انتهاء الصلاحية';

  @override
  String get whMaterialSupplier => 'المورد';

  @override
  String get whMaterialPrice => 'السعر';

  @override
  String get whMaterialNotes => 'ملاحظات';

  @override
  String get whStatusAvailable => 'متوفر';

  @override
  String get whStatusLow => 'ينفد';

  @override
  String get whStatusOut => 'نفد';

  @override
  String get f4Orders => '─── الطلبيات ───';

  @override
  String get whOrdersTitle => 'الطلبيات';

  @override
  String get whOrderNumber => 'رقم الطلب';

  @override
  String get whOrderRequester => 'الطالب';

  @override
  String get whOrderDate => 'التاريخ';

  @override
  String get whOrderStatus => 'الحالة';

  @override
  String get whOrderAction => 'إجراء';

  @override
  String get whOrderFilterNew => 'جديد';

  @override
  String get whOrderFilterDone => 'تم';

  @override
  String get whOrderFilterMissing => 'غير موجود';

  @override
  String get whOrderStatusNew => 'جديد';

  @override
  String get whOrderStatusFulfilled => 'تم';

  @override
  String get whOrderStatusMissing => 'غير موجود';

  @override
  String get f4Invoices => '─── الفواتير ───';

  @override
  String get whInvoicesTitle => 'الفواتير';

  @override
  String get whInvoiceAdd => 'فاتورة جديدة';

  @override
  String get whInvoiceFilterPurchase => 'شراء';

  @override
  String get whInvoiceFilterUsage => 'استخدام';

  @override
  String get whInvoiceWeekly => 'فواتير الأسبوع';

  @override
  String get whInvoiceWeekSummary => 'ملخص الأسبوع';

  @override
  String get whInvoiceTotalPurchase => 'إجمالي شراء';

  @override
  String get whInvoiceTotalUsage => 'إجمالي استخدام';

  @override
  String get whInvoiceTotalLoss => 'خسارة — منتهية';

  @override
  String get whInvoiceExportPdf => 'تصدير PDF';

  @override
  String get f4Reports => '─── التقارير ───';

  @override
  String get whReportsTitle => 'التقارير';

  @override
  String get whReportTabTopMaterials => 'أكثر 10 مواد';

  @override
  String get whReportTabFinancial => 'المالي';

  @override
  String get whReportTopMaterialsTitle => 'المواد الأكثر طلباً';

  @override
  String get whReportMonthlyOrders => 'طلبات شهرية';

  @override
  String get whReportRank => 'الترتيب';

  @override
  String get whReportRequestCount => 'الطلبات';

  @override
  String get whReportCost => 'التكلفة';

  @override
  String get whReportExport => 'تصدير';

  @override
  String get whReportWeeklyPurchases => 'مشتريات الأسبوع';

  @override
  String get whReportUsageCost => 'تكلفة الاستخدام';

  @override
  String get whReportExpiredLoss => 'مواد منتهية';

  @override
  String get f4Notifications => '─── الإشعارات ───';

  @override
  String get whNotificationsTitle => 'الإشعارات';

  @override
  String get whNotifFilterUnread => 'غير مقروء';

  @override
  String get whNotifFilterLow => 'نفاد';

  @override
  String get whNotifFilterExpiry => 'صلاحية';

  @override
  String get whNotifFilterOrder => 'طلبيات';

  @override
  String get whNotifMarkAllRead => 'تحديد الكل كمقروء';

  @override
  String get f4Settings => '─── الإعدادات ───';

  @override
  String get whSettingsTitle => 'الإعدادات';

  @override
  String get whSettingsTabProfile => 'الملف الشخصي';

  @override
  String get whSettingsTabNotifications => 'الإشعارات';

  @override
  String get whSettingsTabSecurity => 'الأمان';

  @override
  String get whSettingsTabAbout => 'عن التطبيق';

  @override
  String get whSettingsFirstName => 'الاسم الأول';

  @override
  String get whSettingsLastName => 'اسم العائلة';

  @override
  String get whSettingsEmail => 'البريد الإلكتروني';

  @override
  String get whSettingsSaveChanges => 'حفظ التغييرات';

  @override
  String get whSettingsNotifLowStock => 'تنبيه نفاد المواد';

  @override
  String get whSettingsNotifLowStockDesc => 'عند الحد الأدنى';

  @override
  String get whSettingsNotifExpiry => 'انتهاء الصلاحية';

  @override
  String get whSettingsNotifExpiryDesc => 'قبل 30 يوماً';

  @override
  String get whSettingsNotifOrders => 'طلبيات جديدة';

  @override
  String get whSettingsNotifOrdersDesc => 'فور الوصول';

  @override
  String get whSettingsNotifWeekly => 'التقرير الأسبوعي';

  @override
  String get whSettingsNotifWeeklyDesc => 'كل أحد';

  @override
  String get whSettingsCurrentPassword => 'كلمة المرور الحالية';

  @override
  String get whSettingsNewPassword => 'الجديدة';

  @override
  String get whSettingsConfirmPassword => 'التأكيد';

  @override
  String get whSettingsUpdatePassword => 'تحديث';

  @override
  String get whSettingsAboutTitle => 'DT.Teeth Repository';

  @override
  String get whSettingsAboutVersion => 'v1.0.0 · مارس 2026 · Flutter Web';

  @override
  String get f4ComingSoon => '─── شارة قيد البناء ───';

  @override
  String get comingSoonTitle => 'قريباً';

  @override
  String get comingSoonSubtitle => 'هذه الشاشة قيد البناء — ستكتمل قريباً';

  @override
  String get screenUnderConstruction => 'قيد البناء';

  @override
  String get f4Lab => '─── نظام المخبر ───';

  @override
  String get labDashboardTitle => 'لوحة التحكم';

  @override
  String get labHeroWelcome => 'مرحباً بك في نظام المخبر 🧪';

  @override
  String get labHeroSubtitle =>
      'آخر تحديث: اليوم — جميع الأنظمة تعمل بشكل طبيعي ✅';

  @override
  String get labHeroStatTodayOrders => 'طلب اليوم';

  @override
  String get labHeroStatInProgress => 'قيد التنفيذ';

  @override
  String get labHeroStatCompletionRate => 'نسبة الإنجاز';

  @override
  String get labStatNewOrders => 'طلبات جديدة';

  @override
  String get labStatManufacturing => 'قيد التصنيع';

  @override
  String get labStatReady => 'جاهز';

  @override
  String get labStatUrgentToday => 'تنتهي اليوم';

  @override
  String get labOrdersFilterAll => 'الكل';

  @override
  String get labOrdersFilterNew => 'جديد';

  @override
  String get labOrdersFilterManufacturing => 'قيد التصنيع';

  @override
  String get labOrdersFilterReady => 'جاهز';

  @override
  String get labOrdersDueToday => 'تنتهي اليوم';

  @override
  String get labOrdersDueTodaySubtitle => 'يجب الانتهاء قبل المساء';

  @override
  String get labTeamTitle => 'إدارة المخبريين';

  @override
  String get labTeamTotal => 'إجمالي المخبريين';

  @override
  String get labTeamActive => 'نشط';

  @override
  String get labTeamAvailable => 'متاح';

  @override
  String get labTeamColumnName => 'المخبري';

  @override
  String get labTeamColumnShift => 'أوقات الدوام';

  @override
  String get labTeamColumnCurrentTask => 'المسؤولية الحالية';

  @override
  String get labTeamColumnStatus => 'الحالة';

  @override
  String get labTeamColumnAction => 'إجراء';

  @override
  String get labTeamAssign => 'توكيل';

  @override
  String get labTeamFree => 'متاح';

  @override
  String get labTeamBusy => 'مشغول';

  @override
  String get labReportTabByType => 'حسب النوع';

  @override
  String get labReportTabByDate => 'حسب التاريخ';

  @override
  String get labReportTabTeam => 'أداء الفريق';

  @override
  String get labReportFilterMonthly => 'شهري';

  @override
  String get labReportFilterWeekly => 'أسبوعي';

  @override
  String get labReportFilterDaily => 'يومي';

  @override
  String get labReportFilterYearly => 'سنوي';

  @override
  String get labReportExportPdf => '📤 تصدير PDF';

  @override
  String get labReportExportExcel => '📊 تصدير Excel';

  @override
  String get labReportSendEmail => '📧 إرسال بالبريد';

  @override
  String get labReportStatTotal => 'طلبات الفترة';

  @override
  String get labReportStatCompleted => 'مكتمل في الوقت';

  @override
  String get labReportStatAvgTime => 'متوسط الوقت';

  @override
  String get labReportStatSatisfaction => 'نسبة الرضا';

  @override
  String get labReportCrownType => 'تلبيسات';

  @override
  String get labReportBridgeType => 'جسور';

  @override
  String get labReportOtherType => 'أخرى';

  @override
  String get labQuickActionOrders => 'الطلبات';

  @override
  String get labQuickActionReport => 'تقرير';

  @override
  String get labQuickActionTeam => 'الفريق';

  @override
  String get labQuickActionAlerts => 'تنبيهات';

  @override
  String get labTeamPerformanceTitle => 'أداء الفريق';

  @override
  String get labSettingsTabProfile => 'الملف';

  @override
  String get labSettingsTabNotifications => 'الإشعارات';

  @override
  String get labSettingsTabAbout => 'عن التطبيق';

  @override
  String get labSettingsNotifNewOrders => 'طلبات جديدة';

  @override
  String get labSettingsNotifNewOrdersDesc => 'إشعار فوري';

  @override
  String get labSettingsNotifUrgent => 'تنبيه العاجل';

  @override
  String get labSettingsNotifUrgentDesc => 'قبل 3 ساعات';

  @override
  String get labSettingsNotifDoctorReady => 'إشعار الطبيب';

  @override
  String get labSettingsNotifDoctorReadyDesc => 'عند الجاهزية FCM';

  @override
  String get labSettingsAboutTitle => 'DT.Teeth Lab';

  @override
  String get labSettingsAboutVersion => 'v1.0.0 · Flutter Web · Laravel API';

  @override
  String get labTopbarSubtitleFull => 'نظام إدارة المخبر · DT.Teeth';

  @override
  String get labProfile => 'الملف الشخصي';

  @override
  String get labManageTechnicians => 'إدارة المخبريين';
}
