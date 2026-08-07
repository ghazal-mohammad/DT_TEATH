// ════════════════════════════════════════════════════════════════════════════
// warehouse_requests_remote_datasource.dart
//
// مصدر بيانات طلبات المواد الواردة للمستودع — warehouseManager/*MaterialRequest*.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/endpoints.dart';

class WarehouseRequestsRemoteDataSource {
  WarehouseRequestsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> getAll() async {
    final res =
        await _dio.get<dynamic>(ApiEndpoints.warehouseShowAllMaterialRequests);
    return _asList(res.data);
  }

  Future<void> fulfill(Object id, {String? notes}) async {
    await _dio.post<dynamic>(
      ApiEndpoints.warehouseFulfillMaterialRequest(id),
      data: FormData.fromMap({if (notes != null && notes.isNotEmpty) 'notes': notes}),
    );
  }

  Future<void> reject(Object id, {required String reason}) async {
    await _dio.post<dynamic>(
      ApiEndpoints.warehouseRejectMaterialRequest(id),
      data: FormData.fromMap({'reason': reason}),
    );
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
