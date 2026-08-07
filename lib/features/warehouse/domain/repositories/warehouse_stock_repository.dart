// ════════════════════════════════════════════════════════════════════════════
// warehouse_stock_repository.dart
//
// عقد إدارة مخزون المستودع (الدفعات): جلب تفاصيل مادة، إضافة دفعة، تعديل كمية
// دفعة (إدخال/إخراج). عمليات الكتابة تعتمد على منطق الباك (FIFO، سجلّات) فهي
// أونلاين-أولاً بمعالجة أخطاء واضحة.
// ════════════════════════════════════════════════════════════════════════════

import '../entities/material_stock.dart';

abstract class WarehouseStockRepository {
  /// تفاصيل مخزون مادة (بياناتها + دفعاتها + الإجمالي).
  Future<MaterialStock> getStockDetails(String materialId);

  /// إضافة دفعة جديدة لمادة.
  Future<void> addBatch({
    required String materialId,
    required int quantity,
    DateTime? expiryDate,
    String? notes,
  });

  /// تعديل كمية دفعة محدّدة (إدخال/إخراج) مع سبب الحركة.
  Future<void> adjustBatch({
    required String batchId,
    required bool isIn,
    required int quantity,
    required StockMovementReason reason,
    String? notes,
  });
}
