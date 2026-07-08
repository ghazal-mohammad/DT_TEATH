// ════════════════════════════════════════════════════════════════════════════
// lab_material_requests_remote_datasource.dart
//
// مصدر بيانات طلبات المواد البعيد (منظور المخبر) — يتصل مباشرة بـ Dio.
// التوكن يُضاف تلقائياً عبر interceptor. يرجّع JSON خام؛ التحويل في الـ repository.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/endpoints.dart';

class LabMaterialRequestsRemoteDataSource {
  LabMaterialRequestsRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /api/labManager/showAllMaterialRequests → طلبات المخبر الخام.
  Future<List<Map<String, dynamic>>> getAll() async {
    final res =
        await _dio.get<dynamic>(ApiEndpoints.labManagerShowAllMaterialRequests);
    return _asList(res.data);
  }

  /// POST /api/labManager/addMaterialRequest — إنشاء طلب مواد.
  /// [body] يُرسَل كـ FormData (Dio يرمّز new_items[i][key] تلقائياً).
  Future<void> create(Map<String, dynamic> body) async {
    await _dio.post<dynamic>(
      ApiEndpoints.labManagerAddMaterialRequest,
      data: FormData.fromMap(body),
    );
  }

  /// POST /api/labManager/deleteMaterialRequest/{id} → حذف طلب مواد.
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

  List<Map<String, dynamic>> _asList(Object? data) {
    final list = (data is Map) ? data['data'] : null;
    if (list is! List) return <Map<String, dynamic>>[];
    return list
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
