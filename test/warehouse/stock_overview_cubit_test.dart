// اختبار: StockOverviewCubit — يربط showAllStock (نظرة عامة) وshowStockLogs
// (سجل الحركة، بفلتر مادة اختياري) — endpoints موجودة بالباك بلا أي مستهلك
// بالفرونت قبل مراجعة ربط المستودع الشاملة (2026-08-15).

import 'package:dt_teeth/core/network/failure.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/stock_overview.dart';
import 'package:dt_teeth/features/warehouse/domain/repositories/warehouse_stock_repository.dart';
import 'package:dt_teeth/features/warehouse/presentation/bloc/stock_overview_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements WarehouseStockRepository {}

void main() {
  late _MockRepo repo;

  const overview = [
    StockOverviewItem(
      materialId: '1',
      name: 'قفازات',
      companyName: 'الأمل',
      unit: 'علبة',
      totalQuantity: 340,
      batchesCount: 3,
      isLow: false,
    ),
    StockOverviewItem(
      materialId: '2',
      name: 'بودرة',
      companyName: 'دنتونا',
      unit: 'كغ',
      totalQuantity: 5,
      batchesCount: 1,
      isLow: true,
    ),
  ];

  const logs = [
    StockLogEntry(id: '5', type: StockLogType.stockIn, quantity: 50),
  ];

  setUp(() => repo = _MockRepo());

  test('load ينجح ⇒ overview محمّل + السجل بلا فلتر', () async {
    when(() => repo.getAllStock()).thenAnswer((_) async => overview);
    when(() => repo.getLogs(materialId: any(named: 'materialId')))
        .thenAnswer((_) async => logs);

    final cubit = StockOverviewCubit(repo);
    await cubit.load();

    expect(cubit.state.status, StockOverviewStatus.loaded);
    expect(cubit.state.overview, overview);
    expect(cubit.state.logs, logs);
    verify(() => repo.getLogs(materialId: null)).called(1);
  });

  test('load يفشل ⇒ error برسالة', () async {
    when(() => repo.getAllStock())
        .thenThrow(const ServerFailure('تعذّر التحميل'));

    final cubit = StockOverviewCubit(repo);
    await cubit.load();

    expect(cubit.state.status, StockOverviewStatus.error);
    expect(cubit.state.errorMessage, 'تعذّر التحميل');
  });

  test('setLogsFilter يعيد تحميل السجل بمادة محدّدة فقط', () async {
    when(() => repo.getAllStock()).thenAnswer((_) async => overview);
    when(() => repo.getLogs(materialId: any(named: 'materialId')))
        .thenAnswer((_) async => logs);

    final cubit = StockOverviewCubit(repo);
    await cubit.load();
    await cubit.setLogsFilter('2');

    expect(cubit.state.logsFilterMaterialId, '2');
    verify(() => repo.getLogs(materialId: '2')).called(1);
  });
}
