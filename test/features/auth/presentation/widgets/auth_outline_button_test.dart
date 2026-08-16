import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dt_teeth/core/theme/app_colors.dart';
import 'package:dt_teeth/features/auth/presentation/widgets/auth_outline_button.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('renders label text', (tester) async {
    await tester.pumpWidget(_wrap(AuthOutlineButton(
      label: 'Sign In',
      onPressed: () {},
    )));
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('tap calls onPressed once, ignores rapid double-tap', (tester) async {
    int count = 0;
    await tester.pumpWidget(_wrap(AuthOutlineButton(
      label: 'Sign In',
      onPressed: () => count++,
    )));

    await tester.tap(find.byType(AuthOutlineButton));
    await tester.tap(find.byType(AuthOutlineButton));
    await tester.pump();

    expect(count, 1);
  });

  testWidgets('disabled when isEnabled is false — tap does nothing', (tester) async {
    int count = 0;
    await tester.pumpWidget(_wrap(AuthOutlineButton(
      label: 'Sign In',
      isEnabled: false,
      onPressed: () => count++,
    )));

    await tester.tap(find.byType(AuthOutlineButton));
    await tester.pump();

    expect(count, 0);
  });

  testWidgets('shows spinner and hides label when isLoading', (tester) async {
    await tester.pumpWidget(_wrap(AuthOutlineButton(
      label: 'Sign In',
      isLoading: true,
      onPressed: () {},
    )));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Sign In'), findsNothing);
  });

  testWidgets('mouse hover does not throw and triggers rebuild', (tester) async {
    await tester.pumpWidget(_wrap(AuthOutlineButton(
      label: 'Sign In',
      onPressed: () {},
    )));

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();

    await gesture.moveTo(tester.getCenter(find.byType(AuthOutlineButton)));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(AuthOutlineButton), findsOneWidget);
  });

  testWidgets('exposes button semantics with tap action enabled (Fix 4)',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_wrap(AuthOutlineButton(
      label: 'Sign In',
      onPressed: () {},
    )));

    final SemanticsNode node =
        tester.getSemantics(find.byType(AuthOutlineButton));
    final SemanticsData data = node.getSemanticsData();
    expect(data.flagsCollection.isButton, isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);
    expect(data.flagsCollection.hasEnabledState, isTrue);
    expect(data.flagsCollection.isEnabled, isTrue);
    expect(node.label, contains('Sign In'));

    handle.dispose();
  });

  testWidgets('disabled button semantics report isEnabled false (Fix 4)',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_wrap(AuthOutlineButton(
      label: 'Sign In',
      isEnabled: false,
      onPressed: () {},
    )));

    final SemanticsNode node =
        tester.getSemantics(find.byType(AuthOutlineButton));
    final SemanticsData data = node.getSemanticsData();
    expect(data.flagsCollection.isButton, isTrue);
    expect(data.flagsCollection.isEnabled, isFalse);

    handle.dispose();
  });

  testWidgets('button shape is a full pill (borderRadius = height / 2)',
      (tester) async {
    await tester.pumpWidget(_wrap(AuthOutlineButton(
      label: 'Sign In',
      onPressed: () {},
    )));

    final bordered = tester
        .widgetList<Container>(find.byType(Container))
        .firstWhere((c) =>
            c.decoration is BoxDecoration &&
            (c.decoration! as BoxDecoration).border != null);
    final decoration = bordered.decoration! as BoxDecoration;

    expect(decoration.borderRadius, BorderRadius.circular(25));
  });

  testWidgets('idle button has no hover fill overlay', (tester) async {
    await tester.pumpWidget(_wrap(AuthOutlineButton(
      label: 'Sign In',
      onPressed: () {},
    )));

    expect(find.byType(FractionallySizedBox), findsNothing);
  });

  testWidgets(
      'hover reveals a vertical bottom-anchored fill that grows to full height',
      (tester) async {
    await tester.pumpWidget(_wrap(AuthOutlineButton(
      label: 'Sign In',
      onPressed: () {},
    )));

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();

    await gesture.moveTo(tester.getCenter(find.byType(AuthOutlineButton)));
    await tester.pump(const Duration(milliseconds: 110)); // mid-sweep (220ms total)

    final midFill =
        tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
    expect(midFill.heightFactor, greaterThan(0.0));
    expect(midFill.heightFactor, lessThan(1.0));
    expect(midFill.alignment, Alignment.bottomCenter);

    await tester.pump(const Duration(milliseconds: 200)); // finish sweep

    final fullFill =
        tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
    expect(fullFill.heightFactor, closeTo(1.0, 0.01));
  });

  testWidgets('label color shifts from navy to white as the fill grows',
      (tester) async {
    await tester.pumpWidget(_wrap(AuthOutlineButton(
      label: 'Sign In',
      onPressed: () {},
    )));

    final idleColor = tester.widget<Text>(find.text('Sign In')).style!.color;
    expect(idleColor, AppColors.authBorderBlue);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.byType(AuthOutlineButton)));
    await tester.pump(const Duration(milliseconds: 220)); // full sweep

    final hoveredColor =
        tester.widget<Text>(find.text('Sign In')).style!.color;
    expect(hoveredColor, Colors.white);
  });
}
