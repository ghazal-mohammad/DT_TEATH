// ════════════════════════════════════════════════════════════════════════════
// lab_material_requests_repository.dart
//
// عقد الوصول لطلبات المواد التي يرسلها المخبر للمستودع.
// عند ربط الباك: RemoteLabMaterialRequestsRepository يستبدل الـ Mock.
// ════════════════════════════════════════════════════════════════════════════

import '../entities/lab_material_request.dart';
import '../entities/warehouse_material_ref.dart';

/// عقد الوصول لطلبات المواد.
abstract class LabMaterialRequestsRepository {
  /// آخر قائمة مُحمَّلة (للعرض الفوري عند إعادة زيارة الصفحة)، أو null إن لم
  /// تُحمَّل بعد. يُمكّن نمط stale-while-revalidate في الـ Cubit.
  List<MatRequest>? get cached;

  /// يجلب كل الطلبات.
  Future<List<MatRequest>> getAll();

  /// يجلب كتالوج مواد المستودع (لاختيار مادة موجودة في النموذج).
  Future<List<WarehouseMaterialRef>> getWarehouseMaterials();

  /// يضيف طلب مادة جديد ويُدرجه بأعلى القائمة.
  ///
  /// [materialId] غير null ⇒ مادة موجودة من الكتالوج (مسار items بـ material_id).
  /// null ⇒ مادة جديدة بالاسم الحر (مسار new_items).
  Future<void> addRequest({
    required String material,
    required String quantity,
    required String unit,
    required String requestedBy,
    int? materialId,
    String? company,
    String? reason,
  });

  /// يحذف طلب مادة بالمعرّف.
  Future<void> delete(String id);

  /// stream للطلبات — لتحديث الـ UI تلقائياً.
  Stream<List<MatRequest>> watchAll();
}
