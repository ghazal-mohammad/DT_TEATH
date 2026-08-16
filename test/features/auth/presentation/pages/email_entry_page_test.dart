import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dt_teeth/core/di/injection_container.dart';
import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/auth/domain/repositories/auth_repository.dart';
import 'package:dt_teeth/features/auth/presentation/bloc/email_entry_cubit.dart';
import 'package:dt_teeth/features/auth/presentation/pages/email_entry_page.dart';
import 'package:dt_teeth/features/auth/presentation/widgets/auth_underline_field.dart';
import 'package:dt_teeth/features/auth/presentation/widgets/auth_outline_button.dart';
import 'package:dt_teeth/shared/bloc/locale_cubit.dart';
import 'package:dt_teeth/shared/widgets/brand/app_logo.dart';

class _MockAuthRepo extends Mock implements AuthRepository {}

void main() {
  setUp(() {
    if (sl.isRegistered<EmailEntryCubit>()) sl.unregister<EmailEntryCubit>();
    sl.registerFactory<EmailEntryCubit>(() => EmailEntryCubit(_MockAuthRepo()));
  });

  tearDown(() {
    if (sl.isRegistered<EmailEntryCubit>()) sl.unregister<EmailEntryCubit>();
  });

  testWidgets('desktop email_entry uses AuthUnderlineField + AuthOutlineButton, mirrored sides',
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
        child: const EmailEntryPage(),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(AuthUnderlineField), findsOneWidget);
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

  testWidgets('desktop branding title is wrapped in a FittedBox with maxLines:1, softWrap:false',
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
        child: const EmailEntryPage(),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));

    final welcomeText = tester.widget<Text>(find.text('WELCOME!'));
    expect(welcomeText.maxLines, 1);
    expect(welcomeText.softWrap, isFalse);

    final fittedBoxAncestor = find.ancestor(
      of: find.text('WELCOME!'),
      matching: find.byType(FittedBox),
    );
    expect(fittedBoxAncestor, findsOneWidget);
  });

  testWidgets(
      'does not show the manager-email subtitle anywhere on activation screen',
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
        child: const EmailEntryPage(),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text('أدخل البريد الإلكتروني الذي سجّله المدير لك'),
      findsNothing,
    );
    expect(find.byIcon(Icons.info_outline_rounded), findsNothing);
  });
}
