// ════════════════════════════════════════════════════════════════════════════
// lab_reports_page.dart — شاشة تقارير المخبر (مربوطة بالباك: labManager/reports).
//
// تستخدم العرض الموحّد ReportsView (المشترك مع المستودع) — هذا الملف مجرّد
// مُحوّل: LabReport → نموذج ReportsView. المنطق في LabReportsCubit.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../../../shared/widgets/reports/reports_view.dart';
import '../../domain/entities/lab_report.dart';
import '../../domain/repositories/lab_reports_repository.dart';
import '../bloc/lab_reports_cubit.dart';
import '../bloc/lab_reports_state.dart';
import '../navigation/lab_sidebar_sections.dart';

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
            body: _mapToView(context, state),
          );
        },
      ),
    );
  }

  Widget _mapToView(BuildContext context, LabReportsState state) {
    final l10n = context.l10n;
    final cubit = context.read<LabReportsCubit>();
    final r = state.report;

    final status = switch (state.status) {
      LabReportsStatus.loading => ReportsViewStatus.loading,
      LabReportsStatus.error => ReportsViewStatus.error,
      LabReportsStatus.loaded => ReportsViewStatus.loaded,
    };

    // فترة ↔ فهرس (0=شهري 1=أسبوعي 2=يومي 3=سنوي).
    int periodIndex(ReportPeriod p) => switch (p) {
          ReportPeriod.monthly => 0,
          ReportPeriod.weekly => 1,
          ReportPeriod.daily => 2,
          ReportPeriod.yearly => 3,
        };
    ReportPeriod periodFor(int i) => switch (i) {
          1 => ReportPeriod.weekly,
          2 => ReportPeriod.daily,
          3 => ReportPeriod.yearly,
          _ => ReportPeriod.monthly,
        };

    String hrs(double h) =>
        h == h.roundToDouble() ? h.toStringAsFixed(0) : h.toStringAsFixed(1);

    final kpis = r == null
        ? const <ReportKpi>[]
        : [
            ReportKpi(
                icon: '📋',
                value: '${r.totalOrders}',
                label: l10n.labReportStatTotal,
                accent: AppColors.dashCyan),
            ReportKpi(
                icon: '✅',
                value: '${r.completedOnTime}',
                label: l10n.labReportStatCompleted,
                accent: AppColors.success),
            ReportKpi(
                icon: '⏱',
                value: '${hrs(r.avgCompletionHours)}${l10n.labReportHourSuffix}',
                label: l10n.labReportStatAvgTime,
                accent: AppColors.dashOrange),
            ReportKpi(
                icon: '🎯',
                value: '${r.onTimePercent}%',
                label: l10n.labReportStatOnTime,
                accent: AppColors.secondary),
          ];

    final byType = r == null
        ? const <ReportSegment>[]
        : [
            for (int i = 0; i < r.ordersByType.length; i++)
              ReportSegment(
                label: r.ordersByType[i].typeAr,
                percentage: r.ordersByType[i].percentage,
                count: r.ordersByType[i].count,
                color: kReportPalette[i % kReportPalette.length],
              ),
          ];

    final byDay = r == null
        ? const <ReportDay>[]
        : [for (final d in r.ordersByDay) ReportDay(label: d.dayAr, count: d.count)];

    final maxDone = (r == null || r.teamPerformance.isEmpty)
        ? 0
        : r.teamPerformance
            .map((t) => t.completedOrders)
            .reduce((a, b) => a > b ? a : b);
    final team = r == null
        ? const <ReportTeamRow>[]
        : [
            for (int i = 0; i < r.teamPerformance.length; i++)
              ReportTeamRow(
                name: r.teamPerformance[i].name,
                trailing: '${r.teamPerformance[i].completedOrders} · '
                    '${hrs(r.teamPerformance[i].averageHours)}${l10n.labReportHourSuffix}',
                fraction: maxDone == 0
                    ? 0
                    : r.teamPerformance[i].completedOrders / maxDone,
                color: kReportPalette[i % kReportPalette.length],
              ),
          ];

    return ReportsView(
      status: status,
      errorMessage: state.errorMessage,
      onRetry: cubit.load,
      selectedPeriod: periodIndex(state.period),
      onPeriodChanged: (i) => cubit.setPeriod(periodFor(i)),
      periodLabel: r?.periodLabel ?? '',
      kpis: kpis,
      ordersByType: byType,
      ordersByDay: byDay,
      teamPerformance: team, // المخبر: يعرض الأداء.
    );
  }
}
