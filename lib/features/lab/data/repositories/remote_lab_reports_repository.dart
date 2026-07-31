// ════════════════════════════════════════════════════════════════════════════
// remote_lab_reports_repository.dart
//
// تنفيذ Remote لـ [LabReportsRepository] — يجلب التقرير عبر
// [LabReportsRemoteDataSource] ويحوّله لـ [LabReport]، ويحوّل أخطاء Dio لـ Failure.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/lab_report.dart';
import '../../domain/repositories/lab_reports_repository.dart';
import '../datasources/lab_reports_remote_datasource.dart';

class RemoteLabReportsRepository implements LabReportsRepository {
  RemoteLabReportsRepository(this._remote);

  final LabReportsRemoteDataSource _remote;

  @override
  Future<LabReport> getReport(ReportPeriod period, {String? date}) async {
    try {
      final json = await _remote.getReports(period.apiValue, date: date);
      return LabReport.fromJson(json);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Failure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const TimeoutFailure();
    }
    if (e.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }
    final status = e.response?.statusCode;
    if (status == null) return const NetworkFailure();
    final data = e.response?.data;
    final msg = (data is Map && data['message'] is String)
        ? data['message'] as String
        : null;
    return ServerFailure(msg ?? 'تعذّر جلب التقرير', code: '$status');
  }
}
