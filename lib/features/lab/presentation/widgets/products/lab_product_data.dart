// ════════════════════════════════════════════════════════════════════════════
// lab_product_data.dart
//
// نموذج منتج المخبر + ثوابت الأنواع/المواد + بذرة بيانات وهمية — مُستخرَجة من
// lab_products_page.dart ضمن تقسيم الصفحات. تُستبدل بـ API لاحقاً.
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
  LabProduct({
    required this.id,
    required this.name,
    required this.type,
    required this.material,
    required this.price,
    required this.productionDays,
  });

  String name;
  String type;
  String material;
  int price;
  int productionDays;
  final String id;
}

/// بذرة بيانات الكتالوج (مؤقّتة حتى ربط GET /api/lab/products).
List<LabProduct> labProductsSeed() => [
      LabProduct(
        id: 'P-01',
        name: 'تلبيسة زيركون كاملة',
        type: 'تلبيسة',
        material: 'Zirconia',
        price: 120000,
        productionDays: 3,
      ),
      LabProduct(
        id: 'P-02',
        name: 'تلبيسة بورسلان على معدن',
        type: 'تلبيسة',
        material: 'PFM',
        price: 75000,
        productionDays: 4,
      ),
      LabProduct(
        id: 'P-03',
        name: 'جسر 3 وحدات زيركون',
        type: 'جسر',
        material: 'Zirconia',
        price: 330000,
        productionDays: 5,
      ),
      LabProduct(
        id: 'P-04',
        name: 'وجه إيماكس تجميلي',
        type: 'وجه (فينير)',
        material: 'E-max',
        price: 95000,
        productionDays: 4,
      ),
      LabProduct(
        id: 'P-05',
        name: 'طقم أكريل كامل',
        type: 'طقم',
        material: 'Acrylic',
        price: 250000,
        productionDays: 7,
      ),
      LabProduct(
        id: 'P-06',
        name: 'تلبيسة معدنية',
        type: 'تلبيسة',
        material: 'Metal',
        price: 45000,
        productionDays: 2,
      ),
    ];
