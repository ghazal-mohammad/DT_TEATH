// ════════════════════════════════════════════════════════════════════════════
// injection_container.dart
//
// إعداد Dependency Injection باستخدام GetIt.
// كل الـ Dependencies تُسجَّل هنا، وتُحقن في الـ Cubits/Repositories.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../../shared/bloc/locale_cubit.dart';
import '../../shared/bloc/mock_system_cubit.dart';
import '../../shared/bloc/theme_cubit.dart';

// ── Auth feature ──────────────────────────────────────────────────────────
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/email_entry_cubit.dart';
import '../../features/auth/presentation/bloc/login_cubit.dart';
import '../../features/auth/presentation/bloc/set_password_cubit.dart';

// ── Profile feature (مشترك: مخبر + مستودع) ─────────────────────────────────
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/bloc/profile_cubit.dart';

/// الحاوية الرئيسية للـ DI.
final GetIt sl = GetIt.instance;

/// تهيئة كل التبعيات — تُستدعى مرة واحدة في main() قبل runApp.
Future<void> initDependencies() async {
  // ── External (مكتبات خارجية) ────────────────────────────────────────────
  sl.registerLazySingleton<Dio>(() => DioClient.build());

  // ── Cubits / BLoCs مشتركة ──────────────────────────────────────────────
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
  sl.registerLazySingleton<LocaleCubit>(() => LocaleCubit());
  sl.registerLazySingleton<MockSystemCubit>(() => MockSystemCubit());

  // ── Auth: Data + Domain ────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  // ── Auth: Cubits — Factory (instance جديدة لكل شاشة) ───────────────────
  sl.registerFactory<EmailEntryCubit>(
    () => EmailEntryCubit(sl<AuthRepository>()),
  );
  sl.registerFactory<LoginCubit>(
    () => LoginCubit(sl<AuthRepository>()),
  );
  sl.registerFactory<SetPasswordCubit>(
    () => SetPasswordCubit(sl<AuthRepository>()),
  );

  // ── Profile: Data + Domain ─────────────────────────────────────────────
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()),
  );

  // ── Profile: Cubit — Factory (instance لكل صفحة بروفايل) ───────────────
  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(sl<ProfileRepository>()),
  );
}

/// تصفير كل التسجيلات — مفيد في الاختبارات.
Future<void> resetDependencies() => sl.reset();
