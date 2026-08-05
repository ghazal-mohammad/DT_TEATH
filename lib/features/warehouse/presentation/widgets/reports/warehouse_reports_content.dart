// ════════════════════════════════════════════════════════════════════════════
// warehouse_reports_content.dart
//
// محتوى تقارير المستودع — يستخدم العرض الموحّد ReportsView (نفس تصميم المخبر)
// بلا تقييم أداء (المستودع لا أداء فنّيين فيه). البيانات **تجريبية (mock)** حتى
// تفعيل مسارات تقارير المستودع في الباك؛ عندها نستبدلها بكيوبت/repo كالمخبر.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/reports/reports_view.dart';

class WarehouseReportsContent extends StatefulWidget {
  const WarehouseReportsContent({super.key});

  @override
  State<WarehouseReportsContent> createState() =>
      _WarehouseReportsContentState();
}

class _WarehouseReportsContentState extends State<WarehouseReportsContent> {
  int _period = 0; // شهري افتراضي

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final kpis = [
      ReportKpi(
          icon: '⏱',
          value: '1.8 ${l10n.reportUnitDay}',
          label: l10n.reportStatAvgSupplyTime,
          accent: AppColors.statusWarn),
      ReportKpi(
          icon: '✅',
          value: '94%',
          label: l10n.reportStatSupplyRate,
          accent: AppColors.statusSuccess),
      ReportKpi(
          icon: '📈',
          value: '156',
          label: l10n.reportStatConsumed,
          accent: AppColors.statusProgress),
      ReportKpi(
          icon: '📦',
          value: '247',
          label: l10n.reportStatTotalMaterials,
          accent: AppColors.statusInfo),
    ];

    // الاستهلاك حسب الفئة (نِسب) — mock.
    final byCategory = [
      ReportSegment(
          label: 'مستهلكات',
          percentage: 42,
          count: 42,
          color: kReportPalette[0]),
      ReportSegment(
          label: 'مواد طبية',
          percentage: 28,
          count: 28,
          color: kReportPalette[1]),
      ReportSegment(
          label: 'أدوية', percentage: 18, count: 18, color: kReportPalette[2]),
      ReportSegment(
          label: 'معادن', percentage: 12, count: 12, color: kReportPalette[3]),
    ];

    // النشاط الأسبوعي — mock.
    final byDay = [
      ReportDay(label: l10n.daySaturday, count: 12),
      ReportDay(label: l10n.daySunday, count: 18),
      ReportDay(label: l10n.dayMonday, count: 9),
      ReportDay(label: l10n.dayTuesday, count: 22),
      ReportDay(label: l10n.dayWednesday, count: 15),
      ReportDay(label: l10n.dayThursday, count: 20),
      ReportDay(label: l10n.dayFriday, count: 4),
    ];

    return ReportsView(
      status: ReportsViewStatus.loaded,
      selectedPeriod: _period,
      onPeriodChanged: (i) => setState(() => _period = i),
      onRetry: () {},
      periodLabel: l10n.whReportMockNote,
      kpis: kpis,
      ordersByType: byCategory,
      ordersByDay: byDay,
      teamPerformance: null, // المستودع: بلا تقييم أداء.
      byTypeTitle: l10n.whReportByCategory,
      byTypeUnit: '%',
      byDayTitle: l10n.whReportActivityByDay,
    );
  }
}
