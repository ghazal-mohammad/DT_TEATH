import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dt_teeth/core/offline/persistent_cache.dart';
import 'package:dt_teeth/features/lab/data/datasources/lab_material_requests_remote_datasource.dart';
import 'package:dt_teeth/features/lab/data/repositories/remote_lab_material_requests_repository.dart';
import 'package:dt_teeth/features/lab/domain/entities/lab_material_request.dart';

class _MockDataSource extends Mock
    implements LabMaterialRequestsRemoteDataSource {}

class _MockCache extends Mock implements PersistentCache {}

void main() {
  late _MockDataSource ds;
  late _MockCache cache;
  late RemoteLabMaterialRequestsRepository repo;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    ds = _MockDataSource();
    cache = _MockCache();
    when(() => cache.load(any())).thenAnswer((_) async => null);
    when(() => cache.save(any(), any())).thenAnswer((_) async {});
    repo = RemoteLabMaterialRequestsRepository(ds, cache);
  });

  test('getAll يحوّل فاتورة بعدة items[] كاملةً — بلا قصّ لأول عنصر', () async {
    when(() => ds.getAll()).thenAnswer(
      (_) async => [
        {
          'id': 1,
          'status': 'new',
          'requester': {'name': 'أحمد'},
          'requester_type': 'lab',
          'notes': 'طلب شهري',
          'items': <Map<String, dynamic>>[
            {
              'id': 1,
              'material': 'زركون',
              'quantity_requested': 10,
              'notes': 'ملاحظة',
            },
            {'id': 2, 'material': 'جبس', 'quantity_requested': 5},
          ],
          'new_items': <Map<String, dynamic>>[],
          'created_at': '2026-08-19 10:00:00',
        },
      ],
    );

    final result = await repo.getAll();

    expect(result, hasLength(1));
    final req = result.first;
    expect(req.items, hasLength(2));
    expect(req.items[0].materialName, 'زركون');
    expect(req.items[0].quantityRequested, 10);
    expect(req.items[1].materialName, 'جبس');
    expect(req.requestedBy, 'أحمد');
    expect(req.date, '2026-08-19');
    expect(req.status, MatRequestStatus.newRequest);
  });

  test('getAll يحوّل فاتورة بعدة new_items[] كاملةً', () async {
    when(() => ds.getAll()).thenAnswer(
      (_) async => [
        {
          'id': 2,
          'status': 'pending',
          'requester': {'name': 'سارة'},
          'requester_type': 'lab',
          'items': <Map<String, dynamic>>[],
          'new_items': <Map<String, dynamic>>[
            {
              'id': 1,
              'material_name': 'صمغ',
              'quantity': 3,
              'unit': 'علبة',
              'company_name': 'دنتال سوريا',
            },
            {
              'id': 2,
              'material_name': 'قفازات',
              'quantity': 20,
              'unit': 'علبة',
              'company_name': 'دنتال سوريا',
            },
          ],
          'created_at': '2026-08-19 11:00:00',
        },
      ],
    );

    final result = await repo.getAll();

    expect(result.first.newItems, hasLength(2));
    expect(result.first.status, MatRequestStatus.inProgress);
    expect(
      result.first.newItems.every((i) => i.companyName == 'دنتال سوريا'),
      isTrue,
    );
  });

  test(
    'addRequestFromWarehouse يبني items[] بمفاتيح صحيحة ويرسل JSON',
    () async {
      when(() => ds.create(any())).thenAnswer((_) async {});
      when(() => ds.getAll()).thenAnswer((_) async => []);

      await repo.addRequestFromWarehouse(
        items: const [
          (materialId: 1, quantity: 10, notes: null),
          (materialId: 2, quantity: 5, notes: 'مستعجل'),
        ],
        notes: 'طلب شهري',
      );

      final captured =
          verify(() => ds.create(captureAny())).captured.single
              as Map<String, dynamic>;
      expect(captured['notes'], 'طلب شهري');
      expect(captured['items'], [
        {'material_id': 1, 'quantity_requested': 10},
        {'material_id': 2, 'quantity_requested': 5, 'notes': 'مستعجل'},
      ]);
      expect(captured.containsKey('new_items'), isFalse);
    },
  );

  test('addRequestFromCompany يكرّر اسم الشركة بكل عنصر', () async {
    when(() => ds.create(any())).thenAnswer((_) async {});
    when(() => ds.getAll()).thenAnswer((_) async => []);

    await repo.addRequestFromCompany(
      companyName: 'شركة دنتال سوريا',
      items: const [
        (materialName: 'صمغ', quantity: 3, unit: 'علبة', reason: 'نحتاجها'),
        (materialName: 'قفازات', quantity: 20, unit: 'علبة', reason: null),
      ],
    );

    final captured =
        verify(() => ds.create(captureAny())).captured.single
            as Map<String, dynamic>;
    final newItems = captured['new_items'] as List;
    expect(newItems, hasLength(2));
    expect(
      newItems.every((i) => (i as Map)['company_name'] == 'شركة دنتال سوريا'),
      isTrue,
    );
    expect((newItems[0] as Map)['reason'], 'نحتاجها');
    expect((newItems[1] as Map).containsKey('reason'), isFalse);
    expect(captured.containsKey('items'), isFalse);
  });

  test('getOne يحوّل فاتورة واحدة كاملة', () async {
    when(() => ds.getOne(5)).thenAnswer(
      (_) async => {
        'id': 5,
        'status': 'completed',
        'requester': {'name': 'أحمد'},
        'requester_type': 'lab',
        'items': <Map<String, dynamic>>[
          {'id': 1, 'material': 'زركون', 'quantity_requested': 10},
        ],
        'new_items': <Map<String, dynamic>>[],
        'created_at': '2026-08-19 09:00:00',
      },
    );

    final req = await repo.getOne('5');
    expect(req.id, '5');
    expect(req.status, MatRequestStatus.delivered);
    expect(req.items.single.materialName, 'زركون');
  });

  test('getWarehouseMaterial يحوّل مادة واحدة', () async {
    when(() => ds.getWarehouseMaterial(3)).thenAnswer(
      (_) async => {'material_id': 3, 'material': 'زركون', 'unit': 'كيلو'},
    );

    final ref = await repo.getWarehouseMaterial(3);
    expect(ref.materialId, 3);
    expect(ref.name, 'زركون');
    expect(ref.unit, 'كيلو');
  });
}
