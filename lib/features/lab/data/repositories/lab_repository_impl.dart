// ════════════════════════════════════════════════════════════════════════════
// lab_repository_impl.dart
//
// تنفيذ LabRepository. يستدعي LabRemoteDataSource ويحوّل أخطاء Dio لـ Failure
// واضحة قبل رفعها للـ presentation.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/failure.dart';
import '../../../../core/session/session_cache_registry.dart';
import '../../domain/entities/technician_performance.dart';
import '../../domain/repositories/lab_repository.dart';
import '../datasources/lab_remote_datasource.dart';
import '../models/lab_technician.dart';

class LabRepositoryImpl implements LabRepository {
  LabRepositoryImpl(this._remote) {
    SessionCacheRegistry.instance.register(() => _cache = null);
  }

  final LabRemoteDataSource _remote;

  /// كاش بالذاكرة لآخر قائمة فنّيين (null = لم تُحمَّل بعد).
  List<LabTechnician>? _cache;

  @override
  List<LabTechnician>? get cachedTechnicians => _cache;

  @override
  Future<List<LabTechnician>> getTechnicians() async {
    try {
      final raw = await _remote.showAllTechnicians();
      final list = raw.map(LabTechnician.fromJson).toList();
      _cache = list;
      return list;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<LabTechnician> getTechnician(int id) async {
    try {
      final raw = await _remote.showTechnician(id);
      return LabTechnician.fromJson(raw);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> updateTechnicianSchedule(
    int id,
    List<Map<String, String>> schedule,
  ) async {
    try {
      await _remote.updateTechnicianWorkSchedule(id, schedule);
      // نُبطل كاش الفنّيين ليعاد جلبه بجدول محدّث عند العرض التالي.
      _cache = null;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<TechnicianPerformance>> getTechniciansPerformance({
    String? from,
    String? to,
  }) async {
    try {
      final raw =
          await _remote.showTechniciansPerformance(from: from, to: to);
      return raw.map(TechnicianPerformance.fromJson).toList(growable: false);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// تحويل DioException لـ Failure مناسب (نفس منطق طبقة الـ auth).
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
    if (data is Map && data['message'] is String) {
      return ServerFailure(data['message'] as String, code: '$status');
    }
    return ServerFailure.fromStatusCode(status);
  }
}
