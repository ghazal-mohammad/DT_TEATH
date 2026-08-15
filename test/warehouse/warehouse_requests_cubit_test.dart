import 'package:dt_teeth/core/network/failure.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/warehouse_request.dart';
import 'package:dt_teeth/features/warehouse/domain/repositories/warehouse_requests_repository.dart';
import 'package:dt_teeth/features/warehouse/presentation/bloc/warehouse_requests_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements WarehouseRequestsRepository {}

void main() {
  late _MockRepo repo;

  WarehouseRequest req(String id, WarehouseRequestStatus s) => WarehouseRequest(
        id: id,
        status: s,
        requesterName: 'ليلى',
        requesterType: 'lab',
        items: const [],
        newItems: const [],
      );

  setUp(() => repo = _MockRepo());

  test('load ينجح ⇒ loaded مع القائمة', () async {
    when(() => repo.getAll()).thenAnswer((_) async => [
          req('1', WarehouseRequestStatus.newReq),
          req('2', WarehouseRequestStatus.completed),
        ]);
    final cubit = WarehouseRequestsCubit(repo);
    await cubit.load();
    expect(cubit.state.status, RequestsStatus.loaded);
    expect(cubit.state.requests.length, 2);
  });

  test('الفلتر يعزل حسب الحالة + العدّاد صحيح', () async {
    when(() => repo.getAll()).thenAnswer((_) async => [
          req('1', WarehouseRequestStatus.newReq),
          req('2', WarehouseRequestStatus.newReq),
          req('3', WarehouseRequestStatus.rejected),
        ]);
    final cubit = WarehouseRequestsCubit(repo);
    await cubit.load();
    cubit.setFilter(RequestsFilter.newReq);
    expect(cubit.state.filtered.length, 2);
    expect(cubit.state.countOf(RequestsFilter.rejected), 1);
    expect(cubit.state.countOf(RequestsFilter.all), 3);
  });

  test('fulfill ينجح ⇒ يعيد التحميل', () async {
    when(() => repo.fulfill(any(), notes: any(named: 'notes')))
        .thenAnswer((_) async {});
    when(() => repo.getAll())
        .thenAnswer((_) async => [req('1', WarehouseRequestStatus.completed)]);
    final cubit = WarehouseRequestsCubit(repo);
    final ok = await cubit.fulfill('1');
    expect(ok, isTrue);
    expect(cubit.state.busyId, isNull);
    verify(() => repo.getAll()).called(1);
  });

  test('reject يفشل ⇒ actionError دون إعادة تحميل', () async {
    when(() => repo.reject(any(), reason: any(named: 'reason')))
        .thenThrow(const ServerFailure('لا يمكن رفض طلب معالَج', code: '422'));
    final cubit = WarehouseRequestsCubit(repo);
    final ok = await cubit.reject('1', reason: 'سبب');
    expect(ok, isFalse);
    expect(cubit.state.actionError, 'لا يمكن رفض طلب معالَج');
    verifyNever(() => repo.getAll());
  });

  test('markPending ينجح ⇒ يعيد التحميل (فعل جديد من الباك 2026-08-14)', () async {
    when(() => repo.markPending(any())).thenAnswer((_) async {});
    when(() => repo.getAll())
        .thenAnswer((_) async => [req('1', WarehouseRequestStatus.inProgress)]);
    final cubit = WarehouseRequestsCubit(repo);
    final ok = await cubit.markPending('1');
    expect(ok, isTrue);
    expect(cubit.state.busyId, isNull);
    verify(() => repo.getAll()).called(1);
  });

  test('markPending يفشل (الطلب مش "جديد") ⇒ actionError دون إعادة تحميل', () async {
    when(() => repo.markPending(any())).thenThrow(
        const ServerFailure('يمكن تحويل الطلب إلى قيد المعالجة فقط إذا كان حالته جديد', code: '422'));
    final cubit = WarehouseRequestsCubit(repo);
    final ok = await cubit.markPending('1');
    expect(ok, isFalse);
    expect(cubit.state.actionError,
        'يمكن تحويل الطلب إلى قيد المعالجة فقط إذا كان حالته جديد');
    verifyNever(() => repo.getAll());
  });
}
