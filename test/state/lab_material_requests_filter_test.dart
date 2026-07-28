// اختبار وحدة: فلترة طلبات المواد — فلتر الحالة + البحث النصّي معًا.

import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/features/lab/domain/entities/lab_material_request.dart';
import 'package:dt_teeth/features/lab/presentation/bloc/lab_material_requests_state.dart';

MatRequest _req(
  String id,
  String material,
  MatRequestStatus status, {
  String? company,
}) =>
    MatRequest(
      id: id,
      material: material,
      quantity: '1',
      unit: 'قطعة',
      requestedBy: 'x',
      date: '2026-01-01',
      status: status,
      company: company,
    );

void main() {
  final data = [
    _req('MR-001', 'زركون', MatRequestStatus.newRequest, company: 'شام'),
    _req('MR-002', 'جبس', MatRequestStatus.delivered),
    _req('MR-003', 'زركون بلوك', MatRequestStatus.unavailable),
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

  test('البحث بالمادة يطابق جزئيًا', () {
    final f = state(q: 'زركون').filtered;
    expect(f.map((r) => r.id), containsAll(['MR-001', 'MR-003']));
    expect(f.length, 2);
  });

  test('البحث بالرقم وبالشركة', () {
    expect(state(q: 'MR-002').filtered.single.material, 'جبس');
    expect(state(q: 'شام').filtered.single.id, 'MR-001');
  });

  test('الحالة + البحث معًا (تقاطع)', () {
    // جديد + "زركون" ⇒ MR-001 فقط (MR-003 غير متوفّر لا جديد).
    final f = state(filter: 1, q: 'زركون').filtered;
    expect(f.single.id, 'MR-001');
  });

  test('بحث بلا نتيجة ⇒ فارغ', () {
    expect(state(q: 'لا يوجد').filtered, isEmpty);
  });
}
