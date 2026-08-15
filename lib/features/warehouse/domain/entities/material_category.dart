// ════════════════════════════════════════════════════════════════════════════
// material_category.dart
//
// فئة المادة في المستودع — **مطابقة لعقد الباك**: category ∈ {clinic, lab, both}
// (أيّ نظام يستخدم المادة: العيادة / المخبر / كلاهما). ليست نوع المادة.
//
// تُستخدم في: الفلترة (filter chips)، شارة الـ tag، والحفظ في الباك (apiKey).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/widgets.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/theme/app_colors.dart';

/// جهة استخدام المادة — تطابق قيم الباك (clinic|lab|both).
enum MaterialCategory {
  /// مواد العيادة.
  clinic,

  /// مواد المخبر.
  lab,

  /// مواد مشتركة (عيادة ومخبر).
  both,
}

extension MaterialCategoryX on MaterialCategory {
  /// النص المعروض في UI (من ARB حسب اللغة).
  String label(BuildContext context) {
    switch (this) {
      case MaterialCategory.clinic:
        return context.l10n.whCategoryClinic;
      case MaterialCategory.lab:
        return context.l10n.whCategoryLab;
      case MaterialCategory.both:
        return context.l10n.whCategoryBoth;
    }
  }

  /// لون الـ tag الـ accent.
  Color get accentColor {
    switch (this) {
      case MaterialCategory.clinic:
        return AppColors.dashCyan;
      case MaterialCategory.lab:
        return AppColors.dashViolet;
      case MaterialCategory.both:
        return AppColors.dashGreen;
    }
  }

  /// المفتاح المُرسَل/المستقبَل من الباك (لا يُترجَم).
  String get apiKey {
    switch (this) {
      case MaterialCategory.clinic:
        return 'clinic';
      case MaterialCategory.lab:
        return 'lab';
      case MaterialCategory.both:
        return 'both';
    }
  }
}

/// factory ينتج [MaterialCategory] من قيمة الباك (null إن لم تُطابق).
MaterialCategory? materialCategoryFromString(String value) {
  final v = value.trim().toLowerCase();
  for (final c in MaterialCategory.values) {
    if (c.apiKey == v) return c;
  }
  return null;
}
