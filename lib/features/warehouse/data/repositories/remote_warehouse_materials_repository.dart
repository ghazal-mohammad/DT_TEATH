// ════════════════════════════════════════════════════════════════════════════
// remote_warehouse_materials_repository.dart
//
// تنفيذ Remote لـ WarehouseMaterialsRepository عبر warehouseManager/* (فُعِّلت
// 2026-08). يستبدل Mock بتغيير سطر التسجيل في DI فقط.
//
// عقد الباك (formatMaterial): {id, name, name_en, company_name, price_per_unit,
// dosage, unit, category(clinic|lab|both), total_stock, batches_count}. الحدّ
// الأدنى للمخزون غير موجود بالباك ⇒ minStock=0 (لا حالة "منخفض" زائفة).
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

  // ── تحويل (مطابق لعقد الباك: formatMaterial) ────────────────────────────
  WarehouseMaterial _fromJson(Map<String, dynamic> j) {
    final nameEn = (j['name_en'] ?? '').toString();
    final dosage = (j['dosage'] ?? '').toString();
    return WarehouseMaterial(
      id: '${j['id'] ?? ''}',
      name: (j['name'] ?? '').toString(),
      nameEn: nameEn.isEmpty ? null : nameEn,
      companyName: (j['company_name'] ?? '').toString(),
      // إن غابت الفئة (استجابة قديمة) نضع clinic كافتراضي آمن.
      category: materialCategoryFromString('${j['category'] ?? ''}') ??
          MaterialCategory.clinic,
      quantity: _toInt(j['total_stock'] ?? j['quantity']),
      unit: (j['unit'] ?? '').toString(),
      pricePerUnit: _toDouble(j['price_per_unit']) ?? 0,
      dosage: dosage.isEmpty ? null : dosage,
      batchesCount: _toInt(j['batches_count']),
    );
  }

  /// body الإرسال — مطابق لـ StoreMaterialRequest:
  /// name, name_en?, company_name, price_per_unit, dosage?, unit, category.
  Map<String, dynamic> _toBody(WarehouseMaterial m) => {
        'name': m.name,
        if (m.nameEn != null && m.nameEn!.isNotEmpty) 'name_en': m.nameEn,
        'company_name': m.companyName,
        'price_per_unit': m.pricePerUnit,
        if (m.dosage != null && m.dosage!.isNotEmpty) 'dosage': m.dosage,
        'unit': m.unit,
        'category': m.category.apiKey,
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
