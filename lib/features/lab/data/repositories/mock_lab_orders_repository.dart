// ════════════════════════════════════════════════════════════════════════════
// mock_lab_orders_repository.dart
//
// تنفيذ mock لـ [LabOrdersRepository] ببيانات في الذاكرة + broadcast stream.
// يطابق نمط MockWarehouseMaterialsRepository. يُستبدل بـ Remote عند ربط الباك.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import '../../domain/entities/lab_order.dart';
import '../../domain/repositories/lab_orders_repository.dart';

/// تنفيذ mock للـ repository — يخزّن الطلبات في الذاكرة (تضيع عند restart).
class MockLabOrdersRepository implements LabOrdersRepository {
  MockLabOrdersRepository() {
    _orders = _seed();
    _controller = StreamController<List<LabOrderFull>>.broadcast(
      onListen: _emit,
    );
  }

  late List<LabOrderFull> _orders;
  late final StreamController<List<LabOrderFull>> _controller;

  static const _mockLatency = Duration(milliseconds: 80);

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_orders));
    }
  }

  @override
  Future<List<LabOrderFull>> getAll() async {
    await Future<void>.delayed(_mockLatency);
    return List.unmodifiable(_orders);
  }

  @override
  Future<void> processOrder({
    required String id,
    required LabOrderBadgeVariant status,
    int? cost,
    String? technician,
  }) async {
    await Future<void>.delayed(_mockLatency);
    final order = _orders.firstWhere(
      (o) => o.id == id,
      orElse: () => throw StateError('LabOrder with id "$id" not found'),
    );
    order.statusVariant = status;
    if (cost != null) order.cost = cost;
    order.assignedTechnician = technician;
    _emit();
  }

  @override
  Stream<List<LabOrderFull>> watchAll() => _controller.stream;

  // ── بذرة الطلبات (مؤقّتة حتى ربط GET /api/lab/orders) ─────────────────────
  static List<LabOrderFull> _seed() => [
        LabOrderFull(
          id: 'LAB-045',
          doctor: 'د. سارة',
          type: 'تلبيسة',
          material: 'PFM',
          tooth: '#14',
          date: '27-03-2026',
          statusVariant: LabOrderBadgeVariant.newOrder,
          isUrgent: true,
          notes: 'سن مكسور — يلزم استعجال',
        ),
        LabOrderFull(
          id: 'LAB-044',
          doctor: 'د. خالد',
          type: 'جسر',
          material: 'Zirconia',
          tooth: '#14-12',
          date: '28-03-2026',
          statusVariant: LabOrderBadgeVariant.manufacturing,
        ),
        LabOrderFull(
          id: 'LAB-043',
          doctor: 'د. أحمد',
          type: 'تلبيسة',
          material: 'Metal',
          tooth: '#36',
          date: '30-03-2026',
          statusVariant: LabOrderBadgeVariant.ready,
        ),
        LabOrderFull(
          id: 'LAB-042',
          doctor: 'د. سارة',
          type: 'وجه',
          material: 'E-max',
          tooth: '#21',
          date: '27-03-2026',
          statusVariant: LabOrderBadgeVariant.manufacturing,
          isUrgent: true,
          notes: 'وجه أمامي — لون A2',
        ),
        LabOrderFull(
          id: 'LAB-041',
          doctor: 'د. ليلى',
          type: 'طقم',
          material: 'Acrylic',
          tooth: '#كامل',
          date: '02-04-2026',
          statusVariant: LabOrderBadgeVariant.newOrder,
        ),
        LabOrderFull(
          id: 'LAB-040',
          doctor: 'د. خالد',
          type: 'تلبيسة',
          material: 'Zirconia',
          tooth: '#26',
          date: '29-03-2026',
          statusVariant: LabOrderBadgeVariant.manufacturing,
        ),
      ];
}
