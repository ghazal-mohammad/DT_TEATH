// ════════════════════════════════════════════════════════════════════════════
// lab_product.dart
//
// كيان منتج المخبر (domain entity) + ثوابت الأنواع/المواد.
// كيان غير قابل للتغيير (immutable) مع copyWith — يطابق نمط warehouse_material.
//
// نُقل من presentation إلى domain ضمن بناء طبقة domain + Cubits للمخبر،
// ليكون مستقلاً عن الـ UI ومصدر البيانات (mock/API).
// ════════════════════════════════════════════════════════════════════════════

/// أنواع التعويضات التي يصنّعها المخبر (قيم عربية ثابتة كباقي النظام).
const List<String> kProductTypes = ['تلبيسة', 'جسر', 'طقم', 'وجه (فينير)', 'زرعة'];

/// المواد المتاحة للتصنيع.
const List<String> kProductMaterials = [
  'Zirconia',
  'PFM',
  'E-max',
  'Metal',
  'Acrylic',
];

/// منتج واحد في كتالوج المخبر (اسم + نوع + مادة + سعر + مدة تصنيع).
class LabProduct {
  const LabProduct({
    required this.id,
    required this.name,
    required this.type,
    required this.material,
    required this.price,
    required this.productionDays,
  });

  final String id;
  final String name;
  final String type;
  final String material;
  final int price;
  final int productionDays;

  /// ينتج نسخة جديدة مع تحديث بعض الحقول (الكيان immutable).
  LabProduct copyWith({
    String? id,
    String? name,
    String? type,
    String? material,
    int? price,
    int? productionDays,
  }) {
    return LabProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      material: material ?? this.material,
      price: price ?? this.price,
      productionDays: productionDays ?? this.productionDays,
    );
  }
}
