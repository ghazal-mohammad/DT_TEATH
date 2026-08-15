// ════════════════════════════════════════════════════════════════════════════
// warehouse_requests_repository.dart
//
// عقد طلبات المواد الواردة للمستودع: عرض، تلبية (خصم FIFO)، رفض. القراءة تعود
// لآخر نسخة معروفة عند الانقطاع؛ الكتابة أونلاين-أولاً (منطق خصم على الباك).
// ════════════════════════════════════════════════════════════════════════════

import '../entities/warehouse_request.dart';

abstract class WarehouseRequestsRepository {
  Future<List<WarehouseRequest>> getAll();

  /// تلبية الطلب كاملاً (يخصم من الدفعات FIFO في الباك).
  Future<void> fulfill(String id, {String? notes});

  /// رفض الطلب مع سبب.
  Future<void> reject(String id, {required String reason});

  /// تحويل الطلب إلى "قيد المعالجة" (من "جديد" فقط).
  Future<void> markPending(String id);
}
