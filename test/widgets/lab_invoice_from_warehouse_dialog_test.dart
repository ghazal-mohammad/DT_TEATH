import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/lab/domain/entities/warehouse_material_ref.dart';
import 'package:dt_teeth/features/lab/presentation/widgets/material_requests/lab_invoice_from_warehouse_dialog.dart';

const _catalog = [
  WarehouseMaterialRef(materialId: 1, name: 'زركون', unit: 'كيلو'),
  WarehouseMaterialRef(materialId: 2, name: 'جبس', unit: 'كيلو'),
];

void main() {
  Widget wrap(Widget child) => MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Builder(builder: (context) => child)),
      );

  testWidgets('اختيار مادتين وإدخال كمية لكل وحدة ⇒ نتيجة items بعنصرين', (tester) async {
    LabInvoiceFromWarehouseResult? result;
    await tester.pumpWidget(wrap(Builder(builder: (context) {
      return ElevatedButton(
        onPressed: () async {
          result = await LabInvoiceFromWarehouseDialog.show(
            context,
            catalog: _catalog,
            onRetryCatalog: () {},
          );
        },
        child: const Text('open'),
      );
    })));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // إضافة "زركون" للسلة
    await tester.tap(find.text('زركون'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إضافة').first);
    await tester.pumpAndSettle();

    // إضافة "جبس" للسلة
    await tester.tap(find.text('جبس'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إضافة').first);
    await tester.pumpAndSettle();

    // إدخال كمية لكل عنصر بالسلة
    final qtyFields = find.byType(TextField);
    await tester.enterText(qtyFields.at(0), '10');
    await tester.enterText(qtyFields.at(1), '5');

    await tester.tap(find.text('إرسال الطلب'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.items, hasLength(2));
    expect(result!.items.map((e) => e.materialId), containsAll([1, 2]));
  });

  testWidgets('إرسال بدون أي مادة ⇒ الحوار يبقى مفتوح (بلا نتيجة)', (tester) async {
    LabInvoiceFromWarehouseResult? result;
    var popped = false;
    await tester.pumpWidget(wrap(Builder(builder: (context) {
      return ElevatedButton(
        onPressed: () async {
          result = await LabInvoiceFromWarehouseDialog.show(context, catalog: _catalog, onRetryCatalog: () {});
          popped = true;
        },
        child: const Text('open'),
      );
    })));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('إرسال الطلب'));
    await tester.pump();

    expect(popped, isFalse);
    expect(result, isNull);
  });
}
