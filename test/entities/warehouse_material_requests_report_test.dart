// اختبار: WarehouseMaterialRequestsReport — يقابل
// ReportController::materialRequests الفعلي (قُرئ الكونترولر مباشرة
// 2026-08-15). ملاحظة موثَّقة: الباك يفلتر status='fulfilled' وهي قيمة غير
// موجودة فعلياً بـ enum (الحقيقية 'completed') ⇒ fulfilled_count/
// fulfillment_rate بيرجعوا 0 دايماً بالبيانات الحقيقية — هاد باغ بالباك، نعرض
// اللي يرجعه بأمانة بلا "تصحيح" من الفرونت.

import 'package:dt_teeth/features/warehouse/domain/entities/warehouse_material_requests_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WarehouseMaterialRequestsReport.fromJson', () {
    test('يقرأ الملخّص + by_requester + قائمة الطلبات', () {
      final report = WarehouseMaterialRequestsReport.fromJson({
        'success': true,
        'data': {
          'summary': {
            'total_requests': 32,
            'fulfilled_count': 0,
            'rejected_count': 3,
            'pending_count': 5,
            'fulfillment_rate': '0%',
          },
          'by_requester': [
            {
              'requester': 'مخبر الأسنان',
              'total_requests': 10,
              'fulfilled': 0,
              'rejected': 1,
              'pending': 1,
            },
          ],
          'requests': [
            {
              'id': 1,
              'requester': 'مخبر الأسنان',
              'status': 'completed',
              'items_count': 3,
              'created_at': '2026-08-10 09:00:00',
            },
          ],
        },
      });
      expect(report.totalRequests, 32);
      expect(report.fulfilledCount, 0);
      expect(report.rejectedCount, 3);
      expect(report.pendingCount, 5);
      expect(report.fulfillmentRate, '0%');
      expect(report.byRequester.single.requester, 'مخبر الأسنان');
      expect(report.byRequester.single.totalRequests, 10);
      expect(report.requests.single.status, 'completed');
      expect(report.requests.single.itemsCount, 3);
    });

    test('استجابة فارغة ⇒ أصفار وقوائم فارغة', () {
      final report = WarehouseMaterialRequestsReport.fromJson(const {});
      expect(report.totalRequests, 0);
      expect(report.fulfillmentRate, '0%');
      expect(report.byRequester, isEmpty);
      expect(report.requests, isEmpty);
    });
  });
}
