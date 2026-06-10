// ════════════════════════════════════════════════════════════════════════════
// lab_remote_datasource.dart
//
// مصدر بيانات المخبر البعيد — يتصل مباشرة بـ Dio.
// التوكن يُضاف تلقائياً عبر interceptor في DioClient.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/endpoints.dart';

class LabRemoteDataSource {
  LabRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /api/labManager/showAllTechnicians
  /// يرجّع قائمة الـ data الخام (List of maps) من الرد.
  Future<List<Map<String, dynamic>>> showAllTechnicians() async {
    final response =
        await _dio.get<dynamic>(ApiEndpoints.labManagerShowAllTechnicians);
    final data = response.data;
    final list = (data is Map) ? data['data'] : null;
    if (list is! List) return <Map<String, dynamic>>[];
    return list
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
