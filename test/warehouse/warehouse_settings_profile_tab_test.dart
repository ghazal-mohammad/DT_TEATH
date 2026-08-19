// اختبار: صفحة إعدادات المستودع — تبويب رابع "الملف الشخصي" يعرض
// EmployeeProfileContent، وتبويب الأمان ما عاد فيه بطاقة تسجيل الخروج.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dt_teeth/core/di/injection_container.dart';
import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/profile/domain/repositories/profile_repository.dart';
import 'package:dt_teeth/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:dt_teeth/features/profile/presentation/widgets/employee_profile_content.dart';
import 'package:dt_teeth/features/warehouse/presentation/pages/warehouse_settings_page.dart';

class _MockProfileRepo extends Mock implements ProfileRepository {}

void main() {
  late _MockProfileRepo profileRepo;

  setUp(() {
    profileRepo = _MockProfileRepo();
    when(() => profileRepo.cachedProfile).thenReturn(null);
    when(() => profileRepo.getProfile())
        .thenThrow(Exception('لا يوجد اتصال شبكة بالاختبار'));
    if (sl.isRegistered<ProfileCubit>()) {
      sl.unregister<ProfileCubit>();
    }
    sl.registerFactory<ProfileCubit>(() => ProfileCubit(profileRepo));
  });

  tearDown(() {
    if (sl.isRegistered<ProfileCubit>()) {
      sl.unregister<ProfileCubit>();
    }
  });

  testWidgets(
      'تبويب "الملف الشخصي" بإعدادات المستودع يعرض EmployeeProfileContent',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WarehouseSettingsPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EmployeeProfileContent), findsNothing);

    await tester.tap(find.text('الملف الشخصي'));
    await tester.pump();

    expect(find.byType(EmployeeProfileContent), findsOneWidget);
  });

  testWidgets('تبويب الأمان بإعدادات المستودع لم يعد فيه بطاقة تسجيل الخروج',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WarehouseSettingsPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('تسجيل الخروج من كل الأجهزة'), findsNothing);
  });
}
