// ════════════════════════════════════════════════════════════════════════════
// remote_warehouse_inventory_repository.dart
//
// تنفيذ Remote لمؤشّرات المخزون: يجلب mostRequested + expiringSoon + lowStock
// معاً (بالتوازي) ويدمجها في InventorySummary. مع كاش دائم بسيط ليصمد أوفلاين.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/network/failure.dart';
import '../../../../core/offline/local_store.dart';
import '../../domain/entities/inventory_summary.dart';
import '../../domain/repositories/warehouse_inventory_repository.dart';
import '../datasources/warehouse_inventory_remote_datasource.dart';

class RemoteWarehouseInventoryRepository
    implements WarehouseInventoryRepository {
  RemoteWarehouseInventoryRepository(this._remote, this._store);

  final WarehouseInventoryRemoteDataSource _remote;
  final LocalStore _store;

  static const String _cacheKey = 'cache.v2.warehouse_inventory_summary';

  @override
  Future<InventorySummary> getSummary() async {
    try {
      final results = await Future.wait([
        _remote.mostRequested(),
        _remote.expiringSoon(),
        _remote.lowStock(),
      ]);
      final summary = InventorySummary.from(
        mostRequested: results[0],
        expiringSoon: results[1],
        lowStock: results[2],
      );
      await _saveCache(results[0], results[1], results[2]);
      return summary;
    } on DioException catch (e) {
      final failure = _mapDioError(e);
      if (failure is NetworkFailure || failure is TimeoutFailure) {
        final cached = await _loadCache();
        if (cached != null) return cached;
      }
      throw failure;
    }
  }

  Future<void> _saveCache(
    Map<String, dynamic> mostRequested,
    Map<String, dynamic> expiringSoon,
    Map<String, dynamic> lowStock,
  ) async {
    try {
      await _store.write(
        _cacheKey,
        jsonEncode({
          'most_requested': mostRequested,
          'expiring_soon': expiringSoon,
          'low_stock': lowStock,
        }),
      );
    } catch (_) {/* الكاش مساعِد */}
  }

  Future<InventorySummary?> _loadCache() async {
    try {
      final raw = await _store.read(_cacheKey);
      if (raw == null || raw.isEmpty) return null;
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return InventorySummary.from(
        mostRequested: Map<String, dynamic>.from(j['most_requested'] as Map),
        expiringSoon: Map<String, dynamic>.from(j['expiring_soon'] as Map),
        lowStock: Map<String, dynamic>.from(j['low_stock'] as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Failure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const TimeoutFailure();
    }
    if (e.type == DioExceptionType.connectionError || e.response == null) {
      return const NetworkFailure();
    }
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return ServerFailure(data['message'] as String,
          code: '${e.response?.statusCode ?? ''}');
    }
    return const ServerFailure('تعذّر جلب مؤشّرات المخزون.');
  }
}
