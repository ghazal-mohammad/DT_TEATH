// اختبار: WarehouseDashboardReport — يقابل ReportController::dashboard
// (buildReport) الفعلي (قُرئ الكونترولر مباشرة 2026-08-15). endpoint موجود
// وجاهز بالكامل بالباك لكن بلا أي مستهلك بالفرونت قبل هالمراجعة.

import 'package:dt_teeth/features/warehouse/domain/entities/warehouse_dashboard_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WarehouseDashboardReport.fromJson', () {
    test('يقرأ consumption_by_category + companies + most_consumed + summary_bars', () {
      final r = WarehouseDashboardReport.fromJson({
        'success': true,
        'data': {
          'period': {'type': 'month', 'from': '2026-08-01', 'to': '2026-08-31', 'month': '2026-08'},
          'saved': false,
          'consumption_by_category': {
            'total_percentage': 100,
            'items': [
              {'category': 'lab', 'label': 'مخبر', 'quantity': 120, 'percentage': 60.0},
              {'category': 'clinic', 'label': 'عيادات', 'quantity': 80, 'percentage': 40.0},
            ],
          },
          'companies': [
            {'rank': 1, 'company_name': 'الأمل', 'invoice_count': 4, 'total_spending': 1500.0},
          ],
          'most_consumed': [
            {
              'material_id': 1,
              'name': 'قفازات',
              'company_name': 'الأمل',
              'category': 'lab',
              'category_label': 'مخبر',
              'unit': 'قطعة',
              'total_consumed': 80,
            },
          ],
          'summary_bars': [
            {'label': '2026-08-10', 'value': 40},
          ],
        },
      });
      expect(r.periodType, 'month');
      expect(r.saved, isFalse);
      expect(r.consumption.items.length, 2);
      expect(r.consumption.items.first.label, 'مخبر');
      expect(r.consumption.items.first.percentage, 60.0);
      expect(r.companies.single.companyName, 'الأمل');
      expect(r.companies.single.totalSpending, 1500.0);
      expect(r.mostConsumed.single.name, 'قفازات');
      expect(r.mostConsumed.single.totalConsumed, 80);
      expect(r.summaryBars.single.label, '2026-08-10');
      expect(r.summaryBars.single.value, 40);
    });

    test('استجابة فارغة ⇒ قوائم فارغة', () {
      final r = WarehouseDashboardReport.fromJson(const {});
      expect(r.consumption.items, isEmpty);
      expect(r.companies, isEmpty);
      expect(r.mostConsumed, isEmpty);
      expect(r.summaryBars, isEmpty);
    });
  });
}
