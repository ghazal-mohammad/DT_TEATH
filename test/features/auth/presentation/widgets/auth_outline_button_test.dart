import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
