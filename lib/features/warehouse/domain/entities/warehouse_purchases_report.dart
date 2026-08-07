// ════════════════════════════════════════════════════════════════════════════
// warehouse_purchases_report.dart
//
// تقرير مشتريات المستودع — يقابل reports/purchase-invoices. يجمّع الإنفاق حسب
// المورّد وحسب الشهر مع ملخّص، ليُعرَض في ReportsView الموحّد.
// ════════════════════════════════════════════════════════════════════════════

/// إنفاق مجمَّع تحت مفتاح (مورّد أو شهر).
class ReportBucket {
  const ReportBucket({
    required this.label,
    required this.spending,
    required this.count,
  });

  final String label;
  final double spending;
  final int count;
}

class WarehousePurchasesReport {
  const WarehousePurchasesReport({
    required this.totalInvoices,
    required this.totalSpending,
    required this.bySupplier,
    required this.byMonth,
  });

  final int totalInvoices;
  final double totalSpending;
  final List<ReportBucket> bySupplier;
  final List<ReportBucket> byMonth;

  factory WarehousePurchasesReport.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final summary = data['summary'] is Map
        ? Map<String, dynamic>.from(data['summary'] as Map)
        : const <String, dynamic>{};
    return WarehousePurchasesReport(
      totalInvoices: _toInt(summary['total_invoices']),
      totalSpending: _toDouble(summary['total_spending']),
      bySupplier: _buckets(data['by_supplier'], 'supplier', 'invoice_count'),
      byMonth: _buckets(data['by_month'], 'month', 'invoice_count'),
    );
  }

  static List<ReportBucket> _buckets(
      Object? raw, String labelKey, String countKey) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .map((m) => ReportBucket(
              label: (m[labelKey] ?? '—').toString(),
              spending: _toDouble(m['total_spending']),
              count: _toInt(m[countKey]),
            ))
        .toList(growable: false);
  }

  static int _toInt(Object? v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
  static double _toDouble(Object? v) =>
      v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;
}
