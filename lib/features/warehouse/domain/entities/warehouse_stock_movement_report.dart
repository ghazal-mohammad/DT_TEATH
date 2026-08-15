// ════════════════════════════════════════════════════════════════════════════
// warehouse_stock_movement_report.dart
//
// تقرير حركة المخزون — يقابل ReportController::stockMovement (الباك، قُرئ
// الكونترولر مباشرة 2026-08-15). كان بلا مستهلك بالفرونت (بيانات تجريبية محلية
// فقط) قبل هالمراجعة.
// ════════════════════════════════════════════════════════════════════════════

/// سطر حركة واحد (formatLog بالباك: id, material, quantity, reason, date).
class StockMovementLogItem {
  const StockMovementLogItem({
    required this.id,
    required this.materialName,
    required this.quantity,
    this.reason,
    this.date,
  });

  final String id;
  final String materialName;
  final int quantity;
  final String? reason;
  final DateTime? date;

  factory StockMovementLogItem.fromJson(Map<String, dynamic> j) =>
      StockMovementLogItem(
        id: '${j['id'] ?? ''}',
        materialName: (j['material'] ?? '').toString(),
        quantity: _toInt(j['quantity']),
        reason: (j['reason']?.toString().isEmpty ?? true)
            ? null
            : j['reason'].toString(),
        date: j['date'] == null ? null : DateTime.tryParse(j['date'].toString()),
      );

  static int _toInt(Object? v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
}

class WarehouseStockMovementReport {
  const WarehouseStockMovementReport({
    required this.totalIncoming,
    required this.totalOutgoing,
    required this.totalMovements,
    required this.incoming,
    required this.outgoing,
  });

  final double totalIncoming;
  final double totalOutgoing;
  final int totalMovements;
  final List<StockMovementLogItem> incoming;
  final List<StockMovementLogItem> outgoing;

  factory WarehouseStockMovementReport.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final summary = data['summary'] is Map
        ? Map<String, dynamic>.from(data['summary'] as Map)
        : const <String, dynamic>{};
    return WarehouseStockMovementReport(
      totalIncoming: _toDouble(summary['total_incoming']),
      totalOutgoing: _toDouble(summary['total_outgoing']),
      totalMovements: _toInt(summary['total_movements']),
      incoming: _items(data['incoming']),
      outgoing: _items(data['outgoing']),
    );
  }

  static List<StockMovementLogItem> _items(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) =>
            StockMovementLogItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  static int _toInt(Object? v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
  static double _toDouble(Object? v) =>
      v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;
}
