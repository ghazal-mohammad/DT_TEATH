// ════════════════════════════════════════════════════════════════════════════
// cached_list_repository.dart
//
// mixin يضيف "قراءة عبر كاش دائم" لأي repository يجلب قائمة من الباك:
//   • عند نجاح الجلب: نحفظ نسخة JSON دائمة.
//   • عند انقطاع الشبكة: نُرجع آخر نسخة معروفة بدل رمي فشل (صمود أوفلاين).
//
// يبقى المنطق الخاص بكل مورد (fromJson، الـ stream، mapDioError) في الـ repo؛
// هذا الـ mixin يوفّر فقط طبقة الكاش المشتركة (DRY).
// ════════════════════════════════════════════════════════════════════════════

import 'persistent_cache.dart';

mixin PersistentListCache {
  /// الكاش الدائم المحقون في الـ repository.
  PersistentCache get persistentCache;

  /// مفتاح المورد الفريد (مثل 'lab_products').
  String get cacheResource;

  /// يحفظ الصفوف الخام لآخر جلب ناجح.
  Future<void> saveCachedRows(List<Map<String, dynamic>> rows) =>
      persistentCache.save(cacheResource, rows);

  /// يقرأ آخر صفوف محفوظة (null إن لا يوجد).
  Future<List<Map<String, dynamic>>?> loadCachedRows() =>
      persistentCache.load(cacheResource);
}
