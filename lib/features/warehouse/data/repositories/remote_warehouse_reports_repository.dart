// ════════════════════════════════════════════════════════════════════════════
// remote_warehouse_reports_repository.dart
//
// تنفيذ Remote لتقارير المستودع (المشتريات). يحوّل DioException لـ Failure واضح.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/warehouse_material_requests_report.dart';
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
    } on DioException catch (e) {
      throw _mapDioError(e);
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
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<WarehouseMaterialRequestsReport> getMaterialRequestsReport({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final json = await _remote.materialRequests(
        from: from != null ? _ymd(from) : null,
        to: to != null ? _ymd(to) : null,
      );
      return WarehouseMaterialRequestsReport.fromJson(json);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Failure _mapDioError(DioException e) {
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
    return const ServerFailure('تعذّر جلب تقرير المشتريات.');
  }
}
