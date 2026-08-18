// ════════════════════════════════════════════════════════════════════════════
// memory_dispose_test.dart
//
// Replaces the deleted fake "Memory Leak Test - 1000 widget builds should not
// retain memory after GC" (which only asserted `1000 - 0 == 1000` against
// hardcoded local constants and could never fail).
//
// `flutter test` cannot measure real process RSS/heap size, so this test uses
// a genuine, real leak-detection proxy instead: it repeatedly builds and tears
// down a real production widget that owns a real, continuously-repeating
// `AnimationController` (a ticker-driven resource, the same shape of resource
// a memory leak in production would typically involve), then asserts that no
// ticker survives the final disposal.
//
// Widget under test: AuthOutlineButton (lib/features/auth/presentation/
// widgets/auth_outline_button.dart). Its State creates
// `AnimationController(vsync: this, duration: ...)..repeat()` in initState()
// and disposes it in dispose(). It is real production code, used on the
// login, email-entry, verify-code and set-password pages. If a future change
// ever removed/broke its dispose() override, the leaked repeating ticker
// would keep re-scheduling itself forever — which is exactly what the
// assertions below would catch (and pumpAndSettle would even time out).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/features/auth/presentation/widgets/auth_outline_button.dart';

void main() {
  testWidgets(
    'Memory Leak Proxy - 100x AuthOutlineButton build/dispose cycles leave '
    'no dangling AnimationController ticker after final teardown',
    (tester) async {
      const int iterations = 100;
      final Stopwatch stopwatch = Stopwatch()..start();

      for (int i = 0; i < iterations; i++) {
        // A distinct key per iteration forces Flutter to unmount the
        // previous AuthOutlineButton element (and dispose its State +
        // AnimationController) rather than reusing it via didUpdateWidget.
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AuthOutlineButton(
                key: ValueKey('auth_outline_button_$i'),
                label: 'Continue $i',
                onPressed: () {},
                withPulseAnimation: true,
              ),
            ),
          ),
        );
        // Pump a frame so the repeating AnimationController actually starts
        // ticking (proving it is a live, real ticker, not an inert stub).
        await tester.pump(const Duration(milliseconds: 16));
      }

      // Replace the tree entirely so the very last AuthOutlineButton
      // instance (and its AnimationController) is also disposed.
      await tester.pumpWidget(const SizedBox.shrink());

      // If any AnimationController from any of the 100 iterations were
      // leaked, its repeating ticker would keep re-scheduling frames
      // forever and this would either time out (throwing a real
      // FlutterError) or leave transientCallbackCount > 0 below.
      await tester.pumpAndSettle();

      stopwatch.stop();
      final int elapsedMs = stopwatch.elapsedMilliseconds;
      debugPrint('memory_dispose_100x_ms=$elapsedMs');

      // 1) No leaked ticker: every AnimationController created across the
      //    100 build/dispose cycles must have been fully torn down. A leak
      //    (e.g. a broken/removed dispose() override) would leave one or
      //    more repeating tickers registered here.
      final int transientCallbacks =
          SchedulerBinding.instance.transientCallbackCount;
      expect(
        transientCallbacks,
        0,
        reason:
            'Leaked AnimationController ticker(s) detected after disposing '
            '$iterations AuthOutlineButton instances '
            '(transientCallbackCount=$transientCallbacks).',
      );

      // 2) No frame is pending — consistent with every animation having
      //    been fully stopped and disposed, not merely paused.
      expect(
        tester.binding.hasScheduledFrame,
        isFalse,
        reason: 'A frame is still scheduled after full teardown, which '
            'indicates a still-running animation/ticker.',
      );

      // 3) Nothing in the loop threw. A disposed AnimationController throws
      //    a FlutterError if it is ever driven again (e.g. by a stray
      //    listener or a double-dispose bug), so this catches that class of
      //    real regression too.
      expect(
        tester.takeException(),
        isNull,
        reason:
            'An exception was thrown while building/disposing '
            '$iterations AuthOutlineButton instances.',
      );

      // Generous sanity ceiling only to catch a true hang — not a
      // performance gate.
      expect(
        elapsedMs,
        lessThan(30000),
        reason: '$iterations build/dispose cycles took ${elapsedMs}ms, '
            'suggesting a hang rather than normal execution.',
      );
    },
  );
}
