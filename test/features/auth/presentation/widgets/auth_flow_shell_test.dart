import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dt_teeth/features/auth/presentation/widgets/auth_flow_shell.dart';

void main() {
  testWidgets('desktop width centers content in a maxWidth-1000 card', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(
      home: AuthFlowShell(flipped: false, child: SizedBox()),
    ));
    await tester.pump(const Duration(milliseconds: 50));

    final constrainedBoxes = tester.widgetList<ConstrainedBox>(find.byType(ConstrainedBox));
    final hasCardConstraint = constrainedBoxes.any((c) =>
        c.constraints.maxWidth == 1000 && c.constraints.maxHeight == 580);
    expect(hasCardConstraint, isTrue);
  });

  testWidgets('mobile width has no 1000-wide card constraint', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(
      home: AuthFlowShell(flipped: false, child: SizedBox()),
    ));
    await tester.pump(const Duration(milliseconds: 50));

    final constrainedBoxes = tester.widgetList<ConstrainedBox>(find.byType(ConstrainedBox));
    final hasCardConstraint = constrainedBoxes.any((c) =>
        c.constraints.maxWidth == 1000 && c.constraints.maxHeight == 580);
    expect(hasCardConstraint, isFalse);
  });
}
