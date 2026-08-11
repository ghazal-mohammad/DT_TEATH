import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dt_teeth/features/auth/presentation/widgets/auth_flow_shell.dart';
import 'package:dt_teeth/features/auth/presentation/widgets/auth_layout_painters.dart';

Widget _wrap(double progress, TextDirection dir) {
  return MaterialApp(
    home: Directionality(
      textDirection: dir,
      child: Scaffold(
        body: SizedBox(
          width: 400,
          height: 300,
          child: AuthRotatingBackground(progress: progress, glowPhase: 0.0),
        ),
      ),
    ),
  );
}

/// Finds the [ClipPath] whose sibling [Opacity] is fully opaque (~1.0) and
/// returns the runtime type of the [CustomClipper] it uses. `Opacity` and
/// `ClipPath` widgets are built in matching list order in
/// `AuthRotatingBackground.build()`, so positional matching identifies which
/// clipper (right/white-on-right vs left/white-on-left) is the visible one.
Type _fullyOpaqueClipperType(WidgetTester tester) {
  final opacities = tester.widgetList<Opacity>(find.byType(Opacity)).toList();
  final clipPaths = tester.widgetList<ClipPath>(find.byType(ClipPath)).toList();
  final fullIndex =
      opacities.indexWhere((o) => (o.opacity - 1.0).abs() < 0.01);
  expect(
    fullIndex,
    greaterThanOrEqualTo(0),
    reason: 'expected exactly one fully-opaque Opacity widget',
  );
  return clipPaths[fullIndex].clipper.runtimeType;
}

void main() {
  testWidgets(
    'progress=0, LTR: AuthDiagRightClipper renders at full opacity (unchanged behavior)',
    (tester) async {
      await tester.pumpWidget(_wrap(0.0, TextDirection.ltr));
      await tester.pump();

      expect(_fullyOpaqueClipperType(tester), AuthDiagRightClipper);
    },
  );

  testWidgets(
    'progress=0, RTL: AuthDiagLeftClipper renders at full opacity (mirrored)',
    (tester) async {
      await tester.pumpWidget(_wrap(0.0, TextDirection.rtl));
      await tester.pump();

      expect(_fullyOpaqueClipperType(tester), AuthDiagLeftClipper);
    },
  );
}
