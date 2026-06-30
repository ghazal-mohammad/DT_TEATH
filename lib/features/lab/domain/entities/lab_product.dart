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

/// فئة صنف المخبر (من showAllItemsCategories) — تُرسَل كـ category_id للباك.
class LabProductCategory {
  const LabProductCategory({required this.id, required this.name});

  final int id;
  final String name;
}

/// منتج واحد في كتالوج المخبر (اسم + فئة + نوع + مادة + سعر + مدة تصنيع).
class LabProduct {
  const LabProduct({
    required this.id,
    required this.name,
    required this.type,
    required this.material,
    required this.price,
    required this.productionDays,
    this.categoryId,
    this.categoryName,
  });

  final String id;
  final String name;
  final String type;
  final String material;
  final int price;
  final int productionDays;

  /// معرّف الفئة (category_id بالباك) — null إن لم تُسنَد فئة.
  final int? categoryId;

  /// اسم الفئة للعرض (يأتي من الباك مع الصنف).
  final String? categoryName;

  /// ينتج نسخة جديدة مع تحديث بعض الحقول (الكيان immutable).
  LabProduct copyWith({
    String? id,
    String? name,
    String? type,
    String? material,
    int? price,
    int? productionDays,
    int? categoryId,
    String? categoryName,
    bool clearCategory = false,
  }) {
    return LabProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      material: material ?? this.material,
      price: price ?? this.price,
      productionDays: productionDays ?? this.productionDays,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      categoryName: clearCategory ? null : (categoryName ?? this.categoryName),
    );
  }
}
