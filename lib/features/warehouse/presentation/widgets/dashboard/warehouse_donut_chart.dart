// ════════════════════════════════════════════════════════════════════════════
// warehouse_donut_chart.dart
//
// Donut chart يعرض توزيع المخزون حسب الفئة (4 segments) + legend بجانبه.
//
// المرجع: DT_Teeth_Warehouse_v6_Enhanced.html — السطور 2184–2201 + 945–955
//
// تصميم الـ widget:
//   ┌────────────────────────────────────────┐
//   │ توزيع المخزون                           │
//   │                                         │
//   │  ╭────╮     ● مستهلكات   42%   104     │
//   │  │ 247│     ● أدوية      26%    64     │
//   │  │مادة│     ● طبية       18%    44     │
//   │  ╰────╯     ● معدات      14%    35     │
//   └────────────────────────────────────────┘
//
// الـ SVG الأصلي يستخدم 4 circles بـ stroke-dasharray مختلفة.
// نعيد التطبيق بـ CustomPainter يرسم arcs.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';

// ══════════════════════════════════════════════════════════════════════════
//                          DATA
// ══════════════════════════════════════════════════════════════════════════

/// segment واحد في الـ donut chart.
class WarehouseDonutSegment {
  const WarehouseDonutSegment({
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
  });

  /// اسم الفئة (مثل "مستهلكات").
  final String label;

  /// القيمة المطلقة (مثل 104).
  final int value;

  /// النسبة المئوية (0–100).
  final double percentage;

  /// لون الـ segment.
  final Color color;
}

// ══════════════════════════════════════════════════════════════════════════
//                          DONUT CHART WIDGET
// ══════════════════════════════════════════════════════════════════════════

/// Donut chart يعرض توزيع المخزون مع legend.
class WarehouseDonutChart extends StatelessWidget {
  const WarehouseDonutChart({
    super.key,
    required this.totalValue,
    required this.totalLabel,
    required this.segments,
  });

  /// القيمة الإجمالية المعروضة في وسط الدائرة.
  final int totalValue;

  /// النص تحت الرقم الإجمالي (مثل "مادة").
  final String totalLabel;

  /// segments الـ donut (يفضّل 4 لمطابقة HTML).
  final List<WarehouseDonutSegment> segments;

  /// factory افتراضي بالقيم القياسية من HTML mockup.
  factory WarehouseDonutChart.standard({
    Key? key,
    required BuildContext context,
  }) {
    return WarehouseDonutChart(
      key: key,
      totalValue: 247,
      totalLabel: context.l10n.whHeroStatRegisteredMaterials,
      segments: [
        WarehouseDonutSegment(
          label: context.l10n.whCategoryConsumables,
          value: 104,
          percentage: 42,
          color: AppColors.tableHeader, // var(--table) في HTML
        ),
        WarehouseDonutSegment(
          label: context.l10n.whCategoryMedicines,
          value: 64,
          percentage: 26,
          color: AppColors.secondaryComponent, // var(--second)
        ),
        WarehouseDonutSegment(
          label: context.l10n.whCategoryMedical,
          value: 44,
          percentage: 18,
          color: AppColors.reservedBg, // var(--reserved)
        ),
        WarehouseDonutSegment(
          label: context.l10n.whCategoryEquipment,
          value: 35,
          percentage: 14,
          color: AppColors.emptyBg, // var(--empty)
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          width: AppSizes.borderThin,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── العنوان ─────────────────────────────────────────────────
          Text(
            context.l10n.whInventoryDistribution,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: AppSizes.fontLG,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: isLight ? AppColors.lightText1 : AppColors.darkText1,
            ),
          ),
          const SizedBox(height: 14),

          // ── الـ donut + legend ──────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // الـ donut
              SizedBox(
                width: 86,
                height: 86,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(86, 86),
                      painter: _DonutPainter(
                        segments: segments,
                        backgroundColor: isLight
                            ? AppColors.lightBorder
                                .withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.05),
                        strokeWidth: 4 * (86 / 36), // scale من viewBox 36→86
                      ),
                    ),
                    // النص في المنتصف
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          totalValue.toString(),
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                            color: isLight
                                ? AppColors.lightText1
                                : AppColors.darkText1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          totalLabel,
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            height: 1.0,
                            color: isLight
                                ? AppColors.lightText3
                                : AppColors.darkText3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // الـ legend
              Expanded(child: _buildLegend(isLight)),
            ],
          ),
        ],
      ),
    );
  }

  /// بناء قائمة الـ legend.
  Widget _buildLegend(bool isLight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: segments.map((s) => _buildLegendItem(s, isLight)).toList(),
    );
  }

  /// بناء عنصر واحد في الـ legend.
  Widget _buildLegendItem(WarehouseDonutSegment segment, bool isLight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // النقطة الملوّنة
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: segment.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          // الاسم
          Expanded(
            child: Text(
              segment.label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.2,
                color: isLight ? AppColors.lightText1 : AppColors.darkText1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          // النسبة المئوية
          Text(
            '${segment.percentage.toInt()}%',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.2,
              color: isLight ? AppColors.lightText3 : AppColors.darkText3,
            ),
          ),
          const SizedBox(width: 6),
          // القيمة
          Text(
            segment.value.toString(),
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: isLight ? AppColors.lightText1 : AppColors.darkText1,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                          DONUT PAINTER
// ══════════════════════════════════════════════════════════════════════════

/// CustomPainter يرسم الـ donut chart segments.
class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.segments,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  final List<WarehouseDonutSegment> segments;
  final Color backgroundColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // ── خلفية الـ donut (دائرة كاملة شاحبة) ─────────────────────────
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // ── رسم الـ segments ─────────────────────────────────────────────
    // نبدأ من الزاوية -90° (top) ونتحرّك بالساعة (clockwise).
    double startAngle = -math.pi / 2;

    for (final segment in segments) {
      final sweepAngle = (segment.percentage / 100) * 2 * math.pi;

      final segmentPaint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        segmentPaint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.segments != segments ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
