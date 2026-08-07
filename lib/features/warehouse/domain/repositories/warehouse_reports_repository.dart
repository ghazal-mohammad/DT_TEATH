// ════════════════════════════════════════════════════════════════════════════
// warehouse_reports_repository.dart
//
// عقد تقارير المستودع. حالياً: تقرير المشتريات (purchase-invoices) بفترة زمنية.
// ملاحظة: تقريرا حركة المخزون والطلبات متوفّران بالباك للتوسيع لاحقاً.
// ════════════════════════════════════════════════════════════════════════════

import '../entities/warehouse_purchases_report.dart';

abstract class WarehouseReportsRepository {
  /// تقرير المشتريات ضمن نطاق [from]–[to] (null ⇒ الافتراضي: هذا الشهر).
  Future<WarehousePurchasesReport> getPurchasesReport({
    DateTime? from,
    DateTime? to,
  });
}
