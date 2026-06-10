// ════════════════════════════════════════════════════════════════════════════
// dio_client.dart
//
// إعداد Dio الرئيسي مع Interceptors:
//   - إضافة Token تلقائياً لكل طلب.
//   - معالجة الأخطاء.
//   - Logging مفصّل في وضع التطوير (Chrome Console).
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_urls.dart';

class DioClient {
  DioClient._();

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  /// نسخة بالذاكرة من التوكن — مصدر الحقيقة أثناء الجلسة.
  /// السبب: قراءة FlutterSecureStorage على Flutter Web غير مستقرة أحياناً
  /// (قد ترجّع null لحظياً)، فكان طلب يُرسَل بدون توكن → 401. الذاكرة تضمن
  /// إرفاق التوكن لكل طلب بشكل حتمي.
  static String? _cachedToken;

  /// Dio instance جاهزة للاستخدام.
  /// تُبنى مرة واحدة عند بدء التطبيق وتُسجّل في GetIt.
  static Dio build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppUrls.baseUrl,
        connectTimeout: AppUrls.connectTimeout,
        receiveTimeout: AppUrls.receiveTimeout,
        sendTimeout: AppUrls.sendTimeout,
        // Accept فقط — Content-Type يضعه Dio تلقائياً حسب نوع الـ body
        // (multipart لـ FormData، application/json لـ Map).
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    // ── Interceptor 1: إضافة Token تلقائياً ──────────────────────────────
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // الذاكرة أولاً، ثم secure storage كاحتياط (وتسخين الذاكرة).
          var token = _cachedToken;
          if (token == null || token.isEmpty) {
            token = await _storage.read(key: _tokenKey);
            if (token != null && token.isNotEmpty) _cachedToken = token;
          }
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        // ملاحظة: لا نمسح التوكن تلقائياً عند 401 — كان أي 401 عابر يهدم
        // الجلسة كلها. تسجيل الخروج الصريح هو اللي يمسح التوكن.
      ),
    );

    // ── Interceptor 2: Logging — في وضع التطوير فقط ──────────────────────
    if (kDebugMode && AppUrls.current == Environment.development) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (line) => debugPrint('[Dio] $line'),
        ),
      );
    }

    return dio;
  }

  /// حفظ التوكن بعد تسجيل الدخول (ذاكرة + storage).
  static Future<void> saveToken(String token) {
    _cachedToken = token;
    return _storage.write(key: _tokenKey, value: token);
  }

  /// مسح التوكن عند تسجيل الخروج (ذاكرة + storage).
  static Future<void> clearToken() {
    _cachedToken = null;
    return _storage.delete(key: _tokenKey);
  }

  /// قراءة التوكن الحالي (الذاكرة أولاً).
  static Future<String?> readToken() async =>
      _cachedToken ?? await _storage.read(key: _tokenKey);
}
