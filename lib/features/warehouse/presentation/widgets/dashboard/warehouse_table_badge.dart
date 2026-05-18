// ════════════════════════════════════════════════════════════════════════════
// warehouse_table_badge.dart
//
// Badge ملوّن مستخدم داخل الجداول والـ chips. عبارة عن نقطة ملوّنة + نص.
//
// المرجع: DT_Teeth_Warehouse_v6_Enhanced.html — السطور 818–827
//
// 5 variants:
//   bc → cyan   (مستهلكات)
//   bv → violet (أدوية، مواد طبية)
//   bg → green  (متوفر)
//   bo → orange (ينفد)
//   br → red    (نفد) — مع pulse animation
//
// CSS الأصلي:
//   .bdg {
//     display:inline-flex; align-items:center; gap:3px;
//     padding:4px 10px; border-radius:20px;
//     font-size:12.5px; font-weight:700;
//   }
//   .bdg::before {
//     content:''; width:4px; height:4px; border-radius:50%
//   }
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';

/// نوع الـ badge — يحدد لون الخلفية والنص والنقطة.
enum WarehouseBadgeVariant {
  /// سماوي — للفئات العامة (مستهلكات).
  cyan,

  /// بنفسجي — للأدوية والمواد الطبية.
  violet,

  /// أخضر — للحالة "متوفر".
  green,

  /// برتقالي — للحالة "ينفد".
  orange,

  /// أحمر — للحالة "نفد" (مع pulse animation).
  red,
}

/// Badge ملوّن صغير مع نقطة ونص.
///
/// مثال:
/// ```dart
/// WarehouseTableBadge(
///   variant: WarehouseBadgeVariant.green,
///   text: context.l10n.whStatusAvailable,
/// )
/// ```
class WarehouseTableBadge extends StatefulWidget {
  const WarehouseTableBadge({
    super.key,
    required this.variant,
    required this.text,
  });

  /// نوع الـ badge.
  final WarehouseBadgeVariant variant;

  /// النص داخل الـ badge.
  final String text;

  @override
  State<WarehouseTableBadge> createState() => _WarehouseTableBadgeState();
}

class _WarehouseTableBadgeState extends State<WarehouseTableBadge>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;

  @override
  void initState() {
    super.initState();
    // فقط الـ red variant عندها pulse animation (من CSS: animation:alertPulse 3s)
    if (widget.variant == WarehouseBadgeVariant.red) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      )..repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant WarehouseTableBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    // لو الـ variant تغيّر من red ↔ غير red، نلغي/نُنشئ الـ controller.
    final wasRed = oldWidget.variant == WarehouseBadgeVariant.red;
    final isRed = widget.variant == WarehouseBadgeVariant.red;
    if (wasRed && !isRed) {
      _pulseController?.dispose();
      _pulseController = null;
    } else if (!wasRed && isRed) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  /// لون الـ badge (نفس النص ونفس النقطة، الخلفية شفّافة).
  Color get _color {
    switch (widget.variant) {
      case WarehouseBadgeVariant.cyan:
        return AppColors.dashCyan;
      case WarehouseBadgeVariant.violet:
        return AppColors.dashViolet;
      case WarehouseBadgeVariant.green:
        return AppColors.dashGreen;
      case WarehouseBadgeVariant.orange:
        return AppColors.dashOrange;
      case WarehouseBadgeVariant.red:
        return AppColors.alertRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;

    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
          width: AppSizes.borderThin,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull), // r20
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // النقطة الملوّنة (::before)
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 3),
          // النص
          Text(
            widget.text,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: color,
            ),
          ),
        ],
      ),
    );

    // إذا الـ variant red، نلفّه بـ FadeTransition للـ pulse.
    if (widget.variant == WarehouseBadgeVariant.red &&
        _pulseController != null) {
      return FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.7).animate(_pulseController!),
        child: badge,
      );
    }

    return badge;
  }
}
