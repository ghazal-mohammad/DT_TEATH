// ════════════════════════════════════════════════════════════════════════════
// lab_material_requests_repository.dart
//
// عقد الوصول لفواتير طلب المواد التي يرسلها المخبر للمستودع.
// ════════════════════════════════════════════════════════════════════════════

import '../entities/lab_material_request.dart';
import '../entities/warehouse_material_ref.dart';

/// عقد الوصول لفواتير طلب المواد.
abstract class LabMaterialRequestsRepository {
  /// آخر قائمة مُحمَّلة (للعرض الفوري عند إعادة زيارة الصفحة)، أو null إن لم
  /// تُحمَّل بعد. يُمكّن نمط stale-while-revalidate في الـ Cubit.
  List<MatRequest>? get cached;

  /// يجلب كل الفواتير.
  Future<List<MatRequest>> getAll();

  /// يجلب فاتورة واحدة بالمعرّف (showMaterialRequest/{id}).
  Future<MatRequest> getOne(String id);

  /// يجلب كتالوج مواد المستودع (لاختيار مواد فاتورة "من المستودع").
  Future<List<WarehouseMaterialRef>> getWarehouseMaterials();

  /// يجلب تفاصيل مادة واحدة من كتالوج المستودع (showWarehouseMaterial/{id}).
  Future<WarehouseMaterialRef> getWarehouseMaterial(int id);

  /// ينشئ فاتورة من مواد كتالوج المستودع (مسار items[] بالباك).
  Future<void> addRequestFromWarehouse({
    required List<({int materialId, int quantity, String? notes})> items,
    String? notes,
  });

  /// ينشئ فاتورة من مواد جديدة من شركة خارجية (مسار new_items[] بالباك).
  /// [companyName] يُكتب مرة وحدة هون ويتكرّر تلقائياً بكل عنصر بجسم الطلب.
  Future<void> addRequestFromCompany({
    required String companyName,
    required List<({String materialName, int quantity, String unit, String? reason})> items,
    String? notes,
  });

  /// يحذف فاتورة بالمعرّف.
  Future<void> delete(String id);

  /// stream للفواتير — لتحديث الـ UI تلقائياً.
  Stream<List<MatRequest>> watchAll();
}
