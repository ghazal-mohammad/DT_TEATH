// اختبار: جدول "طلبات اليوم" بلوحة تحكم المخبر يعرض الطلبات الحقيقية
// المُمرَّرة له (Cubit/repository)، لا بيانات mock ثابتة.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/lab/domain/entities/lab_order.dart';
import 'package:dt_teeth/features/lab/presentation/widgets/dashboard/lab_dashboard_orders_table.dart';

Widget _wrap(Widget child) => MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  setUp(() {
    // نفس القياس المستخدم بباقي اختبارات المخبر (السطح الافتراضي يضيّق الجدول).
  });

  LabOrderFull order({
    required String id,
    required LabOrderBadgeVariant status,
    bool isUrgent = false,
  }) =>
      LabOrderFull(
        id: id,
        doctor: 'د. سارة',
        type: 'تلبيسة',
        material: 'PFM',
        tooth: '#14',
        date: '2026-08-11',
        statusVariant: status,
        isUrgent: isUrgent,
      );

  testWidgets('يعرض الطلبات الحقيقية المُمرَّرة له، لا بيانات mock ثابتة',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(LabDashboardOrdersTable(
      orders: [order(id: 'LAB-REAL-1', status: LabOrderBadgeVariant.newOrder)],
    )));
    await tester.pump();

    // الطلب الحقيقي المُمرَّر يظهر.
    expect(find.text('LAB-REAL-1'), findsOneWidget);
    // رقم من بيانات الـ mock القديمة (lab_dashboard_mock_data.dart) غير موجود.
    expect(find.text('LAB-045'), findsNothing);
  });

  testWidgets('فلتر "جديد" يعرض فقط الطلبات الحقيقية بحالة newOrder',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(LabDashboardOrdersTable(orders: [
      order(id: 'LAB-NEW-1', status: LabOrderBadgeVariant.newOrder),
      order(id: 'LAB-READY-1', status: LabOrderBadgeVariant.ready),
    ])));
    await tester.pump();

    expect(find.text('LAB-NEW-1'), findsOneWidget);
    expect(find.text('LAB-READY-1'), findsOneWidget);

    await tester.tap(find.text('جديد').first);
    await tester.pump();

    expect(find.text('LAB-NEW-1'), findsOneWidget);
    expect(find.text('LAB-READY-1'), findsNothing);
  });
}
