// ════════════════════════════════════════════════════════════════════════════
// app_sizes.dart
//
// مصدر الأبعاد: CSS من ملفات HTML الأصلية.
//
// قاعدة استخدام الأبعاد:
//   1. ممنوع كتابة أرقام يدوية (hardcoded) للأبعاد داخل الكود.
//   2. كل padding/radius/height لازم ياخد قيمته من هنا.
//   3. استخدمي مع ScreenUtil: مثلاً AppSizes.spaceMD.w أو .h أو .sp
//
// المرجع: الملف التقني — الجزء الثامن (القرار 11).
// ════════════════════════════════════════════════════════════════════════════

class AppSizes {
  AppSizes._();

  // ── التدوير (Border Radius) — من --r6 إلى --r24 في HTML ───────────────
  static const double radiusXS = 6.0; // --r6
  static const double radiusSM = 8.0; // --r8
  static const double radiusMD = 10.0; // --r10
  static const double radiusLG = 12.0; // --r12
  static const double radiusXL = 16.0; // --r16
  static const double radiusXXL = 20.0; // --r20
  static const double radius3XL = 24.0; // --r24
  static const double radiusFull = 999.0; // للعناصر الدائرية

  // ── المسافات (Padding / Margin / Gap) ───────────────────────────────────
  static const double spaceXXS = 2.0;
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 14.0; // gap الأساسي في HTML
  static const double spaceLG = 16.0; // padding الكروت
  static const double spaceXL = 20.0;
  static const double space2XL = 24.0;
  static const double space3XL = 32.0;

  // ── أبعاد الـ Sidebar ────────────────────────────────────────────────────
  // القيم مستخرجة من CSS الأصلي (DT_Teeth_Lab_v12_Enhanced.html سطر 472-473).
  static const double sidebarWidth = 232.0; // width:232px في .sb
  static const double sidebarCollapsed = 70.0; // للشاشات الأصغر
  static const double sidebarTopPadding = 16.0; // padding-top في .sb-top
  static const double sidebarHorizontalPadding = 14.0; // padding-horizontal
  static const double sidebarItemPaddingV = 7.0; // padding-vertical لـ .ni
  static const double sidebarItemPaddingH = 9.0; // padding-horizontal لـ .ni
  static const double sidebarIconBoxSize = 32.0; // .ni-ico 32×32
  static const double sidebarLogoSize = 38.0; // .sb-logo-icon 38×38
  static const double sidebarAvatarSize = 30.0; // .sw-av 30×30

  // ── أبعاد الـ Topbar ────────────────────────────────────────────────────
  // القيم مستخرجة من CSS (سطر 604-638).
  static const double topbarHeight = 64.0; // height:64px في .tb
  static const double topbarPadding = 22.0; // padding:0 22px
  static const double topbarGap = 11.0; // gap:11px
  static const double topbarActionSize = 36.0; // .tb-ib 36×36
  static const double topbarSearchWidth = 240.0; // .tb-srch width:240px
  static const double topbarSearchHeight = 36.0;

  // ── أبعاد الأزرار والحقول ───────────────────────────────────────────────
  static const double buttonHeight = 48.0;
  static const double buttonHeightSM = 36.0;
  static const double buttonHeightLG = 56.0;
  static const double inputHeight = 44.0;
  static const double iconButtonSize = 32.0;
  static const double avatarSize = 30.0;
  static const double avatarSizeLG = 44.0;

  // ── أبعاد الكروت ────────────────────────────────────────────────────────
  static const double cardMinHeight = 80.0;
  static const double statCardHeight = 120.0;
  static const double dashHeroHeight = 180.0;

  // ── أحجام الخط (Font Sizes) ─────────────────────────────────────────────
  // من فحص font-size في HTML — القرار 12
  static const double fontXS = 9.0; // تفاصيل صغيرة جداً
  static const double fontSM = 11.0; // labels, badges
  static const double font13 = 13.0; // buttons
  static const double fontMD = 14.0; // body
  static const double fontLG = 16.0;
  static const double fontXL = 18.0; // عناوين الأقسام
  static const double font21 = 21.0; // عناوين الصفحات
  static const double font24 = 24.0;
  static const double fontDisplay = 32.0; // اسم المركز

  // ── أحجام الأيقونات ─────────────────────────────────────────────────────
  static const double iconXS = 12.0;
  static const double iconSM = 16.0;
  static const double iconMD = 20.0;
  static const double iconLG = 24.0;
  static const double iconXL = 32.0;

  // ── عرض الحدود (Border Widths) ──────────────────────────────────────────
  static const double borderThin = 1.0;
  static const double borderMedium = 1.5;
  static const double borderThick = 2.0;

  // ── Breakpoints للتجاوب (القرار 44) ────────────────────────────────────
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
  static const double wideBreakpoint = 1440.0;

  // ── مدد الانيميشن ───────────────────────────────────────────────────────
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 400);

  // ══════════════════════════════════════════════════════════════════════════
  //                    AUTH PAGES — أبعاد خاصة
  // ══════════════════════════════════════════════════════════════════════════
  // أبعاد تُستخدم في صفحات Auth فقط — مُعرَّفة هنا بدل الـ hardcoding.

  /// المسافة الإضافية 28px (بين space2XL=24 و space3XL=32).
  static const double spaceXXL = 28.0;

  /// حجم نص Branding الكبير Desktop (WELCOME!).
  static const double fontAuth46 = 46.0;

  /// حجم نص Branding الكبير Desktop (نسخة أكبر — email_entry).
  static const double fontAuth58 = 58.0;

  /// حجم نص Branding Mobile.
  static const double fontAuth36 = 36.0;

  /// حجم عنوان Form الصغير (verify, set_password mobile).
  static const double fontAuth20 = 20.0;

  /// حجم عنوان Form المتوسط.
  static const double fontAuth22 = 22.0;
}
