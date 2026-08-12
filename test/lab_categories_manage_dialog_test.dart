// اختبار: مودال إدارة فئات أصناف المخبر — إضافة/تعديل/حذف موصولة بالباك
// (labManager/addItemCategory, updateItemCategory, deleteItemCategory) عبر
// LabProductsCubit. كانت هذه الميزة غير موجودة إطلاقاً بالفلاتر رغم جهوزية
// الباك.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/core/network/failure.dart';
import 'package:dt_teeth/features/lab/domain/entities/lab_product.dart';
import 'package:dt_teeth/features/lab/domain/repositories/lab_products_repository.dart';
import 'package:dt_teeth/features/lab/presentation/bloc/lab_products_cubit.dart';
import 'package:dt_teeth/features/lab/presentation/widgets/products/lab_categories_manage_dialog.dart';

class _MockRepo extends Mock implements LabProductsRepository {}

Future<void> _pumpDialog(WidgetTester tester, LabProductsCubit cubit) async {
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () =>
                LabCategoriesManageDialog.show(context, cubit),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  late _MockRepo repo;
  setUp(() {
    repo = _MockRepo();
    when(() => repo.cached).thenReturn(null);
    when(() => repo.getAll()).thenAnswer((_) async => const []);
    when(() => repo.watchAll()).thenAnswer((_) => const Stream.empty());
  });

  testWidgets('إضافة فئة جديدة تظهر بالقائمة فوراً', (tester) async {
    when(() => repo.getCategories()).thenAnswer((_) async => const []);
    when(() => repo.createCategory('سيراميك'))
        .thenAnswer((_) async => const LabProductCategory(id: 5, name: 'سيراميك'));
    final cubit = LabProductsCubit(repository: repo);
    await cubit.load();

    await _pumpDialog(tester, cubit);

    await tester.enterText(find.byType(TextField).first, 'سيراميك');
    await tester.tap(find.text('إضافة'));
    await tester.pumpAndSettle();

    expect(find.text('سيراميك'), findsOneWidget);
  });

  testWidgets('حذف فئة مرفوض من الباك (مرتبطة بأصناف) ⇒ رسالة الباك تظهر، الفئة تبقى',
      (tester) async {
    when(() => repo.getCategories()).thenAnswer(
        (_) async => const [LabProductCategory(id: 3, name: 'Zirconia')]);
    when(() => repo.deleteCategory(3)).thenThrow(const ServerFailure(
        'لا يمكن حذف هذه الفئة لأنها مرتبطة بمنتجات', code: '422'));
    final cubit = LabProductsCubit(repository: repo);
    await cubit.load();

    await _pumpDialog(tester, cubit);
    expect(find.text('Zirconia'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();
    // تأكيد الحذف بمربع الحوار الفرعي.
    await tester.tap(find.text('حذف'));
    await tester.pump(); // يغلق مربع التأكيد وينفّذ الطلب
    await tester.pump(); // يبني الـ toast (بلا انتظار مؤقّت الإخفاء التلقائي)

    expect(find.text('لا يمكن حذف هذه الفئة لأنها مرتبطة بمنتجات'), findsOneWidget);
    expect(find.text('Zirconia'), findsOneWidget);

    // نستهلك مؤقّت الإخفاء التلقائي للـ toast كي لا يبقى معلّقاً بعد الاختبار.
    await tester.pump(const Duration(milliseconds: 2500));
  });
}
