// اختبار وحدة: فلترة الفواتير — فلتر الحالة + البحث النصّي معًا (بمواد
// items[]/newItems[] كاملة، مو حقول مسطّحة).

import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/features/lab/domain/entities/lab_material_request.dart';
import 'package:dt_teeth/features/lab/presentation/bloc/lab_material_requests_state.dart';

MatRequest _fromWarehouse(String id, String material, MatRequestStatus status) => MatRequest(
      id: id,
      status: status,
      requestedBy: 'x',
      requesterType: 'lab',
      date: '2026-01-01',
      items: [MatRequestItem(id: '1', materialName: material, quantityRequested: 1)],
      newItems: const [],
    );

MatRequest _fromCompany(String id, String material, String company, MatRequestStatus status) => MatRequest(
      id: id,
      status: status,
      requestedBy: 'x',
      requesterType: 'lab',
      date: '2026-01-01',
      items: const [],
      newItems: [
        MatRequestNewItem(id: '1', materialName: material, quantity: 1, unit: 'قطعة', companyName: company),
      ],
    );

void main() {
  final data = [
    _fromWarehouse('MR-001', 'زركون', MatRequestStatus.newRequest),
    _fromWarehouse('MR-002', 'جبس', MatRequestStatus.delivered),
    _fromCompany('MR-003', 'زركون بلوك', 'شام', MatRequestStatus.unavailable),
  ];

  LabMaterialRequestsState state({int filter = 0, String q = ''}) =>
      LabMaterialRequestsState(
        status: LabMatRequestsStatus.loaded,
        requests: data,
        filterIndex: filter,
        searchQuery: q,
      );

  test('فلتر 0 = الكل', () {
    expect(state().filtered.length, 3);
  });

  test('فلتر الحالة (1=جديد)', () {
    final f = state(filter: 1).filtered;
    expect(f.length, 1);
    expect(f.first.id, 'MR-001');
  });

  test('البحث بمادة items[] يطابق جزئيًا', () {
    final f = state(q: 'زركون').filtered;
    expect(f.map((r) => r.id), containsAll(['MR-001', 'MR-003']));
    expect(f.length, 2);
  });

  test('البحث برقم الفاتورة', () {
    expect(state(q: 'MR-002').filtered.single.items.single.materialName, 'جبس');
  });

  test('البحث باسم الشركة (newItems فقط)', () {
    expect(state(q: 'شام').filtered.single.id, 'MR-003');
  });

  test('الحالة + البحث معًا (تقاطع)', () {
    final f = state(filter: 1, q: 'زركون').filtered;
    expect(f.single.id, 'MR-001');
  });

  test('بحث بلا نتيجة ⇒ فارغ', () {
    expect(state(q: 'لا يوجد').filtered, isEmpty);
  });
}
