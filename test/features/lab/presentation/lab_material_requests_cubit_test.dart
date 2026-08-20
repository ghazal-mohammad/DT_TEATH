import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dt_teeth/features/lab/domain/entities/warehouse_material_ref.dart';
import 'package:dt_teeth/features/lab/domain/repositories/lab_material_requests_repository.dart';
import 'package:dt_teeth/features/lab/presentation/bloc/lab_material_requests_cubit.dart';
import 'package:dt_teeth/features/lab/presentation/bloc/lab_material_requests_state.dart';

class _MockRepo extends Mock implements LabMaterialRequestsRepository {}

void main() {
  late _MockRepo repo;
  late LabMaterialRequestsCubit cubit;

  setUp(() {
    repo = _MockRepo();
    when(() => repo.cached).thenReturn(null);
    when(() => repo.getAll()).thenAnswer((_) async => []);
    when(() => repo.watchAll()).thenAnswer((_) => const Stream.empty());
    cubit = LabMaterialRequestsCubit(repository: repo);
  });

  tearDown(() => cubit.close());

  test('load ينجح بتحميل الكتالوج ⇒ catalogError يبقى null', () async {
    when(() => repo.getWarehouseMaterials())
        .thenAnswer((_) async => const [WarehouseMaterialRef(materialId: 1, name: 'زركون', unit: 'كيلو')]);

    await cubit.load();

    expect(cubit.state.status, LabMatRequestsStatus.loaded);
    expect(cubit.state.catalog, hasLength(1));
    expect(cubit.state.catalogError, isNull);
  });

  test('فشل تحميل الكتالوج ⇒ catalogError يُملأ (لا يتبلع بصمت)', () async {
    when(() => repo.getWarehouseMaterials()).thenThrow(Exception('network'));

    await cubit.load();

    expect(cubit.state.status, LabMatRequestsStatus.loaded);
    expect(cubit.state.catalogError, isNotNull);
  });

  test('addRequestFromWarehouse ينجح ⇒ true + إعادة تصفير الفلتر', () async {
    when(() => repo.getWarehouseMaterials()).thenAnswer((_) async => []);
    when(() => repo.addRequestFromWarehouse(items: any(named: 'items'), notes: any(named: 'notes')))
        .thenAnswer((_) async {});
    await cubit.load();

    final ok = await cubit.addRequestFromWarehouse(
        items: const [(materialId: 1, quantity: 5, notes: null)]);

    expect(ok, isTrue);
    expect(cubit.state.filterIndex, 0);
  });

  test('addRequestFromCompany يفشل ⇒ false + errorMessage', () async {
    when(() => repo.getWarehouseMaterials()).thenAnswer((_) async => []);
    when(() => repo.addRequestFromCompany(
          companyName: any(named: 'companyName'),
          items: any(named: 'items'),
          notes: any(named: 'notes'),
        )).thenThrow(Exception('server error'));
    await cubit.load();

    final ok = await cubit.addRequestFromCompany(
      companyName: 'شركة',
      items: const [(materialName: 'مادة', quantity: 1, unit: 'قطعة', reason: null)],
    );

    expect(ok, isFalse);
    expect(cubit.state.errorMessage, isNotNull);
  });
}
