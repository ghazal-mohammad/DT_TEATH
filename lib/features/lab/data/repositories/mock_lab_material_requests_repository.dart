// ════════════════════════════════════════════════════════════════════════════
// mock_lab_material_requests_repository.dart
//
// تنفيذ mock لـ [LabMaterialRequestsRepository] ببيانات في الذاكرة + stream.
// يُستبدل بـ Remote عند ربط الباك. البذرة هنا (نُقلت من ملف الـ data).
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import '../../domain/entities/lab_material_request.dart';
import '../../domain/entities/warehouse_material_ref.dart';
import '../../domain/repositories/lab_material_requests_repository.dart';

/// تنفيذ mock للـ repository — يخزّن الطلبات في الذاكرة (تضيع عند restart).
class MockLabMaterialRequestsRepository
    implements LabMaterialRequestsRepository {
  MockLabMaterialRequestsRepository() {
    _requests = [..._seed()];
    _controller = StreamController<List<MatRequest>>.broadcast(onListen: _emit);
  }

  late List<MatRequest> _requests;
  late final StreamController<List<MatRequest>> _controller;

  static const _mockLatency = Duration(milliseconds: 80);

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_requests));
    }
  }

  @override
  List<MatRequest>? get cached => List.unmodifiable(_requests);

  @override
  Future<List<MatRequest>> getAll() async {
    await Future<void>.delayed(_mockLatency);
    return List.unmodifiable(_requests);
  }

  @override
  Future<List<WarehouseMaterialRef>> getWarehouseMaterials() async {
    await Future<void>.delayed(_mockLatency);
    return const [
      WarehouseMaterialRef(materialId: 1, name: 'زركون بلوك A3', unit: 'بلوك'),
      WarehouseMaterialRef(materialId: 2, name: 'غراء طبي أبيض', unit: 'عبوة'),
      WarehouseMaterialRef(materialId: 3, name: 'جبس أخضر', unit: 'كغ'),
      WarehouseMaterialRef(materialId: 4, name: 'إيماكس بلوك', unit: 'بلوك'),
    ];
  }

  @override
  Future<void> addRequest({
    required String material,
    required String quantity,
    required String unit,
    required String requestedBy,
    int? materialId,
    String? company,
    String? reason,
  }) async {
    await Future<void>.delayed(_mockLatency);
    final request = MatRequest(
      id: 'MR-${(_requests.length + 1).toString().padLeft(3, '0')}',
      material: material,
      quantity: quantity,
      unit: unit,
      requestedBy: requestedBy,
      date: DateTime.now().toIso8601String().substring(0, 10),
      status: MatRequestStatus.newRequest,
      company: company,
      reason: reason,
    );
    _requests = [request, ..._requests];
    _emit();
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(_mockLatency);
    _requests = _requests.where((r) => r.id != id).toList();
    _emit();
  }

  @override
  Stream<List<MatRequest>> watchAll() => _controller.stream;

  // ── بذرة الطلبات (مؤقّتة حتى ربط الـ API) ─────────────────────────────────
  static List<MatRequest> _seed() => const [
        MatRequest(
          id: 'MR-001',
          material: 'زركون بلوك A3',
          quantity: '3',
          unit: 'بلوك',
          requestedBy: 'هشام علي',
          date: '2026-05-10',
          status: MatRequestStatus.newRequest,
          labOrderId: 'LAB-143',
        ),
        MatRequest(
          id: 'MR-002',
          material: 'غراء طبي أبيض',
          quantity: '2',
          unit: 'أنبوب',
          requestedBy: 'سامر شماع',
          date: '2026-05-09',
          status: MatRequestStatus.delivered,
          labOrderId: 'LAB-129',
        ),
        MatRequest(
          id: 'MR-003',
          material: 'سيليكون طبع A-Type',
          quantity: '1',
          unit: 'كيلو',
          requestedBy: 'أيار كريم',
          date: '2026-05-09',
          status: MatRequestStatus.unavailable,
          note: 'المادة غير موجودة — طُلبت من المورد',
        ),
        MatRequest(
          id: 'MR-004',
          material: 'أسلاك ربط أورثو',
          quantity: '10',
          unit: 'قطعة',
          requestedBy: 'هشام علي',
          date: '2026-05-08',
          status: MatRequestStatus.delivered,
          labOrderId: 'LAB-182',
        ),
        MatRequest(
          id: 'MR-005',
          material: 'ورنيش PFM',
          quantity: '1',
          unit: 'زجاجة',
          requestedBy: 'سامر شماع',
          date: '2026-05-07',
          status: MatRequestStatus.newRequest,
          labOrderId: 'LAB-168',
        ),
      ];
}
