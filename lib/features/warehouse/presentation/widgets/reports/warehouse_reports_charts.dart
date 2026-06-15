// ════════════════════════════════════════════════════════════════════════════
// warehouse_reports_charts.dart
//
// الصف السفلي: مخطط الدونات + تقويم الحرارة — part of warehouse_reports_content.dart (تقسيم الصفحات العملاقة).
// ════════════════════════════════════════════════════════════════════════════

part of 'warehouse_reports_content.dart';

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
                context.l10n.reportConsumptionByCategory,
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
                      context.l10n.reportOfConsumption,
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
                          fontSize: 13,
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
                        fontSize: 13,
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
                        fontSize: 13,
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final weekdayLabels = [
      l10n.reportWeekdaySun,
      l10n.reportWeekdayMon,
      l10n.reportWeekdayTue,
      l10n.reportWeekdayWed,
      l10n.reportWeekdayThu,
      l10n.reportWeekdayFri,
      l10n.reportWeekdaySat,
    ];
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
                  l10n.reportSupplyByDays,
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
                  color: AppColors.statusProgressBg,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  l10n.reportDaysCount(daysInMonth),
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.statusProgress,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // أيام الأسبوع
          Row(
            children: weekdayLabels
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
          const SizedBox(height: 10),
          _HeatmapLegend(isLight: isLight),
        ],
      ),
    );
  }
}

/// مفتاح ألوان heatmap التقويم: أقل ▢▢▢▣ أكثر.
/// RTL: "أقل" يمين، "أكثر" يسار، المربعات بينهن من فاتح إلى navy.
class _HeatmapLegend extends StatelessWidget {
  const _HeatmapLegend({required this.isLight});
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final colors = [
      isLight ? AppColors.surfaceTintCool4 : AppColors.darkBg2,
      isLight ? AppColors.surfaceTintIndigo : AppColors.darkBg2,
      isLight ? AppColors.surfaceTintBlue : AppColors.darkSurface,
      AppColors.primary,
    ];
    return Row(
      // start في RTL = اليمين. الكلسسر يمتد لجهة اليمين تحت الكاليندر.
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          context.l10n.reportLess,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 11,
            color: isLight ? AppColors.lightText3 : AppColors.darkText3,
          ),
        ),
        const SizedBox(width: 6),
        for (final c in colors) ...[
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
                width: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 3),
        ],
        const SizedBox(width: 3),
        Text(
          context.l10n.reportMore,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 11,
            color: isLight ? AppColors.lightText3 : AppColors.darkText3,
          ),
        ),
      ],
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

  // 4 شدّات لـ heatmap: 0=أبيض/شفاف، 1=فاتح جداً، 2=متوسط، 3=navy.
  int get _level {
    if (highlighted) return 3;
    if (count == 0) return 0;
    if (count <= 5) return 1;
    if (count <= 10) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final lvl = _level;
    final bg = switch (lvl) {
      3 => AppColors.primary,
      2 => isLight ? AppColors.surfaceTintBlue : AppColors.darkSurface,
      1 => isLight ? AppColors.surfaceTintIndigo : AppColors.darkBg2,
      _ => Colors.transparent,
    };
    final isDark = lvl == 3;
    final fgPrimary = isDark
        ? Colors.white
        : (isLight ? AppColors.lightText1 : AppColors.darkText1);
    final fgSecondary = isDark
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
            count > 0 ? '$count' : '0',
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
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ),
    );
  }
}
