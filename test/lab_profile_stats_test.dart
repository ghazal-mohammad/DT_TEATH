// اختبار: عدّادات الملف الشخصي للمخبري (LabProfilePage.loadStats) محسوبة من
// الطلبات الحقيقية، لا أرقام ثابتة (كانت 142/5/7 دائماً).

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dt_teeth/core/di/injection_container.dart';
import 'package:dt_teeth/features/lab/domain/entities/lab_order.dart';
import 'package:dt_teeth/features/lab/domain/repositories/lab_orders_repository.dart';
import 'package:dt_teeth/features/lab/presentation/pages/lab_profile_page.dart';

class _MockOrdersRepo extends Mock implements LabOrdersRepository {}

void main() {
  late _MockOrdersRepo repo;

  LabOrderFull order(LabOrderBadgeVariant status, String date) => LabOrderFull(
        id: '1',
        doctor: 'د. سارة',
        type: 'تلبيسة',
        material: 'PFM',
        tooth: '#14',
        date: date,
        statusVariant: status,
      );

  setUp(() {
    repo = _MockOrdersRepo();
    if (sl.isRegistered<LabOrdersRepository>()) {
      sl.unregister<LabOrdersRepository>();
    }
    sl.registerFactory<LabOrdersRepository>(() => repo);
  });

  tearDown(() {
    if (sl.isRegistered<LabOrdersRepository>()) {
      sl.unregister<LabOrdersRepository>();
    }
  });

  test('يحسب العدّادات من الطلبات الحقيقية لا أرقام ثابتة', () async {
    final now = DateTime.now();
    final thisMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}-05';
    when(() => repo.getAll()).thenAnswer((_) async => [
          order(LabOrderBadgeVariant.ready, thisMonth),
          order(LabOrderBadgeVariant.ready, '2020-01-01'), // شهر مختلف
          order(LabOrderBadgeVariant.manufacturing, thisMonth),
          order(LabOrderBadgeVariant.manufacturing, thisMonth),
          order(LabOrderBadgeVariant.newOrder, thisMonth),
        ]);

    final stats = await LabProfilePage.loadStats();

    expect(stats.completedThisMonth, 1); // ready بس هالشهر
    expect(stats.inProgress, 2);
    expect(stats.readyTotal, 2); // ready بكل الأوقات
  });
}
