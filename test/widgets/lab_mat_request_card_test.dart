import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/lab/domain/entities/lab_material_request.dart';
import 'package:dt_teeth/features/lab/presentation/widgets/material_requests/lab_mat_request_card.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      );

  testWidgets('فاتورة مستودع بمادتين — تعرض عدد المواد ونوع "من المستودع"', (tester) async {
    const req = MatRequest(
      id: '5',
      status: MatRequestStatus.newRequest,
      requestedBy: 'أحمد',
      requesterType: 'lab',
      date: '2026-08-19',
      items: [
        MatRequestItem(id: '1', materialName: 'زركون', quantityRequested: 10),
        MatRequestItem(id: '2', materialName: 'جبس', quantityRequested: 5),
      ],
      newItems: [],
    );

    await tester.pumpWidget(wrap(const LabMatRequestCard(request: req)));
    await tester.pump();

    expect(find.textContaining('مادة'), findsOneWidget);
    expect(find.text('من المستودع'), findsOneWidget);
  });

  testWidgets('فاتورة شركة — تعرض نوع "من شركة"، والدوس عليها يستدعي onTap', (tester) async {
    const req = MatRequest(
      id: '6',
      status: MatRequestStatus.newRequest,
      requestedBy: 'سارة',
      requesterType: 'lab',
      date: '2026-08-19',
      items: [],
      newItems: [
        MatRequestNewItem(id: '1', materialName: 'صمغ', quantity: 3, unit: 'علبة', companyName: 'دنتال'),
      ],
    );

    var tapped = false;
    await tester.pumpWidget(wrap(LabMatRequestCard(request: req, onTap: () => tapped = true)));
    await tester.pump();

    expect(find.text('من شركة'), findsOneWidget);
    await tester.tap(find.byType(LabMatRequestCard));
    expect(tapped, isTrue);
  });
}
