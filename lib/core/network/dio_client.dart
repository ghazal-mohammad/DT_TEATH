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
import 'network_status.dart';

class DioClient {
  DioClient._();

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  /// نسخة بالذاكرة من التوكن — مصدر الحقيقة أثناء الجلسة.
  /// السبب: قراءة FlutterSecureStorage على Flutter Web غير مستقرة أحياناً
  /// (قد ترجّع null لحظياً)، فكان طلب يُرسَل بدون توكن → 401. الذاكرة تضمن
  /// إرفاق التوكن لكل طلب بشكل حتمي.
  static String? _cachedToken;

  /// يُستدعى عند انتهاء الجلسة (401 على طلب مُصادَق) — يضبطه [main] ليمسح
  /// الجلسة محلياً ويوجّه لشاشة الدخول. null قبل ضبطه = لا إجراء.
  static void Function()? onUnauthenticated;

  /// حارس ضد التكرار: عدّة طلبات مُصادَقة قد ترجع 401 معاً بعد انتهاء التوكن،
  /// فنعالج انتهاء الجلسة مرّة واحدة فقط (يُعاد ضبطه عند تسجيل دخول جديد).
  static bool _sessionExpiredHandled = false;

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
          // sendTimeout بلا جسم طلب (GET) يطبع تحذيراً على الويب في كل مرة
          // ("sendTimeout cannot be used without a request body to send on
          // Web") — Dio يتجاهله فعلياً فلا فرق وظيفي، لكنه يُغرق الـ console.
          if (options.method == 'GET') options.sendTimeout = null;

          // حارس النقل الآمن: خارج التطوير المحلّي، امنع أي طلب non-HTTPS
          // (يحمي بيانات المرضى من الإرسال عبر قناة غير مشفّرة — دفاع بعمق
          // ضد تجاوز API_BASE_URL خاطئ بعنوان http في الإنتاج/الاختبار).
          if (AppUrls.current != Environment.development &&
              !options.uri.isScheme('https')) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                error: 'Insecure transport blocked: HTTPS required '
                    'outside development (${options.uri.scheme}).',
              ),
            );
            return;
          }

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
        onResponse: (response, handler) {
          // وصل ردّ من الخادم ⇒ الاتصال متاح.
          NetworkStatus.instance.markOnline();
          handler.next(response);
        },
        onError: (e, handler) {
          // خطأ اتصال/مهلة بلا ردّ ⇒ غير متصل. وجود ردّ (حتى خطأ) ⇒ متصل.
          const offlineTypes = {
            DioExceptionType.connectionError,
            DioExceptionType.connectionTimeout,
            DioExceptionType.receiveTimeout,
            DioExceptionType.sendTimeout,
          };
          if (e.response == null && offlineTypes.contains(e.type)) {
            NetworkStatus.instance.markOffline();
          } else if (e.response != null) {
            NetworkStatus.instance.markOnline();
          }
          // 401 على طلب حمل توكن (Authorization) = التوكن منتهٍ/ملغى → انتهت
          // الجلسة. نستثني طلبات الدخول/التفعيل (لا تحمل توكن) فيبقى خطؤها
          // ظاهراً في النموذج. ومع تسخين التوكن في الذاكرة لم يعُد الـ 401
          // عابراً (سبب الحجب السابق للمعالجة التلقائية زال).
          final bool authed =
              e.requestOptions.headers.containsKey('Authorization');
          if (e.response?.statusCode == 401 &&
              authed &&
              !_sessionExpiredHandled) {
            _sessionExpiredHandled = true;
            onUnauthenticated?.call();
          }
          handler.next(e);
        },
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
    _sessionExpiredHandled = false; // جلسة جديدة → إعادة تسليح حارس الانتهاء.
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
