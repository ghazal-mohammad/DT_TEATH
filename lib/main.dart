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

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/auth/current_user.dart';
import 'core/di/injection_container.dart' as di;
import 'core/monitoring/crash_reporter.dart';
import 'core/l10n/generated/app_localizations.dart';
import 'core/network/dio_client.dart';
import 'core/offline/outbox.dart';
import 'core/offline/outbox_processor.dart';
import 'core/router/app_router.dart';
import 'core/router/route_names.dart';
import 'features/lab/data/repositories/remote_lab_products_repository.dart';
import 'features/lab/domain/repositories/lab_products_repository.dart';
import 'features/warehouse/data/repositories/remote_warehouse_materials_repository.dart';
import 'features/warehouse/domain/repositories/warehouse_materials_repository.dart';
import 'core/search/app_search_warmup.dart';
import 'core/session/session_cache_registry.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'shared/bloc/locale_cubit.dart';
import 'shared/bloc/mock_system_cubit.dart';
import 'shared/bloc/text_scale_cubit.dart';
import 'shared/bloc/theme_cubit.dart';
import 'shared/widgets/feedback/app_error_view.dart';
import 'shared/widgets/feedback/offline_banner.dart';
import 'shared/widgets/command_palette/command_palette.dart';
import 'shared/widgets/session/idle_timeout_watcher.dart';
import 'shared/widgets/session/privacy_guard.dart';

/// مدّة الخمول قبل قفل الجلسة تلقائياً (أمان الأجهزة المشتركة).
const Duration _kIdleTimeout = Duration(minutes: 15);

/// قفل الجلسة عند الخمول: تسجيل خروج صامت (يُبطل التوكن في الباك ويمسح محلياً)
/// ثم توجيه لشاشة الدخول. صامت (بلا نافذة تأكيد) لأنه تلقائي.
void _onIdleTimeout() {
  di.sl<AuthRepository>().logout();
  AppRouter.router.go(RouteNames.login);
}

/// يفتح مركز الأوامر (بحث عالمي) — فقط أثناء جلسة نشطة (لا على شاشات الدخول).
void _openCommandPalette(BuildContext context) {
  if (!CurrentUser.instance.isLoggedIn) return;
  CommandPalette.show(context);
}

/// مُبلِّغ الأعطال المركزي (const، بلا حزمة/مفتاح). يُستبدَل بـ Sentry لاحقاً.
const CrashReporter _crashReporter = ConsoleCrashReporter();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  FlutterError.onError = (details) {
    _crashReporter.recordError(details.exception, details.stack,
        context: 'flutter');
    if (!kReleaseMode) FlutterError.presentError(details);
  };
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    _crashReporter.recordError(error, stack, context: 'platform');
    return true;
  };
  if (kReleaseMode) {
    ErrorWidget.builder = (details) => const AppErrorView();
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  await di.initDependencies();

  SessionCacheRegistry.instance.register(AppSearchWarmup.reset);


  DioClient.onUnauthenticated = () {
    DioClient.clearToken();
    CurrentUser.instance.clear();
    SessionCacheRegistry.instance.clearAll();
    AppRouter.router.go(RouteNames.login);
  };


  await di.sl<Outbox>().load();
  final outboxProcessor = di.sl<OutboxProcessor>()
    ..onResourceSynced = (resource) {
      if (resource == RemoteWarehouseMaterialsRepository.resource) {
        di.sl<WarehouseMaterialsRepository>().getAll();
      } else if (resource == RemoteLabProductsRepository.resource) {
        di.sl<LabProductsRepository>().getAll();
      }
    }
    ..start();
  unawaited(outboxProcessor.process());

  await Future.wait([
    di.sl<ThemeCubit>().loadSavedTheme(),
    di.sl<TextScaleCubit>().loadSaved(),
    di.sl<LocaleCubit>().loadSaved(),
    di.sl<MockSystemCubit>().loadSaved(),
  ]);

  runApp(const DtTeethApp());
}


/// [MaterialApp.router].
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
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              return ScreenUtilInit(
                designSize: const Size(1440, 900),
                minTextAdapt: true,
                splitScreenMode: true,
                builder: (context, child) {
                  return MaterialApp.router(
                    onGenerateTitle: (ctx) =>
                        AppLocalizations.of(ctx).appName,
                    debugShowCheckedModeBanner: false,

                    // الثيم
                    themeMode: themeMode,
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,

                    locale: locale,
                    supportedLocales: AppLocalizations.supportedLocales,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,


                    routerConfig: AppRouter.router,

                    builder: (context, child) {
                      final scale =
                          context.watch<TextScaleCubit>().state.factor;
                      final mq = MediaQuery.of(context);
                             return PrivacyGuard(
                        child: CallbackShortcuts(
                          bindings: <ShortcutActivator, VoidCallback>{
                            const SingleActivator(LogicalKeyboardKey.keyK,
                                    control: true):
                                () => _openCommandPalette(context),
                            const SingleActivator(LogicalKeyboardKey.keyK,
                                meta: true): () => _openCommandPalette(context),
                          },

                          child: OfflineBanner(
                            syncListenable: di.sl<Outbox>(),
                            pendingSyncCount: () => di.sl<Outbox>().pendingCount,
                            child: IdleTimeoutWatcher(
                              timeout: _kIdleTimeout,
                              sessionListenable: CurrentUser.instance,
                              isActive: () => CurrentUser.instance.isLoggedIn,
                              onTimeout: _onIdleTimeout,
                              child: MediaQuery(
                                data: mq.copyWith(
                                    textScaler: TextScaler.linear(scale)),
                                child: child ?? const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ),
                      );
                    },

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
