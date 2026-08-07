import 'package:dt_teeth/core/network/failure.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/inventory_summary.dart';
import 'package:dt_teeth/features/warehouse/domain/repositories/warehouse_inventory_repository.dart';
import 'package:dt_teeth/features/warehouse/presentation/bloc/inventory_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements WarehouseInventoryRepository {}

void main() {
  group('InventorySummary.from', () {
    test('يدمج summary من stock-levels + stock-value (مع غلاف data)', () {
      final s = InventorySummary.from(
        levels: {
          'data': {
            'summary': {
              'total_materials': 18,
              'low_stock_count': 3,
              'normal_stock_count': 15,
              'expired_batches': 2,
            }
          }
        },
        value: {
          'data': {
            'summary': {'total_value': 2850000}
          }
        },
      );
      expect(s.totalMaterials, 18);
      expect(s.lowStockCount, 3);
      expect(s.normalStockCount, 15);
      expect(s.expiredBatches, 2);
      expect(s.totalValue, 2850000);
    });

    test('يتحمّل غياب الحقول ⇒ أصفار', () {
      final s = InventorySummary.from(levels: {}, value: {});
      expect(s.totalMaterials, 0);
      expect(s.totalValue, 0);
    });

    test('يقبل قيمة نصّية للقيمة الكلّية', () {
      final s = InventorySummary.from(
        levels: {'summary': {'total_materials': '5'}},
        value: {'summary': {'total_value': '1234.50'}},
      );
      expect(s.totalMaterials, 5);
      expect(s.totalValue, 1234.5);
    });
  });

  group('InventoryCubit', () {
    late _MockRepo repo;
    setUp(() => repo = _MockRepo());

    test('load ينجح ⇒ loaded مع الملخّص', () async {
      when(() => repo.getSummary()).thenAnswer((_) async => const InventorySummary(
            totalMaterials: 10,
            lowStockCount: 1,
            normalStockCount: 9,
            expiredBatches: 0,
            totalValue: 500,
          ));
      final cubit = InventoryCubit(repo);
      await cubit.load();
      expect(cubit.state.status, InventoryStatus.loaded);
      expect(cubit.state.summary?.totalMaterials, 10);
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
