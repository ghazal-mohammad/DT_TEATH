// ════════════════════════════════════════════════════════════════════════════
// stock_batch.dart
//
// دفعة مخزون واحدة لمادة (WarehouseStock في الباك): كمية + صلاحية اختيارية.
// المخزون في نظامنا مُدار بالدفعات (FIFO حسب الصلاحية)، وإجمالي المادة = مجموع
// كمّيات دفعاتها.
// ════════════════════════════════════════════════════════════════════════════

class StockBatch {
  const StockBatch({
    required this.id,
    required this.quantity,
    this.expiryDate,
    this.isExpired = false,
    this.createdAt,
  });

  final String id;
  final int quantity;
  final DateTime? expiryDate;
  final bool isExpired;
  final DateTime? createdAt;

  /// عدد الأيام المتبقّية للصلاحية (null إن لا تاريخ).
  int? get daysUntilExpiry =>
      expiryDate?.difference(DateTime.now()).inDays;

  factory StockBatch.fromJson(Map<String, dynamic> j) => StockBatch(
        id: '${j['id'] ?? ''}',
        quantity: _toInt(j['quantity']),
        expiryDate: _toDate(j['expiration_date']),
        isExpired: j['is_expired'] == true,
        createdAt: _toDate(j['created_at']),
      );

  static int _toInt(Object? v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;

  static DateTime? _toDate(Object? v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}
