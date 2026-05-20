// ════════════════════════════════════════════════════════════════════════════
// auth_repository_impl.dart
//
// تنفيذ AuthRepository. بيستدعي AuthRemoteDataSource وبيحوّل الأخطاء
// لـFailure واضحة قبل ما يرفعها للـpresentation.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/auth/auth_models.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<void> sendVerification({required String email}) async {
    try {
      await _remote.sendVerification(email: email);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<EmployeeUser> setPassword({
    required String email,
    required String verificationCode,
    required String password,
  }) async {
    try {
      final json = await _remote.setPassword(
        email: email,
        verificationCode: verificationCode,
        password: password,
      );
      final user = EmployeeUser.fromJson(json);

      if (user.token.isEmpty) {
        throw const UnexpectedFailure('الرد لا يحتوي على توكن');
      }

      await DioClient.saveToken(user.token);
      return user;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<EmployeeUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final json = await _remote.login(email: email, password: password);
      final user = EmployeeUser.fromJson(json);

      if (user.token.isEmpty) {
        throw const UnexpectedFailure('الرد لا يحتوي على توكن');
      }
      if (!user.isActive) {
        throw const ServerFailure(
          'الحساب غير مفعّل — تواصل مع المدير.',
          code: '403',
        );
      }

      // حفظ التوكن — Dio interceptor رح يستعملو تلقائياً بعد هيك.
      await DioClient.saveToken(user.token);
      return user;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } on DioException catch (_) {
      // تجاهل أخطاء الـAPI — لازم نمسح التوكن محلياً مهما يكن.
    } finally {
      await DioClient.clearToken();
    }
  }

  /// تحويل DioException لـFailure مناسب.
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
    if (status == null) {
      return const NetworkFailure();
    }

    // محاولة استخراج رسالة من الباك إن وُجدت.
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
