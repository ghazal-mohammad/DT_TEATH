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

import '../constants/app_strings.dart';

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

/// أخطاء السيرفر — تُبنى من status code.
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});

  /// بناء Failure مناسب من كود HTTP.
  factory ServerFailure.fromStatusCode(int statusCode) {
    return switch (statusCode) {
      400 => const ServerFailure(AppStrings.errorValidation, code: '400'),
      401 => const ServerFailure(AppStrings.errorUnauthorized, code: '401'),
      403 => const ServerFailure(AppStrings.errorForbidden, code: '403'),
      404 => const ServerFailure(AppStrings.errorNotFound, code: '404'),
      409 => const ServerFailure(
          'يوجد تعارض — تم تعديل البيانات من مستخدم آخر',
          code: '409',
        ),
      422 => const ServerFailure(AppStrings.errorValidation, code: '422'),
      500 => const ServerFailure(AppStrings.errorServer, code: '500'),
      503 => const ServerFailure(AppStrings.errorMaintenance, code: '503'),
      _ => ServerFailure('خطأ غير متوقع ($statusCode)', code: '$statusCode'),
    };
  }
}

/// أخطاء الشبكة — عدم اتصال.
class NetworkFailure extends Failure {
  const NetworkFailure() : super(AppStrings.errorNetwork, code: 'NETWORK');
}

/// أخطاء التخزين المحلي.
class CacheFailure extends Failure {
  const CacheFailure() : super(AppStrings.errorCache, code: 'CACHE');
}

/// أخطاء التحقق من الحقول.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message) : super(code: 'VALIDATION');
}

/// انتهاء مهلة الانتظار.
class TimeoutFailure extends Failure {
  const TimeoutFailure() : super(AppStrings.errorTimeout, code: 'TIMEOUT');
}

/// خطأ غير متوقع — للحالات الاستثنائية.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([String? customMessage])
      : super(customMessage ?? AppStrings.error, code: 'UNEXPECTED');
}
