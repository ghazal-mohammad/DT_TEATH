// ════════════════════════════════════════════════════════════════════════════
// profile_repository_impl.dart
//
// تنفيذ ProfileRepository. يستدعي ProfileRemoteDataSource ويحوّل أخطاء Dio
// إلى Failure عربية واضحة قبل رفعها للـ presentation (نفس نمط AuthRepositoryImpl).
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/auth/current_user.dart';
import '../../../../core/network/failure.dart';
import '../../../../core/session/session_cache_registry.dart';
import '../../domain/entities/edit_profile_payload.dart';
import '../../domain/entities/employee_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote) {
    // دفاع في العمق: الكاش مربوط أصلاً بمعرّف المالك، لكن نمسحه صراحةً عند الخروج.
    SessionCacheRegistry.instance.register(() {
      _cache = null;
      _cacheOwnerId = null;
    });
  }

  final ProfileRemoteDataSource _remote;

  /// كاش بالذاكرة لآخر ملف + معرّف صاحبه، ليُعرَض فوراً عند إعادة زيارة الصفحة
  /// (هذا الـ repository singleton فالكاش يحيا طوال الجلسة).
  EmployeeProfile? _cache;
  int? _cacheOwnerId;

  @override
  EmployeeProfile? get cachedProfile =>
      _cacheOwnerId == CurrentUser.instance.user?.id ? _cache : null;

  @override
  Future<EmployeeProfile> getProfile() async {
    try {
      final json = await _remote.showProfile();
      final profile = EmployeeProfile.fromJson(json);
      _store(profile);
      return profile;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<EmployeeProfile> updateProfile(EditProfilePayload payload) async {
    try {
      final json = await _remote.editProfile(payload);
      final profile = EmployeeProfile.fromJson(json);
      _store(profile);
      return profile;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// يحفظ الملف في الكاش ويربطه بالمستخدم الحالي (لإبطاله تلقائياً عند تبدّله).
  void _store(EmployeeProfile profile) {
    _cache = profile;
    _cacheOwnerId = CurrentUser.instance.user?.id;
  }

  /// تحويل DioException لـ Failure مناسب.
  Failure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const TimeoutFailure();
    }
    if (e.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }

    final status = e.response?.statusCode;
    if (status == null) return const NetworkFailure();

    // محاولة استخراج رسالة الباك إن وُجدت.
    String? backendMessage;
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      backendMessage = data['message'] as String;
    }

    if (backendMessage != null && backendMessage.isNotEmpty) {
      return ServerFailure(backendMessage, code: '$status');
    }
    return ServerFailure.fromStatusCode(status);
  }
}
