// اختبار: مودال معالجة الطلبية — خيار "غير موجود" (المادة غير متوفرة) لازم
// يُرجع حالة cancelled (يتوفّر عندها راوت setStatusCancelled بالباك)، لا
// newOrder (يلي الـ repository يتجاهله بصمت لأنه ما في انتقال رجوع لـ"جديد").

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/lab/domain/entities/lab_order.dart';
import 'package:dt_teeth/features/lab/presentation/widgets/lab_order_process_dialog.dart';

void main() {
  testWidgets(
      'اختيار "غير موجود" ثم حفظ ⇒ LabProcessResult.status == cancelled',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final order = LabOrderFull(
      id: '9',
      doctor: 'د. سارة',
      type: 'تاج',
      material: 'Zirconia',
      tooth: '#14',
      date: '2026-08-11',
      statusVariant: LabOrderBadgeVariant.manufacturing,
    );

    LabProcessResult? result;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result =
                    await LabOrderProcessDialog.show(context, order);
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // خيار "غير موجود" (المادة غير متوفرة بالمخبر).
    await tester.tap(find.text('غير موجود'));
    await tester.pump();

    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.status, LabOrderBadgeVariant.cancelled);
  });

  testWidgets(
      'طلب "جديد" (لم يبدأ تصنيعه) ⇒ خيار "جاهز للتسليم" معطّل، لا يمكن حفظه '
      'مباشرة (الباك يرفض completed إلا من in_progress)', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final order = LabOrderFull(
      id: '11',
      doctor: 'د. خالد',
      type: 'جسر',
      material: 'PFM',
      tooth: '#21',
      date: '2026-08-11',
      statusVariant: LabOrderBadgeVariant.newOrder,
    );

    LabProcessResult? result;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await LabOrderProcessDialog.show(
                  context,
                  order,
                  technicianNames: const ['فني تجريبي'],
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // محاولة اختيار "جاهز للتسليم" مباشرة على طلب لم يبدأ تصنيعه — معطّل.
    await tester.tap(find.text('جاهز للتسليم'));
    await tester.pump();

    // البقاء على "قيد التصنيع" (الافتراضي) يتطلّب تعيين فنّي — نختاره.
    await tester.tap(find.text('بدون تحديد').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('فني تجريبي').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    // بقي على القيمة الافتراضية (قيد التصنيع) لأن اختيار "جاهز" كان معطّلاً.
    expect(result!.status, LabOrderBadgeVariant.manufacturing);
  });
}
