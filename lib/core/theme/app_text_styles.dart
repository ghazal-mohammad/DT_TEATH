// ════════════════════════════════════════════════════════════════════════════
// app_text_styles.dart
//
// خط المشروع الأساسي: Cairo (مع Tajawal كاحتياطي)
// القرار 12 من الملف التقني.
//
// استخدام:
//   Text('مرحباً', style: AppTextStyles.headlineLarge)
//
// ملاحظة: الألوان لا تُحدد هنا — تُورَث من السياق (Theme) لدعم Dark/Light.
//        إذا احتجت لون مخصص، استخدم .copyWith(color: AppColors.xxx).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Cairo';
  static const String fallbackFontFamily = 'Tajawal';
  static const List<String> fontFamilyFallback = [fallbackFontFamily];

  // ── العناوين الكبيرة (Display / Headlines) ─────────────────────────────
  /// اسم المركز "DT.Teeth" — font-weight: 900
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 32,
    fontWeight: FontWeight.w900,
    height: 1.2,
    letterSpacing: -0.5,
  );

  /// عناوين الصفحات الرئيسية
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 21,
    fontWeight: FontWeight.w800,
    height: 1.3,
  );

  /// عناوين الأقسام
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.35,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  // ── النصوص الأساسية (Body) ──────────────────────────────────────────────
  /// نص أساسي — المحتوى العام
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  /// Labels — أسماء الحقول
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  /// تفاصيل صغيرة
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 9,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // ── نصوص متخصصة ────────────────────────────────────────────────────────
  /// نص الأزرار
  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 13,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
    height: 1.2,
  );

  /// نص الـ Badges (الشارات الصغيرة)
  static const TextStyle badge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 9.5,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  /// نص الـ Labels في القوائم الجانبية
  static const TextStyle sidebarItem = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// عناوين الأقسام في السايدبار (مثل "الرئيسية"، "المخزون")
  static const TextStyle sidebarSection = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    height: 1.2,
  );

  /// نص الحقول الكبيرة (Stat Values)
  static const TextStyle statValue = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    height: 1.1,
  );

  /// وصف الإحصائية
  static const TextStyle statLabel = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // ── نمط اسم المركز مع Gradient (يُطبّق بـ ShaderMask في الـ Widget) ──
  static const TextStyle brandName = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 24,
    fontWeight: FontWeight.w900,
    height: 1.0,
    letterSpacing: -0.3,
  );

  // ── Phase 5.x — أنماط الملف الشخصي ──────────────────────────────────────
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    height: 1.2,
  );

  // ══════════════════════════════════════════════════════════════════════════
  //                    AUTH PAGES TEXT STYLES
  // ══════════════════════════════════════════════════════════════════════════
  // أنماط مخصصة لصفحات Auth — مشتركة بين جميع الصفحات.
  // مصدر حقيقة واحد بدل 234 تكرار لـ fontFamily: AppTextStyles.fontFamily.

  /// عنوان Branding الكبير — Desktop (WELCOME! / ALMOST THERE!)
  /// يُستخدم في LoginBrandingPanel وصفحات Auth.
  static const TextStyle authHeroTitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 46,
    fontWeight: FontWeight.w900,
    letterSpacing: 2.5,
    height: 1.0,
  );

  /// عنوان Branding الكبير — Mobile (أصغر قليلاً).
  static const TextStyle authHeroTitleMobile = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 32,
    fontWeight: FontWeight.w900,
    letterSpacing: 2.5,
    height: 1.1,
  );

  /// Subtitle النظام أسفل الـ hero text (DENTAL CLINIC MANAGEMENT SYSTEM).
  static const TextStyle authSystemSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.5,
    height: 1.3,
  );

  /// عنوان الـ form الرئيسي — Desktop (يظهر فوق الـ fields).
  static const TextStyle authFormTitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 24,
    fontWeight: FontWeight.w900,
    height: 1.2,
  );

  /// عنوان الـ form — Mobile (أصغر قليلاً).
  static const TextStyle authFormTitleMobile = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 22,
    fontWeight: FontWeight.w900,
    height: 1.2,
  );

  /// Subtitle الـ form الوصفي (وصف صغير أسفل العنوان).
  static const TextStyle authFormSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 13,
    height: 1.6,
  );

  /// Labels الحقول (البريد الإلكتروني / كلمة المرور).
  static const TextStyle authFieldLabel = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 13.5,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  /// نص داخل حقول الـ input.
  static const TextStyle authFieldInput = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 15,
    height: 1.4,
  );

  /// Hint text لحقول الـ input.
  static const TextStyle authFieldHint = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    height: 1.4,
  );

  /// نص روابط Auth (سجّل دخولك / Sign Up).
  static const TextStyle authLink = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 13.5,
    height: 1.5,
  );

  /// نص الـ divider (أو / OR).
  static const TextStyle authDividerText = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// نص معلومات أسفل الـ form (hints, tips).
  static const TextStyle authFooterNote = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 11.5,
    height: 1.5,
  );

  /// Label كبير — يُستخدم في بطاقات النظام وعناصر القوائم.
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
}
