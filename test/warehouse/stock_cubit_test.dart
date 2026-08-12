import 'package:dt_teeth/core/network/failure.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/material_stock.dart';
import 'package:dt_teeth/features/warehouse/domain/repositories/warehouse_stock_repository.dart';
import 'package:dt_teeth/features/warehouse/presentation/bloc/stock_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements WarehouseStockRepository {}

void main() {
  late _MockRepo repo;

  MaterialStock stock(int total) => MaterialStock(
        materialId: '1',
        name: 'قفازات',
        unit: 'قطعة',
        companyName: 'الأمل',
        totalQuantity: total,
        batches: const [],
      );

  setUpAll(() => registerFallbackValue(StockMovementReason.adjustment));

  setUp(() => repo = _MockRepo());

  test('load ينجح ⇒ حالة loaded مع البيانات', () async {
    when(() => repo.getStockDetails('1')).thenAnswer((_) async => stock(40));
    final cubit = StockCubit(repo, '1');
    await cubit.load();
    expect(cubit.state.status, StockStatus.loaded);
    expect(cubit.state.stock?.totalQuantity, 40);
  });

  test('load يفشل ⇒ حالة error برسالة', () async {
    when(() => repo.getStockDetails('1'))
        .thenThrow(const ServerFailure('غير موجود', code: '404'));
    final cubit = StockCubit(repo, '1');
    await cubit.load();
    expect(cubit.state.status, StockStatus.error);
    expect(cubit.state.errorMessage, 'غير موجود');
  });

  test('adjustBatch يفشل ⇒ actionError دون رفع changed', () async {
    when(() => repo.adjustBatch(
        batchId: any(named: 'batchId'),
        isIn: any(named: 'isIn'),
        quantity: any(named: 'quantity'),
        reason: any(named: 'reason'),
        notes: any(named: 'notes'))).thenThrow(
      const ServerFailure('الكمية غير كافية', code: '422'),
    );

    final cubit = StockCubit(repo, '1');
    final ok = await cubit.adjustBatch(
      batchId: 'b1',
      isIn: false,
      quantity: 100,
      reason: StockMovementReason.adjustment,
    );
    expect(ok, isFalse);
    expect(cubit.changed, isFalse);
    expect(cubit.state.actionError, 'الكمية غير كافية');
  });
}
