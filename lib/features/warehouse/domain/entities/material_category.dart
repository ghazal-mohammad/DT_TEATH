// ════════════════════════════════════════════════════════════════════════════
// material_category.dart
//
// تعداد فئات المواد في المستودع.
//
// 🎯 الهدف:
//   تعريف موحّد لفئات المواد، يُستخدم في:
//   - الفلترة (filter chips)
//   - عرض الـ tag في material card
//   - الحفظ في الـ backend
//
// 🔮 قابلية التوسيع:
//   - إضافة category جديد = إضافة case + l10n key + لون في mapper
//   - الـ extension getters تجعل التحديث في مكان واحد فقط
//   - الـ fromString factory يدعم backward-compat للـ APIs القديمة
//
// ملاحظة بنيوية:
//   نستخدم enum بسيط مع extensions بدلاً من sealed class لأن:
//   1. كل category له نفس الشكل (label + color + icon فقط)
//   2. enum أبسط للـ JSON serialization
//   3. switch exhaustive يضمن compile-time safety
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/widgets.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../presentation/widgets/dashboard/warehouse_table_badge.dart';

/// تعداد فئات المواد المعتمدة في النظام.
///
/// عند الإضافة/التوسيع:
/// 1. أضف case هنا
/// 2. أضف l10n key في `app_*.arb` بصيغة `whCategoryX`
/// 3. أضف الـ case في `_label`, `_badgeVariant`, `_apiKey`
enum MaterialCategory {
  /// مواد مستهلكة (قفازات، أكواب، خيوط).
  consumables,

  /// أدوية (حقن، أقراص، مراهم).
  medicines,

  /// مواد طبية (سيليكون، جبص، خيوط جراحية).
  medical,

  /// معدات (أجهزة، أدوات).
  equipment,
}

/// extensions لإثراء [MaterialCategory] بـ helpers.
extension MaterialCategoryX on MaterialCategory {
  /// النص المعروض في UI (يأتي من ARB حسب اللغة).
  String label(BuildContext context) {
    switch (this) {
      case MaterialCategory.consumables:
        return context.l10n.whCategoryConsumables;
      case MaterialCategory.medicines:
        return context.l10n.whCategoryMedicines;
      case MaterialCategory.medical:
        return context.l10n.whCategoryMedical;
      case MaterialCategory.equipment:
        return context.l10n.whCategoryEquipment;
    }
  }

  /// نوع الـ badge variant المستخدم لعرض هذه الفئة في material card/table.
  WarehouseBadgeVariant get badgeVariant {
    switch (this) {
      case MaterialCategory.consumables:
        return WarehouseBadgeVariant.cyan;
      case MaterialCategory.medicines:
        return WarehouseBadgeVariant.violet;
      case MaterialCategory.medical:
        return WarehouseBadgeVariant.violet;
      case MaterialCategory.equipment:
        return WarehouseBadgeVariant.green;
    }
  }

  /// لون الـ tag الـ accent (يستخدم في material card top tag).
  Color get accentColor {
    switch (this) {
      case MaterialCategory.consumables:
        return AppColors.dashCyan;
      case MaterialCategory.medicines:
        return AppColors.dashViolet;
      case MaterialCategory.medical:
        return AppColors.dashViolet;
      case MaterialCategory.equipment:
        return AppColors.dashGreen;
    }
  }

  /// المفتاح المستخدم في API/JSON (لا يُترجم).
  String get apiKey {
    switch (this) {
      case MaterialCategory.consumables:
        return 'consumables';
      case MaterialCategory.medicines:
        return 'medicines';
      case MaterialCategory.medical:
        return 'medical';
      case MaterialCategory.equipment:
        return 'equipment';
    }
  }
}

/// factory ينتج [MaterialCategory] من نص (للـ deserialization).
///
/// يرجع `null` إذا النص غير معروف — يسمح للـ caller بمعالجة الحالة بأمان.
MaterialCategory? materialCategoryFromString(String value) {
  for (final c in MaterialCategory.values) {
    if (c.apiKey == value) return c;
  }
  return null;
}
