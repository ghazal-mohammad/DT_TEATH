// ════════════════════════════════════════════════════════════════════════════
// lab_order_models.dart
//
// نموذج بيانات الطلبية لصفحة "طلبات الأطباء" + ثوابت الألوان المرتبطة.
// مفصول عن الـ page نفسها ليصير قابل للاستخدام من المودالات.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/lab_order.dart';

// LabOrderFull و LabOrderBadgeVariant انتقلا إلى domain/entities/lab_order.dart؛
// نعيد تصديرهما هنا كي تبقى الملفات المستوردة لهذا الملف تعمل دون تعديل.
export '../../domain/entities/lab_order.dart'
    show LabOrderFull, LabOrderBadgeVariant, LabOrderPart, LabOrderModification;

/// ألوان الـ status badge (نقطة + نص) — مطابقة لتصميم الجدول بالـ Dashboard.
class LabStatusColors {
  const LabStatusColors._(this.bg, this.fg);
  final Color bg;
  final Color fg;

  static const newOrder = LabStatusColors._(
    AppColors.statusInfoBg,
    AppColors.statusInfo,
  );
  static const manufacturing = LabStatusColors._(
    AppColors.statusProgressBg,
    AppColors.statusProgress,
  );
  static const ready = LabStatusColors._(
    AppColors.statusSuccessBg,
    AppColors.statusSuccess,
  );
  // ملغى — رمادي محايد (لا أحمر حتى لا يلتبس مع urgent).
  static const cancelled = LabStatusColors._(
    AppColors.borderNeutralLight,
    AppColors.categoryGrey,
  );
  static LabStatusColors of(LabOrderBadgeVariant variant) {
    switch (variant) {
      case LabOrderBadgeVariant.newOrder:
        return newOrder;
      case LabOrderBadgeVariant.manufacturing:
        return manufacturing;
      case LabOrderBadgeVariant.ready:
        return ready;
      case LabOrderBadgeVariant.cancelled:
        return cancelled;
    }
  }
}

/// نص حالة الطلبية المترجم (يُحلّ من context.l10n بدل تخزينه ثابتاً).
String labStatusLabel(BuildContext context, LabOrderBadgeVariant variant) {
  final l10n = context.l10n;
  switch (variant) {
    case LabOrderBadgeVariant.newOrder:
      return l10n.statusNew;
    case LabOrderBadgeVariant.manufacturing:
      return l10n.statusManufacturing;
    case LabOrderBadgeVariant.ready:
      return l10n.statusReady;
    case LabOrderBadgeVariant.cancelled:
      return l10n.statusCancelled;
  }
}

/// لون شريط الـ accent على الحافة اليسرى للبطاقة.
Color labOrderAccentColor({required LabOrderBadgeVariant statusVariant}) {
  return LabStatusColors.of(statusVariant).fg;
}
