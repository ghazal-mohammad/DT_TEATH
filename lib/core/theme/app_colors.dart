
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── الألوان الأساسية (ثابتة بين الوضعين) ────────────────────────────────
  static const Color primary = Color(0xFF1A1C4E); // --navy (لون الفاتح الأساسي)
  static const Color secondary = Color(0xFFED8BFA); // --secondary (الوردي)
  static const Color accent = Color(0xFF9EFBEC); // --accent (السماوي — زخرفي)

  // اللون البراند للوضع الغامق — إندِغو (--brand في theme.css).
  // هو اللون المملوء للأزرار/السايدبار النشط/الأفاتار في الغامق.
  // في الفاتح يبقى الكحلي (primary) هو البراند.
  static const Color brand = Color(0xFF7C7FF2); // --brand
  static const Color brandHover = Color(0xFF6E71EC); // brand:hover

  // ── ألوان الحالة (Semantic) ────────────────────────────────────────────
  static const Color success = Color(0xFF0DBD7F); // --clr-green
  static const Color warning = Color(0xFFFADE1F); // --clr-warn
  static const Color alert = Color(0xFF1FFADE); // --clr-alert
  static const Color error = Color(0xFFED8BFA); // --clr-red (وردي في HTML)
  static const Color info = Color(0xFF9EFBEC); // --blue

  // ── ألوان الأنظمة الفرعية ──────────────────────────────────────────────
  static const Color labSystem = Color(0xFFED8BFA); // المخبر = وردي
  static const Color warehouseSystem = Color(0xFF9EFBEC); // المستودع = سماوي
  static const Color clinicSystem = Color(0xFF7DD3FC); // العيادة/الطبيب = أزرق فاتح

  // ── الوضع الداكن (Dark Mode — slate + indigo، مطابق theme.css) ──────────
  // الخلفية رمادي فحمي (مش كحلي) ، والبراند إندِغو.
  static const Color darkBg = Color(0xFF1A1B26); // --bg (خلفية الصفحة)
  static const Color darkBg1 = Color(0xFF262838); // --white (سطح الكروت)
  static const Color darkBg2 = Color(0xFF20222F); // --bg-2 (تعبئة خفيفة/حقول)
  static const Color darkBg3 = Color(0xFF20222F); // --bg-2 (مكافئ)
  static const Color darkSurface = Color(0xFF262838); // --white (سطح)
  static const Color darkGlass = Color(0x247C7FF2); // brand @ 0.14 (لمسة)
  static const Color darkGlass2 = Color(0x0AFFFFFF); // --glass2 (0.04)

  // نصوص الوضع الداكن — تباين مريح (مش أبيض نقي)
  static const Color darkText1 = Color(0xFFE6E7F0); // --text
  static const Color darkText2 = Color(0xFFADB0C4); // --text-2
  static const Color darkText3 = Color(0xFF7E8198); // --text-3
  static const Color darkText4 = Color(0xFFADB0C4); // ثانوي (مكافئ text-2)

  // حدود الوضع الداكن — slate ناعمة وظاهرة
  static const Color darkBorder = Color(0xFF3A3D52); // --border
  static const Color darkBorderHover = Color(0xFF2F3144); // --border-soft

  // ── شارات الحالة في الوضع الغامق (من theme.css) ─────────────────────────
  // خلفيات + نصوص للشرائح (chips/badges). الفاتح يبقى بقيمه الأصلية في الصفحات.
  // الاستخدام: isLight ? <hex الفاتح الأصلي> : AppColors.darkStatusXxx
  static const Color darkChipBlueBg = Color(0xFF2C3E66); // --st-new-bg
  static const Color darkChipBlueText = Color(0xFF8FB6F5); // --st-new
  static const Color darkChipVioletBg = Color(0xFF4A3A66); // --st-prod-bg
  static const Color darkChipVioletText = Color(0xFFC2A4EC); // --st-prod
  static const Color darkChipGreenBg = Color(0xFF234C3C); // --st-ready-bg
  static const Color darkChipGreenText = Color(0xFF6CD7AA); // --st-ready
  static const Color darkChipOrangeBg = Color(0xFF5A3E2C); // --st-urgent-bg
  static const Color darkChipOrangeText = Color(0xFFF0B088); // --st-urgent
  static const Color darkChipRedBg = Color(0xFF4C2530); // أحمر غامق (عاجل)
  static const Color darkChipRedText = Color(0xFFF4A6A6);

  // ── الوضع الفاتح (Light Mode) ──────────────────────────────────────────
  static const Color lightBg = Color(0xAEE9ECFB); // --bg (0.68)
  static const Color lightBg1 = Color(0xD9E9ECFB); // --bg1 (0.85)
  static const Color lightBg2 = Color(0x8CE9ECFB); // --bg2 (0.55)
  static const Color lightBg3 = Color(0xD9E9ECFB); // --bg3 (0.85)
  static const Color lightSurface = Color(0xF7FFFFFF); // --surface (0.97)
  static const Color lightGlass = Color(0x3F9EFBEC); // --glass (0.25)
  static const Color lightGlass2 = Color(0xEBFFFFFF); // --glass2 (0.92)

  // نصوص الوضع الفاتح
  static const Color lightText1 = Color(0xFF1A1C4E); // --t1 داكن
  static const Color lightText2 = Color(0xFF1A1C4E); // --t2
  static const Color lightText3 = Color(0xFF3A5AB8); // --t3
  static const Color lightText4 = Color(0xFF6078C8); // --t4

  // حدود الوضع الفاتح
  static const Color lightBorder = Color(0x261A1C4E); // --cyan-brd (0.15)
  static const Color lightBorderHover = Color(0x4D1A1C4E);

  // ── التدرجات (Gradients) ───────────────────────────────────────────────
  static const List<Color> gradientPrimary = [
    Color(0xFF1A1C4E),
    Color(0xFF3A5AB8),
  ];
  static const List<Color> gradientAccent = [
    Color(0xFF9EFBEC),
    Color(0xFF0DBD7F),
  ];
  static const List<Color> gradientSecondary = [
    Color(0xFFED8BFA),
    Color(0xFF9EFBEC),
  ];

  // ── ظلال ────────────────────────────────────────────────────────────────
  static const Color shadowLight = Color(0x38000000); // --s1 (0.22)
  static const Color shadowMedium = Color(0x33000000); // --s2 (0.20)

  // ── مستويات تنبيه المخزون (Smart Stock Alert — القرار 40) ──────────────
  static const Color stockCritical = Color(0xFFED8BFA); // < 3 أيام
  static const Color stockWarning = Color(0xFFFADE1F); // 3-7 أيام
  static const Color stockCaution = Color(0xFFFADE1F); // 7-14 يوم
  static const Color stockSafe = Color(0xFF0DBD7F); // > 14 يوم

  // ── مستويات الصلاحية (Expiry — القرار 27) ──────────────────────────────
  static const Color expirySafe = Color(0xFF0DBD7F);
  static const Color expiryWarning = Color(0xFFFADE1F);
  static const Color expiryDanger = Color(0xFFED8BFA);
  static const Color expiryCritical = Color(0xFFED8BFA);
  static const Color expiryExpired = Color(0xFF000000);

  // ── ألوان التنبيه الحقيقية (للنقاط والإشعارات) ──────────────────────────
  /// أحمر صارخ — للنقاط (notification dots) والتنبيهات العاجلة.
  /// من CSS: --red: rgba(239,68,68,1)
  static const Color alertRed = Color(0xFFEF4444);

  /// أحمر فاتح — لنصوص التنبيهات داخل badges.
  /// من CSS: rgba(252,165,165,1) — للنصوص على خلفية حمراء شفّافة.
  static const Color alertRedSoft = Color(0xFFFCA5A5);

  // ── تدرّج السايدبار (للـ dark mode فقط) ────────────────────────────────
  /// اللون السفلي لـ gradient السايدبار.
  /// من CSS: background:linear-gradient(180deg, #1A1C4E, #0F1035)
  static const Color sidebarGradientBottom = Color(0xFF0F1035);


  /// خلفية header الجداول والحقول النصية.
  /// من Design Guide: "Table Header/BGtext fields" #BED8FA.
  static const Color tableHeader = Color(0xFFBED8FA);

  /// خلفية حالة "محجوز" (reserved).
  /// من Design Guide: "reserved" #D0FBD7.
  static const Color reservedBg = Color(0xFFD0FBD7);

  /// خلفية حالة "فارغ" (empty).
  /// من Design Guide: "empty" #E2EDFF.
  static const Color emptyBg = Color(0xFFE2EDFF);

  /// المكوّن الثانوي — وردي فاتح للحالات الخاصة.
  /// من Design Guide: "2nd Component" #F1DAFE @ 100%.
  static const Color secondaryComponent = Color(0xFFF1DAFE);

  /// المكوّن الثانوي بشفافية 55% — للحالات Hover/Disabled.
  /// من Design Guide: "2nd Component" #F1DAFE @ 55%.
  /// حساب alpha: 0.55 × 255 = 140 = 0x8C.
  static const Color secondaryComponentSoft = Color(0x8CF1DAFE);

  /// المكوّن الأساسي — أبيض نقي للكروت في الـ light mode.
  /// من Design Guide: "Base Component" #FFFFFF.
  static const Color baseComponent = Color(0xFFFFFFFF);

  /// BG Color العام بشفافية 68% — لخلفية الصفحات.
  /// من Design Guide: "BG Color" #E9ECFB @ 68%.
  /// حساب alpha: 0.68 × 255 = 173.4 ≈ 0xAE.
  static const Color bgGeneral = Color(0xAEE9ECFB);

  /// نص أساسي من Design Guide Selection — أسود نقي.
  /// من Design Guide: Selection #000000.
  static const Color guidePrimaryText = Color(0xFF000000);

  static const Color guideSecondaryText = Color(0xFF353535);


  static const Color dashCyan = Color(0xFF7DD3FC);

  /// أخضر — للـ "متوفر" badges و stat cards الإيجابية.
  /// من CSS: `--green: #22C55E`.
  static const Color dashGreen = Color(0xFF22C55E);

  /// برتقالي — للتنبيهات المتوسطة (طلبات جديدة، حذر).
  /// من CSS: `--orange: #F97316`.
  static const Color dashOrange = Color(0xFFF97316);

  /// بنفسجي — للأدوية والمواد الطبية badges.
  /// من CSS: `--violet: #8B5CF6`.
  static const Color dashViolet = Color(0xFF8B5CF6);

  /// أصفر ذهبي — للـ stat cards الإحصائية (للزيادة).
  /// من CSS: `--amber: #FBBF24`.
  static const Color dashAmber = Color(0xFFFBBF24);

  /// وردي فاتح — للـ stat cards "expiry" و alerts الناعمة.
  /// من CSS: `--pink: #FCA5A5`.
  static const Color dashPink = Color(0xFFFCA5A5);

  /// برتقالي ناعم — لنصوص العناوين في Alert Boxes البرتقالية.
  /// من CSS: `.ab-o .ab-title { color: #fdba74 }`.
  static const Color dashOrangeSoft = Color(0xFFFDBA74);

  /// خلفية stat card في الوضع الداكن (gradient start).
  /// من CSS: `linear-gradient(145deg, rgba(15,30,66,0.8), ...)`.
  static const Color statCardDarkStart = Color(0xCC0F1E42);

  /// خلفية stat card في الوضع الداكن (gradient end).
  /// من CSS: `linear-gradient(145deg, ..., rgba(10,20,44,0.7))`.
  static const Color statCardDarkEnd = Color(0xB30A142C);

  /// خلفية modal/dialog في الوضع الداكن (gradient start).
  /// من CSS: `linear-gradient(145deg, #0a1530, #070f24)`.
  static const Color modalDarkStart = Color(0xFF0A1530);

  /// خلفية modal/dialog في الوضع الداكن (gradient end).
  /// من CSS: `linear-gradient(145deg, #0a1530, #070f24)`.
  static const Color modalDarkEnd = Color(0xFF070F24);

  // ══════════════════════════════════════════════════════════════════════
  //                    HELPER FUNCTIONS (Phase 2.7.1)
  // ══════════════════════════════════════════════════════════════════════

  /// يرجع لون النص المناسب (داكن/فاتح) حسب سطوع الخلفية.
  ///
  /// مفيد لما نحتاج نعرض نص فوق لون ديناميكي (مثل badge بلون متغيّر).
  /// يستخدم صيغة relative luminance (WCAG).
  ///
  /// المرجع:
  /// https://www.w3.org/TR/WCAG20/#relativeluminancedef
  static Color contrastingTextOn(Color background) {
    // حساب الـ relative luminance
    final double luminance = background.computeLuminance();
    // threshold 0.5 — قيم أعلى = خلفية فاتحة = نص داكن
    return luminance > 0.5 ? primary : Colors.white;
  }

  /// يرجع لون حالة المخزون حسب عدد أيام الصلاحية/التوفّر.
  ///
  /// المرجع: القرار 40 (Smart Stock Alert) في الملف التقني.
  ///
  /// - < 3 أيام  → critical (وردي)
  /// - 3-7 أيام  → warning (أصفر)
  /// - 7-14 يوم → caution (أصفر)
  /// - > 14 يوم → safe (أخضر)
  static Color stockColorFor(int daysRemaining) {
    if (daysRemaining < 3) return stockCritical;
    if (daysRemaining <= 7) return stockWarning;
    if (daysRemaining <= 14) return stockCaution;
    return stockSafe;
  }

  /// يرجع لون حالة الصلاحية حسب الأيام المتبقّية.
  ///
  /// المرجع: القرار 27 (Expiry Management) في الملف التقني.
  static Color expiryColorFor(int daysRemaining) {
    if (daysRemaining < 0) return expiryExpired;
    if (daysRemaining < 7) return expiryCritical;
    if (daysRemaining < 30) return expiryDanger;
    if (daysRemaining < 90) return expiryWarning;
    return expirySafe;
  }

  /// يرجع لون نظام فرعي حسب نوعه.
  ///
  /// يكافئ `AppSystemTypeX.primaryColor` لكن للاستخدام بدون الحاجة
  /// لاستيراد الـ enum.
  static Color systemColorFor({required bool isLab}) {
    return isLab ? labSystem : warehouseSystem;
  }

  /// خلفية شفّافة للنظام (للـ badges).
  static Color systemBackgroundFor({required bool isLab, double alpha = 0.08}) {
    return systemColorFor(isLab: isLab).withValues(alpha: alpha);
  }

  /// حدود شفّافة للنظام.
  static Color systemBorderFor({required bool isLab, double alpha = 0.2}) {
    return systemColorFor(isLab: isLab).withValues(alpha: alpha);
  }

  // ── Phase 5.x — ألوان خلفية بديلة للعناصر الداخلية ─────────────────────
  // ══════════════════════════════════════════════════════════════════════
  //      UNIFIED SEMANTIC STATUS PALETTE (توحيد المخبر + المستودع)
  // ══════════════════════════════════════════════════════════════════════
  // الباليتة الدلالية الموحّدة بين النظامين (قرار التوحيد 2026-06-11):
  // نفس الحالة المنطقية = نفس اللون في كل الشاشات.
  // الوضع الغامق: استخدم darkChip* المقابلة (موجودة أعلاه).
  //
  //   عاجل / خطر       → statusUrgent   (أحمر)
  //   جاهز / تم / نجاح → statusSuccess  (أخضر)
  //   جديد / معلومة    → statusInfo     (أزرق)
  //   قيد التنفيذ      → statusProgress (بنفسجي)
  //   تحذير / جزئي     → statusWarn     (برتقالي)

  /// عاجل/خطأ — أحمر موحّد (كان EF4444 بالمخبر و D9434E/E17B2C بالمستودع).
  static const Color statusUrgent = Color(0xFFEF4444);

  /// خلفية شارة "عاجل" الفاتحة.
  static const Color statusUrgentBg = Color(0xFFFEE2E2);

  /// جاهز/تم/نجاح — أخضر موحّد (كان 10B981 بالمخبر و 1F9B6E بالمستودع).
  static const Color statusSuccess = Color(0xFF10B981);

  /// خلفية شارة النجاح الفاتحة (من Design Guide: reserved D0FBD7).
  static const Color statusSuccessBg = reservedBg;

  /// جديد/معلومة — أزرق موحّد (كان 3B82F6 بالمخبر و 2C7FDB بالمستودع).
  static const Color statusInfo = Color(0xFF3B82F6);

  /// خلفية شارة المعلومة الفاتحة (من Design Guide: empty E2EDFF).
  static const Color statusInfoBg = emptyBg;

  /// قيد التنفيذ — بنفسجي موحّد (كان 8B5CF6 بالمخبر و 7A4FCF بالمستودع).
  static const Color statusProgress = Color(0xFF8B5CF6);

  /// خلفية شارة قيد التنفيذ (من Design Guide: 2nd Component F1DAFE).
  static const Color statusProgressBg = secondaryComponent;

  /// تحذير/جزئي — برتقالي موحّد (كان EA580C بالمخبر و E17B2C بالمستودع).
  static const Color statusWarn = Color(0xFFEA580C);

  /// خلفية شارة التحذير الفاتحة.
  static const Color statusWarnBg = Color(0xFFFFEDD5);

  /// خلفية بديلة للعناصر الداخلية (icon containers, input backgrounds)
  static const Color lightBgAlt = Color(0xFFEEF1F9);
  static const Color darkBgAlt = Color(0x1AFFFFFF);

  // ══════════════════════════════════════════════════════════════════════════
  //                    AUTH LAYOUT — Gradient & Colors
  // ══════════════════════════════════════════════════════════════════════════
  // ألوان ومتدرجات مشتركة بين جميع صفحات Auth.
  // مصدر حقيقة واحد — تغيير أي قيمة ينعكس فوراً على كل الصفحات.

  /// ألوان التدرج Navy — مشترك بين: email_entry, login, set_password,
  /// verify_code, system_selection (desktop + mobile لكل منها).
  static const List<Color> authNavyGradientColors = [
    Color(0xFF1A1F5E),
    primary, // 0xFF1A1C4E
    Color(0xFF0E1240),
  ];

  /// Linear gradient جاهز للاستخدام المباشر في كل صفحات Auth.
  static const LinearGradient authNavyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: authNavyGradientColors,
    stops: [0.0, 0.5, 1.0],
  );

  // ── AUTH FORM — ألوان الـ form side (desktop = خلفية بيضاء) ─────────────

  /// لون العنوان الرئيسي للـ form في الـ desktop (جانب أبيض).
  static const Color authFormTitleLight = Color(0xFF111111);

  /// لون النص الثانوي (subtitle/hints) في الـ desktop.
  static const Color authFormSubLight = Color(0xFF555555);

  /// لون الـ divider line (OR separator) في الـ desktop.
  static const Color authDividerLight = Color(0xFFDDDDDD);

  /// لون نص "OR" والروابط الثانوية في الـ desktop.
  static const Color authLinkTextLight = Color(0xFF888888);

  /// خلفية حقل الـ input في الـ desktop.
  static const Color authInputBgLight = Color(0xFFF9F9F9);

  /// حدود حقل الـ input في الـ desktop.
  static const Color authInputBorderLight = Color(0xFFDDDDDD);

  /// لون الأيقونة في حقل الـ input (desktop).
  static const Color authInputIconLight = Color(0xFF888888);

  /// لون النص داخل حقل الـ input (desktop).
  static const Color authInputTextLight = Color(0xFF111111);

  /// لون الـ hint text في حقل الـ input (desktop).
  static const Color authInputHintLight = Color(0xFFAAAAAA);

  /// لون label الحقول (login_page).
  static const Color authLabelLight = Color(0xFF333333);

  /// لون النص الثانوي في cards panel (system_selection).
  static const Color authCardSubLight = Color(0xFF666666);

  /// لون العنوان الكبير في cards panel (system_selection).
  static const Color authCardTitleLight = Color(0xFF111111);

  /// أزرق فاتح مطابق لحدّ الكارت بالمرجع (React: `border-[#05B4D7]`) —
  /// للخطوط الصلبة (حدّ الكارت، حدّ الحقل عند التركيز، حدّ/نص الزر، الأيقونة).
  /// خاصّ بشاشات auth (login/email/verify/setPassword) — لا يُستخدم عالمياً
  /// مثل AppColors.accent، فتغييره لا يمسّ بقية التطبيق.
  static const Color authBorderBlue = Color(0xFF05B4D7);

  /// أزرق فاتح أسطع مطابق لتوهّج الكارت بالمرجع (React: `shadow-[0_0_25px_#4DE1FF]`) —
  /// للتأثيرات الضبابية فقط (BoxShadow، خط التوهج، تدرّج hover). خاصّ بـ auth.
  static const Color authGlowBlue = Color(0xFF4DE1FF);

  // ── AUTH FORM — ألوان الـ form في Mobile (خلفية داكنة) ─────────────────
  // على الـ mobile كل الـ form يكون على خلفية navy — الألوان معكوسة.

  /// نص المحتوى على الـ mobile (فوق navy).
  static Color authFormTextMobile({double alpha = 1.0}) =>
      Colors.white.withValues(alpha: alpha);

  /// حدود حقول الـ input على الـ mobile.
  static Color authInputBorderMobile({double alpha = 0.14}) =>
      Colors.white.withValues(alpha: alpha);

  /// خلفية حقول الـ input على الـ mobile.
  static Color authInputBgMobile({double alpha = 0.04}) =>
      Colors.white.withValues(alpha: alpha);

  /// لون الأيقونات على الـ mobile.
  static Color authInputIconMobile({double alpha = 0.45}) =>
      Colors.white.withValues(alpha: alpha);

  // ══════════════════════════════════════════════════════════════════════
  //   PROMOTED FROM FEATURE FILES (Phase 6 — مصدر واحد للألوان)
  // ══════════════════════════════════════════════════════════════════════
  // درجات كانت مكتوبة يدوياً داخل الشاشات ونُقلت هنا كما هي (نفس القيمة
  // بالضبط — صفر تغيير بصري) لتوحيد مصدر اللون. مرشّحة للدمج لاحقاً مع
  // الباليتة الدلالية عند اعتماد التصميم.

  // ── Auth — خلفية متحركة وسبلاش ──────────────────────────────────────────
  static const Color authPulsePeak = Color(0xFF1C6377); // teal عميق
  static const Color authPulseRest = Color(0xFF090D1B); // navy داكن
  static const Color authParticle = Color(0xFFB8BCC8); // رمادي-أزرق محايد
  static const Color splashSurface = Color(0xFFEFF0F7); // خلفية السبلاش
  static const Color loginErrorText = Color(0xFFFF6B6B); // نص خطأ تسجيل الدخول

  // ── شارات برتقالية/كهرمانية (الوجه الفاتح لـ darkChipOrange*) ───────────
  static const Color chipOrangeBgLight = Color(0xFFFFF7ED);
  static const Color chipOrangeAccentLight = Color(0xFFF59E0B);
  static const Color chipAmberBgLight = Color(0xFFFEF3C7);
  static const Color chipAmberTextLight = Color(0xFFD97706);

  // ── درجات أسطح فاتحة (الوجه الفاتح لـ darkBg2/Surface/Border) ───────────
  static const Color surfaceTintCool = Color(0xFFF1F3F8);
  static const Color surfaceTintCool2 = Color(0xFFF8F9FC);
  static const Color surfaceTintCool3 = Color(0xFFF6F7FB);
  static const Color surfaceTintCool4 = Color(0xFFEFF2FB);
  static const Color surfaceFaint = Color(0xFFFCFCFD);
  static const Color surfaceTintIndigo = Color(0xFFE9ECFB);
  static const Color surfaceTintIndigo2 = Color(0xFFEEEEFB);
  static const Color surfaceTintIndigo3 = Color(0xFFEAECF7);
  static const Color surfaceTintBlue = Color(0xFFC8D2F2);

  // ── حدود/فواصل فاتحة محايدة ─────────────────────────────────────────────
  static const Color borderTintCool = Color(0xFFE5E7EE);
  static const Color borderTintNeutral = Color(0xFFD8DBE6);
  static const Color borderNeutralLight = Color(0xFFE5E7EB);
  static const Color dividerNeutral = Color(0xFFE0E0E0);
  static const Color iconMutedLight = Color(0xFFB0B6C3); // أيقونات placeholder

  // ── درجات دلالية ناعمة (نسخ فاتحة — لا تُغيّر القيمة) ───────────────────
  static const Color progressSoft = Color(0xFFC084FC); // بنفسجي فاتح
  static const Color successSoft = Color(0xFF86EFAC); // أخضر فاتح
  static const Color dangerStrong = Color(0xFFDC2626); // أحمر صريح
  static const Color dangerTintLight = Color(0xFFFEF2F2); // خلفية خطر فاتحة

  // ── تنبيهات تحذير برتقالية فاتحة (warehouse) ────────────────────────────
  static const Color warnTintLight = Color(0xFFFEF5EC);
  static const Color warnTintLight2 = Color(0xFFFFF4EC);
  static const Color warnBorderLight = Color(0xFFF6D8B7);
  static const Color warnBorderLight2 = Color(0xFFF7C6A8);
  static const Color amberBorderLight = Color(0xFFF1CFA8);

  // ── Dashboard accents إضافية ────────────────────────────────────────────
  static const Color dashVioletDeep = Color(0xFF6E59B6);
  static const Color dashMagenta = Color(0xFFB44286);
  static const Color categoryGrey = Color(0xFF6B7280); // تصنيف "معدات"

  // ── ملف الموظف (Employee Profile) — باليتة محلية نُقلت هنا ──────────────
  static const Color profileAvatarGradTop = Color(0xFF2E3270);
  static const Color profileAvatarGradBottom = Color(0xFF14163F);
  static const Color profileBlueIconBg = Color(0xFFE3ECFA);
  static const Color profileBlueAccent = Color(0xFF2E48B5);
  static const Color profilePinkBg = Color(0xFFFBEFF5);
  static const Color profilePinkIconBg = Color(0xFFF7E1EC);
  static const Color profilePinkAccent = Color(0xFFC03E7C);
  static const Color profileCardBorder = Color(0xFFE7EBF3);
  static const Color profileLabel = Color(0xFF8A93A7);
  static const Color profileTintBlue = Color(0xFFEFF2FA);
  static const Color profileTintBlue2 = Color(0xFFEFF3FD);
  static const Color profileTintViolet = Color(0xFFF4EEFB);
  static const Color profileTintViolet2 = Color(0xFFF4ECFB);
  static const Color profileSurface = Color(0xFFF7F9FC);
  static const Color profileGreenAccent = Color(0xFF12A150);
}
