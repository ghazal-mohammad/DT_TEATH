// ════════════════════════════════════════════════════════════════════════════
// remote_warehouse_requests_repository.dart
//
// تنفيذ Remote لـ WarehouseRequestsRepository. القراءة عبر كاش دائم (تعود لآخر
// نسخة عند الانقطاع)؛ التلبية/الرفض أونلاين-أولاً (منطق خصم FIFO على الباك).
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/failure.dart';
import '../../../../core/offline/cached_list_repository.dart';
import '../../../../core/offline/persistent_cache.dart';
import '../../../../core/session/session_cache_registry.dart';
import '../../domain/entities/warehouse_request.dart';
import '../../domain/repositories/warehouse_requests_repository.dart';
import '../datasources/warehouse_requests_remote_datasource.dart';

class RemoteWarehouseRequestsRepository
    with PersistentListCache
    implements WarehouseRequestsRepository {
  RemoteWarehouseRequestsRepository(this._remote, this.persistentCache) {
    SessionCacheRegistry.instance.register(_clearCache);
  }

  @override
  final PersistentCache persistentCache;

  @override
  String get cacheResource => 'warehouse_requests';

  final WarehouseRequestsRemoteDataSource _remote;
  List<WarehouseRequest> _cache = const [];

  void _clearCache() {
    _cache = const [];
  }

  @override
  Future<List<WarehouseRequest>> getAll() async {
    try {
      final raw = await _remote.getAll();
      _cache = raw.map(WarehouseRequest.fromJson).toList();
      await saveCachedRows(raw);
      return List.unmodifiable(_cache);
    } on DioException catch (e) {
      final failure = _mapDioError(e);
      if (failure is NetworkFailure || failure is TimeoutFailure) {
        final cached = await loadCachedRows();
        if (cached != null) {
          _cache = cached.map(WarehouseRequest.fromJson).toList();
          return List.unmodifiable(_cache);
        }
      }
      throw failure;
    }
  }

  @override
  Future<void> fulfill(String id, {String? notes}) async {
    try {
      await _remote.fulfill(id, notes: notes);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> reject(String id, {required String reason}) async {
    try {
      await _remote.reject(id, reason: reason);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> markPending(String id) async {
    try {
      await _remote.markPending(id);
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
    if (e.response == null) return const NetworkFailure();
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return ServerFailure(data['message'] as String,
          code: '${e.response?.statusCode ?? ''}');
    }
    return const ServerFailure('تعذّر تنفيذ عملية الطلب.');
  }
}
