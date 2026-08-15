// ════════════════════════════════════════════════════════════════════════════
// warehouse_reports_remote_datasource.dart
//
// مصدر بيانات تقارير المستودع — warehouseManager/reports/*.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/endpoints.dart';

class WarehouseReportsRemoteDataSource {
  WarehouseReportsRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET reports/purchase-invoices?from=&to= — يرجّع الاستجابة الخام (مع data).
  Future<Map<String, dynamic>> purchaseInvoices({String? from, String? to}) async {
    final res = await _dio.get<dynamic>(
      ApiEndpoints.warehouseReportPurchaseInvoices,
      queryParameters: {
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      },
    );
    return res.data is Map
        ? Map<String, dynamic>.from(res.data as Map)
        : <String, dynamic>{};
  }

  /// GET stock-movement?from=&to= — يرجّع الاستجابة الخام (مع data).
  Future<Map<String, dynamic>> stockMovement({String? from, String? to}) async {
    final res = await _dio.get<dynamic>(
      ApiEndpoints.warehouseReportStockMovement,
      queryParameters: {
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      },
    );
    return res.data is Map
        ? Map<String, dynamic>.from(res.data as Map)
        : <String, dynamic>{};
  }

  /// GET material-requests?from=&to= — يرجّع الاستجابة الخام (مع data).
  Future<Map<String, dynamic>> materialRequests({String? from, String? to}) async {
    final res = await _dio.get<dynamic>(
      ApiEndpoints.warehouseReportMaterialRequests,
      queryParameters: {
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      },
    );
    return res.data is Map
        ? Map<String, dynamic>.from(res.data as Map)
        : <String, dynamic>{};
  }
}
