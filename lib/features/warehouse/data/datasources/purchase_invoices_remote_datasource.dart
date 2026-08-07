// ════════════════════════════════════════════════════════════════════════════
// purchase_invoices_remote_datasource.dart
//
// مصدر بيانات فواتير الشراء — warehouseManager/purchase-invoices.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/endpoints.dart';

class PurchaseInvoicesRemoteDataSource {
  PurchaseInvoicesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> getAll() async {
    final res = await _dio.get<dynamic>(ApiEndpoints.warehousePurchaseInvoices);
    return _asList(res.data);
  }

  List<Map<String, dynamic>> _asList(Object? data) {
    final list = (data is Map) ? data['data'] : null;
    if (list is! List) return <Map<String, dynamic>>[];
    return list
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
