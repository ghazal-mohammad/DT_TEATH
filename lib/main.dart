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

import 'core/auth/current_user.dart';
import 'core/di/injection_container.dart' as di;
import 'core/l10n/generated/app_localizations.dart';
import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'core/router/route_names.dart';
import 'core/session/session_cache_registry.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'shared/bloc/locale_cubit.dart';
import 'shared/bloc/mock_system_cubit.dart';
import 'shared/bloc/text_scale_cubit.dart';
import 'shared/bloc/theme_cubit.dart';
import 'shared/widgets/session/idle_timeout_watcher.dart';

/// مدّة الخمول قبل قفل الجلسة تلقائياً (أمان الأجهزة المشتركة).
const Duration _kIdleTimeout = Duration(minutes: 15);

/// قفل الجلسة عند الخمول: تسجيل خروج صامت (يُبطل التوكن في الباك ويمسح محلياً)
/// ثم توجيه لشاشة الدخول. صامت (بلا نافذة تأكيد) لأنه تلقائي.
void _onIdleTimeout() {
  di.sl<AuthRepository>().logout();
  AppRouter.router.go(RouteNames.login);
}

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

  // معالجة انتهاء الجلسة (401 على طلب مُصادَق): امسح الجلسة محلياً — التوكن
  // والمستخدم وكواش الـ SWR — ووجّه لشاشة الدخول. يُستدعى مرّة واحدة عبر حارس
  // DioClient (لا حلقات إعادة توجيه من طلبات 401 متزامنة).
  DioClient.onUnauthenticated = () {
    DioClient.clearToken();
    CurrentUser.instance.clear();
    SessionCacheRegistry.instance.clearAll();
    AppRouter.router.go(RouteNames.login);
  };

  // تحميل التفضيلات المحفوظة (تشغيل متوازي لتسريع الإقلاع).
  await Future.wait([
    di.sl<ThemeCubit>().loadSavedTheme(),
    di.sl<TextScaleCubit>().loadSaved(),
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
        BlocProvider<TextScaleCubit>.value(value: di.sl<TextScaleCubit>()),
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

                    // غلاف الصفحات: (1) قفل الجلسة بالخمول (أمان)، (2) حجم الخط
                    // (وصولية) عبر MediaQuery.textScaler — كلاهما بلا مسّ أي ودجت
                    // أو تصميم.
                    builder: (context, child) {
                      final scale =
                          context.watch<TextScaleCubit>().state.factor;
                      final mq = MediaQuery.of(context);
                      return IdleTimeoutWatcher(
                        timeout: _kIdleTimeout,
                        sessionListenable: CurrentUser.instance,
                        isActive: () => CurrentUser.instance.isLoggedIn,
                        onTimeout: _onIdleTimeout,
                        child: MediaQuery(
                          data:
                              mq.copyWith(textScaler: TextScaler.linear(scale)),
                          child: child ?? const SizedBox.shrink(),
                        ),
                      );
                    },

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
