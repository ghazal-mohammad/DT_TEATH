// ════════════════════════════════════════════════════════════════════════════
// lab_material_requests_repository.dart
//
// عقد الوصول لطلبات المواد التي يرسلها المخبر للمستودع.
// عند ربط الباك: RemoteLabMaterialRequestsRepository يستبدل الـ Mock.
// ════════════════════════════════════════════════════════════════════════════

import '../entities/lab_material_request.dart';

/// عقد الوصول لطلبات المواد.
abstract class LabMaterialRequestsRepository {
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

  /// stream للطلبات — لتحديث الـ UI تلقائياً.
  Stream<List<MatRequest>> watchAll();
}
