// اختبار: قسم "المواد المستهلكة" بمودال معالجة الطلبية يعمل على مخزون المخبر
// الحقيقي (LabStock من الباك)، لا LabInventoryStore الوهمي (بيانات ثابتة
// بالذاكرة، محذوف الآن).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/lab/domain/entities/lab_order.dart';
import 'package:dt_teeth/features/lab/domain/entities/lab_stock.dart';
import 'package:dt_teeth/features/lab/presentation/widgets/lab_order_process_dialog.dart';

void main() {
  final order = LabOrderFull(
    id: '20',
    doctor: 'د. أحمد',
    type: 'جسر',
    material: 'PFM',
    tooth: '#34-36',
    date: '2026-08-12',
    statusVariant: LabOrderBadgeVariant.manufacturing,
    cost: 80000,
  );

  const stock = [
    LabStock(
      id: 'st-1',
      materialId: 1,
      material: 'سيراميك زيركون',
      unit: 'قطعة',
      quantity: 12,
      isLow: false,
    ),
  ];

  Future<void> openReady(WidgetTester tester, {List<LabStock> s = stock}) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: LabOrderProcessDialog(order: order, stock: s)),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('جاهز للتسليم'));
    await tester.pump();
  }

  testWidgets('يعرض مواد المخزون الحقيقية بقائمة الاختيار، لا بيانات وهمية',
      (tester) async {
    await openReady(tester);
    await tester.tap(find.text('إضافة مادة'));
    await tester.pump();

    await tester.tap(find.text('اختر مادة'));
    await tester.pumpAndSettle();
    expect(find.text('سيراميك زيركون (12.0 قطعة)'), findsWidgets);
  });

  testWidgets('لا يوجد شريط "تكلفة المواد" بعد الآن (لا سعر بمخزون المخبر الحقيقي)',
      (tester) async {
    await openReady(tester);
    expect(find.text('تكلفة المواد'), findsNothing);
  });
}
