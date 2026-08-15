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

  /// GET showAllStock → قائمة كل المواد بإجمالي مخزونها + is_low.
  Future<List<Map<String, dynamic>>> getAllStock() async {
    final res = await _dio.get<dynamic>(ApiEndpoints.warehouseShowAllStock);
    return _asList((res.data is Map) ? (res.data as Map)['data'] : null);
  }

  /// GET showStockLogs?material_id=&warehouse_stock_id= → سجل حركة (مُصفَّح
  /// بالباك، نأخذ الصفحة الأولى فقط حالياً — data.data).
  Future<List<Map<String, dynamic>>> getLogs({Object? materialId}) async {
    final res = await _dio.get<dynamic>(
      ApiEndpoints.warehouseShowStockLogs,
      queryParameters: {if (materialId != null) 'material_id': materialId},
    );
    final data = (res.data is Map) ? (res.data as Map)['data'] : null;
    final rows = (data is Map) ? data['data'] : data;
    return _asList(rows);
  }

  Map<String, dynamic> _asData(Object? data) {
    final inner = (data is Map) ? data['data'] : null;
    if (inner is Map) return Map<String, dynamic>.from(inner);
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _asList(Object? data) {
    if (data is! List) return const [];
    return data
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
  }
}
