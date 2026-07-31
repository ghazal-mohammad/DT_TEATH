// ════════════════════════════════════════════════════════════════════════════
// lab_reports_page.dart  — شاشة التقارير التحليلية للمخبر.
//
// مربوطة بالباك: GET labManager/reports (period=daily|weekly|monthly|yearly)
// عبر LabReportsCubit → LabReportsRepository. تعرض:
//   - أزرار الفترة (شهري/أسبوعي/يومي/سنوي) + تصدير (واجهة).
//   - 4 بطاقات KPI: طلبات الفترة / مكتمل في الوقت / متوسط الوقت / نسبة الإنجاز.
//   - الطلبات حسب اليوم (أعمدة أسبوعية من orders_by_day).
//   - Donut (الطلبات حسب النوع) + أداء الفريق (progress bars).
//
// الودجات المستقلة في widgets/reports/lab_report_widgets.dart.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../../../shared/widgets/loading/app_shimmer_card.dart';
import '../../../../shared/widgets/primitives/app_button.dart';
import '../../../../shared/widgets/primitives/app_filter_chip.dart';
import '../../data/mock/lab_reports_mock_data.dart' show LabChartSegment;
import '../../domain/entities/lab_report.dart';
import '../../domain/repositories/lab_reports_repository.dart';
import '../bloc/lab_reports_cubit.dart';
import '../bloc/lab_reports_state.dart';
import '../navigation/lab_sidebar_sections.dart';
import '../widgets/reports/lab_report_widgets.dart';

// ألوان تُوزَّع على شرائح النوع/الفريق (ثابتة، تحترم هوية النظام).
const List<Color> _kTypeColors = [
  AppColors.dashCyan,
  AppColors.secondary,
  AppColors.dashOrange,
  AppColors.success,
  AppColors.brand,
  AppColors.statusInfo,
];

// ══════════════════════════════════════════════════════════════════════════
//  PAGE
// ══════════════════════════════════════════════════════════════════════════

class LabReportsPage extends StatelessWidget {
  const LabReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider(
      create: (_) =>
          LabReportsCubit(repository: sl<LabReportsRepository>())..load(),
      child: BlocBuilder<LabReportsCubit, LabReportsState>(
        builder: (context, state) {
          return AppShellLayout(
            system: AppSystemType.lab,
            currentRoute: RouteNames.labReports,
            sections: LabSidebarSections.build(context),
            pageTitle: l10n.labReports,
            pageSubtitle: l10n.labTopbarSubtitle,
            userRole: l10n.roleLabManager,
            body: _LabReportsBody(state: state),
          );
        },
      ),
    );
  }
}

int _indexForPeriod(ReportPeriod p) => switch (p) {
      ReportPeriod.monthly => 0,
      ReportPeriod.weekly => 1,
      ReportPeriod.daily => 2,
      ReportPeriod.yearly => 3,
    };

ReportPeriod _periodForIndex(int i) => switch (i) {
      1 => ReportPeriod.weekly,
      2 => ReportPeriod.daily,
      3 => ReportPeriod.yearly,
      _ => ReportPeriod.monthly,
    };

// ══════════════════════════════════════════════════════════════════════════
//  BODY
// ══════════════════════════════════════════════════════════════════════════

class _LabReportsBody extends StatelessWidget {
  const _LabReportsBody({required this.state});

  final LabReportsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final report = state.report;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildReportControls(context, l10n, isLight),
          const SizedBox(height: AppSizes.spaceMD),

          if (state.status == LabReportsStatus.loading || report == null)
            _buildLoadingOrError(context, l10n, isLight)
          else ...[
            Text(
              report.periodLabel,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isLight ? AppColors.lightText3 : AppColors.darkText3,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSizes.spaceMD),
            _buildStatCards(context, l10n, isLight, report),
            const SizedBox(height: AppSizes.spaceLG),
            _buildDayCard(context, isLight, report),
            const SizedBox(height: AppSizes.spaceLG),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                final chart = _buildChartCard(context, isLight, report);
                final team = _buildTeamCard(context, isLight, report);
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: chart),
                      const SizedBox(width: AppSizes.spaceLG),
                      Expanded(child: team),
                    ],
                  );
                }
                return Column(children: [
                  chart,
                  const SizedBox(height: AppSizes.spaceLG),
                  team,
                ]);
              },
            ),
          ],
        ],
      ),
    );
  }

  // ── حالات التحميل/الخطأ ─────────────────────────────────────────────────
  Widget _buildLoadingOrError(
      BuildContext context, AppLocalizations l10n, bool isLight) {
    if (state.status == LabReportsStatus.error) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.space2XL),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 40, color: AppColors.error),
            const SizedBox(height: AppSizes.spaceMD),
            Text(state.errorMessage ?? l10n.error,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSizes.spaceMD),
            AppButton.secondary(
              label: l10n.retry,
              onPressed: () => context.read<LabReportsCubit>().load(),
              size: AppButtonSize.small,
            ),
          ],
        ),
      );
    }
    // تحميل: هياكل عظمية للبطاقات.
    return const Column(
      children: [
        Row(children: [
          Expanded(child: AppShimmerCard(height: 96)),
          SizedBox(width: AppSizes.spaceMD),
          Expanded(child: AppShimmerCard(height: 96)),
          SizedBox(width: AppSizes.spaceMD),
          Expanded(child: AppShimmerCard(height: 96)),
          SizedBox(width: AppSizes.spaceMD),
          Expanded(child: AppShimmerCard(height: 96)),
        ]),
        SizedBox(height: AppSizes.spaceLG),
        AppShimmerCard(height: 180),
        SizedBox(height: AppSizes.spaceLG),
        AppShimmerCard(height: 220),
      ],
    );
  }

  // ── أزرار الفترة + التصدير ───────────────────────────────────────────────
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
          selectedIndex: _indexForPeriod(state.period),
          onChanged: (i) =>
              context.read<LabReportsCubit>().setPeriod(_periodForIndex(i)),
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
            children: [filterChips, const Spacer(), exportButtons],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            filterChips,
            const SizedBox(height: AppSizes.spaceSM),
            exportButtons,
          ],
        );
      },
    );
  }

  // ── بطاقات KPI ───────────────────────────────────────────────────────────
  Widget _buildStatCards(BuildContext context, AppLocalizations l10n,
      bool isLight, LabReport r) {
    final cards = [
      LabReportStatCard(
        icon: '📋',
        value: '${r.totalOrders}',
        label: l10n.labReportStatTotal,
        accentColor: AppColors.dashCyan,
        isLight: isLight,
      ),
      LabReportStatCard(
        icon: '✅',
        value: '${r.completedOnTime}',
        label: l10n.labReportStatCompleted,
        accentColor: AppColors.success,
        isLight: isLight,
      ),
      LabReportStatCard(
        icon: '⏱',
        value: '${_fmtHours(r.avgCompletionHours)}${l10n.labReportHourSuffix}',
        label: l10n.labReportStatAvgTime,
        accentColor: AppColors.dashOrange,
        isLight: isLight,
      ),
      LabReportStatCard(
        icon: '🎯',
        value: '${r.onTimePercent}%',
        label: l10n.labReportStatOnTime,
        accentColor: AppColors.secondary,
        isLight: isLight,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          return Row(children: [
            for (int i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSizes.spaceMD),
              Expanded(child: cards[i]),
            ],
          ]);
        }
        return Column(children: [
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
        ]);
      },
    );
  }

  // ── الطلبات حسب اليوم (أعمدة أسبوعية من orders_by_day) ────────────────────
  Widget _buildDayCard(BuildContext context, bool isLight, LabReport r) {
    final days = r.ordersByDay;
    final maxCount =
        days.isEmpty ? 0 : days.map((d) => d.count).reduce((a, b) => a > b ? a : b);
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
          Text(context.l10n.labReportOrdersByDay,
              style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppSizes.spaceLG),
          if (days.isEmpty)
            Text(context.l10n.labReportNoData,
                style: AppTextStyles.bodySmall.copyWith(
                    color:
                        isLight ? AppColors.lightText4 : AppColors.darkText4))
          else
            SizedBox(
              height: 130,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final d in days)
                    Expanded(
                      child: _DayBar(
                        dayAr: d.dayAr,
                        count: d.count,
                        maxCount: maxCount,
                        isLight: isLight,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Donut: الطلبات حسب النوع ──────────────────────────────────────────────
  Widget _buildChartCard(BuildContext context, bool isLight, LabReport r) {
    final segments = <LabChartSegment>[
      for (int i = 0; i < r.ordersByType.length; i++)
        LabChartSegment(
          label: r.ordersByType[i].typeAr,
          percentage: r.ordersByType[i].percentage,
          count: r.ordersByType[i].count,
          color: _kTypeColors[i % _kTypeColors.length],
        ),
    ];
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
          Text(context.l10n.labReportOrdersByType,
              style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppSizes.spaceMD),
          if (segments.isEmpty)
            Text(context.l10n.labReportNoData,
                style: AppTextStyles.bodySmall.copyWith(
                    color:
                        isLight ? AppColors.lightText4 : AppColors.darkText4))
          else
            Row(
              children: [
                SizedBox(
                  width: 86,
                  height: 86,
                  child: CustomPaint(
                    painter: LabReportDonutPainter(segments: segments),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${r.totalOrders}',
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isLight
                                    ? AppColors.lightText1
                                    : AppColors.darkText1,
                              )),
                          Text(context.l10n.ordersUnit,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isLight
                                    ? AppColors.lightText4
                                    : AppColors.darkText4,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spaceLG),
                Expanded(
                  child: Column(
                    children: segments.map((seg) {
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
                            Text('${seg.percentage}%',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isLight
                                      ? AppColors.lightText3
                                      : AppColors.darkText3,
                                )),
                            const SizedBox(width: 8),
                            Text('${seg.count}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isLight
                                      ? AppColors.lightText1
                                      : AppColors.darkText1,
                                )),
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

  // ── أداء الفريق (progress bars من team_performance) ──────────────────────
  Widget _buildTeamCard(BuildContext context, bool isLight, LabReport r) {
    final team = r.teamPerformance;
    final maxCompleted = team.isEmpty
        ? 0
        : team.map((t) => t.completedOrders).reduce((a, b) => a > b ? a : b);
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
          Text(context.l10n.labReportTeamPerf,
              style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppSizes.spaceMD),
          if (team.isEmpty)
            Text(context.l10n.labReportNoData,
                style: AppTextStyles.bodySmall.copyWith(
                    color:
                        isLight ? AppColors.lightText4 : AppColors.darkText4))
          else
            for (int i = 0; i < team.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.spaceMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(team[i].name, style: AppTextStyles.bodyMedium),
                        Text(
                          '${team[i].completedOrders} · '
                          '${_fmtHours(team[i].averageHours)}${context.l10n.labReportHourSuffix}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: _kTypeColors[i % _kTypeColors.length],
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
                                ? AppColors.dividerNeutral
                                : Colors.white.withValues(alpha: 0.06),
                          ),
                          FractionallySizedBox(
                            widthFactor: maxCompleted == 0
                                ? 0
                                : team[i].completedOrders / maxCompleted,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: _kTypeColors[i % _kTypeColors.length],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  /// يعرض الساعات بلا كسر زائد (2.0 → "2"، 2.4 → "2.4").
  static String _fmtHours(double h) =>
      h == h.roundToDouble() ? h.toStringAsFixed(0) : h.toStringAsFixed(1);
}

// ══════════════════════════════════════════════════════════════════════════
//  عمود يوم واحد في مخطّط الأسبوع
// ══════════════════════════════════════════════════════════════════════════

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.dayAr,
    required this.count,
    required this.maxCount,
    required this.isLight,
  });

  final String dayAr;
  final int count;
  final int maxCount;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final double factor = maxCount == 0 ? 0 : count / maxCount;
    final Color accent = isLight ? AppColors.primary : AppColors.brand;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('$count',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w800,
                color: isLight ? AppColors.lightText1 : AppColors.darkText1,
              )),
          const SizedBox(height: 4),
          Expanded(
            child: FractionallySizedBox(
              heightFactor: factor.clamp(0.02, 1.0),
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: count == 0 ? 0.15 : 0.85),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(dayAr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: isLight ? AppColors.lightText3 : AppColors.darkText3,
              )),
        ],
      ),
    );
  }
}
