// ════════════════════════════════════════════════════════════════════════════
// remote_warehouse_reports_repository.dart
//
// تنفيذ Remote لتقارير المستودع (المشتريات). يحوّل DioException لـ Failure واضح.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/warehouse_dashboard_report.dart';
import '../../domain/entities/warehouse_purchases_report.dart';
import '../../domain/entities/warehouse_stock_movement_report.dart';
import '../../domain/repositories/warehouse_reports_repository.dart';
import '../datasources/warehouse_reports_remote_datasource.dart';

class RemoteWarehouseReportsRepository implements WarehouseReportsRepository {
  RemoteWarehouseReportsRepository(this._remote);

  final WarehouseReportsRemoteDataSource _remote;

  @override
  Future<WarehousePurchasesReport> getPurchasesReport({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final json = await _remote.purchaseInvoices(
        from: from != null ? _ymd(from) : null,
        to: to != null ? _ymd(to) : null,
      );
      return WarehousePurchasesReport.fromJson(json);
    } catch (e) {
      throw _mapError(e, 'تعذّر جلب تقرير المشتريات.');
    }
  }

  @override
  Future<WarehouseStockMovementReport> getStockMovementReport({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final json = await _remote.stockMovement(
        from: from != null ? _ymd(from) : null,
        to: to != null ? _ymd(to) : null,
      );
      return WarehouseStockMovementReport.fromJson(json);
    } catch (e) {
      throw _mapError(e, 'تعذّر جلب تقرير حركة المخزون.');
    }
  }

  @override
  Future<WarehouseDashboardReport> getDashboardReport({
    required String period,
    DateTime? date,
  }) async {
    try {
      final json = await _remote.dashboard(
        period: period,
        date: date != null ? _ymd(date) : null,
      );
      return WarehouseDashboardReport.fromJson(json);
    } catch (e) {
      throw _mapError(e, 'تعذّر جلب تقرير النظرة العامة.');
    }
  }

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// يحوّل أي استثناء (شبكة أو غير متوقع) لـ [Failure] موحّد — بما فيها
  /// استثناءات fromJson (شكل استجابة غير متوقع من الباك: حقل ناقص/نوع مختلف).
  /// قبل هالتوحيد، كانت هاي الاستثناءات (غير DioException) تفلت بلا catch،
  /// فيضل الكيوبت عالق على "جاري التحميل" للأبد بلا أي رسالة أو زر إعادة
  /// محاولة — هيك كانت الحالة الحقيقية وراء "ما بيفتح" بتقارير المشتريات
  /// وحركة المخزون (بعكس "بيطلعلي إعادة المحاولة" وهو DioException حقيقي).
  Failure _mapError(Object e, String fallbackMessage) {
    if (e is Failure) return e;
    if (e is! DioException) return ServerFailure(fallbackMessage);
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const TimeoutFailure();
    }
    if (e.type == DioExceptionType.connectionError || e.response == null) {
      return const NetworkFailure();
    }
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return ServerFailure(data['message'] as String,
          code: '${e.response?.statusCode ?? ''}');
    }
    return ServerFailure(fallbackMessage);
  }
}
