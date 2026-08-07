// ════════════════════════════════════════════════════════════════════════════
// inventory_summary.dart
//
// ملخّص مؤشّرات المخزون للوحة المستودع — يجمع summary من inventory/stock-levels
// و inventory/stock-value.
// ════════════════════════════════════════════════════════════════════════════

class InventorySummary {
  const InventorySummary({
    required this.totalMaterials,
    required this.lowStockCount,
    required this.normalStockCount,
    required this.expiredBatches,
    required this.totalValue,
  });

  final int totalMaterials;
  final int lowStockCount;
  final int normalStockCount;
  final int expiredBatches;
  final double totalValue;

  /// من استجابة stock-levels ({data:{summary:{...}}}) + stock-value لقيمة الإجمالي.
  factory InventorySummary.from({
    required Map<String, dynamic> levels,
    required Map<String, dynamic> value,
  }) {
    final ls = _summaryOf(levels);
    final vs = _summaryOf(value);
    return InventorySummary(
      totalMaterials: _toInt(ls['total_materials']),
      lowStockCount: _toInt(ls['low_stock_count']),
      normalStockCount: _toInt(ls['normal_stock_count']),
      expiredBatches: _toInt(ls['expired_batches']),
      totalValue: _toDouble(vs['total_value']),
    );
  }

  static Map<String, dynamic> _summaryOf(Map<String, dynamic> resp) {
    final data = resp['data'] is Map ? resp['data'] as Map : resp;
    final summary = data['summary'];
    return summary is Map ? Map<String, dynamic>.from(summary) : {};
  }

  static int _toInt(Object? v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
  static double _toDouble(Object? v) =>
      v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;
}
