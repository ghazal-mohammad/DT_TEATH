// Regression test for the Fix 1 [Critical] breakpoint mismatch:
// AuthFlowShell measures the full viewport for its own mobile/desktop
// decision, but (before the fix) each page measured its own LayoutBuilder's
// box.maxWidth — which is the CARD width once desktop-wrapped in
// Padding(24) -> Center -> ConstrainedBox(maxWidth: 1000). For viewport
// widths in [750, 798), the card is narrower than 750 even though the
// viewport itself is >= 750, so the shell picked desktop while the page
// picked mobile (white-on-white).
//
// At viewport width 780: card width = 780 - 48 (padding) = 732 < 750, so the
// OLD buggy per-page check would have rendered _buildMobile(). The shell's
// own viewport check (780 >= 750) always picked desktop. This test proves
// both now agree by reading MediaQuery.sizeOf directly.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dt_teeth/core/di/injection_container.dart';
import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/auth/domain/repositories/auth_repository.dart';
import 'package:dt_teeth/features/auth/presentation/bloc/login_cubit.dart';
import 'package:dt_teeth/features/auth/presentation/pages/login_page.dart';
import 'package:dt_teeth/features/auth/presentation/widgets/auth_flow_shell.dart';
import 'package:dt_teeth/shared/bloc/locale_cubit.dart';

class _MockAuthRepo extends Mock implements AuthRepository {}

void main() {
  setUp(() {
    if (sl.isRegistered<LoginCubit>()) sl.unregister<LoginCubit>();
    sl.registerFactory<LoginCubit>(() => LoginCubit(_MockAuthRepo()));
  });

  tearDown(() {
    if (sl.isRegistered<LoginCubit>()) sl.unregister<LoginCubit>();
  });

  testWidgets(
      'viewport 780 (card width 732 < 750): shell AND page both pick desktop',
      (tester) async {
    tester.view.physicalSize = const Size(780, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: BlocProvider<LocaleCubit>(
        create: (_) => LocaleCubit(),
        child: const AuthFlowShell(flipped: false, child: LoginPage()),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));

    // Shell renders desktop: finds the maxWidth:1000/maxHeight:580 card.
    final constrainedBoxes =
        tester.widgetList<ConstrainedBox>(find.byType(ConstrainedBox));
    final hasCardConstraint = constrainedBoxes.any((c) =>
        c.constraints.maxWidth == 1000 && c.constraints.maxHeight == 580);
    expect(hasCardConstraint, isTrue,
        reason: 'AuthFlowShell should pick desktop at viewport width 780');

    // Page also renders desktop: PositionedDirectional is only present in
    // LoginPage._buildDesktop(), never in _buildMobile(). Before the fix,
    // the page's own LayoutBuilder measured the card (732px < 750) and
    // would have rendered _buildMobile() here instead, despite the shell
    // rendering its desktop diagonal-card background around it.
    expect(find.byType(PositionedDirectional), findsNWidgets(2),
        reason: 'LoginPage should also pick desktop despite its card being '
            'narrower than 750 logical px');
  });
}
