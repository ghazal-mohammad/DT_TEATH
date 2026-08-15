// اختبار: شارة "المواد" بالسايدبار في صفحة المواد يجب أن تعكس lowStockCount
// الحقيقي (نفس مصدر لوحة التحكم عبر InventoryCubit)، لا رقماً ثابتاً (كان 8
// دائماً).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dt_teeth/core/di/injection_container.dart';
import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/inventory_summary.dart';
import 'package:dt_teeth/features/warehouse/domain/repositories/warehouse_inventory_repository.dart';
import 'package:dt_teeth/features/warehouse/domain/repositories/warehouse_materials_repository.dart';
import 'package:dt_teeth/features/warehouse/presentation/pages/warehouse_materials_page.dart';
import 'package:dt_teeth/shared/widgets/navigation/app_sidebar_item.dart';

class _MockMaterialsRepo extends Mock implements WarehouseMaterialsRepository {}

class _MockInventoryRepo extends Mock implements WarehouseInventoryRepository {}

void main() {
  late _MockMaterialsRepo materialsRepo;
  late _MockInventoryRepo inventoryRepo;

  setUp(() {
    materialsRepo = _MockMaterialsRepo();
    inventoryRepo = _MockInventoryRepo();
    when(() => materialsRepo.getAll()).thenAnswer((_) async => []);
    if (sl.isRegistered<WarehouseMaterialsRepository>()) {
      sl.unregister<WarehouseMaterialsRepository>();
    }
    sl.registerFactory<WarehouseMaterialsRepository>(() => materialsRepo);
    if (sl.isRegistered<WarehouseInventoryRepository>()) {
      sl.unregister<WarehouseInventoryRepository>();
    }
    sl.registerFactory<WarehouseInventoryRepository>(() => inventoryRepo);
  });

  tearDown(() {
    if (sl.isRegistered<WarehouseMaterialsRepository>()) {
      sl.unregister<WarehouseMaterialsRepository>();
    }
    if (sl.isRegistered<WarehouseInventoryRepository>()) {
      sl.unregister<WarehouseInventoryRepository>();
    }
  });

  testWidgets('شارة المواد تعرض lowStockCount الحقيقي بدل الرقم الثابت 8',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    when(() => inventoryRepo.getSummary()).thenAnswer((_) async => const InventorySummary(
          mostRequested: [],
          expiringBatches: [],
          lowStockItems: [
            LowStockMaterial(
                materialId: '1',
                name: 'قفازات',
                unit: 'قطعة',
                totalQuantity: 0,
                isOut: true),
          ],
        ));

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WarehouseMaterialsPage(),
      ),
    );
    await tester.pumpAndSettle();

    final materialsItem = tester.widget<AppSidebarItem>(
        find.widgetWithText(AppSidebarItem, 'المواد'));
    expect(materialsItem.badge, '1');
  });
}
