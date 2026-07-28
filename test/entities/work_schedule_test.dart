// اختبار وحدة: نموذج جدول الدوام المشترك (WorkDay/WorkShift) — تحويل ↔ الباك.

import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/core/domain/work_schedule.dart';

void main() {
  group('WorkDayX.fromApi', () {
    test('يطابق قيم الباك (حساسية حالة الأحرف)', () {
      expect(WorkDayX.fromApi('saturday'), WorkDay.saturday);
      expect(WorkDayX.fromApi('FRIDAY'), WorkDay.friday);
      expect(WorkDayX.fromApi(' monday '), WorkDay.monday);
    });
    test('قيمة غير صالحة ⇒ null', () {
      expect(WorkDayX.fromApi('funday'), isNull);
      expect(WorkDayX.fromApi(null), isNull);
    });
  });

  group('WorkShift.fromRaw', () {
    test('يقبل day أو day_of_week ويقصّ الوقت لـ HH:mm', () {
      final s = WorkShift.fromRaw(const {
        'day': 'sunday',
        'start_time': '08:00:00',
        'end_time': '14:30:00',
      });
      expect(s, isNotNull);
      expect(s!.day, WorkDay.sunday);
      expect(s.start, '08:00');
      expect(s.end, '14:30');
    });

    test('بلا يوم صالح ⇒ null', () {
      expect(WorkShift.fromRaw(const {'start_time': '09:00'}), isNull);
    });
  });

  test('toApi يُنتج مفاتيح الباك المتوقّعة', () {
    const s = WorkShift(day: WorkDay.tuesday, start: '09:00', end: '17:00');
    expect(s.toApi(), {
      'day_of_week': 'tuesday',
      'start_time': '09:00',
      'end_time': '17:00',
    });
  });
}
