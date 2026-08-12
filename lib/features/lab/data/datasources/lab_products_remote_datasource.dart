// ════════════════════════════════════════════════════════════════════════════
// lab_products_remote_datasource.dart
//
// مصدر بيانات منتجات المخبر البعيد (Lab Items) — يتصل مباشرة بـ Dio.
// التوكن يُضاف تلقائياً عبر interceptor في DioClient. كل دالة ترجّع JSON خام
// (Map/List)؛ التحويل لـ entity من مسؤولية الـ repository.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/endpoints.dart';

class LabProductsRemoteDataSource {
  LabProductsRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /api/labManager/showAllLabItems → قائمة الأصناف الخام.
  Future<List<Map<String, dynamic>>> getAll() async {
    final res = await _dio.get<dynamic>(ApiEndpoints.labManagerShowAllLabItems);
    return _asList(res.data);
  }

  /// GET /api/labManager/showAllItemsCategories → فئات الأصناف الخام.
  Future<List<Map<String, dynamic>>> getCategories() async {
    final res = await _dio
        .get<dynamic>(ApiEndpoints.labManagerShowAllItemsCategories);
    return _asList(res.data);
  }

  /// POST /api/labManager/addItemCategory → الفئة المُنشأة (data).
  Future<Map<String, dynamic>> createCategory(String name) async {
    final res = await _dio.post<dynamic>(
      ApiEndpoints.labManagerAddItemCategory,
      data: FormData.fromMap({'name': name}),
    );
    return _asData(res.data);
  }

  /// POST /api/labManager/updateItemCategory/{id} → الفئة المُحدَّثة (data).
  Future<Map<String, dynamic>> updateCategory(Object id, String name) async {
    final res = await _dio.post<dynamic>(
      ApiEndpoints.labManagerUpdateItemCategory(id),
      data: FormData.fromMap({'name': name}),
    );
    return _asData(res.data);
  }

  /// POST /api/labManager/deleteItemCategory/{id} → حذف فئة.
  Future<void> deleteCategory(Object id) async {
    await _dio.post<dynamic>(ApiEndpoints.labManagerDeleteItemCategory(id));
  }

  /// POST /api/labManager/addLabItem → الصنف المُنشأ (data).
  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final res = await _dio.post<dynamic>(
      ApiEndpoints.labManagerAddLabItem,
      data: FormData.fromMap(body),
    );
    return _asData(res.data);
  }

  /// POST /api/labManager/updateLabItem/{id} → الصنف المُحدَّث (data).
  Future<Map<String, dynamic>> update(
    Object id,
    Map<String, dynamic> body,
  ) async {
    final res = await _dio.post<dynamic>(
      ApiEndpoints.labManagerUpdateLabItem(id),
      data: FormData.fromMap(body),
    );
    return _asData(res.data);
  }

  /// POST /api/labManager/deleteLabItem/{id} → حذف صنف.
  Future<void> delete(Object id) async {
    await _dio.post<dynamic>(ApiEndpoints.labManagerDeleteLabItem(id));
  }

  // ── مساعدات استخراج ──────────────────────────────────────────────────────

  /// يستخرج `data` كقائمة من ردّ `{success, data:[...]}`.
  List<Map<String, dynamic>> _asList(Object? data) {
    final list = (data is Map) ? data['data'] : null;
    if (list is! List) return <Map<String, dynamic>>[];
    return list
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// يستخرج `data` كـ Map من ردّ `{success, message, data:{...}}`.
  Map<String, dynamic> _asData(Object? data) {
    final inner = (data is Map) ? data['data'] : null;
    if (inner is Map) return Map<String, dynamic>.from(inner);
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }
}
