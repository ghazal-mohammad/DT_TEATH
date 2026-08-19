// اختبار: WarehouseSettingsPage(initialTab: 'profile') يفتح مباشرة على تبويب
// الملف الشخصي بلا نقر (نفس آلية Lab) — وشريط التبويب الأفقي (4 تبويبات بعد
// إضافة "الملف الشخصي") يبقى بسطر واحد جنب بعض بلا RenderFlex overflow،
// بعرض موبايل ضيق وبعرض سطح مكتب واسع كمان (كان قبل الإصلاح عمود تبويبات
// عمودي تحت بعض بالعرض الواسع).

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

  testWidgets('WarehouseSettingsPage(initialTab: "profile") يفتح مباشرة على تبويب الملف الشخصي',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WarehouseSettingsPage(initialTab: 'profile'),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(EmployeeProfileContent), findsOneWidget);
  });

  for (final size in [const Size(390, 844), const Size(1920, 1080)]) {
    testWidgets(
        'شريط التبويب الأفقي بعرض ${size.width.toInt()} — 4 تبويبات بسطر واحد بلا overflow',
        (tester) async {
      tester.view.physicalSize = size;
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

      // لا استثناء RenderFlex أثناء البناء (لو صار overflow، pumpAndSettle
      // أعلاه كان رح يفشل الاختبار عبر FlutterError مباشرة بلا حاجة نلتقطه
      // يدوياً — تركه بلا catch يخلّي الطباعة الكاملة لتشخيص الـ overflow
      // تظهر بمخرجات الاختبار لو صار).
      expect(find.text('الأمان'), findsOneWidget);
      expect(find.text('الإشعارات'), findsOneWidget);
      expect(find.text('التفضيلات'), findsOneWidget);
      expect(find.text('الملف الشخصي'), findsOneWidget);

      // "جنب بعض بسطر واحد" — نفس الارتفاع العمودي (dy) للأربع تبويبات،
      // يعني صف واحد أفقي وليس عمود تبويبات تحت بعض.
      final dyAman = tester.getTopLeft(find.text('الأمان')).dy;
      final dyNotif = tester.getTopLeft(find.text('الإشعارات')).dy;
      final dyPrefs = tester.getTopLeft(find.text('التفضيلات')).dy;
      final dyProfile = tester.getTopLeft(find.text('الملف الشخصي')).dy;
      expect(dyNotif, dyAman);
      expect(dyPrefs, dyAman);
      expect(dyProfile, dyAman);
    });
  }
}
