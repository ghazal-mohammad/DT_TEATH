// اختبار: فشل create/update/delete بـ MaterialsCubit يجب أن يظهر عبر actionError
// منفصل عن حالة التحميل الرئيسية (لا يحوّل status إلى error ويخفي القائمة
// المحمّلة أصلاً) — كان الخطأ يُكتب بالـ state بلا أي مكان يعرضه للمستخدم.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dt_teeth/core/network/failure.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/material_category.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/warehouse_material.dart';
import 'package:dt_teeth/features/warehouse/domain/repositories/warehouse_materials_repository.dart';
import 'package:dt_teeth/features/warehouse/presentation/bloc/materials_cubit.dart';
import 'package:dt_teeth/features/warehouse/presentation/bloc/materials_state.dart';

class _MockRepo extends Mock implements WarehouseMaterialsRepository {}

void main() {
  late _MockRepo repo;
  late MaterialsCubit cubit;

  const material = WarehouseMaterial(
    id: '1',
    name: 'قفازات',
    companyName: 'الأمل',
    category: MaterialCategory.clinic,
    quantity: 40,
    unit: 'قطعة',
    pricePerUnit: 1000,
  );

  setUpAll(() {
    registerFallbackValue(material);
  });

  setUp(() {
    repo = _MockRepo();
    when(() => repo.getAll()).thenAnswer((_) async => [material]);
    when(() => repo.watchAll()).thenAnswer((_) => const Stream.empty());
    cubit = MaterialsCubit(repository: repo);
  });

  tearDown(() => cubit.close());

  test('create يفشل ⇒ actionError دون تغيير status أو القائمة المحمّلة',
      () async {
    await cubit.load();
    when(() => repo.create(any()))
        .thenThrow(const ServerFailure('تحقق من الحقول المطلوبة', code: '422'));

    await cubit.create(material);

    expect(cubit.state.status, MaterialsStatus.loaded);
    expect(cubit.state.materials, [material]);
    expect(cubit.state.actionError, 'تحقق من الحقول المطلوبة');
  });

  test('update يفشل ⇒ actionError دون تغيير status', () async {
    await cubit.load();
    when(() => repo.update(any()))
        .thenThrow(const ServerFailure('خطأ في السيرفر — حاول مرة أخرى بعد قليل', code: '500'));

    await cubit.update(material);

    expect(cubit.state.status, MaterialsStatus.loaded);
    expect(cubit.state.actionError, 'خطأ في السيرفر — حاول مرة أخرى بعد قليل');
  });

  test('delete يفشل ⇒ actionError دون تغيير status', () async {
    await cubit.load();
    when(() => repo.delete(any()))
        .thenThrow(const ServerFailure('العنصر المطلوب غير موجود', code: '404'));

    await cubit.delete('1');

    expect(cubit.state.status, MaterialsStatus.loaded);
    expect(cubit.state.actionError, 'العنصر المطلوب غير موجود');
  });

  test('create ينجح ⇒ actionError يبقى null', () async {
    await cubit.load();
    when(() => repo.create(any())).thenAnswer((_) async => material);

    await cubit.create(material);

    expect(cubit.state.actionError, isNull);
  });
}
