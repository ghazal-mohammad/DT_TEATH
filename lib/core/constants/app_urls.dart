// ════════════════════════════════════════════════════════════════════════════
// app_urls.dart
//
// إعدادات الـ Base URL والبيئات (Development / Staging / Production).
// يُستخدم في Dio Client.
// ════════════════════════════════════════════════════════════════════════════

enum Environment { development, staging, production }

class AppUrls {
  AppUrls._();

  /// البيئة الحالية — تُغيَّر يدوياً عند النشر.
  static const Environment current = Environment.development;

  /// Base URL حسب البيئة.
  static String get baseUrl => switch (current) {
        Environment.development => 'http://localhost:8000',
        Environment.staging => 'https://staging.dt-teeth.example.com',
        Environment.production => 'https://api.dt-teeth.example.com',
      };

  /// مهلة الاتصال القصوى (ثواني).
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 20);
}
