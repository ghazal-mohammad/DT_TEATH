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

    // ── Interceptor 2: Logging آمن — تطوير فقط، مع حجب البيانات الحسّاسة ──
    // لا نستخدم LogInterceptor الافتراضي لأنه يطبع Authorization (التوكن)
    // وكلمات المرور والأكواد إلى console — تسريب اعتمادات. هذا البديل يحجبها.
    if (kDebugMode && AppUrls.current == Environment.development) {
      dio.interceptors.add(_RedactingLogInterceptor());
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

/// Logger تطويري يطبع الطلبات/الاستجابات مع **حجب** الحقول الحسّاسة (Authorization،
/// كلمات المرور، أكواد التحقق، التوكنات) قبل الطباعة — لمنع تسريبها إلى console.
/// يُفعَّل في وضع التطوير فقط (kDebugMode) فلا يصل شيء منه لبناء الإنتاج.
class _RedactingLogInterceptor extends Interceptor {
  static const Set<String> _sensitiveKeys = {
    'password',
    'password_confirmation',
    'current_password',
    'new_password',
    'token',
    'access_token',
    'refresh_token',
    'verification_code',
    'code',
    'otp',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[Dio] → ${options.method} ${options.uri}');
    final headers = Map<String, dynamic>.from(options.headers);
    if (headers.containsKey('Authorization')) {
      headers['Authorization'] = '***';
    }
    debugPrint('[Dio]   headers: $headers');
    debugPrint('[Dio]   body: ${_redact(options.data)}');
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    debugPrint('[Dio] ← ${response.statusCode} ${response.requestOptions.uri}');
    debugPrint('[Dio]   data: ${_redact(response.data)}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('[Dio] ✗ ${err.response?.statusCode} '
        '${err.requestOptions.uri} — ${err.message}');
    handler.next(err);
  }

  /// يستبدل قيم المفاتيح الحسّاسة بـ *** بشكل تعاودي (Map/List/FormData).
  Object? _redact(Object? data) {
    if (data is Map) {
      return data.map((k, v) => MapEntry(
            k,
            _sensitiveKeys.contains(k.toString().toLowerCase())
                ? '***'
                : _redact(v),
          ));
    }
    if (data is List) return data.map(_redact).toList();
    if (data is FormData) {
      return {
        for (final f in data.fields)
          f.key: _sensitiveKeys.contains(f.key.toLowerCase()) ? '***' : f.value,
        if (data.files.isNotEmpty)
          '_files': data.files.map((f) => f.key).toList(),
      };
    }
    return data;
  }
}
