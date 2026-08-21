import 'package:flutter_test/flutter_test.dart';
import 'package:dt_teeth/features/lab/domain/entities/lab_material_request.dart';

void main() {
  test('MatRequest بمواد مستودع متعددة — يحمل كل العناصر بلا قصّ', () {
    const req = MatRequest(
      id: '1',
      status: MatRequestStatus.newRequest,
      requestedBy: 'أحمد',
      requesterType: 'lab',
      date: '2026-08-19',
      notes: 'طلب شهري',
      items: [
        MatRequestItem(id: '1', materialName: 'زركون', quantityRequested: 10),
        MatRequestItem(id: '2', materialName: 'جبس', quantityRequested: 5),
      ],
      newItems: [],
    );

    expect(req.items.length, 2);
    expect(req.itemsCount, 2);
    expect(req.isFromWarehouse, isTrue);
    expect(req.isFromCompany, isFalse);
  });

  test('MatRequest بمواد شركة جديدة متعددة', () {
    const req = MatRequest(
      id: '2',
      status: MatRequestStatus.newRequest,
      requestedBy: 'سارة',
      requesterType: 'lab',
      date: '2026-08-19',
      items: [],
      newItems: [
        MatRequestNewItem(
          id: '1',
          materialName: 'صمغ طبي خاص',
          quantity: 3,
          unit: 'علبة',
          companyName: 'شركة دنتال سوريا',
          reason: 'نحتاج هذه المادة',
        ),
        MatRequestNewItem(
          id: '2',
          materialName: 'قفازات خاصة',
          quantity: 20,
          unit: 'علبة',
          companyName: 'شركة دنتال سوريا',
        ),
      ],
    );

    expect(req.newItems.length, 2);
    expect(req.itemsCount, 2);
    expect(req.isFromCompany, isTrue);
    expect(req.isFromWarehouse, isFalse);
    expect(req.newItems.every((i) => i.companyName == 'شركة دنتال سوريا'), isTrue);
  });
}
