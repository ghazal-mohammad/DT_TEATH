// ════════════════════════════════════════════════════════════════════════════
// build_context_l10n.dart
//
// Extension على BuildContext لتقصير الوصول للـ localization strings.
//
// بدل:
//   Text(AppLocalizations.of(context)!.dashboard)
// نستخدم:
//   Text(context.l10n.dashboard)
//
// الفائدة:
// - أقصر وأوضح (تقريباً 40% أقل كود)
// - Type-safe (الـ IDE يكمّل الـ keys تلقائياً)
// - يحمي من الخطأ الشائع: نسيان `!` أو `of(context)`
//
// الاستخدام:
//   import 'package:dt_teeth/core/l10n/build_context_l10n.dart';
//   Text(context.l10n.email)  // بدل AppLocalizations.of(context)!.email
//
// المرجع:
//   https://dart.dev/language/extension-methods
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import 'generated/app_localizations.dart';

/// Extension على BuildContext لتقصير الوصول للترجمات.
extension BuildContextL10n on BuildContext {
  /// الوصول للترجمات المولّدة من .arb files.
  ///
  /// مثال:
  /// ```dart
  /// Text(context.l10n.dashboard)
  /// Text(context.l10n.authVerifyCodeSubtitle(email))
  /// ```
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// الوصول للـ Locale الحالية.
  ///
  /// مفيد للـ conditional logic:
  /// ```dart
  /// if (context.currentLocale.languageCode == 'ar') { ... }
  /// ```
  Locale get currentLocale => Localizations.localeOf(this);

  /// ما إذا كان الاتجاه الحالي RTL.
  ///
  /// مفيد لـ custom widgets تحتاج تفاصيل الـ direction:
  /// ```dart
  /// final icon = context.isRtl ? Icons.arrow_back : Icons.arrow_forward;
  /// ```
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  /// ما إذا كانت اللغة الحالية عربية.
  bool get isArabic => currentLocale.languageCode == 'ar';

  /// ما إذا كانت اللغة الحالية إنجليزية.
  bool get isEnglish => currentLocale.languageCode == 'en';
}
