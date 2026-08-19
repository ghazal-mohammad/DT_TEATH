// اختبار: صفحة إعدادات المخبر — تبويب رابع "الملف الشخصي" يعرض
// EmployeeProfileContent، وتبويب الأمان ما عاد فيه بطاقة "تسجيل الخروج من
// كل الأجهزة" (نُقل الزر لعنصر ثابت بالسايدبار).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dt_teeth/core/di/injection_container.dart';
import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/lab/domain/repositories/lab_orders_repository.dart';
import 'package:dt_teeth/features/lab/presentation/pages/lab_settings_page.dart';
import 'package:dt_teeth/features/profile/domain/repositories/profile_repository.dart';
import 'package:dt_teeth/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:dt_teeth/features/profile/presentation/widgets/employee_profile_content.dart';

class _MockOrdersRepo extends Mock implements LabOrdersRepository {}
class _MockProfileRepo extends Mock implements ProfileRepository {}

void main() {
  late _MockOrdersRepo ordersRepo;
  late _MockProfileRepo profileRepo;

  setUp(() {
    ordersRepo = _MockOrdersRepo();
    when(() => ordersRepo.getAll()).thenAnswer((_) async => const []);
    if (sl.isRegistered<LabOrdersRepository>()) {
      sl.unregister<LabOrdersRepository>();
    }
    sl.registerFactory<LabOrdersRepository>(() => ordersRepo);

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
    if (sl.isRegistered<LabOrdersRepository>()) {
      sl.unregister<LabOrdersRepository>();
    }
    if (sl.isRegistered<ProfileCubit>()) {
      sl.unregister<ProfileCubit>();
    }
  });

  testWidgets('تبويب "الملف الشخصي" الرابع يعرض EmployeeProfileContent',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LabSettingsPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EmployeeProfileContent), findsNothing);

    await tester.tap(find.text('الملف الشخصي'));
    // pump وحيد (بلا pumpAndSettle) — EmployeeProfileContent فيه شيمر تحميل
    // بانيميشن متكرر لا نهائي قبل وصول رد الشبكة، وpumpAndSettle بينتظره للأبد.
    await tester.pump();

    expect(find.byType(EmployeeProfileContent), findsOneWidget);
  });

  testWidgets('تبويب الأمان لم يعد فيه بطاقة "تسجيل الخروج من كل الأجهزة"',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LabSettingsPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('تسجيل الخروج من كل الأجهزة'), findsNothing);
  });
}
