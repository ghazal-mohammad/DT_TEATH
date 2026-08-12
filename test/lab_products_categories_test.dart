// اختبار: إدارة فئات أصناف المخبر (إضافة/تعديل/حذف) عبر LabProductsCubit —
// الباك جاهز (addItemCategory/updateItemCategory/deleteItemCategory) لكنه لم
// يكن موصولاً بالفلاتر إطلاقاً قبل هذا التغيير.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dt_teeth/core/network/failure.dart';
import 'package:dt_teeth/features/lab/domain/entities/lab_product.dart';
import 'package:dt_teeth/features/lab/domain/repositories/lab_products_repository.dart';
import 'package:dt_teeth/features/lab/presentation/bloc/lab_products_cubit.dart';

class _MockRepo extends Mock implements LabProductsRepository {}

void main() {
  late _MockRepo repo;
  setUp(() {
    repo = _MockRepo();
    when(() => repo.cached).thenReturn(null);
  });

  group('LabProductsCubit — فئات الأصناف', () {
    test('addCategory ينجح ⇒ يضيف الفئة الجديدة لقائمة categories', () async {
      when(() => repo.createCategory('زيركون'))
          .thenAnswer((_) async => const LabProductCategory(id: 9, name: 'زيركون'));
      final cubit = LabProductsCubit(repository: repo);

      final ok = await cubit.addCategory('زيركون');

      expect(ok, isTrue);
      expect(cubit.state.categories, [const LabProductCategory(id: 9, name: 'زيركون')]);
    });

    test('addCategory يفشل (اسم مكرر) ⇒ false مع رسالة خطأ، القائمة لا تتغيّر',
        () async {
      when(() => repo.createCategory('زيركون')).thenThrow(
          const ServerFailure('الاسم مستخدم من قبل', code: '422'));
      final cubit = LabProductsCubit(repository: repo);

      final ok = await cubit.addCategory('زيركون');

      expect(ok, isFalse);
      expect(cubit.state.categories, isEmpty);
      expect(cubit.state.errorMessage, 'الاسم مستخدم من قبل');
    });

    test('removeCategory يفشل (مرتبطة بأصناف) ⇒ false، الفئة تبقى بالقائمة',
        () async {
      when(() => repo.getAll()).thenAnswer((_) async => const []);
      when(() => repo.getCategories()).thenAnswer(
          (_) async => const [LabProductCategory(id: 3, name: 'Zirconia')]);
      when(() => repo.watchAll()).thenAnswer((_) => const Stream.empty());
      when(() => repo.deleteCategory(3)).thenThrow(
          const ServerFailure('لا يمكن حذف هذه الفئة لأنها مرتبطة بمنتجات',
              code: '422'));
      final cubit = LabProductsCubit(repository: repo);
      await cubit.load();

      final ok = await cubit.removeCategory(3);

      expect(ok, isFalse);
      expect(cubit.state.categories, hasLength(1));
    });
  });
}
