// ════════════════════════════════════════════════════════════════════════════
// app_colors.dart
//
// مصدر الألوان:
//   1. CSS variables من ملفات HTML الأصلية:
//      - DT_Teeth_Lab_v12_Enhanced.html
//      - DT_Teeth_Warehouse_v6_Enhanced.html
//   2. Design Guide — Selection Colors (شام، 2026-04-24).
//
// قاعدة استخدام الألوان:
//   1. ممنوع استخدام أي لون خارج هذا الملف داخل المشروع.
//   2. كل تعديل بصري على اللون يتم من هنا فقط — ينعكس على كل الشاشات فوراً.
//   3. الحالات المركّبة (reserved/empty/occupied) تستخدم OccupancyStatus enum
//      الموجود في occupancy_status.dart بدل الوصول المباشر للألوان.
//
// التقسيم:
//   - Brand Colors         → primary, secondary, accent
//   - Semantic Colors      → success, warning, error, info, alert
//   - System Colors        → labSystem, warehouseSystem
//   - Dark Mode Palette    → darkBg*, darkText*, darkBorder*
//   - Light Mode Palette   → lightBg*, lightText*, lightBorder*
//   - Status Colors        → stock*, expiry*
//   - Design Guide         → tableHeader, reservedBg, emptyBg...
//   - Helper Functions     → contrastingTextOn, stockColorFor, expiryColorFor
//
// المرجع: الملف التقني — الجزء السابع (القرار 9).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── الألوان الأساسية (ثابتة بين الوضعين) ────────────────────────────────
  static const Color primary = Color(0xFF1A1C4E); // --primary
  static const Color secondary = Color(0xFFED8BFA); // --secondary (الوردي)
  static const Color accent = Color(0xFF9EFBEC); // --accent (السماوي)

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

  // ── الوضع الداكن (Dark Mode — الافتراضي) ────────────────────────────────
  static const Color darkBg = Color(0xFF1A1C4E); // --bg
  static const Color darkBg1 = Color(0xF51A1C4E); // --bg1 (0.96)
  static const Color darkBg2 = Color(0xEB1A1C4E); // --bg2 (0.92)
  static const Color darkBg3 = Color(0xE01A1C4E); // --bg3 (0.88)
  static const Color darkSurface = Color(0x0FFFFFFF); // --surface (0.06)
  static const Color darkGlass = Color(0x249EFBEC); // --glass (0.14)
  static const Color darkGlass2 = Color(0x0AFFFFFF); // --glass2 (0.04)

  // نصوص الوضع الداكن
  static const Color darkText1 = Color(0xFFFFFFFF); // --t1
  static const Color darkText2 = Color(0xFFE0F7F5); // --t2
  static const Color darkText3 = Color(0xFF9EFBEC); // --t3
  static const Color darkText4 = Color(0xFFC5FDF5); // --t4

  // حدود الوضع الداكن
  static const Color darkBorder = Color(0x479EFBEC); // --cyan-brd (0.28)
  static const Color darkBorderHover = Color(0x4D9EFBEC); // (0.30)

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

  // ══════════════════════════════════════════════════════════════════════
  //   OFFICIAL DESIGN GUIDE PALETTE (مرجعي — مطابق 100% للـ Design Guide)
  // ══════════════════════════════════════════════════════════════════════
  // الباليت الرسمية المستخرجة من ملف Design Guide الموحّد (Selection Colors).
  // هاي القيم لازم تطابق الـ design system بدون تعديل.
  //
  //   #1A1C4E    NavBar Items/text       (=AppColors.primary)
  //   #E9ECFB    BG Color @ 68%          (=AppColors.bgGeneral)
  //   #BED8FA    Table Header / BG text  (=AppColors.tableHeader)
  //   #FFFFFF    Base Component          (=AppColors.baseComponent)
  //   #F1DAFE    2nd Component @ 100%    (=AppColors.secondaryComponent)
  //   #F1DAFE    2nd Component @ 55%     (=AppColors.secondaryComponentSoft)
  //   #E2EDFF    Empty status            (=AppColors.emptyBg)
  //   #D0FBD7    Reserved status         (=AppColors.reservedBg)
  //   #353535    Selection — secondary text (=AppColors.guideSecondaryText)
  //   #000000    Selection — primary text   (=AppColors.guidePrimaryText)

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

  /// نص ثانوي من Design Guide Selection — رمادي داكن.
  /// من Design Guide: Selection #353535.
  static const Color guideSecondaryText = Color(0xFF353535);

  // ══════════════════════════════════════════════════════════════════════
  //         DASHBOARD ACCENT COLORS (Phase 4.2 — Warehouse)
  // ══════════════════════════════════════════════════════════════════════
  // ألوان قياسية مستخدمة في الـ stat cards و chips و badges في Dashboard.
  // مأخوذة مباشرة من HTML mockup CSS variables:
  //   --cyan:#7DD3FC  --green:#22C55E  --orange:#F97316
  //   --violet:#8B5CF6  --amber:#FBBF24  --pink:#FCA5A5

  /// سماوي معياري — للـ chips الإخبارية (chip-ok) وإحصائيات Dashboard hero.
  /// من CSS: `--cyan-b: #7DD3FC` (البديل المعياري للـ accent).
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
}
