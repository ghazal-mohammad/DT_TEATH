// اختبار: مودال تفاصيل طلب المستودع يعرض زر "بدء المعالجة" فقط للطلبات
// الجديدة (canMarkPending) وينادي WarehouseRequestsCubit.markPending عند
// الضغط عليه — الميزة كانت مضافة بالـ entity/cubit/datasource لكن غير مربوطة
// بأي واجهة (اكتُشف 2026-08-15 بمراجعة شاملة لربط نظام المستودع بالباك).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/warehouse_request.dart';
import 'package:dt_teeth/features/warehouse/domain/repositories/warehouse_requests_repository.dart';
import 'package:dt_teeth/features/warehouse/presentation/bloc/warehouse_requests_cubit.dart';
import 'package:dt_teeth/features/warehouse/presentation/widgets/orders/warehouse_request_details_dialog.dart';

class _MockRepo extends Mock implements WarehouseRequestsRepository {}

void main() {
  late _MockRepo repo;
  late WarehouseRequestsCubit cubit;

  WarehouseRequest req(WarehouseRequestStatus s) => WarehouseRequest(
        id: '1',
        status: s,
        requesterName: 'ليلى',
        requesterType: 'lab',
        items: const [],
        newItems: const [],
      );

  setUp(() {
    repo = _MockRepo();
    when(() => repo.getAll()).thenAnswer((_) async => const []);
    cubit = WarehouseRequestsCubit(repo);
  });

  Future<void> pumpDialog(WidgetTester tester, WarehouseRequest r) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<WarehouseRequestsCubit>.value(
          value: cubit,
          child: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () =>
                    WarehouseRequestDetailsDialog.show(context, r),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('طلب "جديد" ⇒ يظهر زر بدء المعالجة، وطلب "قيد المعالجة" ⇒ لا يظهر',
      (tester) async {
    await pumpDialog(tester, req(WarehouseRequestStatus.newReq));
    expect(find.text('بدء المعالجة'), findsOneWidget);

    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();

    await pumpDialog(tester, req(WarehouseRequestStatus.inProgress));
    expect(find.text('بدء المعالجة'), findsNothing);
  });

  testWidgets('الضغط على بدء المعالجة ⇒ يستدعي markPending عبر الـ cubit',
      (tester) async {
    when(() => repo.markPending('1')).thenAnswer((_) async {});

    await pumpDialog(tester, req(WarehouseRequestStatus.newReq));
    await tester.tap(find.text('بدء المعالجة'));
    await tester.pumpAndSettle();

    verify(() => repo.markPending('1')).called(1);
  });
}
