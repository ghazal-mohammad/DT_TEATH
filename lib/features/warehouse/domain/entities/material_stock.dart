// ════════════════════════════════════════════════════════════════════════════
// material_stock.dart
//
// تفاصيل مخزون مادة واحدة: بياناتها + دفعاتها + الإجمالي — يقابل استجابة
// showStockDetails/{materialId} في الباك.
// ════════════════════════════════════════════════════════════════════════════

import 'stock_batch.dart';

class MaterialStock {
  const MaterialStock({
    required this.materialId,
    required this.name,
    required this.unit,
    required this.companyName,
    required this.totalQuantity,
    required this.batches,
  });

  final String materialId;
  final String name;
  final String unit;
  final String companyName;
  final int totalQuantity;
  final List<StockBatch> batches;

  int get batchesCount => batches.length;

  factory MaterialStock.fromJson(Map<String, dynamic> j) {
    final mat = j['material'] is Map
        ? Map<String, dynamic>.from(j['material'] as Map)
        : const <String, dynamic>{};
    final rawBatches = j['batches'];
    final batches = (rawBatches is List)
        ? rawBatches
            .whereType<Map<dynamic, dynamic>>()
            .map((e) => StockBatch.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false)
        : const <StockBatch>[];
    return MaterialStock(
      materialId: '${mat['id'] ?? j['material_id'] ?? ''}',
      name: (mat['name'] ?? '').toString(),
      unit: (mat['unit'] ?? '').toString(),
      companyName: (mat['company_name'] ?? '').toString(),
      totalQuantity: _toInt(j['total_quantity']),
      batches: batches,
    );
  }

  static int _toInt(Object? v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
}

/// نوع حركة المخزون (يطابق قيم reason في الباك).
enum StockMovementReason { purchase, fulfillment, expired, adjustment, returned }

extension StockMovementReasonX on StockMovementReason {
  String get apiKey => switch (this) {
        StockMovementReason.purchase => 'purchase',
        StockMovementReason.fulfillment => 'fulfillment',
        StockMovementReason.expired => 'expired',
        StockMovementReason.adjustment => 'adjustment',
        StockMovementReason.returned => 'return',
      };
}
