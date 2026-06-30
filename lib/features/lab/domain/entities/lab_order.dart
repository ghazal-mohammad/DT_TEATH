// ════════════════════════════════════════════════════════════════════════════
// lab_order.dart
//
// كيانات domain لطلب المخبر: نوع الحالة (badge variant) + النموذج الكامل.
// نُقلت إلى domain ضمن بناء طبقة domain + Cubits؛ كانت سابقاً في presentation/data.
// نقي (pure Dart) — بلا أي اعتماد على Flutter.
//
// ملاحظة توافقية: lab_order_models.dart و lab_dashboard_mock_data.dart يعيدان
// تصدير هذه الرموز (export ... show) كي تبقى الملفات المستوردة القديمة تعمل
// دون تعديل.
// ════════════════════════════════════════════════════════════════════════════

/// نوع badge لطلبات المخبر.
/// "مستعجل" ليست حالة — هي خاصية يحددها الطبيب وتُعرض كشارة منفصلة (isUrgent).
enum LabOrderBadgeVariant {
  newOrder,
  manufacturing,
  ready,
  cancelled,
}

/// قطعة واحدة ضمن طلب الطبيب (سن + نوع + مادة + سعر). الطلب قد يحوي عدّة قطع
/// (items في الباك)؛ النموذج المسطّح يلخّص الأولى، وهذه القائمة تعرض الكل.
class LabOrderPart {
  const LabOrderPart({
    required this.tooth,
    required this.type,
    required this.material,
    this.price = 0,
    this.notes = '',
  });

  final String tooth;
  final String type;
  final String material;
  final int price;
  final String notes;
}

/// نموذج كامل لطلب المخبر — يُستخدم بصفحة الطلبات والمودالات.
///
/// الحقول القابلة للتغيير (statusVariant/cost/assignedTechnician) تُحدَّث عند
/// المعالجة (UC69/UC70/UC71) عبر الـ repository.
class LabOrderFull {
  LabOrderFull({
    required this.id,
    required this.doctor,
    required this.type,
    required this.material,
    required this.tooth,
    required this.date,
    required this.statusVariant,
    this.isUrgent = false,
    this.notes = '',
    this.cost,
    this.assignedTechnician,
    this.parts = const [],
  });

  final String id;
  final String doctor;
  final String type;
  final String material;
  final String tooth;
  final String date;
  LabOrderBadgeVariant statusVariant;
  final bool isUrgent;
  final String notes;

  /// كل قطع الطلب (للعرض الكامل في مودال التفاصيل). الحقول المسطّحة
  /// (type/material/tooth) تلخّص أول قطعة للبطاقة.
  final List<LabOrderPart> parts;

  /// تكلفة تصنيع الطلبية بالليرة السورية (تُسجَّل عند المعالجة) — UC69.
  int? cost;

  /// اسم المخبري المنفّذ للطلبية (تسجيل المنفّذ) — UC70 / UC71.
  String? assignedTechnician;
}
