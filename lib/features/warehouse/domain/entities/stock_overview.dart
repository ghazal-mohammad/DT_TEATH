// ════════════════════════════════════════════════════════════════════════════
// stock_overview.dart
//
// نظرة عامة على مخزون كل المواد (WarehouseStockController::index — عقد الباك
// الفعلي، قُرئ الكونترولر مباشرة 2026-08-15) + سجل حركة المخزون
// (WarehouseStockController::logs). مختلفان عن WarehouseMaterial/MaterialStock:
// showAllStock يرجّع is_low محسوبة من الباك (threshold=10 هارد-كودد بالباك)،
// وهي الإشارة الوحيدة الحقيقية لـ"منخفض" — minStock بـ WarehouseMaterial قيمة
// UI محلية فقط لا يرسلها الباك أبداً.
// ════════════════════════════════════════════════════════════════════════════

import 'material_category.dart';

/// عنصر مادة ضمن نظرة عامة المخزون (showAllStock).
class StockOverviewItem {
  const StockOverviewItem({
    required this.materialId,
    required this.name,
    required this.companyName,
    required this.unit,
    required this.totalQuantity,
    required this.batchesCount,
    required this.isLow,
    this.nameEn,
    this.category,
    this.pricePerUnit = 0,
    this.isActive = true,
  });

  final String materialId;
  final String name;
  final String? nameEn;
  final String companyName;
  final String unit;
  final MaterialCategory? category;
  final double pricePerUnit;
  final bool isActive;
  final int totalQuantity;
  final int batchesCount;

  /// محسوبة بالباك: total_quantity <= 10 (threshold هارد-كودد بالكونترولر).
  final bool isLow;

  factory StockOverviewItem.fromJson(Map<String, dynamic> j) =>
      StockOverviewItem(
        materialId: '${j['material_id'] ?? ''}',
        name: (j['name'] ?? '').toString(),
        nameEn: (j['name_en']?.toString().isEmpty ?? true)
            ? null
            : j['name_en'].toString(),
        companyName: (j['company_name'] ?? '').toString(),
        unit: (j['unit'] ?? '').toString(),
        category: materialCategoryFromString((j['category'] ?? '').toString()),
        pricePerUnit: _toDouble(j['price_per_unit']),
        isActive: j['is_active'] != false,
        totalQuantity: _toInt(j['total_quantity']),
        batchesCount: _toInt(j['batches_count']),
        isLow: j['is_low'] == true,
      );

  static int _toInt(Object? v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
  static double _toDouble(Object? v) =>
      v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;
}

/// نوع حركة السجل (type بالباك: in|out).
enum StockLogType { stockIn, stockOut, unknown }

StockLogType _typeFromApi(String v) => switch (v.trim().toLowerCase()) {
      'in' => StockLogType.stockIn,
      'out' => StockLogType.stockOut,
      _ => StockLogType.unknown,
    };

/// سطر واحد بسجل حركة المخزون (showStockLogs).
class StockLogEntry {
  const StockLogEntry({
    required this.id,
    required this.type,
    required this.quantity,
    this.materialId,
    this.materialName,
    this.warehouseStockId,
    this.reason,
    this.notes,
    this.doneBy,
    this.createdAt,
  });

  final String id;
  final String? materialId;
  final String? materialName;
  final String? warehouseStockId;
  final StockLogType type;
  final int quantity;
  final String? reason;
  final String? notes;
  final String? doneBy;
  final DateTime? createdAt;

  factory StockLogEntry.fromJson(Map<String, dynamic> j) => StockLogEntry(
        id: '${j['id'] ?? ''}',
        materialId: _nn(j['material_id']),
        materialName: _nn(j['material_name']),
        warehouseStockId: _nn(j['warehouse_stock_id']),
        type: _typeFromApi((j['type'] ?? '').toString()),
        quantity: _toInt(j['quantity']),
        reason: _nn(j['reason']),
        notes: _nn(j['notes']),
        doneBy: _nn(j['done_by']),
        createdAt: j['created_at'] == null
            ? null
            : DateTime.tryParse(j['created_at'].toString()),
      );

  static int _toInt(Object? v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
  static String? _nn(Object? v) =>
      (v == null || v.toString().isEmpty) ? null : v.toString();
}
