// ════════════════════════════════════════════════════════════════════════════
// failure.dart
//
// Failure classes لمعالجة الأخطاء بشكل موحّد.
// القرار 7: dartz + Either<Failure, Entity>
// القرار 16: رسائل عربية واضحة لكل نوع خطأ.
//
// القاعدة الذهبية: المستخدم لا يرى أبداً شاشة بيضاء أو رسالة إنكليزية تقنية.
// ════════════════════════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';

// رسائل الأخطاء عربية inline (القرار 16) — طبقة الشبكة تُنشأ بلا BuildContext،
// لذا تملك نصوصها الافتراضية مباشرة. واجهات العرض تستخدم رسالة الـ Failure،
// أو تعود لـ context.l10n.error كاحتياط حين تتوفّر.

/// الصنف الأساسي لكل أنواع الفشل في التطبيق.
abstract class Failure extends Equatable {
  const Failure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'Failure($code): $message';
}

/// يستخرج رسالة عربية **نظيفة** من أي خطأ لعرضها للمستخدم — بلا بادئة تقنية.
///
/// [Failure] تحمل رسالتها الجاهزة (message)، فنعيدها كما هي. أي خطأ آخر (استثناء
/// غير متوقّع) يعود لرسالة عامّة آمنة بدل تسريب `toString()` التقني للمستخدم.
/// تُستخدم في الـ Cubits بدل `e.toString()` (الذي كان يطبع "Failure(422): ...").
String userMessageFromError(Object error) =>
    error is Failure ? error.message : 'حدث خطأ غير متوقع — حاول مجدداً';

/// أخطاء السيرفر — تُبنى من status code.
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});

  /// بناء Failure مناسب من كود HTTP.
  factory ServerFailure.fromStatusCode(int statusCode) {
    return switch (statusCode) {
      400 => const ServerFailure('تحقق من الحقول المطلوبة', code: '400'),
      401 => const ServerFailure(
          'انتهت صلاحية الجلسة — سجّل دخولك مجدداً', code: '401'),
      403 => const ServerFailure(
          'ليس لديك صلاحية للوصول لهذه الصفحة', code: '403'),
      404 => const ServerFailure('العنصر المطلوب غير موجود', code: '404'),
      409 => const ServerFailure(
          'يوجد تعارض — تم تعديل البيانات من مستخدم آخر',
          code: '409',
        ),
      422 => const ServerFailure('تحقق من الحقول المطلوبة', code: '422'),
      500 => const ServerFailure(
          'خطأ في السيرفر — حاول مرة أخرى بعد قليل', code: '500'),
      503 => const ServerFailure('السيرفر في صيانة — عد لاحقاً', code: '503'),
      _ => ServerFailure('خطأ غير متوقع ($statusCode)', code: '$statusCode'),
    };
  }
}

/// أخطاء الشبكة — عدم اتصال.
class NetworkFailure extends Failure {
  const NetworkFailure()
      : super('لا يوجد اتصال بالإنترنت — تحقق من الشبكة', code: 'NETWORK');
}

/// أخطاء التخزين المحلي.
class CacheFailure extends Failure {
  const CacheFailure()
      : super('خطأ في البيانات المحلية — حاول مجدداً', code: 'CACHE');
}

/// أخطاء التحقق من الحقول.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message) : super(code: 'VALIDATION');
}

/// انتهاء مهلة الانتظار.
class TimeoutFailure extends Failure {
  const TimeoutFailure()
      : super('انتهت مهلة الانتظار — السيرفر لا يستجيب', code: 'TIMEOUT');
}

/// خطأ غير متوقع — للحالات الاستثنائية.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([String? customMessage])
      : super(customMessage ?? 'حدث خطأ', code: 'UNEXPECTED');
}
