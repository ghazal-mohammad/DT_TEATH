// اختبار: مودال إدارة مخزون مادة المستودع لم يعد يعرض نموذج "إضافة دفعة"
// (كان يستدعي addStockBatch — حذفه فريق الباك نهائياً 2026-08). بدل هيك يعرض
// تلميحاً بأن إضافة مخزون جديد تصير عبر فاتورة الشراء.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/core/di/injection_container.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/material_category.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/material_stock.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/warehouse_material.dart';
import 'package:dt_teeth/features/warehouse/domain/repositories/warehouse_stock_repository.dart';
import 'package:dt_teeth/features/warehouse/presentation/widgets/materials/warehouse_material_stock_dialog.dart';

class _MockStockRepo extends Mock implements WarehouseStockRepository {}

void main() {
  late _MockStockRepo repo;

  setUp(() {
    repo = _MockStockRepo();
    when(() => repo.getStockDetails('1')).thenAnswer((_) async => const MaterialStock(
          materialId: '1',
          name: 'قفازات',
          unit: 'قطعة',
          companyName: 'الأمل',
          totalQuantity: 40,
          batches: [],
        ));
    if (sl.isRegistered<WarehouseStockRepository>()) {
      sl.unregister<WarehouseStockRepository>();
    }
    sl.registerFactory<WarehouseStockRepository>(() => repo);
  });

  tearDown(() {
    if (sl.isRegistered<WarehouseStockRepository>()) {
      sl.unregister<WarehouseStockRepository>();
    }
  });

  const material = WarehouseMaterial(
    id: '1',
    name: 'قفازات',
    companyName: 'الأمل',
    category: MaterialCategory.clinic,
    quantity: 40,
    unit: 'قطعة',
    pricePerUnit: 1000,
    minStock: 10,
  );

  testWidgets('لا يوجد حقل كمية دفعة جديدة ولا زر "إضافة دفعة"', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () =>
                  WarehouseMaterialStockDialog.show(context, material),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('إضافة دفعة'), findsNothing);
    expect(find.text('كمية الدفعة'), findsNothing);
  });
}
