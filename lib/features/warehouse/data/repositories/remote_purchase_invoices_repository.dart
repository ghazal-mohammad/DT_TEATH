// ════════════════════════════════════════════════════════════════════════════
// remote_purchase_invoices_repository.dart
//
// تنفيذ Remote لفواتير الشراء (عرض) — كاش قراءة دائم يصمد أوفلاين.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core/network/failure.dart';
import '../../../../core/offline/cached_list_repository.dart';
import '../../../../core/offline/persistent_cache.dart';
import '../../../../core/session/session_cache_registry.dart';
import '../../domain/entities/purchase_invoice.dart';
import '../../domain/repositories/purchase_invoices_repository.dart';
import '../datasources/purchase_invoices_remote_datasource.dart';

class RemotePurchaseInvoicesRepository
    with PersistentListCache
    implements PurchaseInvoicesRepository {
  RemotePurchaseInvoicesRepository(this._remote, this.persistentCache) {
    _controller =
        StreamController<List<PurchaseInvoice>>.broadcast(onListen: _emit);
    SessionCacheRegistry.instance.register(_clearCache);
  }

  @override
  final PersistentCache persistentCache;

  @override
  String get cacheResource => 'purchase_invoices';

  final PurchaseInvoicesRemoteDataSource _remote;
  late final StreamController<List<PurchaseInvoice>> _controller;
  List<PurchaseInvoice> _cache = const [];

  void _clearCache() {
    _cache = const [];
    _emit();
  }

  void _emit() {
    if (!_controller.isClosed) _controller.add(List.unmodifiable(_cache));
  }

  @override
  Future<List<PurchaseInvoice>> getAll() async {
    try {
      final raw = await _remote.getAll();
      _cache = raw.map(PurchaseInvoice.fromJson).toList();
      await saveCachedRows(raw);
      _emit();
      return List.unmodifiable(_cache);
    } on DioException catch (e) {
      final failure = _mapDioError(e);
      if (failure is NetworkFailure || failure is TimeoutFailure) {
        final cached = await loadCachedRows();
        if (cached != null) {
          _cache = cached.map(PurchaseInvoice.fromJson).toList();
          _emit();
          return List.unmodifiable(_cache);
        }
      }
      throw failure;
    }
  }

  @override
  Stream<List<PurchaseInvoice>> watchAll() => _controller.stream;

  @override
  Future<PurchaseInvoice> create({
    required String supplierName,
    required DateTime invoiceDate,
    required List<PurchaseInvoiceItemInput> items,
    String? notes,
  }) async {
    try {
      final created = PurchaseInvoice.fromJson(await _remote.create({
        'supplier_name': supplierName,
        'invoice_date': _formatDate(invoiceDate),
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        'items': items.map((i) => i.toJson()).toList(),
      }));
      _cache = [created, ..._cache];
      _emit();
      await saveCachedRows(_cache.map(_toCacheRow).toList());
      return created;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<PurchaseInvoice> update(
    String id, {
    String? supplierName,
    DateTime? invoiceDate,
    String? notes,
  }) async {
    try {
      final updated = PurchaseInvoice.fromJson(await _remote.update(id, {
        if (supplierName != null) 'supplier_name': supplierName,
        if (invoiceDate != null) 'invoice_date': _formatDate(invoiceDate),
        if (notes != null) 'notes': notes,
      }));
      _cache =
          _cache.map((i) => i.id == updated.id ? updated : i).toList();
      _emit();
      await saveCachedRows(_cache.map(_toCacheRow).toList());
      return updated;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// صفّ الكاش الدائم — بشكل formatInvoice كي يُعاد بناؤه بنفس [PurchaseInvoice.fromJson].
  Map<String, dynamic> _toCacheRow(PurchaseInvoice i) => {
        'id': i.id,
        'supplier_name': i.supplierName,
        'invoice_date': i.invoiceDate?.toIso8601String(),
        'total_amount': i.totalAmount,
        'notes': i.notes,
        'created_by': i.createdBy,
        'created_at': i.createdAt?.toIso8601String(),
        'items': i.items
            .map((it) => {
                  'id': it.id,
                  'material': it.materialName,
                  'unit': it.unit,
                  'quantity': it.quantity,
                  'unit_price': it.unitPrice,
                  'total_price': it.totalPrice,
                })
            .toList(),
      };

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
    return const ServerFailure('تعذّر جلب فواتير الشراء.');
  }
}
