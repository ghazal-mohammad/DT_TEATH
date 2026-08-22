// ════════════════════════════════════════════════════════════════════════════
// injection_container.dart
//
// إعداد Dependency Injection باستخدام GetIt.
// كل الـ Dependencies تُسجَّل هنا، وتُحقن في الـ Cubits/Repositories.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../monitoring/crash_reporter.dart';
import '../network/dio_client.dart';
import '../notifications/fcm_service.dart';
import '../notifications/notification_badge_cubit.dart';
import '../offline/local_store.dart';
import '../offline/outbox.dart';
import '../offline/outbox_processor.dart';
import '../offline/persistent_cache.dart';
import '../../shared/bloc/locale_cubit.dart';
import '../../shared/bloc/mock_system_cubit.dart';
import '../../shared/bloc/compact_view_cubit.dart';
import '../../shared/bloc/text_scale_cubit.dart';
import '../../shared/bloc/theme_cubit.dart';

// ── Warehouse feature ──────────────────────────────────────────────────────
import '../../features/warehouse/data/datasources/warehouse_materials_remote_datasource.dart';
import '../../features/warehouse/data/datasources/warehouse_stock_remote_datasource.dart';
import '../../features/warehouse/data/datasources/warehouse_requests_remote_datasource.dart';
import '../../features/warehouse/data/datasources/warehouse_inventory_remote_datasource.dart';
import '../../features/warehouse/data/datasources/purchase_invoices_remote_datasource.dart';
import '../../features/warehouse/data/datasources/warehouse_reports_remote_datasource.dart';
import '../../features/warehouse/data/repositories/remote_warehouse_materials_repository.dart';
import '../../features/warehouse/data/repositories/remote_warehouse_stock_repository.dart';
import '../../features/warehouse/data/repositories/remote_warehouse_requests_repository.dart';
import '../../features/warehouse/data/repositories/remote_warehouse_inventory_repository.dart';
import '../../features/warehouse/data/repositories/remote_purchase_invoices_repository.dart';
import '../../features/warehouse/data/repositories/remote_warehouse_reports_repository.dart';
import '../../features/warehouse/data/datasources/warehouse_notifications_remote_datasource.dart';
import '../../features/warehouse/data/repositories/remote_warehouse_notifications_repository.dart';
import '../../features/warehouse/domain/repositories/warehouse_notifications_repository.dart';
import '../../features/warehouse/domain/repositories/warehouse_materials_repository.dart';
import '../../features/warehouse/domain/repositories/warehouse_stock_repository.dart';
import '../../features/warehouse/domain/repositories/warehouse_requests_repository.dart';
import '../../features/warehouse/domain/repositories/warehouse_inventory_repository.dart';
import '../../features/warehouse/domain/repositories/purchase_invoices_repository.dart';
import '../../features/warehouse/domain/repositories/warehouse_reports_repository.dart';

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

// ── Lab feature ────────────────────────────────────────────────────────────
import '../../features/lab/data/datasources/lab_remote_datasource.dart';
import '../../features/lab/data/datasources/lab_products_remote_datasource.dart';
import '../../features/lab/data/datasources/lab_orders_remote_datasource.dart';
import '../../features/lab/data/datasources/lab_material_requests_remote_datasource.dart';
import '../../features/lab/data/datasources/lab_reports_remote_datasource.dart';
import '../../features/lab/data/datasources/lab_stock_remote_datasource.dart';
import '../../features/lab/data/datasources/lab_notifications_remote_datasource.dart';
import '../../features/lab/data/repositories/lab_repository_impl.dart';
import '../../features/lab/data/repositories/remote_lab_products_repository.dart';
import '../../features/lab/data/repositories/remote_lab_orders_repository.dart';
import '../../features/lab/data/repositories/remote_lab_material_requests_repository.dart';
import '../../features/lab/data/repositories/remote_lab_reports_repository.dart';
import '../../features/lab/data/repositories/remote_lab_stock_repository.dart';
import '../../features/lab/data/repositories/remote_lab_notifications_repository.dart';
import '../../features/lab/domain/repositories/lab_repository.dart';
import '../../features/lab/domain/repositories/lab_products_repository.dart';
import '../../features/lab/domain/repositories/lab_orders_repository.dart';
import '../../features/lab/domain/repositories/lab_material_requests_repository.dart';
import '../../features/lab/domain/repositories/lab_reports_repository.dart';
import '../../features/lab/domain/repositories/lab_stock_repository.dart';
import '../../features/lab/domain/repositories/lab_notifications_repository.dart';

/// الحاوية الرئيسية للـ DI.
final GetIt sl = GetIt.instance;

/// تهيئة كل التبعيات — تُستدعى مرة واحدة في main() قبل runApp.
Future<void> initDependencies() async {
  // ── External (مكتبات خارجية) ────────────────────────────────────────────
  sl.registerLazySingleton<Dio>(() => DioClient.build());

  // ── رصد الأعطال (مركزي، قابل للاستبدال بـ Sentry لاحقاً) ─────────────────
  sl.registerLazySingleton<CrashReporter>(() => const ConsoleCrashReporter());

  // ── Push حقيقي (FCM) — ويب فقط، يُستدعى بعد الدخول (main.dart) ──────────
  sl.registerLazySingleton<FcmService>(() => FcmService(sl<Dio>()));

  // ── عدّاد الإشعارات غير المقروءة — بادج الـ topbar بكل الصفحات ──────────
  sl.registerLazySingleton<NotificationBadgeCubit>(
    () => NotificationBadgeCubit(sl<Dio>()),
  );

  // ── Offline core (كاش دائم + طابور صادر) ────────────────────────────────
  // نُهيّئ SharedPreferences مبكّراً (async) لأن الكاش والطابور يعتمدان عليه.
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<LocalStore>(() => SharedPrefsLocalStore(prefs));
  sl.registerLazySingleton<PersistentCache>(
    () => PersistentCache(sl<LocalStore>()),
  );
  sl.registerLazySingleton<Outbox>(() => Outbox(sl<LocalStore>()));
  sl.registerLazySingleton<OutboxProcessor>(
    () => OutboxProcessor(outbox: sl<Outbox>(), dio: sl<Dio>()),
  );

  // ── Cubits / BLoCs مشتركة ──────────────────────────────────────────────
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
  sl.registerLazySingleton<TextScaleCubit>(() => TextScaleCubit());
  sl.registerLazySingleton<LocaleCubit>(() => LocaleCubit());
  sl.registerLazySingleton<MockSystemCubit>(() => MockSystemCubit());
  sl.registerLazySingleton<CompactViewCubit>(() => CompactViewCubit());

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

  // ── Lab: Data + Domain ─────────────────────────────────────────────────
  sl.registerLazySingleton<LabRemoteDataSource>(
    () => LabRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<LabRepository>(
    () => LabRepositoryImpl(sl<LabRemoteDataSource>()),
  );

  // ── Lab Products (كتالوج الأصناف) — Remote عبر labManager/showAllLabItems ──
  sl.registerLazySingleton<LabProductsRemoteDataSource>(
    () => LabProductsRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<LabProductsRepository>(
    () => RemoteLabProductsRepository(
      sl<LabProductsRemoteDataSource>(),
      sl<PersistentCache>(),
      sl<Outbox>(),
    ),
  );

  // ── Lab Orders (طلبات الأطباء) — Remote عبر labManager/showAllLabOrders ────
  sl.registerLazySingleton<LabOrdersRemoteDataSource>(
    () => LabOrdersRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<LabOrdersRepository>(
    () => RemoteLabOrdersRepository(
      sl<LabOrdersRemoteDataSource>(),
      sl<LabRepository>(),
      sl<PersistentCache>(),
    ),
  );

  // ── Lab Material Requests — Remote عبر labManager/showAllMaterialRequests ──
  sl.registerLazySingleton<LabMaterialRequestsRemoteDataSource>(
    () => LabMaterialRequestsRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<LabMaterialRequestsRepository>(
    () => RemoteLabMaterialRequestsRepository(
      sl<LabMaterialRequestsRemoteDataSource>(),
      sl<PersistentCache>(),
    ),
  );

  // ── Lab Stock (مخزون المخبر) — Remote عبر labManager/showLabStock ──────────
  sl.registerLazySingleton<LabStockRemoteDataSource>(
    () => LabStockRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<LabStockRepository>(
    () => RemoteLabStockRepository(
      sl<LabStockRemoteDataSource>(),
      sl<PersistentCache>(),
    ),
  );

  // ── Lab Reports (تقرير تحليلي) — Remote عبر labManager/reports ────────────
  sl.registerLazySingleton<LabReportsRemoteDataSource>(
    () => LabReportsRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<LabReportsRepository>(
    () => RemoteLabReportsRepository(sl<LabReportsRemoteDataSource>()),
  );

  // ── Warehouse Materials — Remote عبر warehouseManager/showALLMaterials ────
  sl.registerLazySingleton<WarehouseMaterialsRemoteDataSource>(
    () => WarehouseMaterialsRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<WarehouseMaterialsRepository>(
    () => RemoteWarehouseMaterialsRepository(
      sl<WarehouseMaterialsRemoteDataSource>(),
      sl<PersistentCache>(),
      sl<Outbox>(),
    ),
  );

  // ── Warehouse Stock (المخزون والدفعات) — Remote عبر warehouseManager/*Stock* ─
  sl.registerLazySingleton<WarehouseStockRemoteDataSource>(
    () => WarehouseStockRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<WarehouseStockRepository>(
    () => RemoteWarehouseStockRepository(sl<WarehouseStockRemoteDataSource>()),
  );

  // ── Warehouse Requests (طلبات المواد الواردة) — تلبية/رفض ─────────────────
  sl.registerLazySingleton<WarehouseRequestsRemoteDataSource>(
    () => WarehouseRequestsRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<WarehouseRequestsRepository>(
    () => RemoteWarehouseRequestsRepository(
      sl<WarehouseRequestsRemoteDataSource>(),
      sl<PersistentCache>(),
    ),
  );

  // ── Warehouse Inventory (مؤشّرات لوحة المستودع) ──────────────────────────
  sl.registerLazySingleton<WarehouseInventoryRemoteDataSource>(
    () => WarehouseInventoryRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<WarehouseInventoryRepository>(
    () => RemoteWarehouseInventoryRepository(
      sl<WarehouseInventoryRemoteDataSource>(),
      sl<LocalStore>(),
    ),
  );

  // ── Warehouse Purchase Invoices (فواتير الشراء — عرض) ────────────────────
  sl.registerLazySingleton<PurchaseInvoicesRemoteDataSource>(
    () => PurchaseInvoicesRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<PurchaseInvoicesRepository>(
    () => RemotePurchaseInvoicesRepository(
      sl<PurchaseInvoicesRemoteDataSource>(),
      sl<PersistentCache>(),
    ),
  );

  // ── Warehouse Reports (تقرير المشتريات) ──────────────────────────────────
  sl.registerLazySingleton<WarehouseReportsRemoteDataSource>(
    () => WarehouseReportsRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<WarehouseReportsRepository>(
    () => RemoteWarehouseReportsRepository(
        sl<WarehouseReportsRemoteDataSource>()),
  );

  // ── Lab Notifications — Remote عبر labManager/notifications ────────────
  sl.registerLazySingleton<LabNotificationsRemoteDataSource>(
    () => LabNotificationsRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<LabNotificationsRepository>(
    () => RemoteLabNotificationsRepository(
        sl<LabNotificationsRemoteDataSource>()),
  );

  // ── Warehouse Notifications — Remote عبر warehouseManager/notifications ─
  sl.registerLazySingleton<WarehouseNotificationsRemoteDataSource>(
    () => WarehouseNotificationsRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<WarehouseNotificationsRepository>(
    () => RemoteWarehouseNotificationsRepository(
        sl<WarehouseNotificationsRemoteDataSource>()),
  );
}

/// تصفير كل التسجيلات — مفيد في الاختبارات.
Future<void> resetDependencies() => sl.reset();
