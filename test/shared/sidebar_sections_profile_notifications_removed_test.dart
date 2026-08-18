// اختبار: السايدبار (مخبر + مستودع) ما عاد فيه عنصري "الإشعارات" و"الملف
// الشخصي" — صاروا يوصلوا من جرس التوب بار وتبويب الإعدادات بدلاً منهم.
// والبحث العالمي (Ctrl+K) لنتيجة "الملف الشخصي" صار يشاور لصفحة الإعدادات.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/core/auth/auth_models.dart';
import 'package:dt_teeth/core/auth/current_user.dart';
import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/core/router/route_names.dart';
import 'package:dt_teeth/core/search/app_search.dart';
import 'package:dt_teeth/features/lab/presentation/navigation/lab_sidebar_sections.dart';
import 'package:dt_teeth/features/warehouse/presentation/navigation/warehouse_sidebar_sections.dart';

const _testUser = EmployeeUser(
  id: 1,
  name: 'مستخدم اختبار',
  email: 'test@example.com',
  role: EmployeeRole.labManager,
  isActive: true,
  token: 'test-token',
);

void main() {
  tearDown(CurrentUser.instance.clear);

  testWidgets('سايدبار المخبر بلا عنصري الإشعارات والملف الشخصي', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          ctx = context;
          return const SizedBox();
        }),
      ),
    );
    await tester.pumpAndSettle();

    final routes =
        LabSidebarSections.build(ctx).expand((s) => s.items).map((i) => i.route);

    expect(routes.contains(RouteNames.labNotifications), isFalse);
    expect(routes.contains(RouteNames.labProfile), isFalse);
    // باقي العناصر يجب تبقى (مثال: لوحة التحكم والإعدادات).
    expect(routes.contains(RouteNames.labDashboard), isTrue);
    expect(routes.contains(RouteNames.labSettings), isTrue);
  });

  testWidgets('سايدبار المستودع بلا عنصري الإشعارات والملف الشخصي', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          ctx = context;
          return const SizedBox();
        }),
      ),
    );
    await tester.pumpAndSettle();

    final routes = WarehouseSidebarSections.build(ctx)
        .expand((s) => s.items)
        .map((i) => i.route);

    expect(routes.contains(RouteNames.warehouseNotifications), isFalse);
    expect(routes.contains(RouteNames.warehouseProfile), isFalse);
    expect(routes.contains(RouteNames.warehouseDashboard), isTrue);
    expect(routes.contains(RouteNames.warehouseSettings), isTrue);
  });

  test('نتيجة بحث "الملف الشخصي" لمدير المخبر تشاور لصفحة الإعدادات', () {
    CurrentUser.instance.setUser(_testUser);
    final hit = AppSearch.query('الملف الشخصي')
        .firstWhere((h) => h.title == 'الملف الشخصي');
    expect(hit.route, RouteNames.labSettings);
  });

  test('نتيجة بحث "الملف الشخصي" لمدير المستودع تشاور لصفحة الإعدادات', () {
    CurrentUser.instance.setUser(
      const EmployeeUser(
        id: 2,
        name: 'مستودع اختبار',
        email: 'wh@example.com',
        role: EmployeeRole.warehouseManager,
        isActive: true,
        token: 'test-token-2',
      ),
    );
    final hit = AppSearch.query('الملف الشخصي')
        .firstWhere((h) => h.title == 'الملف الشخصي');
    expect(hit.route, RouteNames.warehouseSettings);
  });
}
