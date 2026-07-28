// اختبار وحدة: تحويل TechnicianPerformance من JSON + حساب معدّل الإنجاز (التقييم).

import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/features/lab/domain/entities/technician_performance.dart';

void main() {
  group('TechnicianPerformance.fromJson', () {
    test('يحوّل الحقول ويقصّ الوقت إلى HH:mm', () {
      final p = TechnicianPerformance.fromJson(const {
        'technician_id': 7,
        'name': 'ياسر',
        'shift_start': '09:00:00',
        'shift_end': '17:30:00',
        'total_assigned': 10,
        'total_completed': 6,
        'total_in_progress': 3,
      });
      expect(p.technicianId, 7);
      expect(p.name, 'ياسر');
      expect(p.shiftStart, '09:00');
      expect(p.shiftEnd, '17:30');
      expect(p.totalAssigned, 10);
      expect(p.totalCompleted, 6);
      expect(p.totalInProgress, 3);
    });

    test('يتحمّل قيمًا نصّية/ناقصة بلا انهيار', () {
      final p = TechnicianPerformance.fromJson(const {
        'technician_id': '5',
        'total_assigned': '4',
      });
      expect(p.technicianId, 5);
      expect(p.name, '');
      expect(p.shiftStart, '');
      expect(p.totalAssigned, 4);
      expect(p.totalCompleted, 0);
    });
  });

  group('completionRate (التقييم)', () {
    test('مكتمل ÷ مُسنَد', () {
      const p = TechnicianPerformance(
        technicianId: 1,
        name: 'x',
        shiftStart: '',
        shiftEnd: '',
        totalAssigned: 8,
        totalCompleted: 6,
        totalInProgress: 2,
      );
      expect(p.completionRate, closeTo(0.75, 1e-9));
    });

    test('صفر مُسنَد ⇒ 0 (لا قسمة على صفر)', () {
      const p = TechnicianPerformance(
        technicianId: 1,
        name: 'x',
        shiftStart: '',
        shiftEnd: '',
        totalAssigned: 0,
        totalCompleted: 0,
        totalInProgress: 0,
      );
      expect(p.completionRate, 0);
    });
  });
}
