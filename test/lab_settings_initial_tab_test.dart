// اختبار: labSettingsTabFromQuery (تحويل ?tab= من الراوت لفهرس تبويب) + أن
// LabSettingsPage(initialTab: 3) يفتح مباشرة على تبويب الملف الشخصي بلا
// حاجة للنقر — يخدم حالتين: نتيجة بحث "الملف الشخصي" وإعادة توجيه
// /lab/profile القديم، وكلاهما يمرّران ?tab=profile.

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
  test('labSettingsTabFromQuery("profile") يرجع 3، أي قيمة تانية أو null ترجع 0', () {
    expect(labSettingsTabFromQuery('profile'), 3);
    expect(labSettingsTabFromQuery(null), 0);
    expect(labSettingsTabFromQuery('security'), 0);
    expect(labSettingsTabFromQuery(''), 0);
  });

  group('LabSettingsPage(initialTab: 3)', () {
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

    testWidgets('يفتح مباشرة على تبويب الملف الشخصي بلا نقر', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LabSettingsPage(initialTab: 3),
        ),
      );
      // pump وحيد بدل pumpAndSettle — نفس سبب اختبار التبويب الأصلي: شيمر
      // EmployeeProfileContent فيه أنيميشن متكرر لا نهائي قبل رد الشبكة.
      await tester.pump();
      await tester.pump();

      expect(find.byType(EmployeeProfileContent), findsOneWidget);
    });

    for (final size in [const Size(390, 844), const Size(1920, 1080)]) {
      testWidgets(
          'شريط التبويب بعرض ${size.width.toInt()} — 4 تبويبات بسطر واحد جنب بعض',
          (tester) async {
        // قبل الإصلاح: بعرض سطح مكتب واسع (>720) كانت التبويبات تظهر كعمود
        // جانبي عمودي تحت بعض بدل صف أفقي واحد جنب بعض.
        tester.view.physicalSize = size;
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

        final dySecurity = tester.getTopLeft(find.text('الأمان')).dy;
        final dyNotif = tester.getTopLeft(find.text('الإشعارات')).dy;
        final dyPrefs = tester.getTopLeft(find.text('التفضيلات')).dy;
        final dyProfile = tester.getTopLeft(find.text('الملف الشخصي')).dy;
        expect(dyNotif, dySecurity);
        expect(dyPrefs, dySecurity);
        expect(dyProfile, dySecurity);
      });
    }
  });
}
