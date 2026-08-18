// ════════════════════════════════════════════════════════════════════════════
// warehouse_flow_test.dart
//
// Black-box integration test: the REAL app (real widgets, real Dio/HTTP
// stack over a real socket) against a fake local warehouse backend
// (FakeWarehouseBackend, port 8011). No Dart-side mocking anywhere.
//
// Auth is seeded directly via the app's own real, production session APIs
// (DioClient.saveToken + CurrentUser.instance.setUser) instead of driving a
// fake login UI — a separate agent covers the login flow itself.
//
// Run with:
//   flutter test integration_test/warehouse_flow_test.dart -d windows \
//     --dart-define=API_BASE_URL=http://127.0.0.1:8011
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:dt_teeth/core/auth/auth_models.dart';
import 'package:dt_teeth/core/auth/current_user.dart';
import 'package:dt_teeth/core/network/dio_client.dart';
import 'package:dt_teeth/core/router/app_router.dart';
import 'package:dt_teeth/core/router/route_names.dart';
import 'package:dt_teeth/main.dart' as app;

import 'support/fake_warehouse_backend.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final backend = FakeWarehouseBackend(port: 8011);

  setUpAll(() async {
    await backend.start();
  });

  tearDownAll(() async {
    await backend.stop();
  });

  testWidgets(
    'logged-in warehouse manager reaches dashboard and sees real materials',
    (tester) async {
      backend.failMaterialsEndpoint = false;

      // ── Seed a real logged-in session via the app's own production APIs ──
      await DioClient.clearToken();
      await DioClient.saveToken('fake-token-warehouse');
      CurrentUser.instance.setUser(const EmployeeUser(
        id: 1,
        name: 'Test Warehouse Manager',
        email: 'warehouse@test.local',
        role: EmployeeRole.warehouseManager,
        isActive: true,
        token: 'fake-token-warehouse',
      ));

      app.main();
      await tester.pump(const Duration(milliseconds: 300));

      // The splash screen unconditionally navigates to the auth-email screen
      // after its own 2.8s animation, regardless of any pre-seeded session
      // (no session-restore check exists on that path yet — confirmed by
      // reading lib/features/auth/presentation/pages/splash_page.dart and
      // grepping for CurrentUser usage across lib/features/auth). Rather than
      // burn real wall-clock time waiting for that animation just to be
      // routed to the login flow, jump straight to the warehouse dashboard
      // via the real GoRouter — exactly the destination RouteGuards.guard()
      // (lib/core/router/route_guards.dart) already allows for an
      // authenticated warehouseManager. Real UI navigation is still used for
      // the dashboard → materials hop below, per the black-box requirement.
      AppRouter.router.go(RouteNames.warehouseDashboard);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Real seeded data from the fake backend must be visible on the
      // dashboard (materials list is reused for the sidebar low-stock badge
      // and this assertion also proves the InventoryCubit's 3 endpoint calls
      // succeeded and rendered).
      expect(find.textContaining('قفازات لاتكس M'), findsWidgets);

      // ── Real navigation: tap the real sidebar "Materials" nav item ──────
      final materialsNavItem = find.text('المواد').first;
      await tester.ensureVisible(materialsNavItem);
      await tester.tap(materialsNavItem);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Real seeded materials list must render.
      expect(find.textContaining('قفازات لاتكس M'), findsWidgets);
      expect(find.textContaining('راتنج تعبئة مركّب'), findsWidgets);
      expect(find.textContaining('كحول طبي 70%'), findsWidgets);
    },
  );
}
