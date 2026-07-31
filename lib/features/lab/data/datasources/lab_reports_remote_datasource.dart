// ════════════════════════════════════════════════════════════════════════════
// lab_reports_remote_datasource.dart
//
// مصدر بيانات تقارير المخبر البعيد — GET labManager/reports.
// التوكن يُضاف تلقائياً عبر interceptor. يرجّع JSON خام؛ التحويل في الـ repository.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/endpoints.dart';

class LabReportsRemoteDataSource {
  LabReportsRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /api/labManager/reports?period=..&date=.. → خريطة التقرير الخام.
  /// [period] إلزامي (daily|weekly|monthly|yearly)؛ [date] اختياري (yyyy-MM-dd).
  Future<Map<String, dynamic>> getReports(String period, {String? date}) async {
    final res = await _dio.get<dynamic>(
      ApiEndpoints.labManagerReports,
      queryParameters: {
        'period': period,
        if (date != null && date.isNotEmpty) 'date': date,
      },
    );
    final data = res.data;
    return data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
  }
}
