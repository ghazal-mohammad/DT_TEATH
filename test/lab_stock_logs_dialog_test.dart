// اختبار: حوار سجلّ حركات مخزون المخبر (LabStockLogsDialog) يعرض الكمية
// بإشارة واحدة فقط. الباك يرجّع quantity سالبة أصلاً لحركات الخصم (-5)،
// والودجت كانت تضيف إشارة "−" إضافية أمامها فينتج "−-5" (إشارة مزدوجة).
// الإصلاح: أخذ القيمة المطلقة قبل لصق إشارة العرض.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dt_teeth/core/di/injection_container.dart';
import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/lab/domain/entities/lab_stock_log.dart';
import 'package:dt_teeth/features/lab/domain/repositories/lab_stock_repository.dart';
import 'package:dt_teeth/features/lab/presentation/widgets/inventory/lab_stock_logs_dialog.dart';

class _MockLabStockRepository extends Mock implements LabStockRepository {}

void main() {
  late _MockLabStockRepository repo;

  setUp(() {
    repo = _MockLabStockRepository();
    if (sl.isRegistered<LabStockRepository>()) {
      sl.unregister<LabStockRepository>();
    }
    sl.registerFactory<LabStockRepository>(() => repo);
  });

  tearDown(() {
    if (sl.isRegistered<LabStockRepository>()) {
      sl.unregister<LabStockRepository>();
    }
  });

  Future<void> pumpDialog(WidgetTester tester) async {
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
              onPressed: () => LabStockLogsDialog.show(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    // ينتظر اكتمال getLogs (Future) ثم يعيد البناء.
    await tester.pump();
  }

  testWidgets('حركة خصم بكمية سالبة من الباك تُعرض بإشارة سالبة واحدة فقط',
      (tester) async {
    when(() => repo.getLogs()).thenAnswer((_) async => const [
          LabStockLog(
            id: 'log-1',
            type: 'خصم',
            quantity: -5,
            materialName: 'سيراميك زيركون',
            unit: 'قطعة',
          ),
        ]);

    await pumpDialog(tester);

    expect(find.text('−5 قطعة'), findsOneWidget);
    expect(find.text('−-5 قطعة'), findsNothing);
  });

  testWidgets('حركة إضافة بكمية موجبة من الباك تُعرض بإشارة موجبة واحدة',
      (tester) async {
    when(() => repo.getLogs()).thenAnswer((_) async => const [
          LabStockLog(
            id: 'log-2',
            type: 'إضافة',
            quantity: 5,
            materialName: 'سيراميك زيركون',
            unit: 'قطعة',
          ),
        ]);

    await pumpDialog(tester);

    expect(find.text('+5 قطعة'), findsOneWidget);
  });
}
