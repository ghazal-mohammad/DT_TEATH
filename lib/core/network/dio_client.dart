// ════════════════════════════════════════════════════════════════════════════
// dio_client.dart
//
// إعداد Dio الرئيسي مع Interceptors:
//   - إضافة Token تلقائياً لكل طلب.
//   - معالجة الأخطاء ورفعها كـ Failure.
//   - Logging (مطفأ في Production).
//
// القرار 6: Dio بدل http/Retrofit.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_urls.dart';

class DioClient {
  DioClient._();

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  /// Dio instance جاهزة للاستخدام.
  /// تُبنى مرة واحدة عند بدء التطبيق وتُسجّل في GetIt.
  static Dio build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppUrls.baseUrl,
        connectTimeout: AppUrls.connectTimeout,
        receiveTimeout: AppUrls.receiveTimeout,
        sendTimeout: AppUrls.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ── Interceptor: إضافة Token تلقائياً ────────────────────────────────
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: _tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // معالجة 401 تلقائياً — مسح التوكن ليُعاد التوجيه لـ login.
          if (error.response?.statusCode == 401) {
            _storage.delete(key: _tokenKey);
          }
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// حفظ التوكن بعد تسجيل الدخول.
  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  /// مسح التوكن عند تسجيل الخروج.
  static Future<void> clearToken() => _storage.delete(key: _tokenKey);

  /// قراءة التوكن الحالي.
  static Future<String?> readToken() => _storage.read(key: _tokenKey);
}
