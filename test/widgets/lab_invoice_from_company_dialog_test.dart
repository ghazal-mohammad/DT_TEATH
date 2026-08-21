import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/lab/presentation/widgets/material_requests/lab_invoice_from_company_dialog.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Builder(builder: (context) => child)),
      );

  testWidgets('اسم الشركة + مادتين ⇒ نتيجة بعنصرين، والشركة مكرّرة تلقائياً', (tester) async {
    LabInvoiceFromCompanyResult? result;
    await tester.pumpWidget(wrap(Builder(builder: (context) {
      return ElevatedButton(
        onPressed: () async => result = await LabInvoiceFromCompanyDialog.show(context),
        child: const Text('open'),
      );
    })));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('company_name_field')), 'شركة دنتال سوريا');

    // صف مادة أول موجود افتراضياً
    await tester.enterText(find.byKey(const Key('material_name_0')), 'صمغ طبي خاص');
    await tester.enterText(find.byKey(const Key('material_qty_0')), '3');

    // إضافة صف تاني
    await tester.tap(find.text('+ إضافة مادة'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('material_name_1')), 'قفازات');
    await tester.enterText(find.byKey(const Key('material_qty_1')), '20');

    await tester.tap(find.text('إرسال الطلب'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.companyName, 'شركة دنتال سوريا');
    expect(result!.items, hasLength(2));
    expect(result!.items[0].materialName, 'صمغ طبي خاص');
    expect(result!.items[1].materialName, 'قفازات');
  });

  testWidgets('حقل السبب لكل صف بينبعت مع العنصر', (tester) async {
    LabInvoiceFromCompanyResult? result;
    await tester.pumpWidget(wrap(Builder(builder: (context) {
      return ElevatedButton(
        onPressed: () async => result = await LabInvoiceFromCompanyDialog.show(context),
        child: const Text('open'),
      );
    })));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('company_name_field')), 'شركة دنتال سوريا');
    await tester.enterText(find.byKey(const Key('material_name_0')), 'صمغ طبي خاص');
    await tester.enterText(find.byKey(const Key('material_qty_0')), '3');
    await tester.enterText(find.byKey(const Key('material_reason_0')), 'نحتاجها لطلب مستعجل');

    await tester.tap(find.text('إرسال الطلب'));
    await tester.pumpAndSettle();

    expect(result!.items.single.reason, 'نحتاجها لطلب مستعجل');
  });

  testWidgets('صف فيه اسم بلا كمية ⇒ يُعتبر ناقص ولا يُغلق الحوار', (tester) async {
    LabInvoiceFromCompanyResult? result;
    var popped = false;
    await tester.pumpWidget(wrap(Builder(builder: (context) {
      return ElevatedButton(
        onPressed: () async {
          result = await LabInvoiceFromCompanyDialog.show(context);
          popped = true;
        },
        child: const Text('open'),
      );
    })));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('company_name_field')), 'شركة دنتال سوريا');
    await tester.enterText(find.byKey(const Key('material_name_0')), 'صمغ طبي خاص');
    // بلا كمية — صف ناقص، ما لازم ينبلع بصمت.

    await tester.tap(find.text('إرسال الطلب'));
    await tester.pump();

    expect(popped, isFalse);
    expect(result, isNull);
  });

  testWidgets('اسم شركة فارغ ⇒ لا يُغلق الحوار', (tester) async {
    LabInvoiceFromCompanyResult? result;
    var popped = false;
    await tester.pumpWidget(wrap(Builder(builder: (context) {
      return ElevatedButton(
        onPressed: () async {
          result = await LabInvoiceFromCompanyDialog.show(context);
          popped = true;
        },
        child: const Text('open'),
      );
    })));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('material_name_0')), 'مادة');
    await tester.enterText(find.byKey(const Key('material_qty_0')), '5');
    await tester.tap(find.text('إرسال الطلب'));
    await tester.pump();

    expect(popped, isFalse);
    expect(result, isNull);
  });
}
