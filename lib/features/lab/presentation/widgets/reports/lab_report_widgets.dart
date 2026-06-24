// ════════════════════════════════════════════════════════════════════════════
// lab_report_widgets.dart
//
// ودجات قسم تقارير المخبر المستقلة (اختيار الشهر، التقويم، بطاقة الإحصاء،
// رسّام الدونات) — مُستخرَجة من lab_reports_page.dart ضمن تقسيم الصفحات.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/forms/app_form_select.dart';
import '../../../data/mock/lab_reports_mock_data.dart';

// ══════════════════════════════════════════════════════════════════════════
//  MONTH DROPDOWN
// ══════════════════════════════════════════════════════════════════════════

/// قائمة اختيار الشهر في شريط تحكّم التقرير.
class LabReportMonthDropdown extends StatefulWidget {
  const LabReportMonthDropdown({super.key, required this.isLight});
  final bool isLight;

  @override
  State<LabReportMonthDropdown> createState() =>
      _LabReportMonthDropdownState();
}

class _LabReportMonthDropdownState extends State<LabReportMonthDropdown> {
  String _selected = 'مارس 2026';

  static const _options = [
    'مارس 2026',
    'فبراير 2026',
    'يناير 2026',
    'ديسمبر 2025',
    'نوفمبر 2025',
    'أكتوبر 2025',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: widget.isLight
            ? AppColors.lightGlass2
            : AppColors.darkGlass2,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(
          color: widget.isLight
              ? AppColors.lightBorder
              : AppColors.darkBorder,
        ),
      ),
      child: AppDropdownMenuTheme(
        child: DropdownButton<String>(
          value: _selected,
          isDense: true,
          underline: const SizedBox(),
          dropdownColor:
              widget.isLight ? Colors.white : AppColors.darkBg1,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          style: AppTextStyles.bodySmall.copyWith(
            color: widget.isLight
                ? AppColors.lightText1
                : AppColors.darkText1,
            fontSize: 13,
          ),
          items: _options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (v) => setState(() => _selected = v!),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  CALENDAR GRID
// ══════════════════════════════════════════════════════════════════════════

/// شبكة تقويم الطلبات (عدد الطلبات لكل يوم).
class LabReportCalendarGrid extends StatelessWidget {
  const LabReportCalendarGrid({super.key, required this.isLight});
  final bool isLight;

  static const _dayHeaders = ['سبت', 'جمعة', 'خميس', 'أربعاء', 'ثلاثاء', 'إثنين', 'أحد'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Day headers
        Row(
          children: _dayHeaders.map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isLight
                        ? AppColors.lightText4
                        : AppColors.darkText4,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Calendar cells
        ..._buildWeeks(),
      ],
    );
  }

  List<Widget> _buildWeeks() {
    const data = LabReportsMockData.calendarData;
    final weeks = <Widget>[];
    for (int week = 0; week < 5; week++) {
      final cells = <Widget>[];
      for (int day = 0; day < 7; day++) {
        final idx = week * 7 + day;
        final count = idx < data.length ? data[idx] : null;
        cells.add(Expanded(child: _CalendarCell(count: count, isLight: isLight)));
      }
      weeks.add(Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: cells),
      ));
    }
    return weeks;
  }
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({required this.count, required this.isLight});
  final int? count;
  final bool isLight;

  Color _cellColor() {
    if (count == null) return Colors.transparent;
    if (count! <= 0) return Colors.transparent;
    if (count! >= 10) return AppColors.secondary.withValues(alpha: 0.7);
    if (count! >= 5) return AppColors.secondary.withValues(alpha: 0.4);
    if (count! >= 3) return AppColors.accent.withValues(alpha: 0.3);
    return AppColors.accent.withValues(alpha: 0.15);
  }

  @override
  Widget build(BuildContext context) {
    if (count == null) {
      return Container(
        margin: const EdgeInsets.all(2),
        height: 36,
      );
    }

    return Container(
      margin: const EdgeInsets.all(2),
      height: 36,
      decoration: BoxDecoration(
        color: _cellColor(),
        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        border: count! > 0
            ? Border.all(
                color: isLight
                    ? AppColors.lightBorder
                    : AppColors.darkBorder,
                width: 0.5,
              )
            : null,
      ),
      child: Center(
        child: count! > 0
            ? Text(
                '$count',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              )
            : null,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  REPORT STAT CARD
// ══════════════════════════════════════════════════════════════════════════

/// بطاقة إحصاء في أعلى التقرير (أيقونة + قيمة + label).
class LabReportStatCard extends StatelessWidget {
  const LabReportStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.accentColor,
    required this.isLight,
  });

  final String icon;
  final String value;
  final String label;
  final Color accentColor;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const Spacer(),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSM),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: isLight ? AppColors.lightText1 : AppColors.darkText1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isLight ? AppColors.lightText4 : AppColors.darkText3,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  DONUT CHART PAINTER
// ══════════════════════════════════════════════════════════════════════════

/// رسّام مخطط الدونات لتوزيع الطلبات حسب النوع.
class LabReportDonutPainter extends CustomPainter {
  const LabReportDonutPainter({required this.segments});
  final List<LabChartSegment> segments;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 8.0;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Segments
    double startAngle = -math.pi / 2;
    for (final seg in segments) {
      final sweepAngle = 2 * math.pi * (seg.percentage / 100);
      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - 0.1,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(LabReportDonutPainter oldDelegate) => false;
}
