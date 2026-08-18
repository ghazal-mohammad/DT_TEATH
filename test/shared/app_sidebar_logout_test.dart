// اختبار: عنصر "تسجيل الخروج" ثابت بأسفل AppSidebar، بنفس تنسيق AppSidebarItem
// (متل باقي عناصر التنقّل)، وينفّذ onLogout عند النقر — وليس زر ملاحة عادي
// (isActive دائماً false).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/shared/widgets/core/app_system_type.dart';
import 'package:dt_teeth/shared/widgets/navigation/app_sidebar.dart';
import 'package:dt_teeth/shared/widgets/navigation/app_sidebar_item.dart';

void main() {
  testWidgets(
      'عنصر تسجيل الخروج ثابت بأسفل السايدبار وبنفس تنسيق AppSidebarItem',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    var loggedOut = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AppSidebar(
            system: AppSystemType.lab,
            currentRoute: '/lab/dashboard',
            sections: const [],
            userName: 'اختبار',
            userRole: 'دور',
            onItemTap: (_) {},
            onSystemSwitch: null,
            onLogout: () => loggedOut = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final logoutFinder = find.widgetWithText(AppSidebarItem, 'تسجيل الخروج');
    expect(logoutFinder, findsOneWidget);

    final logoutItem = tester.widget<AppSidebarItem>(logoutFinder);
    expect(logoutItem.isActive, isFalse);

    await tester.tap(logoutFinder);
    await tester.pump();
    expect(loggedOut, isTrue);
  });
}
