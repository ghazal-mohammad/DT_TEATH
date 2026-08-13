import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dt_teeth/core/theme/app_colors.dart';
import 'package:dt_teeth/features/auth/presentation/widgets/auth_underline_field.dart';

Widget _wrap(Widget child, {TextDirection dir = TextDirection.ltr}) {
  return MaterialApp(
    home: Directionality(
      textDirection: dir,
      child: Scaffold(body: Material(child: child)),
    ),
  );
}

void main() {
  testWidgets('renders label and leading icon', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(_wrap(AuthUnderlineField(
      controller: controller,
      label: 'Email',
      icon: Icons.alternate_email_rounded,
    )));

    expect(find.text('Email'), findsOneWidget);
    expect(find.byIcon(Icons.alternate_email_rounded), findsOneWidget);
  });

  testWidgets('shows errorText when provided', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(_wrap(AuthUnderlineField(
      controller: controller,
      label: 'Email',
      icon: Icons.alternate_email_rounded,
      errorText: 'Invalid email',
    )));

    expect(find.text('Invalid email'), findsOneWidget);
  });

  testWidgets('showObscureToggle flips obscureText on tap', (tester) async {
    final controller = TextEditingController(text: 'secret');
    await tester.pumpWidget(_wrap(AuthUnderlineField(
      controller: controller,
      label: 'Password',
      icon: Icons.lock_outline_rounded,
      obscureText: true,
      showObscureToggle: true,
    )));

    TextField field() => tester.widget<TextField>(find.byType(TextField));
    expect(field().obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();

    expect(field().obscureText, isFalse);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
  });

  testWidgets('clear button appears with text and clears it', (tester) async {
    final controller = TextEditingController(text: 'ali@clinic.com');
    await tester.pumpWidget(_wrap(AuthUnderlineField(
      controller: controller,
      label: 'Email',
      icon: Icons.alternate_email_rounded,
    )));

    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();

    expect(controller.text, isEmpty);
  });

  testWidgets('suggestions appear when domains configured and text typed',
      (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(_wrap(AuthUnderlineField(
      controller: controller,
      label: 'Email',
      icon: Icons.alternate_email_rounded,
      suggestionDomains: const ['clinic.com'],
    )));

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'ali');
    await tester.pump();
    // Allow AnimatedSize (200ms) to complete
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('ali@clinic.com'), findsOneWidget);

    await tester.tap(find.text('ali@clinic.com'));
    await tester.pump();

    expect(controller.text, 'ali@clinic.com');
  });

  testWidgets('no suggestions when suggestionDomains is empty', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(_wrap(AuthUnderlineField(
      controller: controller,
      label: 'Email',
      icon: Icons.alternate_email_rounded,
    )));

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'ali');
    await tester.pump();

    expect(find.text('ali@clinic.com'), findsNothing);
  });

  testWidgets('renders as a borderless underline field (filled: false), not a filled box',
      (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(_wrap(AuthUnderlineField(
      controller: controller,
      label: 'Email',
      icon: Icons.alternate_email_rounded,
    )));

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration?.filled, isFalse);
  });

  testWidgets(
      'obscureText: true is honored even without showObscureToggle (Fix 2)',
      (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(_wrap(AuthUnderlineField(
      controller: controller,
      label: 'x',
      icon: Icons.lock_outline_rounded,
      obscureText: true,
    )));

    expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isTrue);
  });

  testWidgets(
      'focusing a field with no suggestionDomains still rebuilds icon color (Fix 3)',
      (tester) async {
    final controller = TextEditingController(text: 'ali@clinic.com');
    await tester.pumpWidget(_wrap(AuthUnderlineField(
      controller: controller,
      label: 'Email',
      icon: Icons.alternate_email_rounded,
    )));

    Icon leadingIcon() =>
        tester.widget<Icon>(find.byIcon(Icons.alternate_email_rounded));

    expect(leadingIcon().color, isNot(AppColors.accent));

    await tester.tap(find.byType(TextField));
    await tester.pump();

    expect(leadingIcon().color, AppColors.accent);
  });
}
