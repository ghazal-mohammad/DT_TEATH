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
  String get authVerifyCodeError =>
      'الكود غير صحيح أو منتهي الصلاحية. حاول مرة أخرى.';

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
  String get commandPaletteHint => 'ابحث أو انتقل... (طلب، منتج، فنّي، مادة)';

  @override
  String get commandPaletteEmpty => 'لا نتائج مطابقة';

  @override
  String get commandPaletteNavHint => 'للتنقّل · Enter للفتح · Esc للإغلاق';

  @override
  String get commandPaletteOpen => 'بحث عالمي (Ctrl+K)';

  @override
  String get commandCatNav => 'تنقّل';

  @override
  String get commandCatOrder => 'طلب';

  @override
  String get commandCatProduct => 'منتج';

  @override
  String get commandCatTechnician => 'فنّي';

  @override
  String get commandCatMaterial => 'مادة';

  @override
  String get commandCatRequest => 'طلب مواد';

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
  String get statusCancelled => 'ملغى';

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
  String get networkOfflineBanner => 'لا يوجد اتصال بالإنترنت';

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
  String get whMaterialsSearchHint => 'فلترة مواد المستودع... (اسم، فئة)';

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
  String get whMaterialUnitHint => 'اختر الوحدة';

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
  String get whOrderDate => 'تاريخ الطلب';

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
  String get labHeroStatDelivered => 'تم توصيلها';

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
  String get labOrdersToday => 'طلبات اليوم';

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
  String get labReportStatOnTime => 'الإنجاز في الوقت';

  @override
  String get labReportHourSuffix => 'س';

  @override
  String get labReportOrdersByDay => 'الطلبات حسب اليوم';

  @override
  String get labReportOrdersByType => 'الطلبات حسب النوع';

  @override
  String get labReportTeamPerf => 'أداء الفريق';

  @override
  String get labReportNoData => 'لا توجد بيانات لهذه الفترة';

  @override
  String get ordersUnit => 'طلب';

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

  @override
  String get labDashboardSearchHint =>
      'فلترة طلبات هذه الصفحة... (رقم، طبيب، مادة)';

  @override
  String get priorityUrgent => 'عاجل';

  @override
  String get priorityMedium => 'متوسطة';

  @override
  String get priorityNormal => 'عادية';

  @override
  String get labStatNeedsFollowup => 'يحتاج متابعة';

  @override
  String get labChipThisMonth => 'هذا الشهر';

  @override
  String get labChipActive => 'نشط';

  @override
  String get labStatReadyOrders => 'طلبات جاهزة';

  @override
  String labTrendFromLastMonth(String value) {
    return '$value من الشهر الماضي';
  }

  @override
  String labTrendFromYesterday(String value) {
    return '$value من أمس';
  }

  @override
  String get labTodayOrders => 'طلبات اليوم';

  @override
  String labOrdersCount(String count) {
    return '$count طلب';
  }

  @override
  String get colOrderNumber => 'رقم الطلب';

  @override
  String get colDoctor => 'الطبيب';

  @override
  String get colType => 'النوع';

  @override
  String get colMaterial => 'المادة';

  @override
  String get colTooth => 'السن';

  @override
  String get colDate => 'الموعد';

  @override
  String get colPriority => 'الأولوية';

  @override
  String get colStatus => 'الحالة';

  @override
  String labGreeting(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get systemAllNormal => 'جميع الأنظمة تعمل بشكل طبيعي';

  @override
  String labLastUpdate(String time) {
    return 'آخر تحديث: $time';
  }

  @override
  String get labOrdersSearchHint =>
      'فلترة طلبات الأطباء... (رقم، طبيب، مادة، سن)';

  @override
  String labOrdersCountOfTotal(String shown, String total) {
    return '$shown طلب من أصل $total';
  }

  @override
  String get labOrderProcess => 'معالجة';

  @override
  String get actionView => 'عرض';

  @override
  String get labNoOrdersInCategory => 'لا توجد طلبيات في هذه الفئة';

  @override
  String get settingsSearchHint => 'بحث في هذه الصفحة...';

  @override
  String get settingsTabSecurity => 'الأمان';

  @override
  String get settingsTabPreferences => 'التفضيلات';

  @override
  String get settingsChangePassword => 'تغيير كلمة المرور';

  @override
  String get settingsChangePasswordDesc =>
      'يفضّل تغيير كلمة المرور كل 90 يوماً لزيادة الأمان';

  @override
  String get settingsCurrentPassword => 'كلمة المرور الحالية';

  @override
  String get settingsNewPassword => 'كلمة المرور الجديدة';

  @override
  String get settingsConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get settingsUpdatePassword => 'تحديث كلمة المرور';

  @override
  String get settings2FA => 'المصادقة الثنائية';

  @override
  String get settings2FADesc => 'حماية إضافية لحسابك عبر رمز OTP';

  @override
  String get settings2FAOtpTitle => 'طلب رمز OTP عند تسجيل الدخول';

  @override
  String get settings2FAOtpDesc =>
      'يصلك رمز عبر البريد الإلكتروني في كل مرة تدخل من جهاز جديد';

  @override
  String get settingsLogoutAll => 'تسجيل الخروج من كل الأجهزة';

  @override
  String get settingsLogoutAllDesc =>
      'إنهاء جميع الجلسات النشطة على الأجهزة الأخرى';

  @override
  String get settingsNotifPrefs => 'تفضيلات الإشعارات';

  @override
  String get settingsNotifPrefsDesc =>
      'حدد أنواع الإشعارات التي تريد استقبالها';

  @override
  String get labSettingsNotifUrgentOrders => 'الطلبات العاجلة';

  @override
  String get labSettingsNotifUrgentOrdersDesc =>
      'الطلبات اللي يجب إنهاؤها اليوم';

  @override
  String get labSettingsNotifNewFromDoctors => 'طلبيات جديدة من الأطباء';

  @override
  String get labSettingsNotifNewFromDoctorsDesc => 'عند وصول طلبية جديدة';

  @override
  String get settingsNotifLowMaterials => 'نقص المواد';

  @override
  String get settingsNotifLowMaterialsDesc => 'عند وصول مادة للحد الأدنى';

  @override
  String get labSettingsNotifWarehouseUpdates => 'تحديثات المستودع';

  @override
  String get labSettingsNotifWarehouseUpdatesDesc =>
      'حالة طلبات التوريد المرسلة';

  @override
  String get labSettingsNotifTeamUpdates => 'تحديثات الفريق';

  @override
  String get labSettingsNotifTeamUpdatesDesc => 'إضافة أو تغيير دوام مخبري';

  @override
  String get settingsNotifChannels => 'قنوات الإشعار';

  @override
  String get settingsNotifChannelsDesc => 'اختر أين تصلك التنبيهات';

  @override
  String get settingsNotifDailyEmail => 'ملخص يومي عبر البريد الإلكتروني';

  @override
  String get settingsNotifDailyEmailDesc => 'يصلك في الساعة 8:00 صباحاً كل يوم';

  @override
  String get settingsNotifSound => 'صوت الإشعارات داخل النظام';

  @override
  String get settingsNotifSoundDesc => 'تشغيل نغمة عند وصول إشعار جديد';

  @override
  String get settingsThemeDesc => 'اختر مظهر النظام';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeSystem => 'افتراضي النظام';

  @override
  String get settingsTextSize => 'حجم الخط';

  @override
  String get settingsTextSizeDesc => 'كبّر أو صغّر خط الواجهة كما يناسبك';

  @override
  String get settingsTextSizeSmall => 'صغير';

  @override
  String get settingsTextSizeNormal => 'عادي';

  @override
  String get settingsTextSizeLarge => 'كبير';

  @override
  String get settingsTextSizeXLarge => 'أكبر';

  @override
  String get settingsLanguageDesc => 'لغة عرض النظام';

  @override
  String get settingsLangArabicHint => 'RTL · الافتراضي';

  @override
  String get settingsLangEnglishHint => 'LTR';

  @override
  String get settingsDisplayPerf => 'العرض والأداء';

  @override
  String get settingsCompactView => 'العرض المضغوط';

  @override
  String get settingsCompactViewDesc =>
      'إظهار مزيد من البيانات في الشاشة الواحدة';

  @override
  String get settingsAutoSave => 'الحفظ التلقائي';

  @override
  String get settingsAutoSaveDesc => 'حفظ التعديلات تلقائياً كل دقيقة';

  @override
  String get notifSearchHint => 'بحث في الإشعارات...';

  @override
  String get sectionToday => 'اليوم';

  @override
  String get sectionYesterday => 'أمس';

  @override
  String get notifEmptyInCategory => 'لا توجد إشعارات في هذه الفئة';

  @override
  String get notifFilterAll => 'الكل';

  @override
  String get notifFilterUnread => 'غير مقروءة';

  @override
  String get notifFilterOrders => 'طلبات';

  @override
  String get notifFilterMaterials => 'مواد';

  @override
  String get notifFilterSystem => 'نظام';

  @override
  String get techSearchHint => 'بحث عن مخبري... (اسم، دور، مهمة)';

  @override
  String get labTeamSectionTitle => 'فريق المخبر';

  @override
  String get techScheduleTitle => 'جدول الدوام';

  @override
  String get techScheduleEdit => 'تعديل الجدول';

  @override
  String get techPerfTitle => 'أداء الفنّيين';

  @override
  String get techPerfThisMonth => 'هذا الشهر';

  @override
  String get techPerfAssigned => 'مُسنَد';

  @override
  String get techPerfInProgress => 'قيد التنفيذ';

  @override
  String get techPerfCompleted => 'مكتمل';

  @override
  String get techScheduleDayOff => 'إجازة';

  @override
  String get techScheduleNeedOne => 'اختر يوم عمل واحدًا على الأقل';

  @override
  String get techScheduleEndAfterStart => 'وقت النهاية يجب أن يكون بعد البداية';

  @override
  String get techScheduleSaved => 'تم حفظ جدول الدوام';

  @override
  String get daySaturday => 'السبت';

  @override
  String get daySunday => 'الأحد';

  @override
  String get dayMonday => 'الاثنين';

  @override
  String get dayTuesday => 'الثلاثاء';

  @override
  String get dayWednesday => 'الأربعاء';

  @override
  String get dayThursday => 'الخميس';

  @override
  String get dayFriday => 'الجمعة';

  @override
  String get labTeamTotalChip => 'الإجمالي';

  @override
  String get labTeamActiveChip => 'يعمل الآن';

  @override
  String get labTeamReadyChip => 'جاهز للتوكيل';

  @override
  String get techStatActiveLabel => 'مخبريون نشطون';

  @override
  String get techStatusBreak => 'استراحة';

  @override
  String get labTeamAddTechnician => 'إضافة مخبري';

  @override
  String get notifMarkAllRead => 'تحديد الكل كمقروء';

  @override
  String get whNotifExpiry => 'انتهاء الصلاحية';

  @override
  String get whNotifExpiryDesc => 'قبل انتهاء الصلاحية بـ 30 يوم';

  @override
  String get whNotifNewSupply => 'طلبيات توريد جديدة';

  @override
  String get whNotifNewSupplyDesc => 'عند وصول طلبية من المخبر/العيادة';

  @override
  String get whNotifSupplierDelay => 'تأخر الموردين';

  @override
  String get whNotifSupplierDelayDesc => 'عند تأخر مورد عن موعد التسليم';

  @override
  String get whNotifInvoicesDue => 'فواتير بانتظار الدفع';

  @override
  String get whNotifInvoicesDueDesc => 'تذكير قبل تاريخ الاستحقاق';

  @override
  String get whOrderPartial => 'جزئي';

  @override
  String get whOrderFulfilled => 'تم التوريد';

  @override
  String get whOrdersEmptyFilter => 'لا يوجد طلبات بهذا الفلتر';

  @override
  String get whOrderRequesterParty => 'الجهة الطالبة';

  @override
  String get colQuantity => 'الكمية';

  @override
  String get profileGeneralInfo => 'معلومات عامة';

  @override
  String get profileHireDate => 'تاريخ التوظيف';

  @override
  String get profileLanguages => 'اللغات';

  @override
  String get profileAdminNotes => 'ملاحظات إدارية';

  @override
  String get profileCompletion => 'اكتمال الملف';

  @override
  String get profileEdit => 'تعديل الملف الشخصي';

  @override
  String get profileSaving => 'جارٍ الحفظ…';

  @override
  String get profileSaveChanges => 'حفظ التغييرات';

  @override
  String get profileChangePhoto => 'تغيير الصورة الشخصية';

  @override
  String get profilePersonalInfo => 'المعلومات الشخصية';

  @override
  String get profilePersonalInfoSubtitle =>
      'البيانات التعريفية ومعلومات الاتصال';

  @override
  String get profilePhone => 'رقم الهاتف';

  @override
  String get profileSecondaryPhone => 'الهاتف الثانوي';

  @override
  String get profileMaritalStatus => 'الحالة الاجتماعية';

  @override
  String get profileSalary => 'الراتب';

  @override
  String get profileEducations => 'الشهادات العلمية';

  @override
  String get profileExperiences => 'الخبرات العملية';

  @override
  String get profileTrainings => 'الدورات التدريبية';

  @override
  String get profileSkills => 'المهارات';

  @override
  String get profileOngoing => 'الآن';

  @override
  String get profilePickDate => 'اختر التاريخ';

  @override
  String get profileNationalId => 'الرقم الوطني';

  @override
  String get profileBirthDate => 'تاريخ الميلاد';

  @override
  String get profileGender => 'الجنس';

  @override
  String get profileAddress => 'العنوان';

  @override
  String get profileWorkSchedule => 'جدول الدوام';

  @override
  String get show => 'إظهار';

  @override
  String get hide => 'إخفاء';

  @override
  String get profileEmployeeId => 'رقم الموظف';

  @override
  String get profileJobInfo => 'المعلومات الوظيفية';

  @override
  String get profileJobInfoSubtitle => 'القسم والدوام والمسمى الوظيفي';

  @override
  String get profileDepartment => 'القسم';

  @override
  String get profileWorkDays => 'أيام الدوام';

  @override
  String get profilePosition => 'المسمى الوظيفي';

  @override
  String get profileDayOff => 'يوم العطلة الأسبوعية';

  @override
  String get profileWeeklyHours => 'عدد ساعات العمل الأسبوعية';

  @override
  String get profileSavedSuccess => 'تم حفظ التعديلات بنجاح';

  @override
  String get profileSaveError => 'تعذّر حفظ التعديلات';

  @override
  String get profilePhotoUpdated => 'تم تحديث صورة الملف الشخصي';

  @override
  String get profileLoadError => 'تعذّر تحميل الملف الشخصي';

  @override
  String get roleEmployee => 'موظف';

  @override
  String get profileStatCompletedOrders => 'طلبات منجزة';

  @override
  String get profileBadgeThisMonth => 'هذا الشهر';

  @override
  String get profileBadgeAverage => 'متوسط';

  @override
  String get profileStatMovementsThisMonth => 'حركات هذا الشهر';

  @override
  String get profileStatLowItems => 'أصناف منخفضة';

  @override
  String get profileStatStockAccuracy => 'دقة المخزون';

  @override
  String get profileBadgeAlert => 'تنبيه';

  @override
  String profilePhotoError(Object error) {
    return 'تعذّر اختيار الصورة: $error';
  }

  @override
  String get ordersFilterAll => 'الكل';

  @override
  String get ordersUrgent => 'عاجل';

  @override
  String get ordersStatusNew => 'جديد';

  @override
  String get ordersStatusPartial => 'جزئي';

  @override
  String get ordersStatusFulfilled => 'تم التوريد';

  @override
  String get ordersQuantity => 'الكمية';

  @override
  String get ordersRequester => 'الطالب';

  @override
  String get ordersDate => 'التاريخ';

  @override
  String get ordersView => 'عرض';

  @override
  String get ordersSupply => 'توريد';

  @override
  String get ordersEmptyTitle => 'لا توجد طلبيات';

  @override
  String get ordersEmptyMessage => 'لا يوجد طلبيات تطابق الفلتر الحالي';

  @override
  String ordersSupplyConfirmed(Object material, Object order) {
    return 'تم تأكيد توريد $material للطلبية $order';
  }

  @override
  String ordersCountSummary(Object count, Object total) {
    return '$count طلبية من أصل $total';
  }

  @override
  String get orderDetailsSubtitle => 'تفاصيل طلبية المواد المرسلة إلى المستودع';

  @override
  String get orderDetailsInfoSection => 'معلومات الطلبية';

  @override
  String get orderDetailsItems => 'عناصر الطلب';

  @override
  String get orderDetailsProgressSection => 'تقدم التوريد';

  @override
  String get orderDetailsNotes => 'ملاحظات';

  @override
  String get orderDetailsModifications => 'طلبات التعديل';

  @override
  String get orderDetailsStatusLabel => 'حالة الطلبية';

  @override
  String get orderDetailsOrderDate => 'تاريخ الطلب';

  @override
  String get orderDetailsRequestData => 'بيانات الطلب';

  @override
  String get orderDetailsMaterial => 'المادة';

  @override
  String get orderDetailsPriority => 'الأولوية';

  @override
  String get orderDetailsNormal => 'عادية';

  @override
  String get orderDetailsRequesterData => 'بيانات الجهة الطالبة';

  @override
  String get orderDetailsParty => 'الجهة';

  @override
  String get orderDetailsResponsible => 'المسؤول';

  @override
  String get orderDetailsRequestNumber => 'رقم الطلب';

  @override
  String get orderTimelineReceived => 'تم الاستلام';

  @override
  String get orderTimelinePartial => 'توريد جزئي';

  @override
  String orderDetailsTitle(Object req) {
    return 'تفاصيل طلبية التوريد $req';
  }

  @override
  String get notifEmptyTitle => 'لا توجد إشعارات';

  @override
  String get notifEmptyMessage => 'لا يوجد إشعارات لعرضها في هذا الفلتر';

  @override
  String get notifGroupToday => 'اليوم';

  @override
  String get notifGroupYesterday => 'أمس';

  @override
  String get notifGroupOlder => 'أقدم';

  @override
  String get notifBadgeOrder => 'طلبية';

  @override
  String get notifBadgeDone => 'إنجاز';

  @override
  String get reportRangeDaily => 'يومي';

  @override
  String get reportRangeWeekly => 'أسبوعي';

  @override
  String get reportRangeMonthly => 'شهري';

  @override
  String get reportRangeYearly => 'سنوي';

  @override
  String get reportSuppliersPerf => 'أداء الموردين';

  @override
  String get reportTopMaterials => 'أكثر المواد استهلاكاً';

  @override
  String get reportFullReport => 'التقرير الكامل';

  @override
  String get reportExportPdf => 'تصدير PDF';

  @override
  String get reportExportExcel => 'تصدير Excel';

  @override
  String get reportStatAvgSupplyTime => 'متوسط مدة التوريد';

  @override
  String get reportStatSupplyRate => 'نسبة التوريد';

  @override
  String get reportStatConsumed => 'مادة استُهلكت';

  @override
  String get reportStatTotalMaterials => 'إجمالي المواد';

  @override
  String get reportUnitDay => 'يوم';

  @override
  String get reportConsumptionByCategory => 'توزّع الاستهلاك حسب الفئة';

  @override
  String get reportOfConsumption => 'من الاستهلاك';

  @override
  String get reportSupplyByDays => 'توزع طلبات التوريد على أيام الشهر';

  @override
  String get reportLess => 'أقل';

  @override
  String get reportMore => 'أكثر';

  @override
  String get reportWeekdaySun => 'أحد';

  @override
  String get reportWeekdayMon => 'إثنين';

  @override
  String get reportWeekdayTue => 'ثلاثاء';

  @override
  String get reportWeekdayWed => 'أربعاء';

  @override
  String get reportWeekdayThu => 'خميس';

  @override
  String get reportWeekdayFri => 'جمعة';

  @override
  String get reportWeekdaySat => 'سبت';

  @override
  String reportMonthlyTitle(Object period) {
    return '$period — التقرير الشهري';
  }

  @override
  String reportGeneratedAt(Object date) {
    return 'تم إنشاء التقرير $date';
  }

  @override
  String reportDaysCount(Object days) {
    return '$days يوم';
  }

  @override
  String reportSupplierSubtitle(Object invoices, Object avgDays) {
    return '$invoices فاتورة · متوسط $avgDays يوم';
  }

  @override
  String get whBadgeTotal => 'إجمالي';

  @override
  String get whStatOutMaterials => 'مواد نفدت';

  @override
  String get whStatLowMaterials => 'مواد ينفد رصيدها';

  @override
  String get whStatAvailMaterials => 'مواد متوفرة';

  @override
  String get whStatTotalMaterials => 'مادة في المستودع';

  @override
  String get whMaterialsEmptyTitle => 'لا يوجد مواد';

  @override
  String get whMaterialsEmptyMessage => 'لا يوجد مواد تطابق الفلاتر الحالية';

  @override
  String get whColCode => 'الكود';

  @override
  String get whColName => 'اسم المادة';

  @override
  String get whColCategory => 'الفئة';

  @override
  String get whColStock => 'المخزون';

  @override
  String get whColMinStock => 'الحد الأدنى';

  @override
  String get whColExpiry => 'الصلاحية';

  @override
  String get whColSupplier => 'المورد';

  @override
  String get whColStatus => 'الحالة';

  @override
  String whMaterialsCount(Object count, Object total) {
    return '$count مادة من أصل $total';
  }

  @override
  String get invStatusPaid => 'مدفوعة';

  @override
  String get invStatusPending => 'بانتظار';

  @override
  String get invEmptyTitle => 'لا توجد فواتير';

  @override
  String get invEmptyMessage => 'لا يوجد فواتير تطابق الفلتر الحالي';

  @override
  String get invPurchaseInvoices => 'فواتير الشراء';

  @override
  String get invAddInvoice => 'إضافة فاتورة';

  @override
  String get invBadgePaid => 'مدفوع';

  @override
  String get invBadgePending => 'معلق';

  @override
  String get invBadgeTotal => 'إجمالي';

  @override
  String get invStatThisMonth => 'فاتورة هذا الشهر';

  @override
  String get invStatPaidTotal => 'إجمالي المدفوع';

  @override
  String get invStatPendingPay => 'بانتظار الدفع';

  @override
  String get invStatTotalPurchases => 'المشتريات الكلية';

  @override
  String get invColNumber => 'رقم الفاتورة';

  @override
  String get invColItemCount => 'عدد المواد';

  @override
  String get invColTotalSyp => 'الإجمالي (ل.س)';

  @override
  String invCount(Object count, Object total) {
    return '$count فاتورة من أصل $total';
  }

  @override
  String get fieldRequired => 'مطلوب';

  @override
  String get fieldOptional => 'اختياري';

  @override
  String get fieldInvalidNumber => 'رقم غير صحيح';

  @override
  String get fieldInvalidAmount => 'مبلغ غير صحيح';

  @override
  String get fieldWriteOrPick => 'اكتب أو اختر من القائمة...';

  @override
  String get invFormTitle => 'إضافة فاتورة شراء';

  @override
  String get invFormSubtitle => 'املأ بيانات الفاتورة الجديدة';

  @override
  String get invFormSupplier => 'المورد';

  @override
  String get invFormSupplierHint => 'مثال: شركة المستلزمات الطبية';

  @override
  String get invFormDate => 'التاريخ';

  @override
  String get invFormNotes => 'ملاحظات';

  @override
  String get invFormSave => 'حفظ الفاتورة';

  @override
  String whGreeting(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get whSystemsNormal => 'جميع الأنظمة تعمل بشكل طبيعي';

  @override
  String get whLastUpdateLabel => 'آخر تحديث: ';

  @override
  String get whTotalMaterials => 'إجمالي المواد';

  @override
  String get whMiniOrdersToday => 'طلب اليوم';

  @override
  String get whSupplyRate => 'نسبة التوريد';

  @override
  String get whStatLowStockShort => 'مواد بالحد الأدنى';

  @override
  String get whStatPendingSupply => 'طلبات بانتظار التوريد';

  @override
  String get whStatMonthPurchases => 'مشتريات الشهر (ل.س)';

  @override
  String get whBadgeAlert => 'تنبيه';

  @override
  String get whBadgeNew => 'جديد';

  @override
  String get whBadgeThisMonth => 'هذا الشهر';

  @override
  String get whNeedsSupply => 'يحتاج توريد';

  @override
  String whTrendThisWeek(String count) {
    return '$count هذا الأسبوع';
  }

  @override
  String whTrendToday(String count) {
    return '$count اليوم';
  }

  @override
  String whTrendVsLastMonth(String value) {
    return '$value من الشهر الماضي';
  }

  @override
  String get whExpiringTitle => 'مواد ستنتهي صلاحيتها قريباً';

  @override
  String get whExpiringSubtitle => 'يجب التصرف بهذه المواد قبل انتهاء صلاحيتها';

  @override
  String whTodayOrdersCount(Object count) {
    return '$count طلب';
  }

  @override
  String get labNotifActionOpenOrder => 'فتح الطلب';

  @override
  String get labNotifActionReview => 'مراجعة';

  @override
  String get labActionTrack => 'تتبع';

  @override
  String get labReqStatusUnavailable => 'غير متوفر';

  @override
  String get labReqRequestedBy => 'طلب بواسطة';

  @override
  String get labReqLabOrder => 'طلبية المخبر';

  @override
  String get labReqEmptyCategory => 'لا توجد طلبيات مواد في هذه الفئة';

  @override
  String get labReqNewRequest => 'طلب مادة جديدة';

  @override
  String get labReqSearchHint => 'فلترة طلبات المواد... (مادة، رقم، شركة)';

  @override
  String get labReqMaterialPickHint =>
      'اكتب للبحث في مواد المستودع أو أدخل مادة جديدة';

  @override
  String get labReqDeleteTitle => 'حذف طلب المواد';

  @override
  String labReqDeleteConfirm(String material) {
    return 'هل تريد حذف طلب «$material»؟ لا يمكن التراجع.';
  }

  @override
  String get labReqFieldMaterial => 'اسم المادة';

  @override
  String get labReqFieldUnit => 'الوحدة';

  @override
  String get labReqFieldCompany => 'اسم الشركة';

  @override
  String get labReqFieldReason => 'سبب الطلب';

  @override
  String get labReqReasonHint => 'مثال: مادة جديدة غير موجودة بالمستودع';

  @override
  String get labReqMaterialRequired => 'اسم المادة مطلوب';

  @override
  String get labReqQuantityRequired => 'أدخل كمية صحيحة';

  @override
  String get labReqSubmit => 'إرسال الطلب';

  @override
  String get labReqSentSuccess => 'تم إرسال طلب المادة للمستودع';

  @override
  String get labTechPendingAssign => 'بانتظار التوكيل';

  @override
  String get techAddButton => 'إضافة المخبري';

  @override
  String get techAddTitle => 'إضافة مخبري جديد';

  @override
  String get techAddSubtitle => 'أدخل بيانات المخبري للانضمام إلى فريق المخبر';

  @override
  String get techSectionBasic => 'البيانات الأساسية';

  @override
  String get techFieldFullName => 'الاسم الكامل';

  @override
  String get techFieldFullNameHint => 'مثال: محمد علي';

  @override
  String get techFieldRole => 'الدور / التخصص';

  @override
  String get techFieldPhone => 'رقم الهاتف (اختياري)';

  @override
  String get techFieldShiftStart => 'بداية الدوام';

  @override
  String get techFieldShiftEnd => 'نهاية الدوام';

  @override
  String get techSkills => 'المهارات';

  @override
  String get techNotesHint => 'ملاحظات إضافية عن المخبري...';

  @override
  String get techNoNameYet => 'بدون اسم بعد';

  @override
  String get orderDetailsProgress => 'تقدم العمل';

  @override
  String get orderDetailsHeading => 'تفاصيل الطلبية';

  @override
  String get orderDetailsSubtitleLab =>
      'تفاصيل الطلبية المرسلة من الطبيب إلى المختبر';

  @override
  String get orderDetailsExpectedDelivery => 'تاريخ التسليم المتوقع';

  @override
  String get orderDetailsOrderData => 'بيانات الطلبية';

  @override
  String get orderDetailsDoctorData => 'بيانات الطبيب';

  @override
  String get orderDetailsSenderDoctor => 'الطبيب المُرسل';

  @override
  String get orderDetailsReceivingLab => 'المختبر المستلم';

  @override
  String get orderDetailsReadyForDelivery => 'جاهز للتسليم';

  @override
  String get labProcessUpdateStatus => 'تحديث الحالة';

  @override
  String get labProcessTitle => 'معالجة الطلبية';

  @override
  String get labProcessDeliveredDesc => 'المادة متوفرة وتم التسليم للطبيب';

  @override
  String get labProcessMissingDesc => 'المادة غير متوفرة في المخبر';

  @override
  String get labAssignTitle => 'توكيل طلبية';

  @override
  String labAssignSubtitle(String name) {
    return 'اختر الطلبية لـ $name';
  }

  @override
  String get profilePageSubtitle => 'بيانات الموظف ومعلومات الوظيفة';

  @override
  String get labInventory => 'مخزون المخبر';

  @override
  String get labInvSearchHint => 'ابحث عن مادة في المخبر...';

  @override
  String get labInvTotal => 'إجمالي المواد';

  @override
  String get labInvLow => 'مواد تنفد';

  @override
  String get labInvOut => 'مواد نفدت';

  @override
  String get stockLogsTitle => 'سجلّ الحركات';

  @override
  String get stockLogsEmpty => 'لا توجد حركات مسجّلة';

  @override
  String get labInvColCategory => 'الفئة';

  @override
  String get labInvConsume => 'تسجيل استهلاك';

  @override
  String get labInvConsumeTitle => 'تسجيل استهلاك مادة';

  @override
  String get labInvConsumeAmount => 'الكمية المستهلكة';

  @override
  String get labInvConsumeHint => 'أدخل الكمية المسحوبة من المخزون';

  @override
  String get labInvCurrentQty => 'المتوفر حالياً';

  @override
  String get labInvEmpty => 'لا توجد مواد في هذه الفئة';

  @override
  String get labInvConsumeExceeds => 'الكمية أكبر من المتوفر';

  @override
  String get labInvConsumeInvalid => 'أدخل كمية صحيحة';

  @override
  String get labProducts => 'منتجات المخبر';

  @override
  String get labProductsSearchHint => 'ابحث عن منتج...';

  @override
  String get labProdTotal => 'إجمالي المنتجات';

  @override
  String get labProdActiveCount => 'منتجات مفعّلة';

  @override
  String get labProdAdd => 'منتج جديد';

  @override
  String get labProdAddTitle => 'إضافة منتج';

  @override
  String get labProdEditTitle => 'تعديل منتج';

  @override
  String get labProdDeleteTitle => 'حذف المنتج';

  @override
  String labProdDeleteConfirm(String name) {
    return 'هل تريد حذف «$name»؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get labProdColType => 'النوع';

  @override
  String get labProdColPrice => 'السعر (ل.س)';

  @override
  String get labProdColDuration => 'مدة التصنيع';

  @override
  String get labProdDaysUnit => 'يوم';

  @override
  String get labProdStatusActive => 'مفعّل';

  @override
  String get labProdStatusInactive => 'متوقف';

  @override
  String get labProdFieldName => 'اسم المنتج';

  @override
  String get labProdFieldType => 'النوع';

  @override
  String get labProdFieldMaterial => 'المادة';

  @override
  String get labProdFieldPrice => 'السعر بالليرة السورية';

  @override
  String get labProdFieldDuration => 'مدة التصنيع (أيام)';

  @override
  String get labProdFieldCategory => 'الفئة';

  @override
  String get labProdNoCategory => 'بلا فئة';

  @override
  String get labProdEmpty => 'لا توجد منتجات';

  @override
  String get labProdNameRequired => 'اسم المنتج مطلوب';

  @override
  String get labProcessCost => 'تكلفة الطلبية (ل.س)';

  @override
  String get labProcessCostHint => 'أدخل تكلفة التصنيع';

  @override
  String get labProcessTechnician => 'المخبري المنفّذ';

  @override
  String get labProcessTechnicianNone => 'بدون تحديد';

  @override
  String get labProcessTechnicianRequired =>
      'اختر المخبري المنفّذ قبل تغيير الحالة';

  @override
  String get labProcessManufacturingDesc => 'الطلبية قيد التصنيع حالياً';

  @override
  String get labProcessReadyTitle => 'جاهز للتسليم';

  @override
  String get orderDetailsCost => 'التكلفة';

  @override
  String get orderDetailsExecutor => 'المخبري المنفّذ';

  @override
  String get whMovementColumn => 'حركة';

  @override
  String get whMovementTitle => 'حركة مخزون';

  @override
  String get whMovementIn => 'إدخال';

  @override
  String get whMovementOut => 'إخراج';

  @override
  String get whMovementAmount => 'الكمية';

  @override
  String get whMovementExceeds => 'الكمية أكبر من المتوفر';

  @override
  String get whMovementInvalid => 'أدخل كمية صحيحة';

  @override
  String get whMovementCurrent => 'المتوفر حالياً';

  @override
  String get labProcessConsumedSection => 'المواد المستهلكة من المخزون';

  @override
  String get labProcessConsumedHint =>
      'تُنقص هذه المواد من مخزون المخبر عند الحفظ';

  @override
  String get labProcessAddMaterial => 'إضافة مادة';

  @override
  String get labProcessSelectMaterial => 'اختر مادة';

  @override
  String get labProcessMaterialsCost => 'تكلفة المواد';

  @override
  String get labProcessNoMaterials => 'لم تُضف مواد بعد';
}
