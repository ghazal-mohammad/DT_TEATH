// اختبار وحدة: عدّادات لوحة المخبر تُحسب بدقّة من قائمة الطلبات الحقيقية
// (جوهر بند "عدّادات اللوحة الحقيقية").

import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/features/lab/domain/entities/lab_order.dart';
import 'package:dt_teeth/features/lab/presentation/bloc/lab_dashboard_state.dart';

LabOrderFull _order(LabOrderBadgeVariant v, {String date = '2020-01-01'}) =>
    LabOrderFull(
      id: 'x',
      doctor: 'd',
      type: 't',
      material: 'm',
      tooth: '#1',
      date: date,
      statusVariant: v,
    );

void main() {
  test('العدّادات تُشتق من حالات الطلبات', () {
    final orders = [
      _order(LabOrderBadgeVariant.newOrder),
      _order(LabOrderBadgeVariant.newOrder),
      _order(LabOrderBadgeVariant.manufacturing),
      _order(LabOrderBadgeVariant.ready),
    ];
    final state = LabDashboardState(
        status: LabDashboardStatus.loaded, orders: orders);

    expect(state.total, 4);
    expect(state.newOrders, 2);
    expect(state.manufacturing, 1);
    expect(state.ready, 1);
  });

  test('dueToday يَعُدّ الطلبات التي تسليمها اليوم فقط', () {
    final now = DateTime.now();
    final today = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    final state = LabDashboardState(
      status: LabDashboardStatus.loaded,
      orders: [
        _order(LabOrderBadgeVariant.newOrder, date: today),
        _order(LabOrderBadgeVariant.manufacturing, date: today),
        _order(LabOrderBadgeVariant.ready, date: '2099-12-31'),
      ],
    );

    expect(state.dueToday, 2);
  });
}
