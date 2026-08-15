// ════════════════════════════════════════════════════════════════════════════
// warehouse_reports_content.dart
//
// 3 تبويبات تقارير مستودع بنفس روح تقارير المخبر (ReportsView الموحّد) —
// الثلاثة مربوطة بالباك فعلاً:
//   • المشتريات — purchase-invoices.
//   • حركة المخزون — stock-movement (قُرئ الكونترولر مباشرة 2026-08-15
//     لتأكيد الشكل، كان بيانات تجريبية محلية فقط قبل هيك).
//   • طلبات المواد — material-requests (نفس الشيء؛ ⚠️ باغ حقيقي موثَّق
//     بالباك: fulfilled_count/fulfillment_rate يرجعوا 0 دائماً لأن الكونترولر
//     يفلتر status=='fulfilled' غير الموجودة أصلاً بالـ enum — القيمة
//     الحقيقية 'completed'. نعرض ما يرجعه الباك بأمانة، لا "نصلحه" بالفرونت).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/primitives/app_segmented_tabs.dart';
import '../../../../../shared/widgets/reports/reports_view.dart';
import '../../bloc/warehouse_reports_cubit.dart';
import '../../../domain/entities/warehouse_dashboard_report.dart';
import '../../../domain/entities/warehouse_material_requests_report.dart';
import '../../../domain/entities/warehouse_purchases_report.dart';
import '../../../domain/entities/warehouse_stock_movement_report.dart';

enum _ReportTab { overview, purchases, stockMovement, materialRequests }

class WarehouseReportsContent extends StatefulWidget {
  const WarehouseReportsContent({super.key});

  @override
  State<WarehouseReportsContent> createState() =>
      _WarehouseReportsContentState();
}

class _WarehouseReportsContentState extends State<WarehouseReportsContent> {
  _ReportTab _tab = _ReportTab.purchases;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSegmentedTabs<_ReportTab>(
          values: _ReportTab.values,
          selected: _tab,
          labelOf: (t) => switch (t) {
            _ReportTab.overview => l10n.whReportTypeOverview,
            _ReportTab.purchases => l10n.whReportTypePurchases,
            _ReportTab.stockMovement => l10n.whReportTypeStockMovement,
            _ReportTab.materialRequests => l10n.whReportTypeMaterialRequests,
          },
          onChanged: (t) => setState(() => _tab = t),
        ),
        const SizedBox(height: 12),
        switch (_tab) {
          _ReportTab.overview => const _DashboardOverviewReportTab(),
          _ReportTab.purchases => const _PurchasesReportTab(),
          _ReportTab.stockMovement => const _StockMovementReportTab(),
          _ReportTab.materialRequests => const _MaterialRequestsReportTab(),
        },
      ],
    );
  }
}

// ── تبويب نظرة عامة — مربوط بالباك (reports/dashboard) ────────────────────
//
// الباك يقبل period=week|month فقط (لا يوافق مؤشّر ReportsView 0..3)، فلا
// يوجد تنقّل فترة تفاعلي هون — يُحمَّل مرة واحدة بـ 'month' عند فتح الصفحة.
// خريطة الاستهلاك اليومية (calendar) غير معروضة عمداً — summary_bars يغطّي
// نفس المفهوم ("الأيام الأنشط") ضمن مكوّنات ReportsView الموحّدة الحالية.

class _DashboardOverviewReportTab extends StatelessWidget {
  const _DashboardOverviewReportTab();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<WarehouseReportsCubit, WarehouseReportsState>(
      builder: (context, state) {
        final cubit = context.read<WarehouseReportsCubit>();
        final report = state.dashboardReport;
        final loading = report == null && state.dashboardError == null;
        return ReportsView(
          status: loading
              ? ReportsViewStatus.loading
              : (report == null
                  ? ReportsViewStatus.error
                  : ReportsViewStatus.loaded),
          selectedPeriod: 0,
          onPeriodChanged: (_) {},
          onRetry: cubit.loadDashboard,
          periodLabel: l10n.whReportOverviewTitle,
          exportTitle: l10n.whReportOverviewTitle,
          errorMessage: state.dashboardError,
          kpis: _kpis(l10n, report),
          ordersByType: _byCategory(report),
          ordersByDay: _byDay(report),
          teamPerformance: _companies(report),
          teamPerformanceTitle: l10n.whReportTopCompanies,
          byTypeTitle: l10n.whReportByCategory,
          byDayTitle: l10n.whReportActivityByDay,
        );
      },
    );
  }

  List<ReportKpi> _kpis(AppLocalizations l10n, WarehouseDashboardReport? r) {
    final totalConsumption =
        r?.consumption.items.fold<int>(0, (sum, e) => sum + e.quantity) ?? 0;
    final topConsumed = (r?.mostConsumed.isNotEmpty ?? false)
        ? r!.mostConsumed.first.name
        : '—';
    return [
      ReportKpi(
          icon: '📦',
          value: totalConsumption.toString(),
          label: l10n.whReportStatTotalConsumption,
          accent: AppColors.statusInfo),
      ReportKpi(
          icon: '⭐',
          value: topConsumed,
          label: l10n.whReportStatTopConsumed,
          accent: AppColors.statusProgress),
      ReportKpi(
          icon: '🏭',
          value: (r?.companies.length ?? 0).toString(),
          label: l10n.whReportStatSuppliers,
          accent: AppColors.statusWarn),
      ReportKpi(
          icon: '📅',
          value: (r?.summaryBars.length ?? 0).toString(),
          label: l10n.whReportStatActiveDays,
          accent: AppColors.statusSuccess),
    ];
  }

  List<ReportSegment> _byCategory(WarehouseDashboardReport? r) {
    final items = r?.consumption.items ?? const [];
    if (items.isEmpty) return const [];
    return [
      for (var i = 0; i < items.length; i++)
        ReportSegment(
          label: items[i].label,
          percentage: items[i].percentage.round(),
          count: items[i].quantity,
          color: kReportPalette[i % kReportPalette.length],
        ),
    ];
  }

  List<ReportDay> _byDay(WarehouseDashboardReport? r) {
    final bars = r?.summaryBars ?? const [];
    return [for (final b in bars) ReportDay(label: b.label, count: b.value)];
  }

  List<ReportTeamRow> _companies(WarehouseDashboardReport? r) {
    final companies = r?.companies ?? const [];
    if (companies.isEmpty) return const [];
    final max = companies
        .map((c) => c.totalSpending)
        .fold<double>(0, (m, v) => v > m ? v : m);
    final safeMax = max > 0 ? max : 1;
    return [
      for (var i = 0; i < companies.length; i++)
        ReportTeamRow(
          name: companies[i].companyName,
          trailing: _compact(companies[i].totalSpending),
          fraction: (companies[i].totalSpending / safeMax).clamp(0, 1),
          color: kReportPalette[i % kReportPalette.length],
        ),
    ];
  }
}

// ── تبويب المشتريات — مربوط بالباك ────────────────────────────────────────

class _PurchasesReportTab extends StatelessWidget {
  const _PurchasesReportTab();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<WarehouseReportsCubit, WarehouseReportsState>(
      builder: (context, state) {
        final cubit = context.read<WarehouseReportsCubit>();
        final report = state.report;
        return ReportsView(
          status: switch (state.status) {
            ReportsStatus.loading => ReportsViewStatus.loading,
            ReportsStatus.error => ReportsViewStatus.error,
            ReportsStatus.initial => ReportsViewStatus.loading,
            ReportsStatus.loaded => ReportsViewStatus.loaded,
          },
          selectedPeriod: state.period,
          onPeriodChanged: cubit.changePeriod,
          onRetry: cubit.load,
          periodLabel: l10n.whReportPurchasesTitle,
          exportTitle: l10n.whReportPurchasesTitle,
          errorMessage: state.errorMessage,
          kpis: _kpis(l10n, report),
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

  List<ReportKpi> _kpis(AppLocalizations l10n, WarehousePurchasesReport? r) {
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
}

String _compact(num v) {
  if (v >= 1000000) {
    return '${(v / 1000000).toStringAsFixed(v % 1000000 == 0 ? 0 : 1)}M';
  }
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}K';
  return v.toStringAsFixed(0);
}

// ── تبويب حركة المخزون — مربوط بالباك (stock-movement) ───────────────────

class _StockMovementReportTab extends StatelessWidget {
  const _StockMovementReportTab();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<WarehouseReportsCubit, WarehouseReportsState>(
      builder: (context, state) {
        final cubit = context.read<WarehouseReportsCubit>();
        final report = state.stockMovementReport;
        final loading = report == null && state.stockMovementError == null;
        return ReportsView(
          status: loading
              ? ReportsViewStatus.loading
              : (report == null
                  ? ReportsViewStatus.error
                  : ReportsViewStatus.loaded),
          selectedPeriod: state.period,
          onPeriodChanged: (p) {
            cubit.changePeriod(p);
            cubit.loadStockMovement();
          },
          onRetry: cubit.loadStockMovement,
          periodLabel: l10n.whReportStockMovementTitle,
          exportTitle: l10n.whReportStockMovementTitle,
          errorMessage: state.stockMovementError,
          kpis: _kpis(l10n, report),
          ordersByType: _byType(l10n, report),
          ordersByDay: _byDay(report),
          teamPerformance: null,
          byTypeTitle: l10n.whReportIncomingVsOutgoing,
          byDayTitle: l10n.whReportMovementsByDay,
        );
      },
    );
  }

  List<ReportKpi> _kpis(AppLocalizations l10n, WarehouseStockMovementReport? r) {
    return [
      ReportKpi(
          icon: '📥',
          value: _compact(r?.totalIncoming ?? 0),
          label: l10n.whReportStatIncoming,
          accent: AppColors.statusSuccess),
      ReportKpi(
          icon: '📤',
          value: _compact(r?.totalOutgoing ?? 0),
          label: l10n.whReportStatOutgoing,
          accent: AppColors.statusUrgent),
      ReportKpi(
          icon: '🔄',
          value: (r?.totalMovements ?? 0).toString(),
          label: l10n.whReportStatMovements,
          accent: AppColors.statusInfo),
    ];
  }

  List<ReportSegment> _byType(
      AppLocalizations l10n, WarehouseStockMovementReport? r) {
    final inQty = r?.totalIncoming ?? 0;
    final outQty = r?.totalOutgoing ?? 0;
    final total = inQty + outQty;
    if (total <= 0) return const [];
    return [
      ReportSegment(
        label: l10n.whReportIncoming,
        percentage: (inQty / total * 100).round(),
        count: inQty.round(),
        color: AppColors.statusSuccess,
      ),
      ReportSegment(
        label: l10n.whReportOutgoing,
        percentage: (outQty / total * 100).round(),
        count: outQty.round(),
        color: AppColors.statusUrgent,
      ),
    ];
  }

  /// تجميع incoming+outgoing حسب اليوم (الباك لا يرجّع تجميعاً يومياً جاهزاً
  /// لهالتقرير — نحسبه من التواريخ الحقيقية بالسطور).
  List<ReportDay> _byDay(WarehouseStockMovementReport? r) {
    if (r == null) return const [];
    final totals = <String, int>{};
    for (final item in [...r.incoming, ...r.outgoing]) {
      final d = item.date;
      if (d == null) continue;
      final key = _dayLabel(d);
      totals[key] = (totals[key] ?? 0) + item.quantity;
    }
    final keys = totals.keys.toList()..sort();
    return [for (final k in keys) ReportDay(label: k, count: totals[k]!)];
  }
}

String _dayLabel(DateTime d) =>
    '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

// ── تبويب طلبات المواد — مربوط بالباك (material-requests) ────────────────

class _MaterialRequestsReportTab extends StatelessWidget {
  const _MaterialRequestsReportTab();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<WarehouseReportsCubit, WarehouseReportsState>(
      builder: (context, state) {
        final cubit = context.read<WarehouseReportsCubit>();
        final report = state.materialRequestsReport;
        final loading = report == null && state.materialRequestsError == null;
        return ReportsView(
          status: loading
              ? ReportsViewStatus.loading
              : (report == null
                  ? ReportsViewStatus.error
                  : ReportsViewStatus.loaded),
          selectedPeriod: state.period,
          onPeriodChanged: (p) {
            cubit.changePeriod(p);
            cubit.loadMaterialRequests();
          },
          onRetry: cubit.loadMaterialRequests,
          periodLabel: l10n.whReportMaterialRequestsTitle,
          exportTitle: l10n.whReportMaterialRequestsTitle,
          errorMessage: state.materialRequestsError,
          kpis: _kpis(l10n, report),
          ordersByType: _byRequester(report),
          ordersByDay: _byDay(report),
          teamPerformance: null,
          byTypeTitle: l10n.whReportByRequester,
          byDayTitle: l10n.whReportRequestsByDay,
        );
      },
    );
  }

  List<ReportKpi> _kpis(
      AppLocalizations l10n, WarehouseMaterialRequestsReport? r) {
    return [
      ReportKpi(
          icon: '📋',
          value: (r?.totalRequests ?? 0).toString(),
          label: l10n.whReportStatTotalRequests,
          accent: AppColors.statusInfo),
      ReportKpi(
          icon: '✅',
          value: (r?.fulfilledCount ?? 0).toString(),
          label: l10n.whReportStatFulfilled,
          accent: AppColors.statusSuccess),
      ReportKpi(
          icon: '❌',
          value: (r?.rejectedCount ?? 0).toString(),
          label: l10n.whReportStatRejected,
          accent: AppColors.statusUrgent),
      ReportKpi(
          icon: '📈',
          value: r?.fulfillmentRate ?? '0%',
          label: l10n.whReportStatFulfillmentRate,
          accent: AppColors.statusProgress),
    ];
  }

  List<ReportSegment> _byRequester(WarehouseMaterialRequestsReport? r) {
    if (r == null || r.byRequester.isEmpty) return const [];
    final total = r.totalRequests > 0 ? r.totalRequests : 1;
    final buckets = [...r.byRequester]
      ..sort((a, b) => b.totalRequests.compareTo(a.totalRequests));
    return [
      for (var i = 0; i < buckets.length; i++)
        ReportSegment(
          label: buckets[i].requester,
          percentage: (buckets[i].totalRequests / total * 100).round(),
          count: buckets[i].totalRequests,
          color: kReportPalette[i % kReportPalette.length],
        ),
    ];
  }

  /// تجميع الطلبات حسب اليوم من created_at الحقيقي (الباك لا يرجّع تجميعاً
  /// يومياً جاهزاً لهالتقرير).
  List<ReportDay> _byDay(WarehouseMaterialRequestsReport? r) {
    if (r == null) return const [];
    final counts = <String, int>{};
    for (final row in r.requests) {
      final d = row.createdAt;
      if (d == null) continue;
      final key = _dayLabel(d);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    final keys = counts.keys.toList()..sort();
    return [for (final k in keys) ReportDay(label: k, count: counts[k]!)];
  }
}
