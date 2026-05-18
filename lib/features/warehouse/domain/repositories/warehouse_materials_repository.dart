// ════════════════════════════════════════════════════════════════════════════
// warehouse_materials_repository.dart
//
// Interface (abstract class) لـ Repository إدارة المواد.
//
// 🎯 الهدف:
//   فصل الـ UI عن مصدر البيانات. الواجهة تعرّف العمليات (CRUD) بدون
//   الالتزام بطريقة التطبيق (mock / API / cache).
//
// 🔮 خطّة التطبيقات (implementations):
//   - Phase 4.3 (الحالي): MockWarehouseMaterialsRepository → بيانات ثابتة
//   - Phase 6 (Backend): RemoteWarehouseMaterialsRepository → REST API
//   - Phase 7 (Offline): CachedWarehouseMaterialsRepository → SQLite + sync
//
// كل implementation تنفذ نفس interface — الـ UI ما يلاحظ الفرق.
// ════════════════════════════════════════════════════════════════════════════

import '../entities/warehouse_material.dart';

/// عقد (contract) للوصول لبيانات المواد.
///
/// **الاستخدام في BLoC**:
/// ```dart
/// class MaterialsCubit extends Cubit<MaterialsState> {
///   MaterialsCubit(this._repo);
///   final WarehouseMaterialsRepository _repo;
///
///   Future<void> load() async {
///     emit(MaterialsLoading());
///     final list = await _repo.getAll();
///     emit(MaterialsLoaded(list));
///   }
/// }
/// ```
abstract class WarehouseMaterialsRepository {
  /// يجلب كل المواد.
  Future<List<WarehouseMaterial>> getAll();

  /// يجلب مادة واحدة بالـ id.
  /// يرمي [StateError] إذا غير موجودة.
  Future<WarehouseMaterial> getById(String id);

  /// يضيف مادة جديدة. يرجع الـ entity مع id من الـ backend.
  Future<WarehouseMaterial> create(WarehouseMaterial material);

  /// يحدّث مادة موجودة. يرجع الـ entity المحدّث.
  Future<WarehouseMaterial> update(WarehouseMaterial material);

  /// يحذف مادة بالـ id.
  Future<void> delete(String id);

  /// stream للمواد — لتحديث UI تلقائي عند تغيّر البيانات.
  ///
  /// التطبيقات الـ remote قد ترجع stream فارغ أو single-emit.
  Stream<List<WarehouseMaterial>> watchAll();
}
