// ════════════════════════════════════════════════════════════════════════════
// warehouse_reports_repository.dart
//
// عقد تقارير المستودع: المشتريات، حركة المخزون، والنظرة العامة
// (reports/dashboard). الثلاثة مربوطة فعلياً بالباك.
//
// تقرير "طلبات المواد" أُزيل نهائياً 2026-08-21 — الباك يرمي خطأ 500
// (Call to undefined relationship [requester] on model [App\Models\
// MaterialRequest]) لأن العلاقة غير معرَّفة بالموديل؛ حتى يُصلَح الباك، لا
// داعي لواجهة معطوبة دائماً بالفرونت.
// ════════════════════════════════════════════════════════════════════════════

import '../entities/warehouse_dashboard_report.dart';
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

  /// تقرير التحليلات العام (استهلاك حسب الفئة/أكثر الشركات/أكثر المواد
  /// استهلاكاً). [period] "week" أو "month" فقط (يرفضه الباك بغيرها).
  Future<WarehouseDashboardReport> getDashboardReport({
    required String period,
    DateTime? date,
  });
}
