// ════════════════════════════════════════════════════════════════════════════
// warehouse_materials_remote_datasource.dart
//
// مصدر بيانات مواد المستودع البعيد — warehouseManager/* (فُعِّلت 2026-08).
// التوكن يُضاف تلقائياً عبر interceptor. يرجّع JSON خام؛ التحويل في الـ repository.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/endpoints.dart';

class WarehouseMaterialsRemoteDataSource {
  WarehouseMaterialsRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET showALLMaterials → [{id,name,unit,price,description,total_stock,...}].
  Future<List<Map<String, dynamic>>> getAll() async {
    final res =
        await _dio.get<dynamic>(ApiEndpoints.warehouseShowAllMaterials);
    return _asList(res.data);
  }

  /// GET showMaterialDetails/{id}.
  Future<Map<String, dynamic>> getById(Object id) async {
    final res =
        await _dio.get<dynamic>(ApiEndpoints.warehouseShowMaterial(id));
    return _asData(res.data);
  }

  /// POST addMaterial → المادة المُنشأة. body: {name, unit, price, description?}.
  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final res = await _dio.post<dynamic>(
      ApiEndpoints.warehouseAddMaterial,
      data: FormData.fromMap(body),
    );
    return _asData(res.data);
  }

  /// POST updateMaterial/{id} → المادة المُحدَّثة.
  Future<Map<String, dynamic>> update(
      Object id, Map<String, dynamic> body) async {
    final res = await _dio.post<dynamic>(
      ApiEndpoints.warehouseUpdateMaterial(id),
      data: FormData.fromMap(body),
    );
    return _asData(res.data);
  }

  /// DELETE materials/{id}.
  Future<void> delete(Object id) async {
    await _dio.delete<dynamic>(ApiEndpoints.warehouseDeleteMaterial(id));
  }

  List<Map<String, dynamic>> _asList(Object? data) {
    final list = (data is Map) ? data['data'] : null;
    if (list is! List) return <Map<String, dynamic>>[];
    return list
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Map<String, dynamic> _asData(Object? data) {
    final inner = (data is Map) ? data['data'] : null;
    if (inner is Map) return Map<String, dynamic>.from(inner);
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }
}
