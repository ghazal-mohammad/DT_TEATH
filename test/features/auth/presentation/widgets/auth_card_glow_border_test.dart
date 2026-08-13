import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dt_teeth/core/theme/app_colors.dart';
import 'package:dt_teeth/features/auth/presentation/widgets/auth_page_transition.dart';

void main() {
  testWidgets(
      'renders the given border stroke in its BoxDecoration in addition to the glow',
      (tester) async {
    const border = Border.fromBorderSide(
      BorderSide(color: AppColors.accent, width: 2),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AuthCardGlowBorder(
            border: border,
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      ),
    );
    await tester.pump();

    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration as BoxDecoration;

    expect(decoration.border, border);
  });
}
