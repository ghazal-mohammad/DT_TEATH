import 'package:dio/dio.dart';
import 'package:dt_teeth/core/offline/persistent_cache.dart';
import 'package:dt_teeth/features/lab/data/datasources/lab_products_remote_datasource.dart';
import 'package:dt_teeth/features/lab/data/repositories/remote_lab_products_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'in_memory_local_store.dart';

class _MockDs extends Mock implements LabProductsRemoteDataSource {}

void main() {
  late _MockDs ds;
  late InMemoryLocalStore store;
  late RemoteLabProductsRepository repo;

  Map<String, dynamic> row(String id, String name) => {
        'id': id,
        'name': name,
        'type': 'تاج',
        'material': 'زيركون',
        'price': '99000.00',
        'duration': '3',
      };

  DioException offline() => DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
      );

  setUp(() {
    ds = _MockDs();
    store = InMemoryLocalStore();
    repo = RemoteLabProductsRepository(ds, PersistentCache(store));
  });

  test('getAll ينجح ⇒ يحفظ نسخة دائمة يمكن استرجاعها أوفلاين', () async {
    when(() => ds.getAll()).thenAnswer((_) async => [row('1', 'تاج')]);
    final first = await repo.getAll();
    expect(first.single.name, 'تاج');

    // انقطاع لاحق ⇒ يعرض المخزّن بدل رمي فشل.
    when(() => ds.getAll()).thenThrow(offline());
    final offlineList = await repo.getAll();
    expect(offlineList.single.name, 'تاج');
  });

  test('getAll أوفلاين بلا كاش ⇒ يرمي فشلاً', () async {
    when(() => ds.getAll()).thenThrow(offline());
    expect(repo.getAll(), throwsA(anything));
  });

  test('كاش المنتجات معزول بمفتاح المورد', () {
    expect(repo.cacheResource, 'lab_products');
  });
}
