// ════════════════════════════════════════════════════════════════════════════
// remote_warehouse_inventory_repository.dart
//
// تنفيذ Remote لمؤشّرات المخزون: يجلب stock-levels + stock-value معاً (بالتوازي)
// ويدمجهما في InventorySummary. مع كاش دائم بسيط ليصمد أوفلاين على اللوحة.
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

  static const String _cacheKey = 'cache.v1.warehouse_inventory_summary';

  @override
  Future<InventorySummary> getSummary() async {
    try {
      final results = await Future.wait([
        _remote.stockLevels(),
        _remote.stockValue(),
      ]);
      final summary =
          InventorySummary.from(levels: results[0], value: results[1]);
      await _saveCache(summary);
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

  Future<void> _saveCache(InventorySummary s) async {
    try {
      await _store.write(
        _cacheKey,
        jsonEncode({
          'total_materials': s.totalMaterials,
          'low_stock_count': s.lowStockCount,
          'normal_stock_count': s.normalStockCount,
          'expired_batches': s.expiredBatches,
          'total_value': s.totalValue,
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
        levels: {
          'summary': {
            'total_materials': j['total_materials'],
            'low_stock_count': j['low_stock_count'],
            'normal_stock_count': j['normal_stock_count'],
            'expired_batches': j['expired_batches'],
          }
        },
        value: {
          'summary': {'total_value': j['total_value']}
        },
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
