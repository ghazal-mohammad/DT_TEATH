// ════════════════════════════════════════════════════════════════════════════
// lab_order_models.dart
//
// نموذج بيانات الطلبية لصفحة "طلبات الأطباء" + ثوابت الألوان المرتبطة.
// مفصول عن الـ page نفسها ليصير قابل للاستخدام من المودالات.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/mock/lab_dashboard_mock_data.dart';

/// أسماء المخبريين (الفنيين) المتاحين — مرجع موحّد للتوكيل وتسجيل المنفّذ.
/// تُستبدل بقائمة من API لاحقاً (GET /api/lab/technicians).
const List<String> kLabTechnicianNames = [
  'محمد علي',
  'سامر حسن',
  'ليلى كريم',
  'يوسف ناصر',
];

/// نموذج كامل لطلب المخبر — يستخدم بصفحة الطلبات والمودالات.
class LabOrderFull {
  LabOrderFull({
    required this.id,
    required this.doctor,
    required this.type,
    required this.material,
    required this.tooth,
    required this.date,
    required this.statusVariant,
    this.isUrgent = false,
    this.notes = '',
    this.cost,
    this.assignedTechnician,
  });

  final String id;
  final String doctor;
  final String type;
  final String material;
  final String tooth;
  final String date;
  LabOrderBadgeVariant statusVariant;
  final bool isUrgent;
  final String notes;

  /// تكلفة تصنيع الطلبية بالليرة السورية (تُسجَّل عند المعالجة) — UC69.
  int? cost;

  /// اسم المخبري المنفّذ للطلبية (تسجيل المنفّذ) — UC70 / UC71.
  String? assignedTechnician;
}

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
  static LabStatusColors of(LabOrderBadgeVariant variant) {
    switch (variant) {
      case LabOrderBadgeVariant.newOrder:
        return newOrder;
      case LabOrderBadgeVariant.manufacturing:
        return manufacturing;
      case LabOrderBadgeVariant.ready:
        return ready;
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
  }
}

/// لون شريط الـ accent على الحافة اليسرى للبطاقة.
/// الأولوية الـ urgent تتقدّم على الـ status العادي.
Color labOrderAccentColor({
  required LabOrderBadgeVariant statusVariant,
  required bool isUrgent,
}) {
  if (isUrgent) return AppColors.statusUrgent;
  return LabStatusColors.of(statusVariant).fg;
}
