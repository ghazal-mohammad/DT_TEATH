
enum Environment { development, staging, production }

class AppUrls {
  AppUrls._();

  /// اسم البيئة وقت البناء (APP_ENV). القيم: development | staging | production.
  static const String _envName =
      String.fromEnvironment('APP_ENV', defaultValue: 'development');

  /// تجاوز اختياري صريح لعنوان الـ API وقت البناء — يتقدّم على اختيار البيئة.
  static const String _baseUrlOverride =
      String.fromEnvironment('API_BASE_URL');

  /// البيئة الحالية — مشتقّة من APP_ENV (الافتراضي development).
  static Environment get current => switch (_envName) {
        'production' => Environment.production,
        'staging' => Environment.staging,
        _ => Environment.development,
      };

  /// Base URL حسب البيئة، أو التجاوز الصريح (API_BASE_URL) إن وُجد.
  static String get baseUrl {
    if (_baseUrlOverride.isNotEmpty) return _baseUrlOverride;
    return switch (current) {
      // 127.0.0.1 لا localhost: على ويندوز localhost يتحلّل أولاً لِـ IPv6
      // (::1) والباك (Laravel dev server) مربوط IPv4 فقط — فيتعلّق/يفشل
      // الاتصال بصمت (تحقّق مباشر: نفس الطلب 0.5s عبر 127.0.0.1 مقابل
      // 1-2.3s عبر localhost، ومحاولة [::1] فشلت بالكامل).
      Environment.development => 'http://127.0.0.1:8000',
      Environment.staging => 'https://staging.dt-teeth.example.com',
      Environment.production => 'https://api.dt-teeth.example.com',
    };
  }

  /// مهلة الاتصال القصوى (ثواني).
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 20);
}
