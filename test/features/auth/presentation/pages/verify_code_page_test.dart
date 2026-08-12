import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dt_teeth/core/di/injection_container.dart';
import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/auth/domain/repositories/auth_repository.dart';
import 'package:dt_teeth/features/auth/presentation/pages/verify_code_page.dart';
import 'package:dt_teeth/features/auth/presentation/widgets/auth_outline_button.dart';
import 'package:dt_teeth/shared/bloc/locale_cubit.dart';

class _MockAuthRepo extends Mock implements AuthRepository {}

void main() {
  setUp(() {
    if (sl.isRegistered<AuthRepository>()) sl.unregister<AuthRepository>();
    sl.registerLazySingleton<AuthRepository>(() => _MockAuthRepo());
  });

  tearDown(() {
    if (sl.isRegistered<AuthRepository>()) sl.unregister<AuthRepository>();
  });

  testWidgets('desktop verify_code uses AuthOutlineButton and PositionedDirectional',
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
        child: const VerifyCodePage(email: 'ali@clinic.com'),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(AuthOutlineButton), findsOneWidget);
    expect(find.byType(PositionedDirectional), findsNWidgets(2));
  });
}
