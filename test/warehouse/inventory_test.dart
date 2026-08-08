import 'package:dt_teeth/core/network/failure.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/inventory_summary.dart';
import 'package:dt_teeth/features/warehouse/domain/repositories/warehouse_inventory_repository.dart';
import 'package:dt_teeth/features/warehouse/presentation/bloc/inventory_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements WarehouseInventoryRepository {}

void main() {
  group('InventorySummary.from', () {
    test('يدمج القوائم الثلاث (mostRequested/expiringSoon/lowStock)', () {
      final s = InventorySummary.from(
        mostRequested: {
          'data': [
            {
              'material_id': 1,
              'name': 'قفازات',
              'unit': 'كرتونة',
              'request_count': 5,
              'total_quantity': 20,
            },
          ],
        },
        expiringSoon: {
          'data': {
            'days': 20,
            'batches_count': 1,
            'batches': [
              {
                'batch_id': 7,
                'material_id': 1,
                'name': 'قفازات',
                'unit': 'كرتونة',
                'quantity': 10,
                'expiration_date': '2026-08-20',
                'days_remaining': 12,
              },
            ],
          },
        },
        lowStock: {
          'data': {
            'threshold': 10,
            'count': 1,
            'items': [
              {
                'material_id': 2,
                'name': 'كمامات',
                'unit': 'علبة',
                'total_quantity': 3,
                'is_out': false,
              },
            ],
          },
        },
      );

      expect(s.mostRequested, hasLength(1));
      expect(s.mostRequested.single.name, 'قفازات');
      expect(s.mostRequested.single.requestCount, 5);

      expect(s.expiringCount, 1);
      expect(s.expiringBatches.single.daysRemaining, 12);
      expect(s.expiringBatches.single.expirationDate, DateTime(2026, 8, 20));

      expect(s.lowStockCount, 1);
      expect(s.lowStockItems.single.name, 'كمامات');
      expect(s.lowStockItems.single.isOut, isFalse);
    });

    test('يتحمّل غياب الحقول ⇒ قوائم فارغة', () {
      final s = InventorySummary.from(
        mostRequested: {},
        expiringSoon: {},
        lowStock: {},
      );
      expect(s.mostRequested, isEmpty);
      expect(s.expiringBatches, isEmpty);
      expect(s.lowStockItems, isEmpty);
      expect(s.expiringCount, 0);
      expect(s.lowStockCount, 0);
    });

    test('يقبل قيماً نصّية للأعداد (الباك يرسل decimals كنصوص أحياناً)', () {
      final s = InventorySummary.from(
        mostRequested: {
          'data': [
            {
              'material_id': 1,
              'name': 'مادة',
              'unit': 'قطعة',
              'request_count': '5',
              'total_quantity': '20',
            },
          ],
        },
        expiringSoon: {},
        lowStock: {},
      );
      expect(s.mostRequested.single.requestCount, 5);
      expect(s.mostRequested.single.totalQuantity, 20);
    });
  });

  group('InventoryCubit', () {
    late _MockRepo repo;
    setUp(() => repo = _MockRepo());

    test('load ينجح ⇒ loaded مع الملخّص', () async {
      when(() => repo.getSummary()).thenAnswer((_) async => const InventorySummary(
            mostRequested: [],
            expiringBatches: [],
            lowStockItems: [
              LowStockMaterial(
                materialId: '1',
                name: 'مادة',
                unit: 'قطعة',
                totalQuantity: 2,
                isOut: false,
              ),
            ],
          ));
      final cubit = InventoryCubit(repo);
      await cubit.load();
      expect(cubit.state.status, InventoryStatus.loaded);
      expect(cubit.state.summary?.lowStockCount, 1);
    });

    test('load يفشل ⇒ error بلا كسر (summary يبقى null)', () async {
      when(() => repo.getSummary()).thenThrow(const NetworkFailure());
      final cubit = InventoryCubit(repo);
      await cubit.load();
      expect(cubit.state.status, InventoryStatus.error);
      expect(cubit.state.summary, isNull);
    });
  });
}
