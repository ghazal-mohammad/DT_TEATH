// ════════════════════════════════════════════════════════════════════════════
// occupancy_status.dart
//
// تعداد حالات الخلايا/العناصر في الجداول والقوائم.
// يُستخدم في جداول: الكراسي (Dental Chairs)، الرفوف (Warehouse Shelves)،
// الفترات الزمنية (Time Slots)، وأي جدول فيه حالة تشغيل.
//
// المرجع البصري: Design Guide — Selection Colors:
//   - reserved (محجوز)  → #D0FBD7 (أخضر فاتح)
//   - empty (فارغ)       → #E2EDFF (أزرق فاتح)
//   - occupied (مشغول)   → #F1DAFE (وردي فاتح)
//   - maintenance (صيانة)→ #FFE5CC (برتقالي فاتح) — مستنتج من الباليت
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// حالات الخلايا/العناصر في الجداول.
///
/// تُستخدم لتصنيف:
/// - الكراسي في عيادة الأسنان (reserved = محجوز لمريض، empty = متاح)
/// - خلايا الرفوف في المستودع (occupied = بها مادة، empty = فارغة)
/// - الفترات الزمنية في جداول المواعيد
enum OccupancyStatus {
  /// محجوز — أخضر فاتح (#D0FBD7).
  /// المعنى: العنصر محجوز ومؤكّد (مريض محجوز، كمية محجوزة لطلب).
  reserved,

  /// فارغ — أزرق فاتح (#E2EDFF).
  /// المعنى: العنصر متاح للاستخدام (كرسي فارغ، رف فارغ).
  empty,

  /// مشغول — وردي فاتح (#F1DAFE).
  /// المعنى: العنصر قيد الاستخدام الفعلي (مريض حالي، مادة محجوزة فعلياً).
  occupied,

  /// صيانة — برتقالي فاتح.
  /// المعنى: العنصر خارج الخدمة مؤقّتاً.
  maintenance,
}

/// مجموعة ألوان متناسقة لحالة واحدة.
///
/// بدل ما نرجع لون واحد، بنرجع الـ 3 مستويات المعتادة:
/// - `background`: خلفية الخلية/Badge (شفّاف)
/// - `border`: حدود (أقوى شوية)
/// - `text`: لون النص (الأقوى — قابل للقراءة)
///
/// هاد بيضمن إنه كل الحالات تستخدم نفس منطق الـ color system
/// (light bg + medium border + strong text).
class StatusColorSet {
  const StatusColorSet({
    required this.background,
    required this.border,
    required this.text,
  });

  /// خلفية الخلية/البادج (الأفتح).
  final Color background;

  /// حدود الخلية/البادج (متوسط).
  final Color border;

  /// لون النص (الأدكن — لضمان contrast).
  final Color text;
}

/// Extension على [OccupancyStatus] يوفّر الألوان والنصوص.
extension OccupancyStatusX on OccupancyStatus {
  /// يرجع مجموعة ألوان الحالة (bg + border + text).
  ///
  /// الـ border و text محسوبين من الـ bg بطريقة ذكية:
  /// - `border` = نفس اللون بـ opacity أعلى (~0.6)
  /// - `text` = لون غامق من نفس العائلة اللونية
  StatusColorSet get colors {
    switch (this) {
      case OccupancyStatus.reserved:
        return const StatusColorSet(
          background: AppColors.reservedBg, // #D0FBD7
          border: Color(0xFF7DDFA0), // green-ish
          text: Color(0xFF166534), // dark green
        );
      case OccupancyStatus.empty:
        return const StatusColorSet(
          background: AppColors.emptyBg, // #E2EDFF
          border: Color(0xFF9AB5E8), // blue-ish
          text: Color(0xFF1E3A8A), // dark blue
        );
      case OccupancyStatus.occupied:
        return const StatusColorSet(
          background: AppColors.secondaryComponent, // #F1DAFE
          border: Color(0xFFD7A3E8), // purple-ish
          text: Color(0xFF6B21A8), // dark purple
        );
      case OccupancyStatus.maintenance:
        return const StatusColorSet(
          background: Color(0xFFFFE5CC), // orange-light
          border: Color(0xFFFCA860),
          text: Color(0xFF9A3412),
        );
    }
  }

  /// النص العربي للحالة.
  String get labelAr {
    switch (this) {
      case OccupancyStatus.reserved:
        return 'محجوز';
      case OccupancyStatus.empty:
        return 'فارغ';
      case OccupancyStatus.occupied:
        return 'مشغول';
      case OccupancyStatus.maintenance:
        return 'صيانة';
    }
  }

  /// النص الإنجليزي للحالة.
  String get labelEn {
    switch (this) {
      case OccupancyStatus.reserved:
        return 'Reserved';
      case OccupancyStatus.empty:
        return 'Empty';
      case OccupancyStatus.occupied:
        return 'Occupied';
      case OccupancyStatus.maintenance:
        return 'Maintenance';
    }
  }
}
