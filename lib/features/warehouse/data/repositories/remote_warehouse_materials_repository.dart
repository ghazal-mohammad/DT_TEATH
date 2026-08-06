// ════════════════════════════════════════════════════════════════════════════
// remote_warehouse_materials_repository.dart
//
// تنفيذ Remote لـ WarehouseMaterialsRepository عبر warehouseManager/* (فُعِّلت
// 2026-08). يستبدل Mock بتغيير سطر التسجيل في DI فقط.
//
// ملاحظة فجوة الباك: قائمة showALLMaterials (formatMaterial) لا تُرجع الفئة ولا
// الحدّ الأدنى للمخزون — فنضع الفئة الافتراضية (consumables) وminStock=0 (لا
// حالة "منخفض" زائفة) حتى يوفّرهما الباك.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core/network/failure.dart';
import '../../../../core/session/session_cache_registry.dart';
import '../../domain/entities/material_category.dart';
import '../../domain/entities/warehouse_material.dart';
import '../../domain/repositories/warehouse_materials_repository.dart';
import '../datasources/warehouse_materials_remote_datasource.dart';

class RemoteWarehouseMaterialsRepository
    implements WarehouseMaterialsRepository {
  RemoteWarehouseMaterialsRepository(this._remote) {
    _controller =
        StreamController<List<WarehouseMaterial>>.broadcast(onListen: _emit);
    SessionCacheRegistry.instance.register(_clearCache);
  }

  final WarehouseMaterialsRemoteDataSource _remote;
  late final StreamController<List<WarehouseMaterial>> _controller;
  List<WarehouseMaterial> _cache = const [];

  void _clearCache() {
    _cache = const [];
    _emit();
  }

  void _emit() {
    if (!_controller.isClosed) _controller.add(List.unmodifiable(_cache));
  }

  @override
  Future<List<WarehouseMaterial>> getAll() async {
    try {
      final raw = await _remote.getAll();
      _cache = raw.map(_fromJson).toList();
      _emit();
      return List.unmodifiable(_cache);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<WarehouseMaterial> getById(String id) async {
    try {
      return _fromJson(await _remote.getById(id));
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<WarehouseMaterial> create(WarehouseMaterial material) async {
    try {
      final created = _fromJson(await _remote.create(_toBody(material)));
      _cache = [..._cache, created];
      _emit();
      return created;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<WarehouseMaterial> update(WarehouseMaterial material) async {
    try {
      final updated =
          _fromJson(await _remote.update(material.id, _toBody(material)));
      _cache = _cache
          .map((m) => m.id == updated.id ? updated : m)
          .toList(growable: false);
      _emit();
      return updated;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _remote.delete(id);
      _cache = _cache.where((m) => m.id != id).toList(growable: false);
      _emit();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Stream<List<WarehouseMaterial>> watchAll() => _controller.stream;

  // ── تحويل ──────────────────────────────────────────────────────────────
  WarehouseMaterial _fromJson(Map<String, dynamic> j) {
    return WarehouseMaterial(
      id: '${j['id'] ?? ''}',
      name: (j['name'] ?? '').toString(),
      // الباك لا يوفّر الفئة في القائمة → افتراضي محايد حتى إضافتها.
      category: materialCategoryFromString('${j['category'] ?? ''}') ??
          MaterialCategory.consumables,
      quantity: _toInt(j['total_stock'] ?? j['quantity']),
      unit: (j['unit'] ?? '').toString(),
      minStock: _toInt(j['min_stock']), // غائب حالياً ⇒ 0.
      price: _toDouble(j['price']),
      notes: (j['description'] ?? '').toString().isEmpty
          ? null
          : j['description'].toString(),
    );
  }

  /// body الإرسال — الباك يقبل {name, unit, price, description} فقط.
  Map<String, dynamic> _toBody(WarehouseMaterial m) => {
        'name': m.name,
        'unit': m.unit,
        'price': m.price ?? 0,
        if (m.notes != null && m.notes!.isNotEmpty) 'description': m.notes,
      };

  static int _toInt(Object? v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
  static double? _toDouble(Object? v) =>
      v is num ? v.toDouble() : double.tryParse('${v ?? ''}');

  Failure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const TimeoutFailure();
    }
    if (e.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return ServerFailure(data['message'] as String,
          code: '${e.response?.statusCode ?? ''}');
    }
    return const ServerFailure('تعذّر تنفيذ العملية على المستودع.');
  }
}
