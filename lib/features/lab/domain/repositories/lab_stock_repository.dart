// ════════════════════════════════════════════════════════════════════════════
// lab_stock_repository.dart
//
// عقد الوصول لمخزون المخبر الداخلي. عند ربط الباك: RemoteLabStockRepository.
// يطابق نمط بقية عقود المخبر (getAll + عمليات + watchAll).
// ════════════════════════════════════════════════════════════════════════════

import '../entities/lab_stock.dart';

/// عقد الوصول لمخزون المخبر.
abstract class LabStockRepository {
  /// يجلب كل مواد مخزون المخبر.
  Future<List<LabStock>> getAll();

  /// يضيف كمية لمادة (إضافة يدوية للمخزون). [notes] اختياري.
  Future<void> addQuantity({
    required String id,
    required double quantity,
    String? notes,
  });

  /// يخصم كمية من مادة (تسجيل استهلاك). [notes] اختياري.
  /// يرمي Failure إذا الكمية المطلوبة أكبر من المتاح (422 من الباك).
  Future<void> subtractQuantity({
    required String id,
    required double quantity,
    String? notes,
  });

  /// stream لمخزون المخبر — لتحديث الـ UI تلقائياً بعد أي عملية.
  Stream<List<LabStock>> watchAll();
}
