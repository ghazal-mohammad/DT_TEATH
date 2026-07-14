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

  /// GET /api/labManager/showTechniciansPerformance → تقرير أداء الفنّيين.
  /// [from]/[to] اختياريان (yyyy-MM-dd)؛ الافتراضي بالباك = الشهر الحالي.
  Future<List<Map<String, dynamic>>> showTechniciansPerformance({
    String? from,
    String? to,
  }) async {
    final res = await _dio.get<dynamic>(
      ApiEndpoints.labManagerShowTechniciansPerformance,
      queryParameters: {
        if (from != null && from.isNotEmpty) 'from': from,
        if (to != null && to.isNotEmpty) 'to': to,
      },
    );
    final list = (res.data is Map) ? res.data['data'] : null;
    if (list is! List) return <Map<String, dynamic>>[];
    return list
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// GET /api/labManager/showTechnician/{id} → فنّي واحد كامل (مع الجدول).
  Future<Map<String, dynamic>> showTechnician(Object id) async {
    final res =
        await _dio.get<dynamic>(ApiEndpoints.labManagerShowTechnician(id));
    final inner = (res.data is Map) ? res.data['data'] : null;
    return inner is Map ? Map<String, dynamic>.from(inner) : {};
  }

  /// POST /api/labManager/updateTechnicianWorkSchedule/{id}
  /// [schedule] عناصرها {day_of_week, start_time (H:i), end_time (H:i)}.
  Future<void> updateTechnicianWorkSchedule(
    Object id,
    List<Map<String, String>> schedule,
  ) async {
    // FormData يرمّز schedule[i][key] تلقائياً — يطابق توقّع الباك (array).
    final form = <String, dynamic>{};
    for (var i = 0; i < schedule.length; i++) {
      schedule[i].forEach((k, v) => form['schedule[$i][$k]'] = v);
    }
    await _dio.post<dynamic>(
      ApiEndpoints.labManagerUpdateTechnicianWorkSchedule(id),
      data: FormData.fromMap(form),
    );
  }
}
