// ════════════════════════════════════════════════════════════════════════════
// app_assets.dart
//
// مسارات كل الأصول (صور، أيقونات، animations، خطوط).
// ════════════════════════════════════════════════════════════════════════════

class AppAssets {
  AppAssets._();

  static const String _imagesPath = 'assets/images';
  static const String _animationsPath = 'assets/animations';

  // ── اللوغو — 4 نسخ بخلفية شفّافة ──────────────────────────────────────
  // بدون نص:
  static const String logoLightNoText   = '$_imagesPath/logo/logo_light_no_text.png';
  static const String logoDarkNoText    = '$_imagesPath/logo/logo_dark_no_text.png';
  // مع نص "DT_Teeth":
  static const String logoLightWithText = '$_imagesPath/logo/logo_light_with_text.png';
  static const String logoDarkWithText  = '$_imagesPath/logo/logo_dark_with_text.png';

  /// Aliases للتوافق مع الكود القديم
  @Deprecated('استخدم logoDarkNoText')
  static const String logoDarkTheme = logoDarkNoText;
  @Deprecated('استخدم logoLightNoText')
  static const String logoLightTheme = logoLightNoText;
  @Deprecated('استخدم logoDarkNoText')
  static const String logo = logoDarkNoText;
  @Deprecated('استخدم logoDarkNoText')
  static const String logoWhite = logoDarkNoText;
  @Deprecated('استخدم logoLightNoText')
  static const String logoDark = logoLightNoText;
  @Deprecated('استخدم AppLogo widget')
  static const String logoIcon = logoDarkNoText;

  // ── الحالات الفارغة ──────────────────────────────────────────────────────
  static const String emptyNoOrders         = '$_imagesPath/empty_states/no_orders.svg';
  static const String emptyNoMaterials      = '$_imagesPath/empty_states/no_materials.svg';
  static const String emptyNoNotifications  = '$_imagesPath/empty_states/no_notifications.svg';
  static const String emptyNoData           = '$_imagesPath/empty_states/no_data.svg';

  // ── Onboarding ───────────────────────────────────────────────────────────
  static const String onboardingLab       = '$_imagesPath/onboarding/lab.svg';
  static const String onboardingWarehouse = '$_imagesPath/onboarding/warehouse.svg';

  // ── Lottie Animations ────────────────────────────────────────────────────
  static const String loadingAnimation = '$_animationsPath/loading.json';
  static const String successAnimation = '$_animationsPath/success.json';
  static const String errorAnimation   = '$_animationsPath/error.json';
}
