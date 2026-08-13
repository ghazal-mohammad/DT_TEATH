import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dt_teeth/core/di/injection_container.dart';
import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/auth/domain/repositories/auth_repository.dart';
import 'package:dt_teeth/features/auth/presentation/bloc/set_password_cubit.dart';
import 'package:dt_teeth/features/auth/presentation/pages/set_password_page.dart';
import 'package:dt_teeth/features/auth/presentation/widgets/auth_underline_field.dart';
import 'package:dt_teeth/features/auth/presentation/widgets/auth_outline_button.dart';
import 'package:dt_teeth/shared/bloc/locale_cubit.dart';
import 'package:dt_teeth/shared/widgets/brand/app_logo.dart';

class _MockAuthRepo extends Mock implements AuthRepository {}

void main() {
  setUp(() {
    if (sl.isRegistered<SetPasswordCubit>()) {
      sl.unregister<SetPasswordCubit>();
    }
    sl.registerFactory<SetPasswordCubit>(() => SetPasswordCubit(_MockAuthRepo()));
  });

  tearDown(() {
    if (sl.isRegistered<SetPasswordCubit>()) {
      sl.unregister<SetPasswordCubit>();
    }
  });

  testWidgets('desktop set_password uses AuthUnderlineField x2 and AuthOutlineButton',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: BlocProvider<LocaleCubit>(
        create: (_) => LocaleCubit(),
        child: const SetPasswordPage(email: 'ali@clinic.com', verificationCode: '123456'),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(AuthUnderlineField), findsNWidgets(2));
    expect(find.byType(AuthOutlineButton), findsOneWidget);
    expect(find.byType(PositionedDirectional), findsNWidgets(2));

    // Fix 5: prove actual mirrored geometry, not just widget-type presence.
    // Branding is at `start` (visual-right under RTL), form at `end`
    // (visual-left under RTL) — so the branding logo must sit to the right
    // of the form's submit button on screen.
    expect(
      tester.getTopLeft(find.byType(AppLogo)).dx,
      greaterThan(tester.getTopLeft(find.byType(AuthOutlineButton)).dx),
    );
  });
}
