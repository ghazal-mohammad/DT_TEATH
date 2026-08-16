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

  testWidgets('idle button always shows filled navy/purple gradient',
      (tester) async {
    await tester.pumpWidget(_wrap(AuthOutlineButton(
      label: 'Sign In',
      onPressed: () {},
    )));

    final filled = tester
        .widgetList<Container>(find.byType(Container))
        .firstWhere((c) {
      final d = c.decoration;
      return d is BoxDecoration && d.gradient != null;
    });
    final decoration = filled.decoration! as BoxDecoration;
    final gradient = decoration.gradient! as LinearGradient;

    expect(gradient.colors, const [
      AppColors.authHoverFillStart,
      AppColors.authGlowBlue,
    ]);
    expect(find.byType(FractionallySizedBox), findsNothing);

    final labelColor = tester.widget<Text>(find.text('Sign In')).style!.color;
    expect(labelColor, Colors.white);
  });
}
