// ════════════════════════════════════════════════════════════════════════════
// remote_lab_products_repository.dart
//
// تنفيذ Remote لـ [LabProductsRepository] — يجلب/ينشئ/يحدّث منتجات المخبر من
// الباك عبر [LabProductsRemoteDataSource]، ويحوّل أخطاء Dio لـ Failure واضحة.
//
// يطابق عقد MockLabProductsRepository تماماً (نفس الواجهة + stream) فالـ UI لا
// يلاحظ الفرق — التبديل بينهما يتمّ في الـ DI فقط.
//
// مطابقة العقد مع الباك (تحقّق فعلي 2026-06-24):
//   - الصنف يرجع: {id, category{}, name, name_en, type, material,
//                  price:"99000.00"(نص), duration:"3"(نص), is_active}.
//   - الإنشاء/التحديث يقبلان: name,type,material,price,duration (category_id
//     و name_en اختياريان) — فحقول نموذج LabProduct الحالية تكفي بلا تغيير UI.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/lab_product.dart';
import '../../domain/repositories/lab_products_repository.dart';
import '../datasources/lab_products_remote_datasource.dart';

class RemoteLabProductsRepository implements LabProductsRepository {
  RemoteLabProductsRepository(this._remote) {
    _controller = StreamController<List<LabProduct>>.broadcast(
      onListen: _emit,
    );
  }

  final LabProductsRemoteDataSource _remote;
  late final StreamController<List<LabProduct>> _controller;

  /// نسخة بالذاكرة من الكتالوج — مصدر التحديثات للـ stream بعد كل عملية.
  List<LabProduct> _cache = const [];

  /// هل جُلب الكتالوج مرة على الأقل؟ (لتمييز "لم يُحمَّل" عن "مُحمَّل وفارغ").
  bool _loaded = false;

  @override
  List<LabProduct>? get cached => _loaded ? List.unmodifiable(_cache) : null;

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_cache));
    }
  }

  @override
  Future<List<LabProduct>> getAll() async {
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
  Future<LabProduct> create(LabProduct product) async {
    try {
      final json = await _remote.create(_toBody(product));
      final created = _fromJson(json);
      _cache = [..._cache, created];
      _emit();
      return created;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<LabProduct> update(LabProduct product) async {
    try {
      final json = await _remote.update(product.id, _toBody(product));
      final updated = _fromJson(json);
      _cache = _cache
          .map((p) => p.id == updated.id ? updated : p)
          .toList(growable: false);
      _emit();
      return updated;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Stream<List<LabProduct>> watchAll() => _controller.stream;

  // ── تحويل JSON ↔ entity ──────────────────────────────────────────────────

  /// يحوّل صنف الباك إلى [LabProduct]. price/duration قد يرجعان نصوصاً.
  LabProduct _fromJson(Map<String, dynamic> j) => LabProduct(
        id: '${j['id'] ?? ''}',
        name: (j['name'] ?? '').toString(),
        type: (j['type'] ?? '').toString(),
        material: (j['material'] ?? '').toString(),
        price: _toInt(j['price']),
        productionDays: _toInt(j['duration']),
      );

  /// جسم الطلب للإنشاء/التحديث (الحقول التي يقبلها الباك من نموذجنا).
  Map<String, dynamic> _toBody(LabProduct p) => {
        'name': p.name,
        'type': p.type,
        'material': p.material,
        'price': p.price,
        'duration': p.productionDays,
      };

  static int _toInt(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return double.tryParse('${v ?? ''}')?.toInt() ??
        int.tryParse('${v ?? ''}') ??
        0;
  }

  /// تحويل DioException لـ Failure مناسب (نفس منطق طبقة الـ auth/lab).
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
