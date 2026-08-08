// ════════════════════════════════════════════════════════════════════════════
// warehouse_inventory_remote_datasource.dart
//
// مصدر بيانات مؤشّرات المخزون — warehouseManager/{mostRequestedMaterials,
// expiringSoonMaterials, lowStockMaterials}. يرجّع الاستجابة الخام (مع data)
// لأن التلخيص يحتاج القوائم المتداخلة (batches/items) داخلها.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/endpoints.dart';

class WarehouseInventoryRemoteDataSource {
  WarehouseInventoryRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET mostRequestedMaterials?limit= — الافتراضي بالباك limit=10.
  Future<Map<String, dynamic>> mostRequested() async {
    final res =
        await _dio.get<dynamic>(ApiEndpoints.warehouseInventoryMostRequested);
    return _asMap(res.data);
  }

  /// GET expiringSoonMaterials?days= — الافتراضي بالباك days=20.
  Future<Map<String, dynamic>> expiringSoon() async {
    final res =
        await _dio.get<dynamic>(ApiEndpoints.warehouseInventoryExpiringSoon);
    return _asMap(res.data);
  }

  /// GET lowStockMaterials?threshold= — الافتراضي بالباك threshold=10.
  Future<Map<String, dynamic>> lowStock() async {
    final res =
        await _dio.get<dynamic>(ApiEndpoints.warehouseInventoryLowStock);
    return _asMap(res.data);
  }

  Map<String, dynamic> _asMap(Object? data) =>
      data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
}
