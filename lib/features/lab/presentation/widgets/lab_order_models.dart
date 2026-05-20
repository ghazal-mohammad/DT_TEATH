// ════════════════════════════════════════════════════════════════════════════
// lab_order_models.dart
//
// نموذج بيانات الطلبية لصفحة "طلبات الأطباء" + ثوابت الألوان المرتبطة.
// مفصول عن الـ page نفسها ليصير قابل للاستخدام من المودالات.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../data/mock/lab_dashboard_mock_data.dart';

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
}

/// ألوان الـ status badge (نقطة + نص) — مطابقة لتصميم الجدول بالـ Dashboard.
class LabStatusColors {
  const LabStatusColors._(this.bg, this.fg, this.label);
  final Color bg;
  final Color fg;
  final String label;

  static const newOrder = LabStatusColors._(
    Color(0xFFE2EDFF),
    Color(0xFF3B82F6),
    'جديد',
  );
  static const manufacturing = LabStatusColors._(
    Color(0xFFF1DAFE),
    Color(0xFF8B5CF6),
    'قيد التصنيع',
  );
  static const ready = LabStatusColors._(
    Color(0xFFD0FBD7),
    Color(0xFF10B981),
    'جاهز',
  );
  static const urgent = LabStatusColors._(
    Color(0xFFFEE2E2),
    Color(0xFFEF4444),
    'عاجل',
  );

  static LabStatusColors of(LabOrderBadgeVariant variant) {
    switch (variant) {
      case LabOrderBadgeVariant.newOrder:
        return newOrder;
      case LabOrderBadgeVariant.manufacturing:
        return manufacturing;
      case LabOrderBadgeVariant.ready:
        return ready;
      case LabOrderBadgeVariant.urgent:
        return urgent;
    }
  }
}

/// لون شريط الـ accent على الحافة اليسرى للبطاقة.
/// الأولوية الـ urgent تتقدّم على الـ status العادي.
Color labOrderAccentColor({
  required LabOrderBadgeVariant statusVariant,
  required bool isUrgent,
}) {
  if (isUrgent) return const Color(0xFFEF4444);
  return LabStatusColors.of(statusVariant).fg;
}
