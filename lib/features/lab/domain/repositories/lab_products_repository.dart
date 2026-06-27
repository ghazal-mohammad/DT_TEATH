// ════════════════════════════════════════════════════════════════════════════
// lab_products_repository.dart
//
// عقد (interface) للوصول لبيانات كتالوج منتجات المخبر — يفصل الـ UI عن مصدر
// البيانات (mock/API). يطابق نمط WarehouseMaterialsRepository.
//
// التطبيقات:
//   - الحالي: MockLabProductsRepository (بيانات في الذاكرة)
//   - Backend لاحقاً: RemoteLabProductsRepository (GET/POST/PUT /api/lab/products)
// كل تطبيق ينفّذ نفس العقد — الـ UI ما يلاحظ الفرق.
// ════════════════════════════════════════════════════════════════════════════

import '../entities/lab_product.dart';

/// عقد الوصول لبيانات منتجات المخبر.
abstract class LabProductsRepository {
  /// آخر كتالوج مُحمَّل (للعرض الفوري عند إعادة زيارة الصفحة)، أو null إن لم
  /// يُحمَّل بعد. يُمكّن نمط stale-while-revalidate في الـ Cubit.
  List<LabProduct>? get cached;

  /// يجلب كل المنتجات.
  Future<List<LabProduct>> getAll();

  /// يضيف منتجاً جديداً. يرجع الـ entity مع id مولّد.
  Future<LabProduct> create(LabProduct product);

  /// يحدّث منتجاً موجوداً. يرجع الـ entity المحدّث.
  Future<LabProduct> update(LabProduct product);

  /// stream للمنتجات — لتحديث الـ UI تلقائياً عند أي تغيير.
  Stream<List<LabProduct>> watchAll();
}
