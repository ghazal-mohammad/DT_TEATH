// ════════════════════════════════════════════════════════════════════════════
// warehouse_stock_remote_datasource.dart
//
// مصدر بيانات مخزون المستودع البعيد — warehouseManager/*Stock* (فُعِّلت 2026-08).
// يرجّع JSON خام؛ التحويل في الـ repository.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/endpoints.dart';

class WarehouseStockRemoteDataSource {
  WarehouseStockRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET showStockDetails/{materialId} → {material, total_quantity, batches[]}.
  Future<Map<String, dynamic>> getStockDetails(Object materialId) async {
    final res = await _dio
        .get<dynamic>(ApiEndpoints.warehouseShowStockDetails(materialId));
    return _asData(res.data);
  }

  /// POST adjustStockQuantity/{batchId}. body: {type, quantity, reason, notes?}.
  Future<Map<String, dynamic>> adjustBatch(
      Object batchId, Map<String, dynamic> body) async {
    final res = await _dio.post<dynamic>(
      ApiEndpoints.warehouseAdjustStock(batchId),
      data: FormData.fromMap(body),
    );
    return _asData(res.data);
  }

  Map<String, dynamic> _asData(Object? data) {
    final inner = (data is Map) ? data['data'] : null;
    if (inner is Map) return Map<String, dynamic>.from(inner);
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }
}
