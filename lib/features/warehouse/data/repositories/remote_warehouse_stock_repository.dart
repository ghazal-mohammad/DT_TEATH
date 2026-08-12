// ════════════════════════════════════════════════════════════════════════════
// remote_warehouse_stock_repository.dart
//
// تنفيذ Remote لـ WarehouseStockRepository عبر warehouseManager/*Stock*.
// أونلاين-أولاً (عمليات الدفعات تعتمد منطق الباك)، مع تحويل DioException لـ
// Failure واضح.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/material_stock.dart';
import '../../domain/repositories/warehouse_stock_repository.dart';
import '../datasources/warehouse_stock_remote_datasource.dart';

class RemoteWarehouseStockRepository implements WarehouseStockRepository {
  RemoteWarehouseStockRepository(this._remote);

  final WarehouseStockRemoteDataSource _remote;

  @override
  Future<MaterialStock> getStockDetails(String materialId) async {
    try {
      return MaterialStock.fromJson(await _remote.getStockDetails(materialId));
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> adjustBatch({
    required String batchId,
    required bool isIn,
    required int quantity,
    required StockMovementReason reason,
    String? notes,
  }) async {
    try {
      await _remote.adjustBatch(batchId, {
        'type': isIn ? 'in' : 'out',
        'quantity': quantity,
        'reason': reason.apiKey,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });
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
    // الباك يرجّع رسائل واضحة (كمية غير كافية، مادة غير موجودة…) — نعرضها.
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return ServerFailure(data['message'] as String,
          code: '${e.response?.statusCode ?? ''}');
    }
    return const ServerFailure('تعذّر تنفيذ عملية المخزون.');
  }
}
