import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/lab/presentation/widgets/material_requests/lab_invoice_type_chooser_dialog.dart';

void main() {
  testWidgets('اختيار "من مواد المستودع" يرجع LabInvoiceType.warehouse', (tester) async {
    LabInvoiceType? result;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async => result = await LabInvoiceTypeChooserDialog.show(context),
            child: const Text('open'),
          );
        }),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('من مواد المستودع'));
    await tester.pumpAndSettle();

    expect(result, LabInvoiceType.warehouse);
  });
}
