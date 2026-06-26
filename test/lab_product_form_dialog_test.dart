// اختبار انحدار: مودال تعديل منتج المخبر يجب أن يفتح دون انهيار حتى عندما تكون
// قيمة النوع/المادة قادمة من الباك وخارج القوائم الثابتة (kProductTypes/
// kProductMaterials) — كان DropdownButtonFormField ينهار بـ "value not in items".

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/lab/domain/entities/lab_product.dart';
import 'package:dt_teeth/features/lab/presentation/widgets/products/lab_product_form_dialog.dart';

void main() {
  testWidgets('يفتح مودال التعديل بقيم باك خارج القائمة بلا انهيار',
      (tester) async {
    const product = LabProduct(
      id: '1',
      name: 'تركيب زركون',
      type: 'تليسة', // خارج kProductTypes
      material: 'PVC', // خارج kProductMaterials
      price: 150000,
      productionDays: 5,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: LabProductFormDialog(existing: product),
        ),
      ),
    );
    await tester.pump();

    // لا استثناء أثناء البناء (كان ينهار سابقاً).
    expect(tester.takeException(), isNull);
    // القيمتان الخارجتان عن القائمة ظاهرتان (أُضيفتا للخيارات).
    expect(find.text('تليسة'), findsWidgets);
    expect(find.text('PVC'), findsWidgets);
  });
}
