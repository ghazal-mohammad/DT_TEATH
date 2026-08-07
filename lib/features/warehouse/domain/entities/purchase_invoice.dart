// ════════════════════════════════════════════════════════════════════════════
// purchase_invoice.dart
//
// فاتورة شراء واردة للمستودع — تقابل formatInvoice في الباك. فاتورة واحدة =
// مورّد + تاريخ + إجمالي + عدّة بنود (مواد بكمية وسعر).
// ════════════════════════════════════════════════════════════════════════════

class PurchaseInvoiceItem {
  const PurchaseInvoiceItem({
    required this.id,
    required this.materialName,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  final String id;
  final String materialName;
  final String unit;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  factory PurchaseInvoiceItem.fromJson(Map<String, dynamic> j) =>
      PurchaseInvoiceItem(
        id: '${j['id'] ?? ''}',
        materialName: (j['material'] ?? '').toString(),
        unit: (j['unit'] ?? '').toString(),
        quantity: _toInt(j['quantity']),
        unitPrice: _toDouble(j['unit_price']),
        totalPrice: _toDouble(j['total_price']),
      );

  static int _toInt(Object? v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
  static double _toDouble(Object? v) =>
      v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;
}

class PurchaseInvoice {
  const PurchaseInvoice({
    required this.id,
    required this.supplierName,
    required this.totalAmount,
    required this.items,
    this.invoiceDate,
    this.notes,
    this.createdBy,
    this.createdAt,
  });

  final String id;
  final String supplierName;
  final double totalAmount;
  final List<PurchaseInvoiceItem> items;
  final DateTime? invoiceDate;
  final String? notes;
  final String? createdBy;
  final DateTime? createdAt;

  int get itemsCount => items.length;

  factory PurchaseInvoice.fromJson(Map<String, dynamic> j) => PurchaseInvoice(
        id: '${j['id'] ?? ''}',
        supplierName: (j['supplier_name'] ?? '').toString(),
        totalAmount: PurchaseInvoiceItem._toDouble(j['total_amount']),
        invoiceDate: DateTime.tryParse('${j['invoice_date'] ?? ''}'),
        notes: (j['notes']?.toString().isEmpty ?? true)
            ? null
            : j['notes'].toString(),
        createdBy: (j['created_by']?.toString().isEmpty ?? true)
            ? null
            : j['created_by'].toString(),
        createdAt: DateTime.tryParse('${j['created_at'] ?? ''}'),
        items: (j['items'] is List)
            ? (j['items'] as List)
                .whereType<Map<dynamic, dynamic>>()
                .map((e) =>
                    PurchaseInvoiceItem.fromJson(Map<String, dynamic>.from(e)))
                .toList(growable: false)
            : const [],
      );
}
