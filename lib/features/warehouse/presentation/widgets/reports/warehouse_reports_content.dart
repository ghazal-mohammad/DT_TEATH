// ════════════════════════════════════════════════════════════════════════════
// warehouse_reports_content.dart
//
// 3 تبويبات تقارير مستودع بنفس روح تقارير المخبر (ReportsView الموحّد):
//   • المشتريات — **مربوط بالباك فعلاً** (purchase-invoices، مؤكَّد شغّال).
//   • حركة المخزون / طلبات المواد — الباك ما أكّد بعد جهوزية هالـ2 endpoints
//     (stock-movement/material-requests موجودان بالكود بس مو موثَّقين
//     بالكولكشن المرجعي) — فهاي التبويبات بـ**بيانات تجريبية محلية فقط**
//     (whReportMockNote) لتوضيح الشكل المطلوب للباك، بلا أي نداء شبكة. لا
//     تُربط فعلياً إلا بعد تأكيد الـ endpoints.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/primitives/app_segmented_tabs.dart';
import '../../../../../shared/widgets/reports/reports_view.dart';
import '../../bloc/warehouse_reports_cubit.dart';
import '../../../domain/entities/warehouse_purchases_report.dart';

enum _ReportTab { purchases, stockMovement, materialRequests }

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
            _ReportTab.purchases => l10n.whReportTypePurchases,
            _ReportTab.stockMovement => l10n.whReportTypeStockMovement,
            _ReportTab.materialRequests => l10n.whReportTypeMaterialRequests,
          },
          onChanged: (t) => setState(() => _tab = t),
        ),
        const SizedBox(height: 12),
        switch (_tab) {
          _ReportTab.purchases => const _PurchasesReportTab(),
          _ReportTab.stockMovement => _MockNoticeWrap(
              child: _StockMovementMockTab(sample: _stockMovementSample()),
            ),
          _ReportTab.materialRequests => _MockNoticeWrap(
              child:
                  _MaterialRequestsMockTab(sample: _materialRequestsSample()),
            ),
        },
      ],
    );
  }
}

/// شارة "بيانات تجريبية" فوق التبويبات غير المربوطة بعد.
class _MockNoticeWrap extends StatelessWidget {
  const _MockNoticeWrap({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.statusWarn.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            border:
                Border.all(color: AppColors.statusWarn.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 15, color: AppColors.statusWarn),
              const SizedBox(width: 6),
              Expanded(
                child: Text(context.l10n.whReportMockNote,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.statusWarn)),
              ),
            ],
          ),
        ),
        child,
      ],
    );
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

// ── تبويب حركة المخزون — بيانات تجريبية ──────────────────────────────────

class _StockMovementSample {
  const _StockMovementSample({
    required this.incoming,
    required this.outgoing,
    required this.movements,
    required this.byDay,
  });
  final int incoming;
  final int outgoing;
  final int movements;
  final List<ReportDay> byDay;
}

_StockMovementSample _stockMovementSample() => const _StockMovementSample(
      incoming: 1240,
      outgoing: 860,
      movements: 47,
      byDay: [
        ReportDay(label: '٠٤-٠٨', count: 120),
        ReportDay(label: '٠٥-٠٨', count: 260),
        ReportDay(label: '٠٦-٠٨', count: 180),
        ReportDay(label: '٠٧-٠٨', count: 310),
        ReportDay(label: '٠٨-٠٨', count: 90),
        ReportDay(label: '٠٩-٠٨', count: 140),
      ],
    );

class _StockMovementMockTab extends StatelessWidget {
  const _StockMovementMockTab({required this.sample});
  final _StockMovementSample sample;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = sample.incoming + sample.outgoing;
    return ReportsView(
      status: ReportsViewStatus.loaded,
      selectedPeriod: 0,
      onPeriodChanged: (_) {},
      onRetry: () {},
      periodLabel: l10n.whReportStockMovementTitle,
      exportTitle: l10n.whReportStockMovementTitle,
      kpis: [
        ReportKpi(
            icon: '📥',
            value: _compact(sample.incoming),
            label: l10n.whReportStatIncoming,
            accent: AppColors.statusSuccess),
        ReportKpi(
            icon: '📤',
            value: _compact(sample.outgoing),
            label: l10n.whReportStatOutgoing,
            accent: AppColors.statusUrgent),
        ReportKpi(
            icon: '🔄',
            value: sample.movements.toString(),
            label: l10n.whReportStatMovements,
            accent: AppColors.statusInfo),
      ],
      ordersByType: total == 0
          ? const []
          : [
              ReportSegment(
                label: l10n.whReportIncoming,
                percentage: (sample.incoming / total * 100).round(),
                count: sample.incoming,
                color: AppColors.statusSuccess,
              ),
              ReportSegment(
                label: l10n.whReportOutgoing,
                percentage: (sample.outgoing / total * 100).round(),
                count: sample.outgoing,
                color: AppColors.statusUrgent,
              ),
            ],
      ordersByDay: sample.byDay,
      teamPerformance: null,
      byTypeTitle: l10n.whReportIncomingVsOutgoing,
      byDayTitle: l10n.whReportMovementsByDay,
    );
  }
}

// ── تبويب طلبات المواد — بيانات تجريبية ──────────────────────────────────

class _MaterialRequestsSample {
  const _MaterialRequestsSample({
    required this.total,
    required this.fulfilled,
    required this.rejected,
    required this.fulfillmentRate,
    required this.byRequester,
    required this.byDay,
  });
  final int total;
  final int fulfilled;
  final int rejected;
  final String fulfillmentRate;
  final List<ReportSegment> byRequester;
  final List<ReportDay> byDay;
}

_MaterialRequestsSample _materialRequestsSample() =>
    const _MaterialRequestsSample(
      total: 32,
      fulfilled: 24,
      rejected: 3,
      fulfillmentRate: '75%',
      byRequester: [
        ReportSegment(
            label: 'مخبر الأسنان',
            percentage: 56,
            count: 18,
            color: AppColors.dashCyan),
        ReportSegment(
            label: 'عيادة د. سامر',
            percentage: 28,
            count: 9,
            color: AppColors.secondary),
        ReportSegment(
            label: 'عيادة د. لين',
            percentage: 16,
            count: 5,
            color: AppColors.dashOrange),
      ],
      byDay: [
        ReportDay(label: '٠٤-٠٨', count: 5),
        ReportDay(label: '٠٥-٠٨', count: 8),
        ReportDay(label: '٠٦-٠٨', count: 3),
        ReportDay(label: '٠٧-٠٨', count: 7),
        ReportDay(label: '٠٨-٠٨', count: 4),
        ReportDay(label: '٠٩-٠٨', count: 5),
      ],
    );

class _MaterialRequestsMockTab extends StatelessWidget {
  const _MaterialRequestsMockTab({required this.sample});
  final _MaterialRequestsSample sample;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ReportsView(
      status: ReportsViewStatus.loaded,
      selectedPeriod: 0,
      onPeriodChanged: (_) {},
      onRetry: () {},
      periodLabel: l10n.whReportMaterialRequestsTitle,
      exportTitle: l10n.whReportMaterialRequestsTitle,
      kpis: [
        ReportKpi(
            icon: '📋',
            value: sample.total.toString(),
            label: l10n.whReportStatTotalRequests,
            accent: AppColors.statusInfo),
        ReportKpi(
            icon: '✅',
            value: sample.fulfilled.toString(),
            label: l10n.whReportStatFulfilled,
            accent: AppColors.statusSuccess),
        ReportKpi(
            icon: '❌',
            value: sample.rejected.toString(),
            label: l10n.whReportStatRejected,
            accent: AppColors.statusUrgent),
        ReportKpi(
            icon: '📈',
            value: sample.fulfillmentRate,
            label: l10n.whReportStatFulfillmentRate,
            accent: AppColors.statusProgress),
      ],
      ordersByType: sample.byRequester,
      ordersByDay: sample.byDay,
      teamPerformance: null,
      byTypeTitle: l10n.whReportByRequester,
      byDayTitle: l10n.whReportRequestsByDay,
    );
  }
}
