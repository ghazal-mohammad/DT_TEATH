// اختبار: شارة "الطلبيات" بالسايدبار في صفحة طلبيات المستودع يجب أن تعكس
// عدد الطلبات "الجديدة" الحقيقي من WarehouseRequestsCubit، لا رقماً ثابتاً
// (كان 3 دائماً).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dt_teeth/core/di/injection_container.dart';
import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/warehouse_request.dart';
import 'package:dt_teeth/features/warehouse/domain/repositories/warehouse_requests_repository.dart';
import 'package:dt_teeth/features/warehouse/presentation/pages/warehouse_orders_page.dart';
import 'package:dt_teeth/shared/widgets/navigation/app_sidebar_item.dart';

class _MockRequestsRepo extends Mock implements WarehouseRequestsRepository {}

void main() {
  late _MockRequestsRepo repo;

  WarehouseRequest req(String id, WarehouseRequestStatus status) =>
      WarehouseRequest(
        id: id,
        status: status,
        requesterName: 'د. سارة',
        requesterType: 'lab',
        items: const [],
        newItems: const [],
      );

  setUp(() {
    repo = _MockRequestsRepo();
    if (sl.isRegistered<WarehouseRequestsRepository>()) {
      sl.unregister<WarehouseRequestsRepository>();
    }
    sl.registerFactory<WarehouseRequestsRepository>(() => repo);
  });

  tearDown(() {
    if (sl.isRegistered<WarehouseRequestsRepository>()) {
      sl.unregister<WarehouseRequestsRepository>();
    }
  });

  testWidgets('شارة الطلبيات تعرض عدد الطلبات الجديدة الحقيقي بدل الرقم الثابت 3',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    when(() => repo.getAll()).thenAnswer((_) async => [
          req('1', WarehouseRequestStatus.newReq),
          req('2', WarehouseRequestStatus.completed),
        ]);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WarehouseOrdersPage(),
      ),
    );
    await tester.pumpAndSettle();

    final ordersItem =
        tester.widget<AppSidebarItem>(find.widgetWithText(AppSidebarItem, 'الطلبيات'));
    expect(ordersItem.badge, '1');
  });
}
