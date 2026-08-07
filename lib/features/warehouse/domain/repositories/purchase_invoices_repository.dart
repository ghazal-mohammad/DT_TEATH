// ════════════════════════════════════════════════════════════════════════════
// purchase_invoices_repository.dart
//
// عقد فواتير الشراء الواردة للمستودع (عرض). القراءة تعود لآخر نسخة عند الانقطاع.
// ملاحظة: الإنشاء (store) متعدّد البنود — مؤجَّل لواجهة لاحقة.
// ════════════════════════════════════════════════════════════════════════════

import '../entities/purchase_invoice.dart';

abstract class PurchaseInvoicesRepository {
  Future<List<PurchaseInvoice>> getAll();
  Stream<List<PurchaseInvoice>> watchAll();
}
