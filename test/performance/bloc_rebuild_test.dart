// اختبار: BlocSelector يجنّب rebuild الويدجت التي لا تعتمد إلا على حقل واحد
// من الـ state (activeFilter) عند تغيّر حقول أخرى غير ذات صلة (searchQuery).
//
// يبني widget tree حقيقي فيه:
//   1. BlocBuilder بدون buildWhen — يعيد البناء عند أي emit (baseline).
//   2. BlocSelector يختار state.activeFilter فقط — يجب ألا يعيد البناء
//      عندما يتغيّر searchQuery فقط.
//
// العدّادات حقيقية (تُزاد داخل builder فعلياً عند كل استدعاء)، وليست أرقاماً
// محسوبة من ثوابت وهمية كما كان بالاختبار القديم المحذوف.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dt_teeth/features/warehouse/domain/entities/material_category.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/material_filter.dart';
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

  testWidgets(
    'BlocSelector consumer skips rebuild on unrelated searchQuery changes, '
    'while unscoped BlocBuilder rebuilds on every emit',
    (tester) async {
      // عدّادات حقيقية — تُزاد فعلياً داخل builder عند كل rebuild فعلي.
      var allBuildCount = 0;
      var filterOnlyBuildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: Column(
              children: [
                // 1) يعيد البناء عند أي state جديد (لا يوجد buildWhen).
                BlocBuilder<MaterialsCubit, MaterialsState>(
                  builder: (context, state) {
                    allBuildCount++;
                    return Text(
                      'materials:${state.materials.length}:builds:$allBuildCount',
                      key: const Key('allConsumer'),
                    );
                  },
                ),
                // 2) يعتمد فقط على activeFilter — يجب أن يتجاهل تغيّر searchQuery.
                BlocSelector<MaterialsCubit, MaterialsState, MaterialFilter>(
                  selector: (state) => state.activeFilter,
                  builder: (context, activeFilter) {
                    filterOnlyBuildCount++;
                    return Text(
                      'filter:${activeFilter.name}:builds:$filterOnlyBuildCount',
                      key: const Key('filterConsumer'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // البناء الأولي (frame واحد) لكلا الـ consumers.
      expect(allBuildCount, 1);
      expect(filterOnlyBuildCount, 1);

      // ملاحظة عن الـ double pump: bloc/Cubit يبثّ الـ state عبر
      // StreamController.broadcast() (توزيع غير متزامن/microtask)، فـ
      // pump() واحد لا يكفي دائماً لتفريغ الـ microtask queue بالكامل قبل
      // بناء الفريم التالي. نستخدم pumpTwice() لضمان استقرار كل rebuild
      // فعلي قبل قراءة العدّادات — تم التحقق تجريبياً أن هذا يعطي عدّاً
      // ثابتاً ومطابقاً لعدد الـ emits الفعلي.
      Future<void> pumpTwice() async {
        await tester.pump();
        await tester.pump();
      }

      // load() يصدر إشارتين داخلياً (loading ثم loaded) قبل أي pump من
      // الاختبار، فتُدمَج Flutter في rebuild واحد فقط عند الـ pump التالي.
      // activeFilter لا يتغيّر أثناء load() فلا يعيد BlocSelector البناء.
      await cubit.load();
      await pumpTwice();
      expect(allBuildCount, 2);
      expect(filterOnlyBuildCount, 1);

      // تغييرات searchQuery فقط — يجب أن تُحرّك الـ BlocBuilder غير المُقيَّد
      // فقط، وتترك BlocSelector (المرتبط بـ activeFilter) بلا تغيير.
      cubit.setSearchQuery('a');
      await pumpTwice();
      cubit.setSearchQuery('ab');
      await pumpTwice();
      cubit.setSearchQuery('abc');
      await pumpTwice();
      expect(allBuildCount, 5);
      expect(filterOnlyBuildCount, 1, reason: 'searchQuery فقط تغيّر — activeFilter لم يتغيّر');

      // تغيير activeFilter فعلياً — يجب أن يعيد BlocSelector البناء هذه المرّة.
      cubit.setFilter(MaterialFilter.lowStock);
      await pumpTwice();
      expect(allBuildCount, 6);
      expect(filterOnlyBuildCount, 2);

      // clearFilters يعيد activeFilter إلى all (تغيّر آخر لـ activeFilter)
      // بالإضافة لمسح searchQuery.
      cubit.clearFilters();
      await pumpTwice();
      expect(allBuildCount, 7);
      expect(filterOnlyBuildCount, 3);

      final avoidedRebuilds = allBuildCount - filterOnlyBuildCount;
      debugPrint(
        'bloc_rebuild_avoided=$avoidedRebuilds '
        'firstCounter=$allBuildCount secondCounter=$filterOnlyBuildCount',
      );

      // العدّادات حقيقية من widget tree حقيقي — لا نسب مُختلَقة من ثوابت.
      expect(
        filterOnlyBuildCount,
        lessThan(allBuildCount),
        reason:
            'الـ BlocSelector المرتبط بـ activeFilter فقط يجب أن يتجنّب '
            'rebuilds التي سبّبتها تغييرات searchQuery غير ذات الصلة',
      );
      expect(avoidedRebuilds, 4);
    },
  );
}
