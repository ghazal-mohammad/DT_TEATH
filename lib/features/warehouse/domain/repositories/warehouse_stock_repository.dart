// ════════════════════════════════════════════════════════════════════════════
// warehouse_stock_repository.dart
//
// عقد إدارة مخزون المستودع (الدفعات): جلب تفاصيل مادة، تعديل كمية دفعة موجودة
// (إدخال/إخراج). إضافة دفعة جديدة صارت حصراً عبر فاتورة الشراء (الباك حذف
// addStockBatch نهائياً 2026-08) — انظر PurchaseInvoicesRepository.create.
// عمليات الكتابة تعتمد على منطق الباك (FIFO، سجلّات) فهي أونلاين-أولاً
// بمعالجة أخطاء واضحة.
// ════════════════════════════════════════════════════════════════════════════

import '../entities/material_stock.dart';

abstract class WarehouseStockRepository {
  /// تفاصيل مخزون مادة (بياناتها + دفعاتها + الإجمالي).
  Future<MaterialStock> getStockDetails(String materialId);

  /// تعديل كمية دفعة محدّدة (إدخال/إخراج) مع سبب الحركة.
  Future<void> adjustBatch({
    required String batchId,
    required bool isIn,
    required int quantity,
    required StockMovementReason reason,
    String? notes,
  });
}
