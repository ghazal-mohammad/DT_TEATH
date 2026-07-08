// ════════════════════════════════════════════════════════════════════════════
// warehouse_material_ref.dart
//
// مرجع مادة من كتالوج المستودع (GET showAllWarehouseMaterials) — يُستخدم في
// نموذج طلب المواد لاختيار مادة موجودة (بـ material_id عبر مسار items) بدل
// إدخالها يدوياً كمادة جديدة (new_items). الحقول تطابق WarehouseMaterialResource:
//   { id, material_id, material(الاسم), unit, quantity, description }.
// ════════════════════════════════════════════════════════════════════════════

/// مادة من كتالوج المستودع (اسمها ومعرّفها ووحدتها) لاختيارها في طلب مواد.
class WarehouseMaterialRef {
  const WarehouseMaterialRef({
    required this.materialId,
    required this.name,
    required this.unit,
  });

  /// معرّف المادة في جدول materials (يُرسَل كـ material_id في مسار items).
  final int materialId;

  /// اسم المادة للعرض/البحث.
  final String name;

  /// وحدة القياس (تُملأ تلقائياً عند الاختيار).
  final String unit;
}
