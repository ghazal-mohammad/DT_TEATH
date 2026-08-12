// ════════════════════════════════════════════════════════════════════════════
// lab_products_repository.dart
//
// عقد (interface) للوصول لبيانات كتالوج منتجات المخبر — يفصل الـ UI عن مصدر
// البيانات. يطابق نمط WarehouseMaterialsRepository.
// التنفيذ الحقيقي: RemoteLabProductsRepository (data/repositories/).
// ════════════════════════════════════════════════════════════════════════════

import '../entities/lab_product.dart';

/// عقد الوصول لبيانات منتجات المخبر.
abstract class LabProductsRepository {
  /// آخر كتالوج مُحمَّل (للعرض الفوري عند إعادة زيارة الصفحة)، أو null إن لم
  /// يُحمَّل بعد. يُمكّن نمط stale-while-revalidate في الـ Cubit.
  List<LabProduct>? get cached;

  /// يجلب كل المنتجات.
  Future<List<LabProduct>> getAll();

  /// يجلب فئات الأصناف من الباك (showAllItemsCategories) لقائمة الفئة بالنموذج.
  Future<List<LabProductCategory>> getCategories();

  /// يضيف فئة جديدة (addItemCategory). يرجع الفئة مع id مولّد.
  Future<LabProductCategory> createCategory(String name);

  /// يعدّل اسم فئة موجودة (updateItemCategory/{id}).
  Future<LabProductCategory> updateCategory(int id, String name);

  /// يحذف فئة بالمعرّف (deleteItemCategory/{id}). الباك يرفض الحذف (422) لو
  /// الفئة مرتبطة بأصناف — الخطأ يصعد كـ Failure برسالة الباك.
  Future<void> deleteCategory(int id);

  /// يضيف منتجاً جديداً. يرجع الـ entity مع id مولّد.
  Future<LabProduct> create(LabProduct product);

  /// يحدّث منتجاً موجوداً. يرجع الـ entity المحدّث.
  Future<LabProduct> update(LabProduct product);

  /// يحذف منتجاً بالمعرّف.
  Future<void> delete(String id);

  /// stream للمنتجات — لتحديث الـ UI تلقائياً عند أي تغيير.
  Stream<List<LabProduct>> watchAll();
}
