// ════════════════════════════════════════════════════════════════════════════
// remote_lab_stock_repository.dart
//
// تنفيذ Remote لـ [LabStockRepository] — يجلب مخزون المخبر ويضيف/يخصم الكميات
// عبر [LabStockRemoteDataSource]، ويطابق العقد (نفس الواجهة + stream).
//
// مطابقة العقد (تحقّق فعلي 2026-06-24):
//   GET showLabStock → [{id, material_id, material, unit, quantity, is_low,
//                        expiration_date}].
//   addToStock/subtractFromStock يقبلان {quantity (numeric ≥0.01), notes?}؛
//   الخصم يرجّع 422 إن تجاوز المتاح. نُعيد الجلب بعد كل عملية ليعكس الـ stream
//   حقيقة الباك (هو مصدر is_low والكميات).
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/lab_stock.dart';
import '../../domain/entities/lab_stock_log.dart';
import '../../domain/repositories/lab_stock_repository.dart';
import '../../../../core/session/session_cache_registry.dart';
import '../datasources/lab_stock_remote_datasource.dart';

class RemoteLabStockRepository implements LabStockRepository {
  RemoteLabStockRepository(this._remote) {
    _controller = StreamController<List<LabStock>>.broadcast(onListen: _emit);
    SessionCacheRegistry.instance.register(_clearCache);
  }

  /// يمسح كاش الجلسة (يُستدعى عند تسجيل الخروج) — منعًا لتسريب بيانات مستخدم لآخر.
  void _clearCache() {
    _cache = const [];
    _loaded = false;
    _emit();
  }

  final LabStockRemoteDataSource _remote;
  late final StreamController<List<LabStock>> _controller;
  List<LabStock> _cache = const [];

  /// هل جُلب المخزون مرة على الأقل؟ (لتمييز "لم يُحمَّل" عن "مُحمَّل وفارغ").
  bool _loaded = false;

  @override
  List<LabStock>? get cached => _loaded ? List.unmodifiable(_cache) : null;

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_cache));
    }
  }

  @override
  Future<List<LabStockLog>> getLogs() async {
    try {
      final raw = await _remote.getLogs();
      return raw
          .map((m) => LabStockLog(
                id: '${m['id'] ?? ''}',
                type: (m['type'] ?? '').toString(),
                quantity: int.tryParse('${m['quantity'] ?? ''}') ?? 0,
                materialName: (m['material_name'] ?? '').toString(),
                unit: (m['unit'] ?? '').toString(),
                reason: (m['reason'] ?? '').toString(),
                notes: (m['notes'] ?? '').toString(),
                createdAt: (m['created_at'] ?? '').toString(),
              ))
          .toList(growable: false);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<LabStock>> getAll() async {
    try {
      final raw = await _remote.getAll();
      _cache = raw.map(_fromJson).toList();
      _loaded = true;
      _emit();
      return List.unmodifiable(_cache);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> addQuantity({
    required String id,
    required double quantity,
    String? notes,
  }) async {
    try {
      await _remote.add(id, quantity, notes: notes);
      await getAll();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> subtractQuantity({
    required String id,
    required double quantity,
    String? notes,
  }) async {
    try {
      await _remote.subtract(id, quantity, notes: notes);
      await getAll();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Stream<List<LabStock>> watchAll() => _controller.stream;

  // ── تحويل JSON → entity ──────────────────────────────────────────────────

  LabStock _fromJson(Map<String, dynamic> j) => LabStock(
        id: '${j['id'] ?? ''}',
        materialId: _toInt(j['material_id']),
        material: (j['material'] ?? '').toString(),
        unit: (j['unit'] ?? '').toString(),
        quantity: _toDouble(j['quantity']),
        isLow: j['is_low'] == true,
        expirationDate: (j['expiration_date'] as String?)?.isNotEmpty == true
            ? j['expiration_date'] as String
            : null,
      );

  static int _toInt(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('${v ?? ''}') ?? 0;
  }

  static double _toDouble(Object? v) {
    if (v is num) return v.toDouble();
    return double.tryParse('${v ?? ''}') ?? 0;
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
    if (data is Map && data['message'] is String) {
      return ServerFailure(data['message'] as String, code: '$status');
    }
    return ServerFailure.fromStatusCode(status);
  }
}
