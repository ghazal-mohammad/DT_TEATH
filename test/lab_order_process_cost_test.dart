// اختبار: حقل "التكلفة" بمودال معالجة الطلبية صار للعرض فقط — الباك يحسب
// total_cost تلقائياً (مجموع أسعار بنود الطلبية) ولا يقبل قيمة يدوية، فحقل
// إدخال قابل للتعديل كان يعطي وهم حفظ لا يحصل فعلياً.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/lab/domain/entities/lab_order.dart';
import 'package:dt_teeth/features/lab/presentation/widgets/lab_order_process_dialog.dart';

void main() {
  testWidgets('يعرض تكلفة الطلبية كنص للقراءة فقط، لا حقل إدخال قابل للتعديل',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final order = LabOrderFull(
      id: '7',
      doctor: 'د. ليلى',
      type: 'طقم',
      material: 'Acrylic',
      tooth: '#كامل',
      date: '2026-08-11',
      statusVariant: LabOrderBadgeVariant.manufacturing,
      cost: 150000,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LabOrderProcessDialog(order: order),
        ),
      ),
    );
    await tester.pump();

    // نختار "جاهز للتسليم" (الحالة الوحيدة التي تُظهر قسم التكلفة).
    await tester.tap(find.text('جاهز للتسليم'));
    await tester.pump();

    // التكلفة الحقيقية من الباك تظهر كنص.
    expect(find.text('150,000 ل.س'), findsOneWidget);

    // لا يوجد أي TextField لإدخال تكلفة يدوية بعد الآن.
    final costField = find.byWidgetPredicate(
      (w) => w is TextField && w.keyboardType == TextInputType.number,
    );
    // السطر المتبقّي من نوع number هو حقل الكمية بصفوف الاستهلاك فقط — لا
    // يوجد حقل تكلفة، فنتحقق عبر التسمية بدل العدّ المطلق.
    expect(costField, findsNothing,
        reason: 'ما عاد في صفوف استهلاك افتراضياً، فلا حقول رقمية إطلاقاً');
  });
}
