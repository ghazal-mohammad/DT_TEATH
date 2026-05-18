// ════════════════════════════════════════════════════════════════════════════
// main.dart
//
// نقطة دخول التطبيق.
// يقوم بـ:
//   1. تهيئة الـ Dependency Injection (GetIt).
//   2. تحميل اختيار الثيم المحفوظ (ThemeCubit).
//   3. تحميل اختيار اللغة المحفوظة (LocaleCubit) — Phase 2.7.2.
//   4. تشغيل التطبيق مع ScreenUtil + GoRouter + MultiBlocProvider.
//
// بنية الـ Bloc Providers:
//   - ThemeCubit  → يتحكم بـ dark/light
//   - LocaleCubit → يتحكم بـ ar/en
//   - أي Cubit جديد (Auth, User...) يُضاف هنا
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/injection_container.dart' as di;
import 'core/l10n/generated/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/bloc/locale_cubit.dart';
import 'shared/bloc/mock_system_cubit.dart';
import 'shared/bloc/theme_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // إعدادات System UI — خلفية شفافة لشريط الحالة.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // تهيئة الـ DI قبل runApp.
  await di.initDependencies();

  // تحميل التفضيلات المحفوظة (تشغيل متوازي لتسريع الإقلاع).
  await Future.wait([
    di.sl<ThemeCubit>().loadSavedTheme(),
    di.sl<LocaleCubit>().loadSaved(),
    di.sl<MockSystemCubit>().loadSaved(),
  ]);

  runApp(const DtTeethApp());
}

/// الـ Widget الجذر للتطبيق.
///
/// يغلّف التطبيق بكل الـ providers الضرورية ويبني [MaterialApp.router].
class DtTeethApp extends StatelessWidget {
  const DtTeethApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>.value(value: di.sl<ThemeCubit>()),
        BlocProvider<LocaleCubit>.value(value: di.sl<LocaleCubit>()),
        BlocProvider<MockSystemCubit>.value(value: di.sl<MockSystemCubit>()),
      ],
      // BlocBuilder خارجي يراقب الثيم + اللغة معاً.
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              return ScreenUtilInit(
                // أبعاد التصميم الأساسي — مطابقة لتصميم HTML (1440×900).
                designSize: const Size(1440, 900),
                minTextAdapt: true,
                splitScreenMode: true,
                builder: (context, child) {
                  return MaterialApp.router(
                    // العنوان الآن من الـ l10n — يتبدل مع اللغة.
                    onGenerateTitle: (ctx) =>
                        AppLocalizations.of(ctx).appName,
                    debugShowCheckedModeBanner: false,

                    // الثيم
                    themeMode: themeMode,
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,

                    // الدولية والـ RTL — تُحدّد تلقائياً من LocaleCubit.
                    locale: locale,
                    supportedLocales: AppLocalizations.supportedLocales,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,

                    // التنقل
                    routerConfig: AppRouter.router,

                    // ملاحظة: إزالة Directionality اليدوي — Flutter الآن يحدد
                    // الـ textDirection تلقائياً من الـ locale (ar → RTL، en → LTR).
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
