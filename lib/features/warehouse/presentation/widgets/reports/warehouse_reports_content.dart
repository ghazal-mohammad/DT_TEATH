// ════════════════════════════════════════════════════════════════════════════
// warehouse_reports_content.dart
//
// محتوى صفحة تقارير المستودع — مطابق لـ mockup التصميم.
//
// 🎯 البنية:
//   1. شريط التصدير + اختيار الفترة (يومي/أسبوعي/شهري/سنوي)
//   2. ترويسة التقرير: شهر + تاريخ الإنشاء
//   3. صف 4 بطاقات إحصائية (مدة التوريد، نسبة التوريد، استهلاك، إجمالي)
//   4. صفّ بطاقتين: donut توزع الاستهلاك + شبكة الأيام
// ════════════════════════════════════════════════════════════════════════════

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';

// ══════════════════════════════════════════════════════════════════════════
//                             VIEW RANGE
// ══════════════════════════════════════════════════════════════════════════

enum _ReportRange { daily, weekly, monthly, yearly }

extension on _ReportRange {
  String get label => switch (this) {
        _ReportRange.daily => 'يومي',
        _ReportRange.weekly => 'أسبوعي',
        _ReportRange.monthly => 'شهري',
        _ReportRange.yearly => 'سنوي',
      };
}

// ══════════════════════════════════════════════════════════════════════════
//                            MAIN CONTENT
// ══════════════════════════════════════════════════════════════════════════

class WarehouseReportsContent extends StatefulWidget {
  const WarehouseReportsContent({super.key});

  @override
  State<WarehouseReportsContent> createState() =>
      _WarehouseReportsContentState();
}

class _WarehouseReportsContentState extends State<WarehouseReportsContent> {
  _ReportRange _range = _ReportRange.monthly;

  // الفترة الحالية (mock — مطابق للـ design).
  static const _periodLabel = 'مارس 2026';
  static const _generatedAt = '22 مايو 2026';
  static const _daysInMonth = 31;

  // الأيام ذات النشاط (highlighted) — مطابق للـ mockup.
  static const _highlightedDays = {9, 11, 17, 24, 26};

  // توزّع الاستهلاك حسب الفئة — مطابق للـ mockup.
  static const _categoryShares = <_CategoryShare>[
    _CategoryShare(label: 'مستهلكات', percent: 42, color: Color(0xFF1A1C4E)),
    _CategoryShare(label: 'مواد طبية', percent: 28, color: Color(0xFF7A4FCF)),
    _CategoryShare(label: 'أدوية', percent: 18, color: Color(0xFF2C7FDB)),
    _CategoryShare(label: 'معادن', percent: 12, color: Color(0xFF1F9B6E)),
  ];

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Toolbar(
          range: _range,
          onRangeChange: (r) => setState(() => _range = r),
          isLight: isLight,
        ),
        const SizedBox(height: 16),
        _ReportHeader(
          period: _periodLabel,
          generatedAt: _generatedAt,
          isLight: isLight,
        ),
        const SizedBox(height: 14),
        _StatsRow(isLight: isLight),
        const SizedBox(height: 14),
        _BottomRow(
          isLight: isLight,
          shares: _categoryShares,
          daysInMonth: _daysInMonth,
          highlighted: _highlightedDays,
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                          1) TOOLBAR
// ══════════════════════════════════════════════════════════════════════════

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.range,
    required this.onRangeChange,
    required this.isLight,
  });
  final _ReportRange range;
  final ValueChanged<_ReportRange> onRangeChange;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AppButton(
          label: 'تصدير PDF',
          onPressed: () {},
          variant: AppButtonVariant.primary,
          size: AppButtonSize.small,
        ),
        AppButton(
          label: 'تصدير Excel',
          onPressed: () {},
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.small,
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isLight ? AppColors.baseComponent : AppColors.darkSurface,
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            border: Border.all(
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time_rounded,
                  size: 14,
                  color:
                      isLight ? AppColors.lightText3 : AppColors.darkText3),
              const SizedBox(width: 6),
              Text(
                'مارس 2026',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color:
                      isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        ..._ReportRange.values.map((r) => Padding(
              padding: const EdgeInsetsDirectional.only(start: 6),
              child: _PillChip(
                label: r.label,
                selected: r == range,
                onTap: () => onRangeChange(r),
              ),
            )),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                          2) REPORT HEADER
// ══════════════════════════════════════════════════════════════════════════

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({
    required this.period,
    required this.generatedAt,
    required this.isLight,
  });
  final String period;
  final String generatedAt;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.description_outlined,
            size: 18, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          '$period — التقرير الشهري',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isLight ? AppColors.lightText1 : AppColors.darkText1,
          ),
        ),
        const Spacer(),
        Text(
          'تم إنشاء التقرير $generatedAt',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12,
            color: isLight ? AppColors.lightText3 : AppColors.darkText3,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                          3) STATS ROW
// ══════════════════════════════════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.isLight});
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 1080
          ? 4
          : c.maxWidth >= 620
              ? 2
              : 1;
      return GridView.count(
        crossAxisCount: cols,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: switch (cols) { 4 => 1.85, 2 => 2.4, _ => 3.0 },
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          _StatBox(
            badge: '-0.4 يوم',
            badgeColor: Color(0xFFE17B2C),
            value: '1.8',
            valueSuffix: 'يوم',
            label: 'متوسط مدة التوريد',
            icon: Icons.access_time_rounded,
            accent: Color(0xFFE17B2C),
          ),
          _StatBox(
            badge: '+2%',
            badgeColor: Color(0xFF1F9B6E),
            value: '94',
            valueSuffix: '%',
            label: 'نسبة التوريد',
            icon: Icons.check_rounded,
            accent: Color(0xFF1F9B6E),
          ),
          _StatBox(
            badge: 'هذا الشهر',
            badgeColor: Color(0xFF7A4FCF),
            value: '156',
            label: 'مادة استُهلكت',
            icon: Icons.trending_up_rounded,
            accent: Color(0xFF7A4FCF),
          ),
          _StatBox(
            badge: '4+',
            badgeColor: Color(0xFF2C7FDB),
            value: '247',
            label: 'إجمالي المواد',
            icon: Icons.inventory_2_outlined,
            accent: Color(0xFF2C7FDB),
          ),
        ],
      );
    });
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.badge,
    required this.badgeColor,
    required this.value,
    this.valueSuffix,
    required this.label,
    required this.icon,
    required this.accent,
  });

  final String badge;
  final Color badgeColor;
  final String value;
  final String? valueSuffix;
  final String label;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      decoration: BoxDecoration(
        color: isLight ? AppColors.baseComponent : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 4, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusFull),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: badgeColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, size: 17, color: accent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          value,
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                            color: isLight
                                ? AppColors.lightText1
                                : AppColors.darkText1,
                          ),
                        ),
                        if (valueSuffix != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            valueSuffix!,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isLight
                                  ? AppColors.lightText3
                                  : AppColors.darkText3,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isLight
                            ? AppColors.lightText3
                            : AppColors.darkText3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                          4) BOTTOM ROW (donut + calendar)
// ══════════════════════════════════════════════════════════════════════════

class _BottomRow extends StatelessWidget {
  const _BottomRow({
    required this.isLight,
    required this.shares,
    required this.daysInMonth,
    required this.highlighted,
  });
  final bool isLight;
  final List<_CategoryShare> shares;
  final int daysInMonth;
  final Set<int> highlighted;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final isNarrow = c.maxWidth < 920;
      final donut = _DonutCard(isLight: isLight, shares: shares);
      final calendar = _CalendarCard(
        isLight: isLight,
        daysInMonth: daysInMonth,
        highlighted: highlighted,
      );
      if (isNarrow) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [donut, const SizedBox(height: 14), calendar],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: calendar),
          const SizedBox(width: 14),
          Expanded(child: donut),
        ],
      );
    });
  }
}

// ── Donut card ──────────────────────────────────────────────────────────

class _CategoryShare {
  const _CategoryShare({
    required this.label,
    required this.percent,
    required this.color,
  });
  final String label;
  final int percent;
  final Color color;
}

class _DonutCard extends StatelessWidget {
  const _DonutCard({required this.isLight, required this.shares});
  final bool isLight;
  final List<_CategoryShare> shares;

  @override
  Widget build(BuildContext context) {
    return _Card(
      isLight: isLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.donut_large_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'توزّع الاستهلاك حسب الفئة',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: CustomPaint(
              painter: _DonutPainter(shares: shares),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '100%',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isLight
                            ? AppColors.lightText1
                            : AppColors.darkText1,
                      ),
                    ),
                    Text(
                      'من الاستهلاك',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 11,
                        color: isLight
                            ? AppColors.lightText3
                            : AppColors.darkText3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...shares.map((s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: s.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.label,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isLight
                              ? AppColors.lightText1
                              : AppColors.darkText1,
                        ),
                      ),
                    ),
                    Text(
                      '${s.percent}%',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isLight
                            ? AppColors.lightText3
                            : AppColors.darkText3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${s.percent}',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: s.color,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.shares});
  final List<_CategoryShare> shares;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const thickness = 22.0;
    final rect = Rect.fromCircle(center: center, radius: radius - thickness / 2);

    final total = shares.fold<int>(0, (a, s) => a + s.percent);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.butt;

    var startAngle = -math.pi / 2;
    for (final s in shares) {
      final sweep = (s.percent / total) * 2 * math.pi;
      paint.color = s.color;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      !identical(old.shares, shares);
}

// ── Calendar card ───────────────────────────────────────────────────────

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.isLight,
    required this.daysInMonth,
    required this.highlighted,
  });
  final bool isLight;
  final int daysInMonth;
  final Set<int> highlighted;

  static const _weekdayLabels = [
    'أحد',
    'إثنين',
    'ثلاثاء',
    'أربعاء',
    'خميس',
    'جمعة',
    'سبت',
  ];

  @override
  Widget build(BuildContext context) {
    return _Card(
      isLight: isLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.event_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'توزع طلبات التوريد على أيام الشهر',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color:
                        isLight ? AppColors.lightText1 : AppColors.darkText1,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFE3FA),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  '$daysInMonth يوم',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7A4FCF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // أيام الأسبوع
          Row(
            children: _weekdayLabels
                .map((d) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          d,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isLight
                                ? AppColors.lightText3
                                : AppColors.darkText3,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          _CalendarGrid(
            isLight: isLight,
            daysInMonth: daysInMonth,
            highlighted: highlighted,
          ),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.isLight,
    required this.daysInMonth,
    required this.highlighted,
  });
  final bool isLight;
  final int daysInMonth;
  final Set<int> highlighted;

  @override
  Widget build(BuildContext context) {
    // 5 صفوف لتغطية 31 يوم (مارس 2026 يبدأ من الأحد للتبسيط، مطابق للـ mockup).
    // count + activityMap = mock values matching mockup numbers.
    final activity = <int, int>{
      1: 5,
      2: 7,
      4: 5,
      5: 2,
      6: 6,
      7: 7,
      9: 17, // highlighted
      11: 26, // highlighted
      12: 12,
      13: 13,
      15: 14,
      16: 5,
      17: 9, // highlighted
      18: 4,
      19: 20,
      20: 21,
      22: 3,
      23: 4,
      24: 24, // highlighted
      25: 25,
      26: 11, // highlighted
      27: 5,
      28: 8,
    };

    // 6 أسطر بطول 7 = 42 cell. أول 31 منهن تمثل أيام مارس.
    final rows = <Widget>[];
    for (var week = 0; week < 5; week++) {
      final cells = <Widget>[];
      for (var dow = 0; dow < 7; dow++) {
        final day = week * 7 + dow + 1;
        if (day > daysInMonth) {
          cells.add(const Expanded(child: SizedBox(height: 46)));
        } else {
          final isHi = highlighted.contains(day);
          final n = activity[day] ?? 0;
          cells.add(Expanded(
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: _DayCell(
                day: day,
                count: n,
                highlighted: isHi,
                isLight: isLight,
              ),
            ),
          ));
        }
      }
      rows.add(Row(children: cells));
    }
    return Column(children: rows);
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.count,
    required this.highlighted,
    required this.isLight,
  });
  final int day;
  final int count;
  final bool highlighted;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final hasActivity = count > 0;
    final bg = highlighted
        ? AppColors.primary
        : hasActivity
            ? (isLight ? const Color(0xFFE9ECFB) : AppColors.darkSurface)
            : Colors.transparent;
    final fgPrimary = highlighted
        ? Colors.white
        : (isLight ? AppColors.lightText1 : AppColors.darkText1);
    final fgSecondary = highlighted
        ? Colors.white.withValues(alpha: 0.8)
        : (isLight ? AppColors.lightText3 : AppColors.darkText3);

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: Text(
              '$day',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: fgSecondary,
              ),
            ),
          ),
          Text(
            hasActivity ? '$count' : '0',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: fgPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                              REUSABLE PIECES
// ══════════════════════════════════════════════════════════════════════════

class _Card extends StatelessWidget {
  const _Card({required this.isLight, required this.child});
  final bool isLight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      decoration: BoxDecoration(
        color: isLight ? AppColors.baseComponent : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: child,
    );
  }
}

class _PillChip extends StatelessWidget {
  const _PillChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = selected
        ? AppColors.primary
        : (isLight ? AppColors.baseComponent : AppColors.darkSurface);
    final fg = selected
        ? Colors.white
        : (isLight ? AppColors.lightText1 : AppColors.darkText1);
    final border = selected
        ? AppColors.primary
        : (isLight ? AppColors.lightBorder : AppColors.darkBorder);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ),
    );
  }
}
