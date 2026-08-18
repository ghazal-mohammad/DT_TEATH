// ════════════════════════════════════════════════════════════════════════════
// lab_flow_test.dart
//
// Real black-box integration test: real app (app.main()), real widget tree,
// real Dio/HTTP stack over a real socket to a local fake backend
// (support/fake_lab_backend.dart) on 127.0.0.1:8012 — no Dart-side mocking.
//
// Run with:
//   flutter test integration_test/lab_flow_test.dart -d windows \
//     --dart-define=API_BASE_URL=http://127.0.0.1:8012
//
// Flow: seed a real logged-in lab-manager session via the app's own
// production session APIs (DioClient.saveToken + CurrentUser.setUser — see
// lib/core/network/dio_client.dart, lib/core/auth/current_user.dart), boot
// the real app, reach the lab dashboard, verify real seeded order data
// rendered from a real HTTP round-trip, then use real sidebar navigation
// (a real tap, real context.go()) to reach the doctor-orders list screen and
// verify the same seeded orders render there too.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:dt_teeth/core/auth/auth_models.dart';
import 'package:dt_teeth/core/auth/current_user.dart';
import 'package:dt_teeth/core/network/dio_client.dart';
import 'package:dt_teeth/core/router/app_router.dart';
import 'package:dt_teeth/core/router/route_names.dart';
import 'package:dt_teeth/main.dart' as app;

import 'support/fake_lab_backend.dart';

/// Pumps for a fixed wall-clock window instead of `pumpAndSettle()`.
///
/// `pumpAndSettle()` waits until no more frames are scheduled at all, which
/// can hang/timeout if any part of the tree runs a repeating animation
/// (e.g. a shimmer loading placeholder) — a real risk here since the
/// dashboard/orders pages show shimmer while `isLoading` is true. A bounded
/// pump loop gives real async work (the real HTTP round-trip, go_router page
/// transitions) enough real time to complete without that failure mode.
Future<void> _pumpFor(WidgetTester tester, Duration duration) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FakeLabBackend backend;

  setUpAll(() async {
    backend = FakeLabBackend();
    await backend.start(requestedPort: 8012);
  });

  tearDownAll(() async {
    await backend.stop();
  });

  testWidgets(
    'logged-in lab manager reaches dashboard and sees real orders',
    (tester) async {
      // ── Seed a real, logged-in lab-manager session using the app's own
      // real, production session APIs (not test mocking) — auth itself is
      // out of scope here.
      await DioClient.clearToken();
      await DioClient.saveToken('fake-token-lab');
      CurrentUser.instance.setUser(const EmployeeUser(
        id: 1,
        name: 'Test Lab Manager',
        email: 'lab@test.local',
        role: EmployeeRole.labManager,
        isActive: true,
        token: 'fake-token-lab',
      ));

      // ── Boot the real app: real DI (real Dio pointed at 127.0.0.1:8012 via
      // --dart-define=API_BASE_URL), real router, real widget tree.
      app.main();
      await _pumpFor(tester, const Duration(seconds: 8));

      // SplashPage always navigates to /auth/email unconditionally after its
      // animation (lib/features/auth/presentation/pages/splash_page.dart —
      // _go() calls context.go(RouteNames.authEmail) without consulting
      // CurrentUser at all; a pre-existing gap unrelated to this flow). We
      // already seeded a valid session above, so drive the real GoRouter
      // straight to the lab dashboard, the same way a deep link would.
      // RouteGuards.guard (lib/core/router/route_guards.dart) still runs for
      // real on this navigation and allows it because
      // CurrentUser.instance.role == EmployeeRole.labManager.
      AppRouter.router.go(RouteNames.labDashboard);
      await _pumpFor(tester, const Duration(seconds: 5));

      // ── Dashboard: a real GET /api/labManager/showAllLabOrders round-trip
      // to the fake backend must have populated real seeded data on screen —
      // not just "no crash". Order id 424201 and its doctor name are seeded
      // in support/fake_lab_backend.dart and appear nowhere else in the app.
      expect(find.text('424201'), findsWidgets);
      expect(find.text('د. سارة السيد'), findsWidgets);

      // ── Real navigation: tap the real sidebar nav item (Arabic label,
      // matches lib/core/l10n/arb/app_ar.arb "doctorOrders") to hop to the
      // doctor-orders list screen — a real tap driving real context.go(),
      // not a router shortcut.
      final ordersNavItem = find.text('طلبات الأطباء');
      expect(ordersNavItem, findsWidgets);
      await tester.tap(ordersNavItem.first);
      await _pumpFor(tester, const Duration(seconds: 5));

      // ── Orders list: all 4 seeded orders (spanning new/in_progress/
      // completed/cancelled) render as real cards from a fresh real HTTP
      // round-trip on this screen.
      expect(find.text('424201'), findsWidgets);
      expect(find.text('424202'), findsWidgets);
      expect(find.text('424203'), findsWidgets);
      expect(find.text('424204'), findsWidgets);
      expect(find.text('د. عمر خليل'), findsWidgets);
    },
  );
}
