// ════════════════════════════════════════════════════════════════════════════
// auth_flow_test.dart
//
// Real, black-box end-to-end test: the REAL app (package:dt_teeth/main.dart)
// running against a REAL HTTP server (FakeAuthBackend, plain dart:io — not a
// mock of any Dart code) that implements the real employee-auth contract.
//
// Drives: splash -> email entry -> verify code -> set password -> (the app
// auto-logs-in on a successful setPassword, per set_password_page.dart's
// `context.go(_dashboardForRole(state.user?.role))`) -> lab dashboard.
//
// IMPORTANT: this app's auth screens use AuthOutlineButton, which runs an
// AnimationController with `..repeat()` (an infinite pulse glow) for as
// long as the button is on screen. That means `tester.pumpAndSettle()` can
// NEVER return on any auth screen — it would spin until its internal
// timeout and throw. So this whole file avoids pumpAndSettle entirely and
// instead pumps in small fixed steps, polling for the next real widget to
// appear (see `_pumpUntilFound`). This mirrors what the existing widget
// tests under test/features/auth/presentation/pages/ do (fixed `tester.pump`
// calls, never pumpAndSettle).
//
// Run with (must use port 8010 — see integration_test/support/fake_auth_backend.dart
// header and the port-collision note in the task that produced this file):
//   flutter test integration_test/auth_flow_test.dart -d windows --dart-define=API_BASE_URL=http://127.0.0.1:8010
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:dt_teeth/core/constants/app_urls.dart';
import 'package:dt_teeth/core/network/dio_client.dart';
import 'package:dt_teeth/features/auth/presentation/pages/set_password_page.dart';
import 'package:dt_teeth/features/auth/presentation/widgets/auth_outline_button.dart';
import 'package:dt_teeth/features/auth/presentation/widgets/auth_underline_field.dart';
import 'package:dt_teeth/features/auth/presentation/widgets/otp_input.dart';
import 'package:dt_teeth/features/lab/presentation/pages/lab_pages.dart';
import 'package:dt_teeth/main.dart' as app;

import 'support/fake_auth_backend.dart';

/// Pumps repeatedly in small fixed steps (never pumpAndSettle — see file
/// header) until [finder] finds at least one widget, or [timeout] elapses.
/// Because this runs under IntegrationTestWidgetsFlutterBinding (a real
/// engine, real clock, real I/O), each pumped step genuinely lets pending
/// real HTTP requests to the fake backend progress and complete.
Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
  Duration step = const Duration(milliseconds: 100),
}) async {
  final DateTime deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(step);
    if (tester.any(finder)) return;
  }
  // One last pump/check so the failure assertion below has fresh state.
  await tester.pump(step);
  if (!tester.any(finder)) {
    final texts = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    // ignore: avoid_print
    print('DIAG: on-screen texts at timeout: $texts');
  }
  expect(finder, findsWidgets,
      reason: 'Timed out after $timeout waiting for $finder');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthBackend backend;

  setUpAll(() async {
    backend = FakeAuthBackend(port: 8010);
    await backend.start();
  });

  tearDownAll(() async {
    await backend.stop();
  });

  setUp(() {
    // Clean slate for every test: forget any token saved by an earlier run
    // on this machine, and make sure the deliberate-failure toggle is off.
    backend.forceLoginFailure = false;
  });

  testWidgets(
    'real activation flow (sendVerification -> verifyCode -> setPassword) '
    'reaches the lab dashboard',
    (tester) async {
      await DioClient.clearToken();

      const String testEmail = 'integration.test@dtteeth.example';
      const String testPassword = 'S3curePass!';

      // ── Boot the REAL app (real DI, real GoRouter, real Dio) ───────────
      await app.main();
      await tester.pump();
      // ignore: avoid_print
      print('DIAG: AppUrls.baseUrl = ${AppUrls.baseUrl}');

      // ── Splash: tap to skip its 2.8s animation instead of waiting it out
      // (SplashPage's root GestureDetector calls `_go()` immediately on tap).
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byType(Scaffold).first, warnIfMissed: false);

      // ── Email entry screen ───────────────────────────────────────────
      await _pumpUntilFound(tester, find.byType(AuthUnderlineField));

      // ignore: avoid_print
      print('DIAG: AuthUnderlineField count = ${tester.widgetList(find.byType(AuthUnderlineField)).length}, '
          'TextField count = ${tester.widgetList(find.byType(TextField)).length}, '
          'AuthOutlineButton count = ${tester.widgetList(find.byType(AuthOutlineButton)).length}');

      final Finder emailField = find
          .descendant(
            of: find.byType(AuthUnderlineField),
            matching: find.byType(TextField),
          )
          .first;
      await tester.enterText(emailField, testEmail);
      await tester.pump(const Duration(milliseconds: 100));
      // ignore: avoid_print
      print('DIAG: emailField controller.text after enterText = '
          '"${tester.widget<TextField>(emailField).controller?.text}"');

      await tester.tap(find.byType(AuthOutlineButton).first, warnIfMissed: false);
      // Real network round trip to FakeAuthBackend's sendVerification, then
      // a real GoRouter navigation + route-transition animation.
      await _pumpUntilFound(tester, find.byType(OtpInput));

      // ── Verify-code screen — 6 separate one-digit boxes ─────────────────
      final Finder otpBoxes = find.descendant(
        of: find.byType(OtpInput),
        matching: find.byType(TextField),
      );
      expect(otpBoxes, findsNWidgets(6));
      const String code = FakeAuthBackend.fixedCode; // '123456'
      for (int i = 0; i < code.length; i++) {
        await tester.enterText(otpBoxes.at(i), code[i]);
        await tester.pump(const Duration(milliseconds: 60));
      }
      // Last digit triggers OtpInput.onCompleted -> _verify() automatically
      // (verifyCode() call, then context.go to set-password on success).
      await _pumpUntilFound(tester, find.byType(SetPasswordPage));

      // ── Set-password screen ─────────────────────────────────────────
      final Finder pwdFields = find.descendant(
        of: find.byType(AuthUnderlineField),
        matching: find.byType(TextField),
      );
      expect(pwdFields, findsNWidgets(2));
      await tester.enterText(pwdFields.at(0), testPassword);
      await tester.pump(const Duration(milliseconds: 60));
      await tester.enterText(pwdFields.at(1), testPassword);
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byType(AuthOutlineButton));
      // Real setPassword call -> success -> role 5 (lab manager) ->
      // context.go(RouteNames.labDashboard) per set_password_page.dart.
      await _pumpUntilFound(
        tester,
        find.byType(LabDashboardPage),
        timeout: const Duration(seconds: 15),
      );

      // ── Real assertion: we are genuinely on the lab dashboard route,
      // rendered by the real LabDashboardPage widget (route-specific —
      // does not render on any other route in app_router.dart).
      expect(find.byType(LabDashboardPage), findsOneWidget);
    },
  );
}
