// ════════════════════════════════════════════════════════════════════════════
// auth_remote_datasource.dart
//
// مصدر البيانات البعيد — يتصل مباشرة بـ Dio.
// كل دالة بترجع response.data خام (Map). الـrepository بيحوّلو لـentities.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/endpoints.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  /// POST /api/employee/sendVerification
  Future<Map<String, dynamic>> sendVerification({required String email}) async {
    final response = await _dio.post(
      ApiEndpoints.employeeSendVerification,
      data: FormData.fromMap({'email': email}),
    );
    return _asMap(response.data);
  }

  /// POST /api/employee/verifyCode
  Future<Map<String, dynamic>> verifyCode({
    required String email,
    required String verificationCode,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.employeeVerifyCode,
      data: FormData.fromMap({
        'email': email,
        'verification_code': verificationCode,
      }),
    );
    return _asMap(response.data);
  }

  /// POST /api/employee/setPassword
  Future<Map<String, dynamic>> setPassword({
    required String email,
    required String verificationCode,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.employeeSetPassword,
      data: FormData.fromMap({
        'email': email,
        'verification_code': verificationCode,
        'password': password,
      }),
    );
    return _asMap(response.data);
  }

  /// POST /api/employee/login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.employeeLogin,
      data: FormData.fromMap({
        'email': email,
        'password': password,
      }),
    );
    return _asMap(response.data);
  }

  /// POST /api/employee/logout (محمي بـ Bearer)
  Future<void> logout() async {
    await _dio.post(ApiEndpoints.employeeLogout);
  }

  // ── Forgot Password (إعادة تعيين كلمة سر لحساب مُفعَّل) ──────────────────

  /// POST /api/forgotPassword/sendCode
  Future<Map<String, dynamic>> sendResetCode({required String email}) async {
    final response = await _dio.post(
      ApiEndpoints.forgotPasswordSendCode,
      data: FormData.fromMap({'email': email}),
    );
    return _asMap(response.data);
  }

  /// POST /api/forgotPassword/verifyCode
  Future<Map<String, dynamic>> verifyResetCode({
    required String email,
    required String verificationCode,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.forgotPasswordVerifyCode,
      data: FormData.fromMap({
        'email': email,
        'verification_code': verificationCode,
      }),
    );
    return _asMap(response.data);
  }

  /// POST /api/forgotPassword/resetPassword (body: email + password فقط)
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.forgotPasswordReset,
      data: FormData.fromMap({
        'email': email,
        'password': password,
      }),
    );
    return _asMap(response.data);
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }
}
