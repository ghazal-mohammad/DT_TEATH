// ════════════════════════════════════════════════════════════════════════════
// mock_lab_products_repository.dart
//
// تنفيذ mock لـ [LabProductsRepository] ببيانات في الذاكرة + broadcast stream.
// يطابق نمط MockWarehouseMaterialsRepository. يُستبدل بـ Remote عند ربط الباك.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import '../../domain/entities/lab_product.dart';
import '../../domain/repositories/lab_products_repository.dart';

/// تنفيذ mock للـ repository — يخزّن الكتالوج في الذاكرة (يضيع عند restart).
class MockLabProductsRepository implements LabProductsRepository {
  MockLabProductsRepository() {
    _products = List<LabProduct>.from(_seedData);
    _controller = StreamController<List<LabProduct>>.broadcast(
      onListen: _emit,
    );
  }

  late List<LabProduct> _products;
  late final StreamController<List<LabProduct>> _controller;

  /// محاكاة latency الشبكة.
  static const _mockLatency = Duration(milliseconds: 80);

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_products));
    }
  }

  @override
  Future<List<LabProduct>> getAll() async {
    await Future<void>.delayed(_mockLatency);
    return List.unmodifiable(_products);
  }

  @override
  Future<LabProduct> create(LabProduct product) async {
    await Future<void>.delayed(_mockLatency);
    final id = product.id.isEmpty
        ? 'P-${DateTime.now().millisecondsSinceEpoch % 100000}'
        : product.id;
    final created = product.copyWith(id: id);
    _products.add(created);
    _emit();
    return created;
  }

  @override
  Future<LabProduct> update(LabProduct product) async {
    await Future<void>.delayed(_mockLatency);
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index < 0) {
      throw StateError('LabProduct with id "${product.id}" not found');
    }
    _products[index] = product;
    _emit();
    return product;
  }

  @override
  Stream<List<LabProduct>> watchAll() => _controller.stream;

  // ── بذرة الكتالوج (مؤقّتة حتى ربط GET /api/lab/products) ──────────────────
  static const List<LabProduct> _seedData = [
    LabProduct(
      id: 'P-01',
      name: 'تلبيسة زيركون كاملة',
      type: 'تلبيسة',
      material: 'Zirconia',
      price: 120000,
      productionDays: 3,
    ),
    LabProduct(
      id: 'P-02',
      name: 'تلبيسة بورسلان على معدن',
      type: 'تلبيسة',
      material: 'PFM',
      price: 75000,
      productionDays: 4,
    ),
    LabProduct(
      id: 'P-03',
      name: 'جسر 3 وحدات زيركون',
      type: 'جسر',
      material: 'Zirconia',
      price: 330000,
      productionDays: 5,
    ),
    LabProduct(
      id: 'P-04',
      name: 'وجه إيماكس تجميلي',
      type: 'وجه (فينير)',
      material: 'E-max',
      price: 95000,
      productionDays: 4,
    ),
    LabProduct(
      id: 'P-05',
      name: 'طقم أكريل كامل',
      type: 'طقم',
      material: 'Acrylic',
      price: 250000,
      productionDays: 7,
    ),
    LabProduct(
      id: 'P-06',
      name: 'تلبيسة معدنية',
      type: 'تلبيسة',
      material: 'Metal',
      price: 45000,
      productionDays: 2,
    ),
  ];
}
