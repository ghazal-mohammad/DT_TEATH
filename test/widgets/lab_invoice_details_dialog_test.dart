import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/lab/domain/entities/lab_material_request.dart';
import 'package:dt_teeth/features/lab/presentation/widgets/material_requests/lab_invoice_details_dialog.dart';

void main() {
  testWidgets('يعرض كل عناصر الفاتورة (مو أول واحد بس) + زر طباعة', (tester) async {
    final req = MatRequest(
      id: '10',
      status: MatRequestStatus.newRequest,
      requestedBy: 'أحمد',
      requesterType: 'lab',
      date: '2026-08-19',
      items: const [
        MatRequestItem(id: '1', materialName: 'زركون', quantityRequested: 10),
        MatRequestItem(id: '2', materialName: 'جبس', quantityRequested: 5),
      ],
      newItems: const [],
    );
    var printed = false;

    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => LabInvoiceDetailsDialog.show(context, req, onPrint: () => printed = true),
            child: const Text('open'),
          );
        }),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('زركون'), findsOneWidget);
    expect(find.text('جبس'), findsOneWidget);

    await tester.tap(find.text('طباعة'));
    expect(printed, isTrue);
  });
}
