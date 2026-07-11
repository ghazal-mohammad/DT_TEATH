// ════════════════════════════════════════════════════════════════════════════
// lab_stock_log.dart
//
// كيان سجلّ حركة مخزون (إضافة/خصم) — من GET showLabStockLogs.
// الحقول تطابق LabStockLogResource:
//   { id, type(نص عربي من الباك), quantity, reason, notes, material_name, unit,
//     created_at }.
// ملاحظة: الباك يرجّع type مترجَماً ("إضافة"/"خصم")؛ نميّز الاتجاه عبر [isAdd].
// ════════════════════════════════════════════════════════════════════════════

/// حركة واحدة على مخزون المخبر (إضافة أو خصم كمية).
class LabStockLog {
  const LabStockLog({
    required this.id,
    required this.type,
    required this.quantity,
    required this.materialName,
    this.unit = '',
    this.reason = '',
    this.notes = '',
    this.createdAt = '',
  });

  final String id;

  /// نص الاتجاه كما يرجّعه الباك ("إضافة" / "خصم").
  final String type;
  final int quantity;
  final String materialName;
  final String unit;
  final String reason;
  final String notes;
  final String createdAt;

  /// هل الحركة إضافة؟ (يميّز اللون/الأيقونة). يتحمّل نصّ عربي أو 'add' إنجليزي.
  bool get isAdd =>
      type.contains('إضاف') || type.trim().toLowerCase() == 'add';
}
