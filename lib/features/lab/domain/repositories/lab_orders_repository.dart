// ════════════════════════════════════════════════════════════════════════════
// lab_orders_repository.dart
//
// عقد (interface) للوصول لطلبات الأطباء في المخبر — يفصل الـ UI عن مصدر البيانات.
// يطابق نمط WarehouseMaterialsRepository / LabProductsRepository.
//
// عند ربط الباك: RemoteLabOrdersRepository يستبدل الـ Mock دون لمس الـ UI.
// ════════════════════════════════════════════════════════════════════════════

import '../entities/lab_order.dart';

/// عقد الوصول لطلبات الأطباء.
abstract class LabOrdersRepository {
  /// آخر قائمة مُحمَّلة (للعرض الفوري عند إعادة زيارة الصفحة)، أو null إن لم
  /// تُحمَّل بعد. تُمكّن نمط stale-while-revalidate في الـ Cubit.
  List<LabOrderFull>? get cached;

  /// يجلب كل الطلبات.
  Future<List<LabOrderFull>> getAll();

  /// يعالج طلباً: يحدّث الحالة + التكلفة + المخبري المنفّذ (UC69/UC70/UC71).
  Future<void> processOrder({
    required String id,
    required LabOrderBadgeVariant status,
    int? cost,
    String? technician,
  });

  /// stream للطلبات — لتحديث الـ UI تلقائياً عند أي تغيير.
  Stream<List<LabOrderFull>> watchAll();
}
