// ════════════════════════════════════════════════════════════════════════════
// material_filter.dart
//
// تعداد فلاتر شريط الـ chips في صفحة Materials.
//
// 🎯 الهدف:
//   تعريف موحّد لفلاتر العرض (الكل / ينفد / صلاحية / فئات).
//   كل filter يعرف كيف يُطبَّق على List<WarehouseMaterial>.
//
// 🔮 قابلية التوسيع:
//   - أضف case + l10n + apply()
//   - الـ apply() نقي (pure) — سهل اختباره
//   - الـ count getters للعدد على كل filter (تظهر في chip)
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/widgets.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import 'material_category.dart';
import 'material_status.dart';
import 'warehouse_material.dart';

/// فلاتر صفحة Materials (شريط الـ chips العلوي).
enum MaterialFilter {
  /// كل المواد.
  all,

  /// المواد التي تنفد (low + outOfStock).
  lowStock,

  /// المواد التي ستنتهي صلاحيتها (expiringSoon + expired).
  expiring,

  /// مواد العيادة.
  clinic,

  /// مواد المخبر.
  lab,

  /// مواد مشتركة.
  both,
}

/// extensions للـ MaterialFilter.
extension MaterialFilterX on MaterialFilter {
  /// النص المعروض في الـ chip (يأتي من ARB).
  String label(BuildContext context) {
    switch (this) {
      case MaterialFilter.all:
        return context.l10n.whFilterAll;
      case MaterialFilter.lowStock:
        return context.l10n.whFilterLowStock;
      case MaterialFilter.expiring:
        return context.l10n.whFilterExpiring;
      case MaterialFilter.clinic:
        return context.l10n.whCategoryClinic;
      case MaterialFilter.lab:
        return context.l10n.whCategoryLab;
      case MaterialFilter.both:
        return context.l10n.whCategoryBoth;
    }
  }

  /// أيقونة اختيارية تظهر قبل النص (null إذا ما في).
  String? get emoji {
    switch (this) {
      case MaterialFilter.lowStock:
        return '⚠';
      case MaterialFilter.expiring:
        return '⏰';
      default:
        return null;
    }
  }

  /// يطبّق الفلتر على قائمة مواد ويرجع الـ subset المطابق.
  List<WarehouseMaterial> apply(List<WarehouseMaterial> materials) {
    switch (this) {
      case MaterialFilter.all:
        return materials;

      case MaterialFilter.lowStock:
        return materials.where((m) {
          final s = m.status;
          return s == MaterialStatus.low || s == MaterialStatus.outOfStock;
        }).toList(growable: false);

      case MaterialFilter.expiring:
        return materials.where((m) {
          final s = m.status;
          return s == MaterialStatus.expiringSoon ||
              s == MaterialStatus.expired;
        }).toList(growable: false);

      case MaterialFilter.clinic:
        return materials
            .where((m) => m.category == MaterialCategory.clinic)
            .toList(growable: false);

      case MaterialFilter.lab:
        return materials
            .where((m) => m.category == MaterialCategory.lab)
            .toList(growable: false);

      case MaterialFilter.both:
        return materials
            .where((m) => m.category == MaterialCategory.both)
            .toList(growable: false);
    }
  }

  /// يحسب عدد المواد المطابقة لهذا الفلتر (للعرض في chip count).
  int countIn(List<WarehouseMaterial> materials) {
    return apply(materials).length;
  }
}
