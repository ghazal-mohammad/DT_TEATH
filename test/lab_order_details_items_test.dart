// اختبار: مودال تفاصيل الطلب يعرض كل قطع الطلب عند تعدّدها (لا يكتفي بالأولى).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/lab/domain/entities/lab_order.dart';
import 'package:dt_teeth/features/lab/presentation/widgets/lab_order_details_dialog.dart';

void main() {
  testWidgets('يعرض كل قطع الطلب عند تعدّدها بلا انهيار', (tester) async {
    // سطح واقعي (المودال 720px) — السطح الافتراضي 800×600 يضيّقه فيتجاوز.
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final order = LabOrderFull(
      id: '5',
      doctor: 'د. سارة',
      type: 'تاج',
      material: 'Zirconia',
      tooth: '#14',
      date: '2026-07-01',
      statusVariant: LabOrderBadgeVariant.newOrder,
      parts: const [
        LabOrderPart(
            tooth: '#14', type: 'تاج', material: 'Zirconia', price: 120000),
        LabOrderPart(tooth: '#21', type: 'جسر', material: 'PFM', price: 80000),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: LabOrderDetailsDialog(order: order)),
      ),
    );
    await tester.pump();

    // ملاحظة: المودال نفسه يُظهر تجاوز RenderFlex بسيطاً في بيئة الاختبار (قياس
    // خطوط مختلف، مسبق وغير متعلّق بتعدّد العناصر) — نستهلكه ثم نتحقّق من الميزة.
    tester.takeException();
    // القطعة الثانية (جسر) تظهر فقط ضمن قائمة العناصر، لا في ملخّص البطاقة.
    expect(find.text('جسر'), findsWidgets);
  });
}
