// ════════════════════════════════════════════════════════════════════════════
// lab_stock.dart
//
// كيان domain لمادة في مخزون المخبر الداخلي. نقي (pure Dart).
// مطابق لرد GET /api/labManager/showLabStock (تحقّق فعلي 2026-06-24):
//   { id, material_id, material(اسم), unit, quantity, is_low, expiration_date }
// ملاحظة: الباك لا يوفّر فئة/حدّ أدنى/سعر وحدة لمخزون المخبر — يكتفي بـ is_low.
// ════════════════════════════════════════════════════════════════════════════

/// حالة مخزون المادة (محسوبة من الكمية + is_low).
enum LabStockStatus { available, low, out }

/// مادة واحدة في مخزون المخبر الداخلي.
class LabStock {
  const LabStock({
    required this.id,
    required this.materialId,
    required this.material,
    required this.unit,
    required this.quantity,
    required this.isLow,
    this.expirationDate,
  });

  /// معرّف سجل المخزون (lab_stocks.id) — يُستعمل في add/subtract.
  final String id;

  /// معرّف المادة الأصل (materials.id).
  final int materialId;

  /// اسم المادة.
  final String material;

  /// وحدة القياس (كغ، قطعة، ...).
  final String unit;

  /// الكمية الحالية (قد تكون عشرية — الباك يقبل numeric).
  final double quantity;

  /// هل وصلت لحدّ التنبيه؟ (يحسبه الباك).
  final bool isLow;

  /// تاريخ انتهاء الصلاحية كنص (yyyy-MM-dd) أو null.
  final String? expirationDate;

  /// الحالة المحسوبة: نفد (0) → منخفض (is_low) → متوفّر.
  LabStockStatus get status {
    if (quantity <= 0) return LabStockStatus.out;
    if (isLow) return LabStockStatus.low;
    return LabStockStatus.available;
  }

  LabStock copyWith({
    String? id,
    int? materialId,
    String? material,
    String? unit,
    double? quantity,
    bool? isLow,
    String? expirationDate,
    bool clearExpiration = false,
  }) {
    return LabStock(
      id: id ?? this.id,
      materialId: materialId ?? this.materialId,
      material: material ?? this.material,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      isLow: isLow ?? this.isLow,
      expirationDate:
          clearExpiration ? null : (expirationDate ?? this.expirationDate),
    );
  }
}
