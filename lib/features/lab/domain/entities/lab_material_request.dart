// ════════════════════════════════════════════════════════════════════════════
// lab_material_request.dart
//
// كيان domain لطلب مادة من المستودع (منظور المخبر) + حالته. نقي (pure Dart).
// نُقل من presentation ضمن بناء طبقة domain؛ يُعاد تصديره من
// lab_mat_request_data.dart كي تبقى الملفات القديمة تعمل دون تعديل.
// ════════════════════════════════════════════════════════════════════════════

enum MatRequestStatus { newRequest, delivered, unavailable }

/// طلب مادة واحد أرسله المخبر للمستودع.
class MatRequest {
  const MatRequest({
    required this.id,
    required this.material,
    required this.quantity,
    required this.unit,
    required this.requestedBy,
    required this.date,
    required this.status,
    this.labOrderId,
    this.note,
    this.company,
    this.reason,
  });
  final String id;
  final String material;
  final String quantity;
  final String unit;
  final String requestedBy;
  final String date;
  final MatRequestStatus status;
  final String? labOrderId;
  final String? note;

  /// اسم الشركة المصنّعة (للمواد الجديدة غير الموجودة بالمستودع).
  final String? company;

  /// سبب الطلب — يُعرض للمستودع ليعرف ليش المخبر طالب المادة.
  final String? reason;
}
