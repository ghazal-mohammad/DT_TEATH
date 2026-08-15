// ════════════════════════════════════════════════════════════════════════════
// warehouse_reports_repository.dart
//
// عقد تقارير المستودع. حالياً: تقرير المشتريات (purchase-invoices) بفترة زمنية.
// ملاحظة: تقريرا حركة المخزون والطلبات متوفّران بالباك للتوسيع لاحقاً.
// ════════════════════════════════════════════════════════════════════════════

import '../entities/warehouse_dashboard_report.dart';
import '../entities/warehouse_material_requests_report.dart';
import '../entities/warehouse_purchases_report.dart';
import '../entities/warehouse_stock_movement_report.dart';

abstract class WarehouseReportsRepository {
  /// تقرير المشتريات ضمن نطاق [from]–[to] (null ⇒ الافتراضي: هذا الشهر).
  Future<WarehousePurchasesReport> getPurchasesReport({
    DateTime? from,
    DateTime? to,
  });

  /// تقرير حركة المخزون ضمن نطاق [from]–[to] (null ⇒ الافتراضي: هذا الشهر).
  Future<WarehouseStockMovementReport> getStockMovementReport({
    DateTime? from,
    DateTime? to,
  });

  /// تقرير طلبات المواد ضمن نطاق [from]–[to] (null ⇒ الافتراضي: هذا الشهر).
  Future<WarehouseMaterialRequestsReport> getMaterialRequestsReport({
    DateTime? from,
    DateTime? to,
  });

  /// تقرير التحليلات العام (استهلاك حسب الفئة/أكثر الشركات/أكثر المواد
  /// استهلاكاً). [period] "week" أو "month" فقط (يرفضه الباك بغيرها).
  Future<WarehouseDashboardReport> getDashboardReport({
    required String period,
    DateTime? date,
  });
}
