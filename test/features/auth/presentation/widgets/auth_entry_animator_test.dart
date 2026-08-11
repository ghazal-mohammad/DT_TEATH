import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dt_teeth/features/auth/presentation/widgets/auth_entry_animator.dart';

Widget _wrap(Widget child, TextDirection dir) {
  final controller = AnimationController(
    vsync: const TestVSync(),
    duration: const Duration(milliseconds: 100),
  )..value = 0.0; // t=0 → full offset applied, easiest to assert.

  return MaterialApp(
    home: Directionality(
      textDirection: dir,
      child: Scaffold(
        body: AuthEntryAnimator(
          controller: controller,
          delay: const Interval(0.0, 1.0),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('LTR: initial offset is positive (60,0)', (tester) async {
    await tester.pumpWidget(_wrap(const SizedBox(width: 10, height: 10), TextDirection.ltr));
    // find.byType(Transform) matches multiple Transforms in a full MaterialApp
    // tree (Material's own internals) — scope to the one that is an ancestor
    // of the animated child so we assert on AuthEntryAnimator's own Transform.
    final transformFinder = find.ancestor(
      of: find.byType(SizedBox),
      matching: find.byType(Transform),
    );
    final transform = tester.widget<Transform>(transformFinder.first);
    expect(transform.transform.getTranslation().x, greaterThan(0));
  });

  testWidgets('RTL: initial offset is negative (mirrored)', (tester) async {
    await tester.pumpWidget(_wrap(const SizedBox(width: 10, height: 10), TextDirection.rtl));
    final transformFinder = find.ancestor(
      of: find.byType(SizedBox),
      matching: find.byType(Transform),
    );
    final transform = tester.widget<Transform>(transformFinder.first);
    expect(transform.transform.getTranslation().x, lessThan(0));
  });
}
