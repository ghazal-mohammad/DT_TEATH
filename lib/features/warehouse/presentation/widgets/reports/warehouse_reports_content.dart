// ════════════════════════════════════════════════════════════════════════════
// warehouse_reports_content.dart
//
// تقرير مشتريات المستودع — **مربوط بالباك** (reports/purchase-invoices) عبر
// العرض الموحّد ReportsView (نفس تصميم المخبر) بلا تقييم أداء. الفترة تُحوَّل
// لنطاق from–to في الكيوبت.
//
// ملاحظة: تقريرا حركة المخزون والطلبات متوفّران بالباك للتوسيع لاحقاً (تبويب نوع).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/reports/reports_view.dart';
import '../../bloc/warehouse_reports_cubit.dart';
import '../../../domain/entities/warehouse_purchases_report.dart';

class WarehouseReportsContent extends StatelessWidget {
  const WarehouseReportsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<WarehouseReportsCubit, WarehouseReportsState>(
      builder: (context, state) {
        final cubit = context.read<WarehouseReportsCubit>();
        final report = state.report;
        return ReportsView(
          status: _mapStatus(state.status),
          selectedPeriod: state.period,
          onPeriodChanged: cubit.changePeriod,
          onRetry: cubit.load,
          periodLabel: l10n.whReportPurchasesTitle,
          errorMessage: state.errorMessage,
          kpis: _kpis(context, report),
          ordersByType: _bySupplier(report),
          ordersByDay: _byMonth(report),
          teamPerformance: null, // المستودع: بلا تقييم أداء.
          byTypeTitle: l10n.whReportBySupplier,
          byTypeUnit: 'ل.س',
          byDayTitle: l10n.whReportByMonth,
        );
      },
    );
  }

  ReportsViewStatus _mapStatus(ReportsStatus s) => switch (s) {
        ReportsStatus.loading => ReportsViewStatus.loading,
        ReportsStatus.error => ReportsViewStatus.error,
        ReportsStatus.initial => ReportsViewStatus.loading,
        ReportsStatus.loaded => ReportsViewStatus.loaded,
      };

  List<ReportKpi> _kpis(
      BuildContext context, WarehousePurchasesReport? r) {
    final l10n = context.l10n;
    final invoices = r?.totalInvoices ?? 0;
    final spending = r?.totalSpending ?? 0;
    final avg = invoices > 0 ? spending / invoices : 0;
    final suppliers = r?.bySupplier.length ?? 0;
    return [
      ReportKpi(
          icon: '🧾',
          value: invoices.toString(),
          label: l10n.whReportStatInvoices,
          accent: AppColors.statusInfo),
      ReportKpi(
          icon: '💰',
          value: _compact(spending),
          label: l10n.whReportStatSpending,
          accent: AppColors.statusSuccess),
      ReportKpi(
          icon: '📊',
          value: _compact(avg),
          label: l10n.whReportStatAvgInvoice,
          accent: AppColors.statusProgress),
      ReportKpi(
          icon: '🏭',
          value: suppliers.toString(),
          label: l10n.whReportStatSuppliers,
          accent: AppColors.statusWarn),
    ];
  }

  List<ReportSegment> _bySupplier(WarehousePurchasesReport? r) {
    if (r == null || r.bySupplier.isEmpty) return const [];
    final total = r.totalSpending > 0 ? r.totalSpending : 1;
    final buckets = [...r.bySupplier]
      ..sort((a, b) => b.spending.compareTo(a.spending));
    return [
      for (var i = 0; i < buckets.length; i++)
        ReportSegment(
          label: buckets[i].label,
          percentage: (buckets[i].spending / total * 100).round(),
          count: buckets[i].spending.round(),
          color: kReportPalette[i % kReportPalette.length],
        ),
    ];
  }

  List<ReportDay> _byMonth(WarehousePurchasesReport? r) {
    if (r == null) return const [];
    return [
      for (final b in r.byMonth)
        ReportDay(label: b.label, count: b.spending.round()),
    ];
  }

  /// تنسيق مضغوط للمبالغ (2.8M / 12K / 247).
  static String _compact(num v) {
    if (v >= 1000000) {
      return '${(v / 1000000).toStringAsFixed(v % 1000000 == 0 ? 0 : 1)}M';
    }
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}K';
    return v.toStringAsFixed(0);
  }
}
