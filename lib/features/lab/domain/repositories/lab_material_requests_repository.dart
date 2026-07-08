// ════════════════════════════════════════════════════════════════════════════
// lab_material_requests_repository.dart
//
// عقد الوصول لطلبات المواد التي يرسلها المخبر للمستودع.
// عند ربط الباك: RemoteLabMaterialRequestsRepository يستبدل الـ Mock.
// ════════════════════════════════════════════════════════════════════════════

import '../entities/lab_material_request.dart';

/// عقد الوصول لطلبات المواد.
abstract class LabMaterialRequestsRepository {
  /// آخر قائمة مُحمَّلة (للعرض الفوري عند إعادة زيارة الصفحة)، أو null إن لم
  /// تُحمَّل بعد. يُمكّن نمط stale-while-revalidate في الـ Cubit.
  List<MatRequest>? get cached;

  /// يجلب كل الطلبات.
  Future<List<MatRequest>> getAll();

  /// يضيف طلب مادة جديد (يولّد المعرّف والتاريخ) ويُدرجه بأعلى القائمة.
  Future<void> addRequest({
    required String material,
    required String quantity,
    required String unit,
    required String requestedBy,
    String? company,
    String? reason,
  });

  /// يحذف طلب مادة بالمعرّف.
  Future<void> delete(String id);

  /// stream للطلبات — لتحديث الـ UI تلقائياً.
  Stream<List<MatRequest>> watchAll();
}
