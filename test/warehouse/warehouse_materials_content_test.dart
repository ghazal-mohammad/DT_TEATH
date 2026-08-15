// اختبار: فشل إنشاء/تعديل/حذف مادة يجب أن يظهر كـ SnackBar للمستخدم — كان
// الخطأ يُكتب بالـ state بصمت بلا أي عرض.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/material_category.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/warehouse_material.dart';
import 'package:dt_teeth/features/warehouse/domain/repositories/warehouse_materials_repository.dart';
import 'package:dt_teeth/features/warehouse/presentation/bloc/materials_cubit.dart';
import 'package:dt_teeth/features/warehouse/presentation/widgets/materials/warehouse_materials_content.dart';

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

  setUp(() {
    repo = _MockRepo();
    when(() => repo.getAll()).thenAnswer((_) async => [material]);
    when(() => repo.watchAll()).thenAnswer((_) => const Stream.empty());
    cubit = MaterialsCubit(repository: repo);
  });

  tearDown(() => cubit.close());

  testWidgets('فشل حذف مادة يظهر كـ SnackBar', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await cubit.load();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: const WarehouseMaterialsContent(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    cubit.emit(cubit.state
        .copyWith(actionError: 'العنصر المطلوب غير موجود'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('العنصر المطلوب غير موجود'), findsOneWidget);
  });
}
