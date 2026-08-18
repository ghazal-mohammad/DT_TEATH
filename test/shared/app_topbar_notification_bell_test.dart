// اختبار: جرس الإشعارات بالتوب بار — يظهر لما onNotificationTap موجود، يخفى
// لو null، ويستدعي الـ callback عند النقر (مع النقطة الحمراء لو notificationCount>0).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/shared/widgets/navigation/app_topbar.dart';
import 'package:dt_teeth/shared/widgets/navigation/app_topbar_action.dart';

void main() {
  testWidgets(
      'جرس الإشعارات يظهر بالتوب بار وينفّذ onNotificationTap عند النقر',
      (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          appBar: AppTopbar(
            title: 'اختبار',
            showSearch: false,
            notificationCount: 2,
            onNotificationTap: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    final bellFinder = find.byWidgetPredicate(
      (w) => w is AppTopbarAction && w.tooltip == 'الإشعارات',
    );
    expect(bellFinder, findsOneWidget);

    final bell = tester.widget<AppTopbarAction>(bellFinder);
    expect(bell.hasDot, isTrue);

    await tester.tap(bellFinder);
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('الجرس مخفي لو onNotificationTap فارغ (null)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          appBar: AppTopbar(title: 'اختبار', showSearch: false),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(AppTopbarAction), findsNothing);
  });
}
