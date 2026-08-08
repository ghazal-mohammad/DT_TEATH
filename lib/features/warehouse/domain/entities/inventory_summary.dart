// ════════════════════════════════════════════════════════════════════════════
// inventory_summary.dart
//
// ملخّص مؤشّرات المخزون للوحة المستودع — يجمع 3 قوائم من الباك (2026-08-08):
//   mostRequestedMaterials · expiringSoonMaterials · lowStockMaterials.
// لا يوفّر الباك بعد الآن "إجمالي عدد المواد" ولا "القيمة الإجمالية للمخزون" —
// حُذفا من هذا الكيان (كانا من inventory/stock-levels+stock-value القديمة).
// ════════════════════════════════════════════════════════════════════════════

int _toInt(Object? v) =>
    v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;

/// مادة من قائمة "الأكثر طلباً" (mostRequestedMaterials).
class MostRequestedMaterial {
  const MostRequestedMaterial({
    required this.materialId,
    required this.name,
    required this.unit,
    required this.requestCount,
    required this.totalQuantity,
  });

  final String materialId;
  final String name;
  final String unit;
  final int requestCount;
  final int totalQuantity;

  factory MostRequestedMaterial.fromJson(Map<String, dynamic> j) =>
      MostRequestedMaterial(
        materialId: '${j['material_id'] ?? ''}',
        name: (j['name'] ?? '').toString(),
        unit: (j['unit'] ?? '').toString(),
        requestCount: _toInt(j['request_count']),
        totalQuantity: _toInt(j['total_quantity']),
      );
}

/// دفعة من قائمة "قريبة الانتهاء" (expiringSoonMaterials → data.batches).
class ExpiringBatch {
  const ExpiringBatch({
    required this.batchId,
    required this.materialId,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.expirationDate,
    required this.daysRemaining,
  });

  final String batchId;
  final String materialId;
  final String name;
  final String unit;
  final int quantity;
  final DateTime? expirationDate;
  final int daysRemaining;

  factory ExpiringBatch.fromJson(Map<String, dynamic> j) => ExpiringBatch(
        batchId: '${j['batch_id'] ?? ''}',
        materialId: '${j['material_id'] ?? ''}',
        name: (j['name'] ?? '').toString(),
        unit: (j['unit'] ?? '').toString(),
        quantity: _toInt(j['quantity']),
        expirationDate: DateTime.tryParse('${j['expiration_date'] ?? ''}'),
        daysRemaining: _toInt(j['days_remaining']),
      );
}

/// مادة من قائمة "منخفضة المخزون" (lowStockMaterials → data.items).
class LowStockMaterial {
  const LowStockMaterial({
    required this.materialId,
    required this.name,
    required this.unit,
    required this.totalQuantity,
    required this.isOut,
  });

  final String materialId;
  final String name;
  final String unit;
  final int totalQuantity;
  final bool isOut;

  factory LowStockMaterial.fromJson(Map<String, dynamic> j) =>
      LowStockMaterial(
        materialId: '${j['material_id'] ?? ''}',
        name: (j['name'] ?? '').toString(),
        unit: (j['unit'] ?? '').toString(),
        totalQuantity: _toInt(j['total_quantity']),
        isOut: j['is_out'] == true,
      );
}

class InventorySummary {
  const InventorySummary({
    required this.mostRequested,
    required this.expiringBatches,
    required this.lowStockItems,
  });

  final List<MostRequestedMaterial> mostRequested;
  final List<ExpiringBatch> expiringBatches;
  final List<LowStockMaterial> lowStockItems;

  int get expiringCount => expiringBatches.length;
  int get lowStockCount => lowStockItems.length;

  /// من استجابات الباك الثلاث: mostRequestedMaterials (data: [...]),
  /// expiringSoonMaterials (data.batches: [...]), lowStockMaterials (data.items: [...]).
  factory InventorySummary.from({
    required Map<String, dynamic> mostRequested,
    required Map<String, dynamic> expiringSoon,
    required Map<String, dynamic> lowStock,
  }) {
    final mostRequestedList = _listOf(mostRequested['data']);
    final expiringData = expiringSoon['data'];
    final batchesList = expiringData is Map
        ? _listOf(expiringData['batches'])
        : const <Map<String, dynamic>>[];
    final lowStockData = lowStock['data'];
    final itemsList = lowStockData is Map
        ? _listOf(lowStockData['items'])
        : const <Map<String, dynamic>>[];

    return InventorySummary(
      mostRequested:
          mostRequestedList.map(MostRequestedMaterial.fromJson).toList(),
      expiringBatches: batchesList.map(ExpiringBatch.fromJson).toList(),
      lowStockItems: itemsList.map(LowStockMaterial.fromJson).toList(),
    );
  }

  static List<Map<String, dynamic>> _listOf(Object? v) {
    if (v is! List) return const [];
    return v
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
