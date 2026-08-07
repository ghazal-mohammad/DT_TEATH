import 'package:dio/dio.dart';
import 'package:dt_teeth/core/network/network_status.dart';
import 'package:dt_teeth/core/offline/outbox.dart';
import 'package:dt_teeth/core/offline/outbox_entry.dart';
import 'package:dt_teeth/core/offline/outbox_processor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'in_memory_local_store.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late InMemoryLocalStore store;
  late Outbox outbox;
  late OutboxProcessor processor;

  OutboxEntry entry(String id) => OutboxEntry(
        id: id,
        resource: 'warehouse_materials',
        method: OutboxMethod.post,
        path: '/api/warehouseManager/addMaterial',
        body: {'name': id},
        createdAt: DateTime(2026, 1, int.parse(id.replaceAll(RegExp('[^0-9]'), ''))),
      );

  Response<dynamic> okResponse() => Response<dynamic>(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 200,
      );

  DioException transientError() => DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
      );

  DioException serverError(int code) => DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: code,
        ),
      );

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(Options());
  });

  setUp(() async {
    dio = _MockDio();
    store = InMemoryLocalStore();
    outbox = Outbox(store);
    await outbox.load();
    processor = OutboxProcessor(
      outbox: outbox,
      dio: dio,
      networkStatus: NetworkStatus.instance,
    );
    NetworkStatus.instance.markOnline();
  });

  test('نجاح الإرسال يزيل العملية من الطابور ويُشعِر المورد', () async {
    when(() => dio.request<dynamic>(any(),
        data: any(named: 'data'),
        options: any(named: 'options'))).thenAnswer((_) async => okResponse());

    await outbox.add(entry('1'));
    final synced = <String>[];
    processor.onResourceSynced = synced.add;

    await processor.process();

    expect(outbox.pendingCount, 0);
    expect(synced, ['warehouse_materials']);
  });

  test('خطأ شبكة عابر يُبقي العملية ويوقف التصريف', () async {
    when(() => dio.request<dynamic>(any(),
            data: any(named: 'data'), options: any(named: 'options')))
        .thenThrow(transientError());

    await outbox.add(entry('1'));
    await processor.process();

    // بقيت للمحاولة لاحقاً، وبلا زيادة محاولات (فشل عابر لا يُحسب poison).
    expect(outbox.pendingCount, 1);
    expect(outbox.entries.single.attempts, 0);
  });

  test('خطأ خادم دائم يزيد المحاولات ثم يُسقِط بعد الحدّ', () async {
    when(() => dio.request<dynamic>(any(),
            data: any(named: 'data'), options: any(named: 'options')))
        .thenThrow(serverError(422));

    await outbox.add(entry('1'));

    // 5 تمريرات ⇒ المحاولات 1..4 تبقى، الخامسة تُسقِط (poison-pill).
    for (var i = 0; i < 5; i++) {
      await processor.process();
    }
    expect(outbox.pendingCount, 0);
  });

  test('لا يُصرّف عندما يكون غير متصل', () async {
    NetworkStatus.instance.markOffline();
    await outbox.add(entry('1'));
    await processor.process();
    expect(outbox.pendingCount, 1);
    verifyNever(() => dio.request<dynamic>(any(),
        data: any(named: 'data'), options: any(named: 'options')));
    NetworkStatus.instance.markOnline();
  });

  test('FIFO: يُرسِل بترتيب الإنشاء', () async {
    final calls = <String>[];
    when(() => dio.request<dynamic>(any(),
        data: any(named: 'data'),
        options: any(named: 'options'))).thenAnswer((inv) async {
      final data = inv.namedArguments[const Symbol('data')] as Map?;
      calls.add(data?['name']?.toString() ?? '');
      return okResponse();
    });

    await outbox.add(entry('2'));
    await outbox.add(entry('1'));
    await processor.process();

    expect(calls, ['1', '2']); // createdAt يوم 1 قبل يوم 2.
    expect(outbox.pendingCount, 0);
  });
}
