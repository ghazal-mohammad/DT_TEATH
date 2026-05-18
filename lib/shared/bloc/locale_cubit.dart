// ════════════════════════════════════════════════════════════════════════════
// locale_cubit.dart
//
// Cubit لإدارة لغة التطبيق (عربي/إنجليزي).
// يحفظ اختيار المستخدم في SharedPreferences ويستعيده عند إعادة فتح التطبيق.
//
// التصميم:
//   - State = Locale (class جاهز من Flutter)
//   - الافتراضي: عربي (ar) — المشروع موجّه للسوق العربي
//   - تغيير اللغة → persist فوراً → BlocListener في MaterialApp يعيد البناء
//
// الاستخدام:
//   context.read<LocaleCubit>().setLocale(const Locale('en'));
//   context.read<LocaleCubit>().toggle(); // تبديل بين ar ↔ en
//
// المرجع:
//   https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization#setting-the-locale
//   https://bloclibrary.dev/bloc-concepts/#cubit
// ════════════════════════════════════════════════════════════════════════════

import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// مفتاح التخزين في SharedPreferences.
const String _kLocaleKey = 'app.locale.language_code';

/// اللغات المدعومة في التطبيق.
///
/// أي إضافة لغة جديدة لاحقاً (مثل فرنسي) بتتطلب:
/// 1. إنشاء ملف `app_fr.arb`
/// 2. إضافة القيمة هنا
/// 3. إضافة `Locale('fr')` في `supportedLocales` في main.dart
enum SupportedLocale {
  arabic('ar'),
  english('en');

  const SupportedLocale(this.code);

  /// رمز اللغة (ISO 639-1).
  final String code;

  /// تحويل من كود إلى enum. يرجع [arabic] إذا لم يُتعرف على الكود.
  static SupportedLocale fromCode(String? code) {
    return SupportedLocale.values.firstWhere(
      (l) => l.code == code,
      orElse: () => SupportedLocale.arabic,
    );
  }

  /// تحويل إلى Locale من Flutter.
  Locale toLocale() => Locale(code);
}

/// Cubit يدير لغة التطبيق الحالية مع حفظ الاختيار محلياً.
class LocaleCubit extends Cubit<Locale> {
  /// ينشئ [LocaleCubit] بلغة افتراضية (العربية).
  ///
  /// استخدم [LocaleCubit.loadSaved] إذا كنت تريد استعادة اللغة المحفوظة.
  LocaleCubit() : super(SupportedLocale.arabic.toLocale());

  /// يحمّل اللغة المحفوظة من SharedPreferences.
  ///
  /// يُستدعى عادةً في `main()` قبل تشغيل `runApp()`:
  /// ```dart
  /// final cubit = LocaleCubit();
  /// await cubit.loadSaved();
  /// runApp(MyApp(localeCubit: cubit));
  /// ```
  Future<void> loadSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedCode = prefs.getString(_kLocaleKey);
      if (savedCode != null) {
        final locale = SupportedLocale.fromCode(savedCode);
        emit(locale.toLocale());
      }
    } catch (_) {
      // فشل القراءة من SharedPreferences — نبقى على الافتراضي (ar).
      // مقبول: المستخدم يقدر يعدّل اللغة من الإعدادات بعد التشغيل.
    }
  }

  /// يعيّن اللغة ويحفظ الاختيار.
  Future<void> setLocale(SupportedLocale locale) async {
    if (state.languageCode == locale.code) return; // لا تغيير
    emit(locale.toLocale());
    await _persist(locale.code);
  }

  /// يبدّل بين العربية والإنجليزية.
  ///
  /// مفيد لزر الـ AppLanguageToggle بنقرة واحدة.
  Future<void> toggle() async {
    final SupportedLocale next = state.languageCode == 'ar'
        ? SupportedLocale.english
        : SupportedLocale.arabic;
    await setLocale(next);
  }

  /// يعيد ما إذا كانت اللغة الحالية عربية.
  bool get isArabic => state.languageCode == 'ar';

  /// يعيد ما إذا كانت اللغة الحالية إنجليزية.
  bool get isEnglish => state.languageCode == 'en';

  /// يحفظ في SharedPreferences.
  Future<void> _persist(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLocaleKey, code);
    } catch (_) {
      // فشل الحفظ — نتجاهل. الاختيار شغّال حتى إغلاق التطبيق.
    }
  }
}
