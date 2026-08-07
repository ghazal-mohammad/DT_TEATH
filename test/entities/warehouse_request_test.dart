import 'package:dt_teeth/features/warehouse/domain/entities/warehouse_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WarehouseRequest.fromJson (MaterialRequestResource)', () {
    test('يقرأ الحالة + الطالب + العناصر (موجودة وجديدة)', () {
      final r = WarehouseRequest.fromJson({
        'id': 7,
        'status': 'new',
        'requester_type': 'lab',
        'notes': 'عاجل',
        'requester': {'id': 3, 'name': 'ليلى'},
        'items': [
          {'id': 1, 'material': 'قفازات', 'quantity_requested': 20, 'status': 'pending'},
        ],
        'new_items': [
          {'id': 9, 'material_name': 'مادة جديدة', 'quantity': 5, 'unit': 'علبة', 'company_name': 'الأمل'},
        ],
        'created_at': '2026-08-01 09:00:00',
      });
      expect(r.id, '7');
      expect(r.status, WarehouseRequestStatus.newReq);
      expect(r.requesterName, 'ليلى');
      expect(r.requesterType, 'lab');
      expect(r.items.single.materialName, 'قفازات');
      expect(r.items.single.quantityRequested, 20);
      expect(r.newItems.single.materialName, 'مادة جديدة');
      expect(r.newItems.single.unit, 'علبة');
      expect(r.itemsCount, 2);
      expect(r.notes, 'عاجل');
    });

    test('حالة غير معروفة ⇒ unknown، وقوائم غائبة ⇒ فارغة', () {
      final r = WarehouseRequest.fromJson({'id': 1, 'status': 'weird'});
      expect(r.status, WarehouseRequestStatus.unknown);
      expect(r.items, isEmpty);
      expect(r.newItems, isEmpty);
      expect(r.itemsCount, 0);
    });
  });

  group('صلاحيات الحالة', () {
    test('new: يمكن التلبية والرفض', () {
      expect(WarehouseRequestStatus.newReq.canFulfill, isTrue);
      expect(WarehouseRequestStatus.newReq.canReject, isTrue);
    });
    test('in_progress: يمكن التلبية لا الرفض', () {
      expect(WarehouseRequestStatus.inProgress.canFulfill, isTrue);
      expect(WarehouseRequestStatus.inProgress.canReject, isFalse);
    });
    test('completed/rejected: لا تلبية ولا رفض', () {
      expect(WarehouseRequestStatus.completed.canFulfill, isFalse);
      expect(WarehouseRequestStatus.rejected.canReject, isFalse);
    });
  });
}
