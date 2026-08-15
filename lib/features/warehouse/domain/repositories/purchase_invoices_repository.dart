// ════════════════════════════════════════════════════════════════════════════
// purchase_invoices_repository.dart
//
// عقد فواتير الشراء الواردة للمستودع. القراءة تعود لآخر نسخة عند الانقطاع.
// الإنشاء/التعديل بلا صمود أوفلاين عمداً — العملية تُنشئ دفعات مخزون وتُعيد
// حساب السعر لحظياً استناداً لبيانات المواد الحالية، فقائمة الانتظار الأوفلاين
// قد تُنفَّذ لاحقاً على بيانات (أسعار/مواد) لم تعد صحيحة.
// ════════════════════════════════════════════════════════════════════════════

import '../entities/purchase_invoice.dart';

abstract class PurchaseInvoicesRepository {
  Future<List<PurchaseInvoice>> getAll();

  /// POST addPurchaseInvoice — ينشئ الفاتورة + دفعات مخزون جديدة لكل بند.
  Future<PurchaseInvoice> create({
    required String supplierName,
    required DateTime invoiceDate,
    required List<PurchaseInvoiceItemInput> items,
    String? notes,
  });

  /// POST updatePurchaseInvoice/{id} — يعدّل بيانات الفاتورة العامة فقط
  /// (الباك لا يدعم تعديل البنود بعد الإنشاء).
  Future<PurchaseInvoice> update(
    String id, {
    String? supplierName,
    DateTime? invoiceDate,
    String? notes,
  });
}
