// ════════════════════════════════════════════════════════════════════════════
// purchase_invoices_remote_datasource.dart
//
// مصدر بيانات فواتير الشراء — warehouseManager/{showAllPurchaseInvoices,
// showPurchaseInvoiceDetails/{id}, addPurchaseInvoice, updatePurchaseInvoice/{id}}.
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

  Future<Map<String, dynamic>> getById(Object id) async {
    final res =
        await _dio.get<dynamic>(ApiEndpoints.warehousePurchaseInvoice(id));
    return _asMap(res.data);
  }

  /// POST addPurchaseInvoice. body: {supplier_name, invoice_date, notes?,
  /// items: [{material_id, quantity, unit_price, expiration_date?}]}.
  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final res = await _dio.post<dynamic>(
      ApiEndpoints.warehouseAddPurchaseInvoice,
      data: FormData.fromMap(body),
    );
    return _asMap(res.data);
  }

  /// POST updatePurchaseInvoice/{id}. body: {supplier_name?, invoice_date?, notes?}
  /// (الباك لا يدعم تعديل البنود — فقط بيانات الفاتورة العامة).
  Future<Map<String, dynamic>> update(
      Object id, Map<String, dynamic> body) async {
    final res = await _dio.post<dynamic>(
      ApiEndpoints.warehouseUpdatePurchaseInvoice(id),
      data: FormData.fromMap(body),
    );
    return _asMap(res.data);
  }

  Map<String, dynamic> _asMap(Object? data) {
    final map = (data is Map) ? data['data'] : null;
    return map is Map ? Map<String, dynamic>.from(map) : <String, dynamic>{};
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
