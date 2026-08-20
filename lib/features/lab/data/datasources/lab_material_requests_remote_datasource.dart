// ════════════════════════════════════════════════════════════════════════════
// lab_material_requests_remote_datasource.dart
//
// مصدر بيانات فواتير طلب المواد البعيد (منظور المخبر) — يتصل مباشرة بـ Dio.
// التوكن يُضاف تلقائياً عبر interceptor. يرجّع JSON خام؛ التحويل في الـ repository.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/endpoints.dart';

class LabMaterialRequestsRemoteDataSource {
  LabMaterialRequestsRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /api/labManager/showAllMaterialRequests → فواتير المخبر الخام.
  Future<List<Map<String, dynamic>>> getAll() async {
    final res =
        await _dio.get<dynamic>(ApiEndpoints.labManagerShowAllMaterialRequests);
    return _asList(res.data);
  }

  /// GET /api/labManager/showMaterialRequest/{id} → فاتورة واحدة خام.
  Future<Map<String, dynamic>> getOne(Object id) async {
    final res =
        await _dio.get<dynamic>(ApiEndpoints.labManagerShowMaterialRequest(id));
    return _asMap(res.data);
  }

  /// POST /api/labManager/addMaterialRequest — إنشاء فاتورة.
  /// [body] يُرسَل كـ JSON خام (Map) — Dio يضبط Content-Type: application/json
  /// تلقائياً لأي body من نوع Map (راجع DioClient.build)، مطابقةً حرفية
  /// لتوثيق الـ API (خلافاً للسلوك القديم الذي كان يرسل FormData).
  Future<void> create(Map<String, dynamic> body) async {
    await _dio.post<dynamic>(
      ApiEndpoints.labManagerAddMaterialRequest,
      data: body,
    );
  }

  /// POST /api/labManager/deleteMaterialRequest/{id} → حذف فاتورة.
  Future<void> delete(Object id) async {
    await _dio
        .post<dynamic>(ApiEndpoints.labManagerDeleteMaterialRequest(id));
  }

  /// GET /api/labManager/showAllWarehouseMaterials → كتالوج مواد المستودع الخام.
  Future<List<Map<String, dynamic>>> getWarehouseMaterials() async {
    final res = await _dio
        .get<dynamic>(ApiEndpoints.labManagerShowAllWarehouseMaterials);
    return _asList(res.data);
  }

  /// GET /api/labManager/showWarehouseMaterial/{id} → مادة مستودع واحدة خام.
  Future<Map<String, dynamic>> getWarehouseMaterial(Object id) async {
    final res = await _dio
        .get<dynamic>(ApiEndpoints.labManagerShowWarehouseMaterial(id));
    return _asMap(res.data);
  }

  List<Map<String, dynamic>> _asList(Object? data) {
    final list = (data is Map) ? data['data'] : null;
    if (list is! List) return <Map<String, dynamic>>[];
    return list
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Map<String, dynamic> _asMap(Object? data) {
    final map = (data is Map) ? data['data'] : null;
    return map is Map ? Map<String, dynamic>.from(map) : <String, dynamic>{};
  }
}
