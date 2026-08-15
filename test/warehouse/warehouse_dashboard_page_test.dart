// اختبار: شارة "مواد منخفضة" بالسايدبار في لوحة تحكم المستودع يجب أن تعكس
// lowStockCount الحقيقي من InventoryCubit، لا رقماً ثابتاً (كان 8 دائماً).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dt_teeth/core/di/injection_container.dart';
import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/inventory_summary.dart';
import 'package:dt_teeth/features/warehouse/domain/repositories/warehouse_inventory_repository.dart';
import 'package:dt_teeth/features/warehouse/presentation/pages/warehouse_dashboard_page.dart';
import 'package:dt_teeth/shared/widgets/navigation/app_sidebar_item.dart';

class _MockInventoryRepo extends Mock implements WarehouseInventoryRepository {}

void main() {
  late _MockInventoryRepo repo;

  setUp(() {
    repo = _MockInventoryRepo();
    if (sl.isRegistered<WarehouseInventoryRepository>()) {
      sl.unregister<WarehouseInventoryRepository>();
    }
    sl.registerFactory<WarehouseInventoryRepository>(() => repo);
  });

  tearDown(() {
    if (sl.isRegistered<WarehouseInventoryRepository>()) {
      sl.unregister<WarehouseInventoryRepository>();
    }
  });

  testWidgets('شارة المواد تعرض lowStockCount الحقيقي بدل الرقم الثابت 8',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    when(() => repo.getSummary()).thenAnswer((_) async => const InventorySummary(
          mostRequested: [],
          expiringBatches: [],
          lowStockItems: [
            LowStockMaterial(
                materialId: '1',
                name: 'قفازات',
                unit: 'قطعة',
                totalQuantity: 0,
                isOut: true),
            LowStockMaterial(
                materialId: '2',
                name: 'كمامات',
                unit: 'قطعة',
                totalQuantity: 3,
                isOut: false),
          ],
        ));

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WarehouseDashboardPage(),
      ),
    );
    await tester.pumpAndSettle();

    final materialsItem = tester.widget<AppSidebarItem>(
        find.widgetWithText(AppSidebarItem, 'المواد'));
    expect(materialsItem.badge, '2');
  });
}
