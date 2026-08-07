// ════════════════════════════════════════════════════════════════════════════
// warehouse_inventory_remote_datasource.dart
//
// مصدر بيانات مؤشّرات المخزون — warehouseManager/inventory/*. يرجّع الاستجابة
// الخام (مع مفتاح data) لأن التلخيص يحتاج summary داخلها.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/endpoints.dart';

class WarehouseInventoryRemoteDataSource {
  WarehouseInventoryRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> stockLevels() async {
    final res =
        await _dio.get<dynamic>(ApiEndpoints.warehouseInventoryStockLevels);
    return _asMap(res.data);
  }

  Future<Map<String, dynamic>> stockValue() async {
    final res =
        await _dio.get<dynamic>(ApiEndpoints.warehouseInventoryStockValue);
    return _asMap(res.data);
  }

  Map<String, dynamic> _asMap(Object? data) =>
      data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
}
