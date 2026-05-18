// ════════════════════════════════════════════════════════════════════════════
// material_status.dart
//
// تعداد حالات المواد في المخزون.
//
// 🎯 الهدف:
//   حالة كل مادة محسوبة من (qty, minStock, expiryDate). نوحّد المنطق
//   في مكان واحد بدل تكراره في كل widget.
//
// 🔮 قابلية التوسيع:
//   - أضف status case جديد + l10n key + variant
//   - حدّث dictogic في `MaterialStatusResolver.resolve()`
//   - الـ priority property يحدد أيّ حالة تظهر في الـ flag إذا تعدّدت
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/widgets.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../presentation/widgets/dashboard/warehouse_table_badge.dart';

/// تعداد حالات المواد في المخزون.
enum MaterialStatus {
  /// متوفر — الكمية > minStock والصلاحية > 30 يوم.
  available,

  /// ينفد — الكمية ≤ minStock.
  low,

  /// نفد — الكمية = 0.
  outOfStock,

  /// ستنتهي قريباً — الصلاحية ≤ 30 يوم.
  expiringSoon,

  /// منتهي الصلاحية — الصلاحية ≤ 0.
  expired,
}

/// extensions لإثراء [MaterialStatus] بـ helpers.
extension MaterialStatusX on MaterialStatus {
  /// النص المعروض في UI.
  String label(BuildContext context) {
    switch (this) {
      case MaterialStatus.available:
        return context.l10n.whStatusAvailable;
      case MaterialStatus.low:
        return context.l10n.whStatusLow;
      case MaterialStatus.outOfStock:
        return context.l10n.whStatusOut;
      case MaterialStatus.expiringSoon:
        return context.l10n.whFilterExpiring;
      case MaterialStatus.expired:
        return context.l10n.whStatusOut;
    }
  }

  /// نوع badge variant للحالة.
  WarehouseBadgeVariant get badgeVariant {
    switch (this) {
      case MaterialStatus.available:
        return WarehouseBadgeVariant.green;
      case MaterialStatus.low:
        return WarehouseBadgeVariant.orange;
      case MaterialStatus.outOfStock:
      case MaterialStatus.expired:
        return WarehouseBadgeVariant.red;
      case MaterialStatus.expiringSoon:
        return WarehouseBadgeVariant.orange;
    }
  }

  /// اللون الأساسي للحالة (يُستخدم في الـ flag وbborder).
  Color get accentColor {
    switch (this) {
      case MaterialStatus.available:
        return AppColors.dashGreen;
      case MaterialStatus.low:
        return AppColors.dashOrange;
      case MaterialStatus.outOfStock:
      case MaterialStatus.expired:
        return AppColors.alertRed;
      case MaterialStatus.expiringSoon:
        return AppColors.dashOrange;
    }
  }

  /// أولوية الحالة عند تعدّد الإشارات (الأعلى = أهم).
  /// مثال: لو مادة `low` و `expiringSoon`، نظهر الـ flag الـ outOfStock أولاً.
  int get priority {
    switch (this) {
      case MaterialStatus.outOfStock:
      case MaterialStatus.expired:
        return 100;
      case MaterialStatus.low:
        return 80;
      case MaterialStatus.expiringSoon:
        return 60;
      case MaterialStatus.available:
        return 0;
    }
  }

  /// هل تستحق الـ pulse animation في material card؟
  bool get shouldPulse {
    return this == MaterialStatus.outOfStock ||
        this == MaterialStatus.low ||
        this == MaterialStatus.expired;
  }

  /// هل تظهر كـ flag في زاوية الكارت؟
  bool get showsFlag {
    return this != MaterialStatus.available;
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                          STATUS RESOLVER
// ══════════════════════════════════════════════════════════════════════════

/// المنطق المركزي لحساب حالة المادة من بياناتها الخام.
class MaterialStatusResolver {
  MaterialStatusResolver._();

  /// عتبة "ستنتهي قريباً" بالأيام.
  static const int expiringSoonThresholdDays = 30;

  /// يحسب حالة المادة الفعلية بناءً على البيانات.
  ///
  /// الترتيب: expired > outOfStock > low > expiringSoon > available
  static MaterialStatus resolve({
    required int quantity,
    required int minStock,
    int? daysUntilExpiry,
  }) {
    if (daysUntilExpiry != null && daysUntilExpiry <= 0) {
      return MaterialStatus.expired;
    }
    if (quantity <= 0) {
      return MaterialStatus.outOfStock;
    }
    if (quantity <= minStock) {
      return MaterialStatus.low;
    }
    if (daysUntilExpiry != null &&
        daysUntilExpiry <= expiringSoonThresholdDays) {
      return MaterialStatus.expiringSoon;
    }
    return MaterialStatus.available;
  }
}
