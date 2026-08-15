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
import '../entities/stock_overview.dart';

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

  /// نظرة عامة على مخزون كل المواد (showAllStock) — تتضمّن is_low المحسوبة
  /// بالباك، الإشارة الحقيقية الوحيدة لـ"منخفض" (minStock بـ WarehouseMaterial
  /// قيمة UI محلية لا يرسلها الباك أبداً).
  Future<List<StockOverviewItem>> getAllStock();

  /// سجل حركة المخزون (showStockLogs)، بفلتر مادة اختياري.
  Future<List<StockLogEntry>> getLogs({String? materialId});
}
