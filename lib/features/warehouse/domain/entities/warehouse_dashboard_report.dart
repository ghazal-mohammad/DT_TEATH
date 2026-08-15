// ════════════════════════════════════════════════════════════════════════════
// warehouse_dashboard_report.dart
//
// تقرير التحليلات العام — يقابل ReportController::dashboard (buildReport)
// الفعلي (قُرئ الكونترولر مباشرة 2026-08-15). كان endpoint جاهزاً بالكامل
// بالباك (استهلاك حسب الفئة، أكثر الشركات توريداً، أكثر المواد استهلاكاً)
// بلا أي مستهلك بالفرونت قبل هالمراجعة.
//
// لا نموذج لـ calendar (خريطة استهلاك يومية) هنا عمداً — summary_bars يغطّي
// نفس مفهوم "الأيام الأنشط" بشكل كافٍ للعرض الحالي (ReportsView الموحّد لا
// يدعم خريطة تقويم مخصّصة، وبناء ويدجت جديدة له خارج نطاق هالربط).
// ════════════════════════════════════════════════════════════════════════════

class CategoryConsumptionItem {
  const CategoryConsumptionItem({
    required this.category,
    required this.label,
    required this.quantity,
    required this.percentage,
  });

  final String category;
  final String label;
  final int quantity;
  final double percentage;

  factory CategoryConsumptionItem.fromJson(Map<String, dynamic> j) =>
      CategoryConsumptionItem(
        category: (j['category'] ?? '').toString(),
        label: (j['label'] ?? '').toString(),
        quantity: _toInt(j['quantity']),
        percentage: _toDouble(j['percentage']),
      );

  static int _toInt(Object? v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
  static double _toDouble(Object? v) =>
      v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;
}

class ConsumptionByCategory {
  const ConsumptionByCategory({required this.items});

  final List<CategoryConsumptionItem> items;

  static const empty = ConsumptionByCategory(items: []);

  factory ConsumptionByCategory.fromJson(Map<String, dynamic> j) {
    final raw = j['items'];
    if (raw is! List) return empty;
    return ConsumptionByCategory(
      items: raw
          .whereType<Map<dynamic, dynamic>>()
          .map((e) =>
              CategoryConsumptionItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false),
    );
  }
}

class CompanyPerformance {
  const CompanyPerformance({
    required this.rank,
    required this.companyName,
    required this.invoiceCount,
    required this.totalSpending,
  });

  final int rank;
  final String companyName;
  final int invoiceCount;
  final double totalSpending;

  factory CompanyPerformance.fromJson(Map<String, dynamic> j) =>
      CompanyPerformance(
        rank: _toInt(j['rank']),
        companyName: (j['company_name'] ?? '—').toString(),
        invoiceCount: _toInt(j['invoice_count']),
        totalSpending: _toDouble(j['total_spending']),
      );

  static int _toInt(Object? v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
  static double _toDouble(Object? v) =>
      v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;
}

class MostConsumedMaterial {
  const MostConsumedMaterial({
    required this.materialId,
    required this.name,
    required this.totalConsumed,
    this.companyName,
    this.category,
    this.categoryLabel,
    this.unit,
  });

  final String materialId;
  final String name;
  final String? companyName;
  final String? category;
  final String? categoryLabel;
  final String? unit;
  final int totalConsumed;

  factory MostConsumedMaterial.fromJson(Map<String, dynamic> j) =>
      MostConsumedMaterial(
        materialId: '${j['material_id'] ?? ''}',
        name: (j['name'] ?? '—').toString(),
        companyName: _nn(j['company_name']),
        category: _nn(j['category']),
        categoryLabel: _nn(j['category_label']),
        unit: _nn(j['unit']),
        totalConsumed: _toInt(j['total_consumed']),
      );

  static int _toInt(Object? v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
  static String? _nn(Object? v) =>
      (v == null || v.toString().isEmpty) ? null : v.toString();
}

class SummaryBar {
  const SummaryBar({required this.label, required this.value});

  final String label;
  final int value;

  factory SummaryBar.fromJson(Map<String, dynamic> j) => SummaryBar(
        label: (j['label'] ?? '').toString(),
        value: j['value'] is num
            ? (j['value'] as num).toInt()
            : int.tryParse('${j['value'] ?? ''}') ?? 0,
      );
}

class WarehouseDashboardReport {
  const WarehouseDashboardReport({
    required this.periodType,
    required this.saved,
    required this.consumption,
    required this.companies,
    required this.mostConsumed,
    required this.summaryBars,
  });

  final String periodType;
  final bool saved;
  final ConsumptionByCategory consumption;
  final List<CompanyPerformance> companies;
  final List<MostConsumedMaterial> mostConsumed;
  final List<SummaryBar> summaryBars;

  factory WarehouseDashboardReport.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final period = data['period'] is Map
        ? Map<String, dynamic>.from(data['period'] as Map)
        : const <String, dynamic>{};
    return WarehouseDashboardReport(
      periodType: (period['type'] ?? 'month').toString(),
      saved: data['saved'] == true,
      consumption: data['consumption_by_category'] is Map
          ? ConsumptionByCategory.fromJson(
              Map<String, dynamic>.from(data['consumption_by_category'] as Map))
          : ConsumptionByCategory.empty,
      companies: _list(data['companies'])
          .map(CompanyPerformance.fromJson)
          .toList(growable: false),
      mostConsumed: _list(data['most_consumed'])
          .map(MostConsumedMaterial.fromJson)
          .toList(growable: false),
      summaryBars: _list(data['summary_bars'])
          .map(SummaryBar.fromJson)
          .toList(growable: false),
    );
  }

  static List<Map<String, dynamic>> _list(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
  }
}
