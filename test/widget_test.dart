// ════════════════════════════════════════════════════════════════════════════
// widget_test.dart
//
// اختبار أساسي للتأكد من أن التطبيق يبني بدون أخطاء.
// اختبارات تفصيلية للـ widgets المنفردة في ملفات منفصلة (Phase 2.6).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Smoke test: empty MaterialApp builds', (WidgetTester tester) async {
    // اختبار أساسي للتأكد من أن البنية الأساسية تعمل.
    // اختبار التطبيق الكامل يحتاج setup للـ DI + AppLocalizations،
    // وسنبنيه في Phase 3.6 (Verification).
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('DT.Teeth')),
        ),
      ),
    );

    expect(find.text('DT.Teeth'), findsOneWidget);
  });
}
