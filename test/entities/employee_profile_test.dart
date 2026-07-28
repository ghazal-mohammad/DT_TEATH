// اختبار وحدة: تحويل EmployeeProfile من ردّ showProfile (تغليف data + الجدول).

import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/core/domain/work_schedule.dart';
import 'package:dt_teeth/features/profile/domain/entities/employee_profile.dart';

void main() {
  test('يفكّ تغليف {data:{...}} ويقرأ الحقول الأساسية', () {
    final p = EmployeeProfile.fromJson(const {
      'data': {
        'id': 7,
        'name': 'رامي',
        'email': 'r@x.com',
        'phone': '099',
        'gender': 'ذكر',
        'secondary_phone': '011',
        'salary': '500000',
        'hire_date': '2023-02-10',
        'skills': ['تيجان', 'جسور'],
      }
    });
    expect(p.id, 7);
    expect(p.name, 'رامي');
    expect(p.email, 'r@x.com');
    expect(p.gender, 'ذكر');
    expect(p.secondaryPhone, '011');
    expect(p.skills, ['تيجان', 'جسور']);
  });

  test('يقبل الكائن المباشر (بلا data)', () {
    final p = EmployeeProfile.fromJson(const {'id': 1, 'name': 'x'});
    expect(p.id, 1);
    expect(p.name, 'x');
    expect(p.schedule, isEmpty);
  });

  test('يحوّل schedule[] إلى WorkShift مع قصّ الأوقات', () {
    final p = EmployeeProfile.fromJson(const {
      'data': {
        'id': 1,
        'schedule': [
          {'day': 'saturday', 'start_time': '09:00:00', 'end_time': '17:00:00'},
          {'day': 'bad', 'start_time': '00:00', 'end_time': '00:00'},
        ],
      }
    });
    // العنصر غير الصالح (bad) يُسقَط.
    expect(p.schedule.length, 1);
    expect(p.schedule.first.day, WorkDay.saturday);
    expect(p.schedule.first.start, '09:00');
  });
}
