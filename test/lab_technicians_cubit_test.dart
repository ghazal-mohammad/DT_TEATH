// اختبار: LabTechniciansCubit — "توكيل طلبية" ولوحة الطلبات القابلة للتوكيل
// موصولة بـ LabOrdersRepository الحقيقي، لا قائمة وهمية مزروعة بالذاكرة
// (_seedOrders سابقاً).

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dt_teeth/core/network/failure.dart';
import 'package:dt_teeth/features/lab/data/models/lab_technician.dart';
import 'package:dt_teeth/features/lab/domain/entities/lab_order.dart';
import 'package:dt_teeth/features/lab/domain/repositories/lab_orders_repository.dart';
import 'package:dt_teeth/features/lab/domain/repositories/lab_repository.dart';
import 'package:dt_teeth/features/lab/presentation/bloc/lab_technicians_cubit.dart';

class _MockLabRepo extends Mock implements LabRepository {}

class _MockOrdersRepo extends Mock implements LabOrdersRepository {}

void main() {
  late _MockLabRepo labRepo;
  late _MockOrdersRepo ordersRepo;

  const tech = LabTechnician(
    id: 7,
    name: 'يوسف ناصر',
    email: 'y@clinic.com',
    phone: '0999',
    isActive: true,
  );

  LabOrderFull order(String id, LabOrderBadgeVariant status) => LabOrderFull(
        id: id,
        doctor: 'د. سارة',
        type: 'تلبيسة',
        material: 'PFM',
        tooth: '#14',
        date: '2026-08-12',
        statusVariant: status,
      );

  setUpAll(() {
    registerFallbackValue(LabOrderBadgeVariant.manufacturing);
  });

  setUp(() {
    labRepo = _MockLabRepo();
    ordersRepo = _MockOrdersRepo();
    when(() => labRepo.cachedTechnicians).thenReturn(null);
    when(() => labRepo.getTechnicians()).thenAnswer((_) async => [tech]);
    when(() => labRepo.getTechniciansPerformance())
        .thenAnswer((_) async => const []);
  });

  test('load يعرض فقط الطلبات الجديدة (newOrder) كقابلة للتوكيل', () async {
    when(() => ordersRepo.getAll()).thenAnswer((_) async => [
          order('LAB-1', LabOrderBadgeVariant.newOrder),
          order('LAB-2', LabOrderBadgeVariant.manufacturing),
        ]);
    final cubit =
        LabTechniciansCubit(repository: labRepo, ordersRepository: ordersRepo);

    await cubit.load(roleLabel: 'فني', pendingLabel: 'بانتظار');

    expect(cubit.state.orders.map((o) => o.id), ['LAB-1']);
  });

  test('assign ينجح ⇒ يستدعي processOrder الحقيقي ويعيد تحميل القوائم',
      () async {
    when(() => ordersRepo.getAll()).thenAnswer(
        (_) async => [order('LAB-1', LabOrderBadgeVariant.newOrder)]);
    when(() => ordersRepo.processOrder(
          id: any(named: 'id'),
          status: any(named: 'status'),
          technician: any(named: 'technician'),
        )).thenAnswer((_) async {});
    final cubit =
        LabTechniciansCubit(repository: labRepo, ordersRepository: ordersRepo);
    await cubit.load(roleLabel: 'فني', pendingLabel: 'بانتظار');

    final techItem = cubit.state.technicians.single;
    final ok = await cubit.assign(techItem, 'LAB-1');

    expect(ok, isTrue);
    verify(() => ordersRepo.processOrder(
          id: 'LAB-1',
          status: LabOrderBadgeVariant.manufacturing,
          technician: 'يوسف ناصر',
        )).called(1);
  });

  test('assign يفشل (الباك يرفض) ⇒ false مع رسالة خطأ', () async {
    when(() => ordersRepo.getAll()).thenAnswer(
        (_) async => [order('LAB-1', LabOrderBadgeVariant.newOrder)]);
    when(() => ordersRepo.processOrder(
          id: any(named: 'id'),
          status: any(named: 'status'),
          technician: any(named: 'technician'),
        )).thenThrow(const ServerFailure('الفنّي مشغول حالياً على طلب آخر', code: '422'));
    final cubit =
        LabTechniciansCubit(repository: labRepo, ordersRepository: ordersRepo);
    await cubit.load(roleLabel: 'فني', pendingLabel: 'بانتظار');
    final techItem = cubit.state.technicians.single;

    final ok = await cubit.assign(techItem, 'LAB-1');

    expect(ok, isFalse);
    expect(cubit.state.errorMessage, 'الفنّي مشغول حالياً على طلب آخر');
  });
}
