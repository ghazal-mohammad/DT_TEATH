// ════════════════════════════════════════════════════════════════════════════
// lab_reports_page.dart  — Phase 5.4 ✅
//
// شاشة التقارير — مطابقة 100% لـ HTML المرجعي (pg-lr).
//
// الهيكل:
//   - Report Controls: filter chips (شهري/أسبوعي/يومي/سنوي) + month select + أزرار تصدير
//   - 4 stat cards: طلبات الفترة / مكتمل في الوقت / متوسط الوقت / نسبة الرضا
//   - تقويم الطلبات حسب التاريخ
//   - صف سفلي: Donut Chart (الطلبات حسب النوع) + أداء الفريق (progress bars)
//
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — pg-lr
// ════════════════════════════════════════════════════════════════════════════

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/forms/app_form_select.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../../../shared/widgets/primitives/app_button.dart';
import '../../../../shared/widgets/primitives/app_filter_chip.dart';
import '../navigation/lab_sidebar_sections.dart';

// ══════════════════════════════════════════════════════════════════════════
//  MOCK DATA
// ══════════════════════════════════════════════════════════════════════════

/// بيانات التقرير الشهري (مارس 2026)
class _ReportMockData {
  static const int totalOrders = 83;
  static const int completedOnTime = 79;
  static const String avgTime = '2.4h';
  static const String satisfactionRate = '96%';
  static const String periodLabel = '📅 مارس 2026 — التقرير الشهري';

  // Donut chart - الطلبات حسب النوع
  static const List<_ChartSegment> chartSegments = [
    _ChartSegment(label: 'تلبيسات', percentage: 55, count: 46, color: AppColors.statusProgress),
    _ChartSegment(label: 'جسور', percentage: 30, count: 25, color: AppColors.statusInfo),
    _ChartSegment(label: 'أخرى', percentage: 15, count: 12, color: AppColors.dashGreen),
  ];

  // أداء الفريق
  static const List<_TeamPerf> teamPerformance = [
    _TeamPerf(name: 'محمد علي', ordersCount: 34, avgTime: '2.1h', progress: 0.85, color1: AppColors.primary, color2: AppColors.statusInfo),
    _TeamPerf(name: 'سامر حسن', ordersCount: 28, avgTime: '2.6h', progress: 0.70, color1: AppColors.statusProgress, color2: Color(0xFFC084FC)),
    _TeamPerf(name: 'ليلى كريم', ordersCount: 21, avgTime: '2.8h', progress: 0.52, color1: AppColors.dashGreen, color2: Color(0xFF86EFAC)),
  ];

  // بيانات التقويم - عدد الطلبات لكل يوم
  static const List<int?> calendarData = [
    null, null, null, null, null, null, 1, // أسبوع 1
    2, 4, 3, 5, 3, 2, null,               // أسبوع 2
    null, 3, 4, 12, 5, 3, 2,              // أسبوع 3
    1, 4, 5, 3, 7, 3, null,               // أسبوع 4
    null, 3, null, null, null, null, null, // أسبوع 5
  ];
}

class _ChartSegment {
  const _ChartSegment({
    required this.label,
    required this.percentage,
    required this.count,
    required this.color,
  });
  final String label;
  final int percentage;
  final int count;
  final Color color;
}

class _TeamPerf {
  const _TeamPerf({
    required this.name,
    required this.ordersCount,
    required this.avgTime,
    required this.progress,
    required this.color1,
    required this.color2,
  });
  final String name;
  final int ordersCount;
  final String avgTime;
  final double progress;
  final Color color1;
  final Color color2;
}

// ══════════════════════════════════════════════════════════════════════════
//  PAGE
// ══════════════════════════════════════════════════════════════════════════

class LabReportsPage extends StatefulWidget {
  const LabReportsPage({super.key});

  @override
  State<LabReportsPage> createState() => _LabReportsPageState();
}

class _LabReportsPageState extends State<LabReportsPage> {
  int _filterIndex = 0; // 0=شهري 1=أسبوعي 2=يومي 3=سنوي

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppShellLayout(
      system: AppSystemType.lab,
      currentRoute: RouteNames.labReports,
      sections: LabSidebarSections.build(context),
      pageTitle: l10n.labReports,
      pageSubtitle: l10n.labTopbarSubtitle,
      userRole: l10n.roleLabManager,
      body: _LabReportsBody(
        filterIndex: _filterIndex,
        onFilterChanged: (i) => setState(() => _filterIndex = i),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  BODY
// ══════════════════════════════════════════════════════════════════════════

class _LabReportsBody extends StatelessWidget {
  const _LabReportsBody({
    required this.filterIndex,
    required this.onFilterChanged,
  });

  final int filterIndex;
  final ValueChanged<int> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. Report Controls ───────────────────────────────────────
          _buildReportControls(context, l10n, isLight),

          const SizedBox(height: AppSizes.spaceMD),

          // ── 2. Period Label ──────────────────────────────────────────
          Text(
            _ReportMockData.periodLabel,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isLight ? AppColors.lightText3 : AppColors.darkText3,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: AppSizes.spaceMD),

          // ── 3. Stat Cards ────────────────────────────────────────────
          _buildStatCards(context, l10n, isLight),

          const SizedBox(height: AppSizes.spaceLG),

          // ── 4. Calendar Card ─────────────────────────────────────────
          _buildCalendarCard(context, l10n, isLight),

          const SizedBox(height: AppSizes.spaceLG),

          // ── 5. Bottom Row: Chart + Team ──────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildChartCard(context, isLight)),
                    const SizedBox(width: AppSizes.spaceLG),
                    Expanded(child: _buildTeamCard(context, isLight)),
                  ],
                );
              }
              return Column(
                children: [
                  _buildChartCard(context, isLight),
                  const SizedBox(height: AppSizes.spaceLG),
                  _buildTeamCard(context, isLight),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  Widget _buildReportControls(
      BuildContext context, AppLocalizations l10n, bool isLight) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 650;
        final filterChips = AppFilterChipRow(
          options: [
            l10n.labReportFilterMonthly,
            l10n.labReportFilterWeekly,
            l10n.labReportFilterDaily,
            l10n.labReportFilterYearly,
          ],
          selectedIndex: filterIndex,
          onChanged: onFilterChanged,
        );

        final exportButtons = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton.primary(
              label: l10n.labReportExportPdf,
              onPressed: () {},
              size: AppButtonSize.small,
            ),
            const SizedBox(width: AppSizes.spaceSM),
            AppButton.secondary(
              label: l10n.labReportExportExcel,
              onPressed: () {},
              size: AppButtonSize.small,
            ),
            const SizedBox(width: AppSizes.spaceSM),
            AppButton.secondary(
              label: l10n.labReportSendEmail,
              onPressed: () {},
              size: AppButtonSize.small,
            ),
          ],
        );

        if (isWide) {
          return Row(
            children: [
              filterChips,
              const Spacer(),
              // Month Select
              _MonthDropdown(isLight: isLight),
              const SizedBox(width: AppSizes.spaceSM),
              exportButtons,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            filterChips,
            const SizedBox(height: AppSizes.spaceSM),
            Row(
              children: [
                _MonthDropdown(isLight: isLight),
                const Spacer(),
              ],
            ),
            const SizedBox(height: AppSizes.spaceSM),
            exportButtons,
          ],
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  Widget _buildStatCards(BuildContext context, AppLocalizations l10n, bool isLight) {
    final cards = [
      _ReportStatCard(
        icon: '📋',
        value: '${_ReportMockData.totalOrders}',
        label: l10n.labReportStatTotal,
        accentColor: AppColors.dashCyan,
        isLight: isLight,
      ),
      _ReportStatCard(
        icon: '✅',
        value: '${_ReportMockData.completedOnTime}',
        label: l10n.labReportStatCompleted,
        accentColor: AppColors.success,
        isLight: isLight,
      ),
      _ReportStatCard(
        icon: '⏱',
        value: _ReportMockData.avgTime,
        label: l10n.labReportStatAvgTime,
        accentColor: AppColors.dashOrange,
        isLight: isLight,
      ),
      _ReportStatCard(
        icon: '💎',
        value: _ReportMockData.satisfactionRate,
        label: l10n.labReportStatSatisfaction,
        accentColor: AppColors.secondary,
        isLight: isLight,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          return Row(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSizes.spaceMD),
                Expanded(child: cards[i]),
              ],
            ],
          );
        }
        return Column(
          children: [
            Row(children: [
              Expanded(child: cards[0]),
              const SizedBox(width: AppSizes.spaceMD),
              Expanded(child: cards[1]),
            ]),
            const SizedBox(height: AppSizes.spaceMD),
            Row(children: [
              Expanded(child: cards[2]),
              const SizedBox(width: AppSizes.spaceMD),
              Expanded(child: cards[3]),
            ]),
          ],
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  Widget _buildCalendarCard(
      BuildContext context, AppLocalizations l10n, bool isLight) {
    return Container(
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spaceLG, AppSizes.spaceLG,
              AppSizes.spaceLG, AppSizes.spaceMD,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('📅 الطلبات حسب التاريخ',
                    style: AppTextStyles.headlineSmall),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'تصدير ←',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      color: isLight
                          ? AppColors.lightText3
                          : AppColors.darkText3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSizes.spaceLG),
            child: _CalendarGrid(isLight: isLight),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  Widget _buildChartCard(BuildContext context, bool isLight) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMD),
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
          Text(
            'الطلبات حسب النوع',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSizes.spaceMD),
          Row(
            children: [
              // Donut SVG-like chart using CustomPaint
              SizedBox(
                width: 86,
                height: 86,
                child: CustomPaint(
                  painter: _DonutPainter(
                    segments: _ReportMockData.chartSegments,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_ReportMockData.totalOrders}',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isLight
                                ? AppColors.lightText1
                                : AppColors.darkText1,
                          ),
                        ),
                        Text(
                          'طلب',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isLight
                                ? AppColors.lightText4
                                : AppColors.darkText4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spaceLG),
              // Legend
              Expanded(
                child: Column(
                  children: _ReportMockData.chartSegments.map((seg) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: seg.color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(seg.label,
                                style: AppTextStyles.bodySmall),
                          ),
                          Text(
                            '${seg.percentage}%',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isLight
                                  ? AppColors.lightText3
                                  : AppColors.darkText3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${seg.count}',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isLight
                                  ? AppColors.lightText1
                                  : AppColors.darkText1,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  Widget _buildTeamCard(BuildContext context, bool isLight) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMD),
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
          Text(
            'أداء الفريق',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSizes.spaceMD),
          ..._ReportMockData.teamPerformance.map((t) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(t.name, style: AppTextStyles.bodyMedium),
                      Text(
                        '${t.ordersCount} · ${t.avgTime}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: t.color2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    child: Stack(
                      children: [
                        Container(
                          height: 8,
                          color: isLight
                              ? const Color(0xFFE0E0E0)
                              : Colors.white.withValues(alpha: 0.06),
                        ),
                        FractionallySizedBox(
                          widthFactor: t.progress,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [t.color1, t.color2],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  MONTH DROPDOWN
// ══════════════════════════════════════════════════════════════════════════

class _MonthDropdown extends StatefulWidget {
  const _MonthDropdown({required this.isLight});
  final bool isLight;

  @override
  State<_MonthDropdown> createState() => _MonthDropdownState();
}

class _MonthDropdownState extends State<_MonthDropdown> {
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

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({required this.isLight});
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
    final data = _ReportMockData.calendarData;
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

class _ReportStatCard extends StatelessWidget {
  const _ReportStatCard({
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

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.segments});
  final List<_ChartSegment> segments;

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
  bool shouldRepaint(_DonutPainter oldDelegate) => false;
}
