// ════════════════════════════════════════════════════════════════════════════
// crash_reporter.dart
//
// طبقة تجريد لرصد الأعطال — مركزيّة، بلا حزمة خارجية ولا DSN/مفتاح (متّسقة مع
// موقفنا الأمني: لا أسرار في التطبيق). تلتقط الأخطاء غير المُلتقَطة وتحجب أيّ
// بيانات حسّاسة قبل الإبلاغ. قابلة للاستبدال بـ Sentry/Crashlytics لاحقاً عبر
// تنفيذ [CrashReporter] آخر وتسجيله في DI — دون لمس أماكن الالتقاط.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';

/// عقد رصد الأعطال — نقطة واحدة لكل خطأ غير مُلتقَط.
abstract class CrashReporter {
  /// يسجّل خطأً مع أثر المكدّس وسياق اختياري (مثل الشاشة/العملية).
  void recordError(Object error, StackTrace? stack, {String? context});
}

/// تنفيذ افتراضي يطبع للـ console بعد **حجب** البيانات الحسّاسة. لا يشحن شيئاً
/// خارجياً — آمن للإنتاج، وجاهز ليُستبدَل بمُبلِّغ حقيقي.
class ConsoleCrashReporter implements CrashReporter {
  const ConsoleCrashReporter();

  @override
  void recordError(Object error, StackTrace? stack, {String? context}) {
    final where = context != null ? ' @$context' : '';
    debugPrint('⛑️ [CrashReporter]$where ${redactSensitive(error.toString())}');
    if (stack != null) {
      // نطبع المكدّس محجوباً أيضاً (قد يحوي قيمًا في رسائل الاستثناءات).
      debugPrint(redactSensitive(stack.toString()));
    }
  }
}

/// يحجب الأنماط الحسّاسة (توكن Bearer، بريد، أزواج مفتاح=قيمة لكلمات السر/الأكواد)
/// من أي نص قبل تسجيله — كي لا تتسرّب اعتمادات أو PII في تقارير الأعطال.
String redactSensitive(String input) {
  var out = input;
  // توكن Bearer.
  out = out.replaceAll(
    RegExp(r'Bearer\s+[A-Za-z0-9._\-|]+', caseSensitive: false),
    'Bearer ***',
  );
  // عناوين البريد.
  out = out.replaceAll(
    RegExp(r'[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}'),
    '***@***',
  );
  // أزواج key=value / key: value لمفاتيح حسّاسة (نحتفظ بالمفتاح والفاصل، نحجب القيمة).
  out = out.replaceAllMapped(
    RegExp(
      r'(password|password_confirmation|current_password|new_password|token|access_token|refresh_token|verification_code|otp|code)'
      r'(\s*[=:]\s*)'
      r'([^\s,;}&]+)',
      caseSensitive: false,
    ),
    (m) => '${m[1]}${m[2]}***',
  );
  return out;
}
