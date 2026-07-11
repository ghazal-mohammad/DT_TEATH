// ════════════════════════════════════════════════════════════════════════════
// lab_stock_remote_datasource.dart
//
// مصدر بيانات مخزون المخبر البعيد — يتصل مباشرة بـ Dio. التوكن يُضاف تلقائياً
// عبر interceptor. يرجّع JSON خام؛ التحويل لـ entity في الـ repository.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/endpoints.dart';

class LabStockRemoteDataSource {
  LabStockRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /api/labManager/showLabStock → مواد المخزون الخام.
  Future<List<Map<String, dynamic>>> getAll() async {
    final res = await _dio.get<dynamic>(ApiEndpoints.labManagerShowLabStock);
    return _asList(res.data);
  }

  /// POST /api/labManager/addToStock/{id} — إضافة كمية.
  Future<void> add(Object id, double quantity, {String? notes}) async {
    await _dio.post<dynamic>(
      ApiEndpoints.labManagerAddToStock(id),
      data: FormData.fromMap({
        'quantity': quantity,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      }),
    );
  }

  /// POST /api/labManager/subtractFromStock/{id} — خصم كمية.
  Future<void> subtract(Object id, double quantity, {String? notes}) async {
    await _dio.post<dynamic>(
      ApiEndpoints.labManagerSubtractFromStock(id),
      data: FormData.fromMap({
        'quantity': quantity,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      }),
    );
  }

  /// GET /api/labManager/showLabStockLogs → سجلّ حركات المخزون (مُصفّح).
  /// الرد مُصفّح Laravel: العناصر تحت `data`.
  Future<List<Map<String, dynamic>>> getLogs() async {
    final res =
        await _dio.get<dynamic>(ApiEndpoints.labManagerShowLabStockLogs);
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
