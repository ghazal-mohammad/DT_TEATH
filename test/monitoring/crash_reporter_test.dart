import 'package:dt_teeth/core/monitoring/crash_reporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('redactSensitive', () {
    test('يحجب توكن Bearer', () {
      final out = redactSensitive('Authorization: Bearer abc.def-ghi|jkl');
      expect(out, contains('Bearer ***'));
      expect(out, isNot(contains('abc.def')));
    });

    test('يحجب البريد الإلكتروني', () {
      final out = redactSensitive('failed for laila.lab@example.com now');
      expect(out, contains('***@***'));
      expect(out, isNot(contains('laila.lab@example.com')));
    });

    test('يحجب قيمة كلمة السر/الكود مع إبقاء المفتاح', () {
      expect(redactSensitive('password=Secret123!'), 'password=***');
      expect(redactSensitive('verification_code: 4821'),
          'verification_code: ***');
      expect(redactSensitive('token = xyz.123'), 'token = ***');
    });

    test('لا يمسّ النصّ العادي', () {
      const msg = 'RangeError: index 5 out of range for length 3';
      expect(redactSensitive(msg), msg);
    });

    test('يحجب عدّة أنماط في نفس النص', () {
      final out = redactSensitive(
          'user a@b.com sent Bearer tok_123 with password=hunter2');
      expect(out, isNot(contains('a@b.com')));
      expect(out, isNot(contains('tok_123')));
      expect(out, isNot(contains('hunter2')));
    });
  });

  group('ConsoleCrashReporter', () {
    test('recordError لا يرمي (مع/بدون مكدّس وسياق)', () {
      const reporter = ConsoleCrashReporter();
      expect(
        () => reporter.recordError(
            StateError('password=abc'), StackTrace.current,
            context: 'test'),
        returnsNormally,
      );
      expect(() => reporter.recordError(Exception('x'), null),
          returnsNormally);
    });
  });
}
