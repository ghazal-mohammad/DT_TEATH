// اختبار: WarehouseStockMovementReport — يقابل ReportController::stockMovement
// الفعلي (قُرئ الكونترولر مباشرة 2026-08-15، لا تخمين). كان هالتقرير بيانات
// تجريبية محلية فقط قبل هالمراجعة.

import 'package:dt_teeth/features/warehouse/domain/entities/warehouse_stock_movement_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WarehouseStockMovementReport.fromJson', () {
    test('يقرأ الملخّص + قوائم incoming/outgoing (formatLog)', () {
      final report = WarehouseStockMovementReport.fromJson({
        'success': true,
        'data': {
          'period': {'from': '2026-08-01', 'to': '2026-08-15'},
          'summary': {
            'total_incoming': 500,
            'total_outgoing': 320,
            'total_movements': 47,
          },
          'incoming': [
            {
              'id': 1,
              'material': 'قفازات',
              'quantity': 50,
              'reason': 'purchase',
              'date': '2026-08-10 09:00:00',
            },
          ],
          'outgoing': [
            {
              'id': 2,
              'material': 'بودرة',
              'quantity': 12,
              'reason': 'fulfillment',
              'date': '2026-08-11 10:00:00',
            },
          ],
        },
      });
      expect(report.totalIncoming, 500);
      expect(report.totalOutgoing, 320);
      expect(report.totalMovements, 47);
      expect(report.incoming.single.materialName, 'قفازات');
      expect(report.incoming.single.quantity, 50);
      expect(report.incoming.single.reason, 'purchase');
      expect(report.incoming.single.date, DateTime.parse('2026-08-10 09:00:00'));
      expect(report.outgoing.single.materialName, 'بودرة');
    });

    test('استجابة فارغة ⇒ أصفار وقوائم فارغة', () {
      final report = WarehouseStockMovementReport.fromJson(const {});
      expect(report.totalIncoming, 0);
      expect(report.totalOutgoing, 0);
      expect(report.totalMovements, 0);
      expect(report.incoming, isEmpty);
      expect(report.outgoing, isEmpty);
    });
  });
}
