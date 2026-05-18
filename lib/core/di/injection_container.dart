// ════════════════════════════════════════════════════════════════════════════
// injection_container.dart
//
// إعداد Dependency Injection باستخدام GetIt.
// القرار 8: GetIt + Injectable (سنستخدم Injectable في Features المتقدمة).
//
// حالياً (Feature 1 - Foundation) نسجّل فقط:
//   - Dio client
//   - ThemeCubit
// باقي الـ BLoCs والـ Repositories تُسجَّل في Features 3-7.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../../shared/bloc/locale_cubit.dart';
import '../../shared/bloc/mock_system_cubit.dart';
import '../../shared/bloc/theme_cubit.dart';

/// الحاوية الرئيسية للـ DI.
final GetIt sl = GetIt.instance;

/// تهيئة كل التبعيات — تُستدعى مرة واحدة في main() قبل runApp.
Future<void> initDependencies() async {
  // ── External (مكتبات خارجية) ────────────────────────────────────────────
  sl.registerLazySingleton<Dio>(() => DioClient.build());

  // ── Cubits / BLoCs (Singletons) ────────────────────────────────────────
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
  sl.registerLazySingleton<LocaleCubit>(() => LocaleCubit());
  sl.registerLazySingleton<MockSystemCubit>(() => MockSystemCubit());

  // TODO: في Feature 3 — تسجيل AuthBloc + AuthRepository
  // TODO: في Feature 4 — تسجيل WarehouseBloc + WarehouseRepository
  // TODO: في Feature 5 — تسجيل LabBloc + LabRepository
  // TODO: في Feature 6 — تسجيل AuditService + ExpiryCheckerService
  // ملاحظة: MockSystemCubit مؤقت — يُستبدل بـ AuthCubit عند توفر الـ Backend.
}

/// تصفير كل التسجيلات — مفيد في الاختبارات.
Future<void> resetDependencies() => sl.reset();
