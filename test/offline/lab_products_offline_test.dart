import 'package:dio/dio.dart';
import 'package:dt_teeth/core/network/network_status.dart';
import 'package:dt_teeth/core/offline/outbox.dart';
import 'package:dt_teeth/core/offline/persistent_cache.dart';
import 'package:dt_teeth/features/lab/data/datasources/lab_products_remote_datasource.dart';
import 'package:dt_teeth/features/lab/data/repositories/remote_lab_products_repository.dart';
import 'package:dt_teeth/features/lab/domain/entities/lab_product.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'in_memory_local_store.dart';

class _MockDs extends Mock implements LabProductsRemoteDataSource {}

void main() {
  late _MockDs ds;
  late InMemoryLocalStore store;
  late Outbox outbox;
  late RemoteLabProductsRepository repo;

  Map<String, dynamic> row(String id, String name) => {
        'id': id,
        'name': name,
        'type': 'تاج',
        'material': 'زيركون',
        'price': '99000.00',
        'duration': '3',
      };

  LabProduct product({String id = '', String name = 'صنف'}) => LabProduct(
        id: id,
        name: name,
        type: 'تاج',
        material: 'زيركون',
        price: 99000,
        productionDays: 3,
      );

  DioException offline() => DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
      );

  setUp(() async {
    ds = _MockDs();
    store = InMemoryLocalStore();
    outbox = Outbox(store);
    await outbox.load();
    repo = RemoteLabProductsRepository(
      ds,
      PersistentCache(store),
      outbox,
      networkStatus: NetworkStatus.instance,
    );
    NetworkStatus.instance.markOnline();
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

  group('الكتابة الأوفلاين عبر الطابور (لا فقدان)', () {
    setUp(() => NetworkStatus.instance.markOffline());
    tearDown(() => NetworkStatus.instance.markOnline());

    test('create أوفلاين ⇒ عنصر تفاؤلي + POST addLabItem في الطابور', () async {
      final created = await repo.create(product(name: 'جديد'));
      expect(created.id, startsWith('local_'));
      expect(outbox.pendingCount, 1);
      expect(outbox.entries.single.path, contains('addLabItem'));
      verifyNever(() => ds.create(any()));
    });

    test('تعديل صنف محلّي غير مُزامَن ⇒ يحدّث POST لا يضيف عملية', () async {
      final created = await repo.create(product(name: 'أول'));
      await repo.update(created.copyWith(name: 'مُعدّل'));
      expect(outbox.pendingCount, 1);
      expect(outbox.entries.single.body!['name'], 'مُعدّل');
    });

    test('حذف صنف محلّي غير مُزامَن ⇒ يلغي عملية الإنشاء', () async {
      final created = await repo.create(product(name: 'مؤقت'));
      await repo.delete(created.id);
      expect(outbox.pendingCount, 0);
    });

    test('تعديل صنف خادمي أوفلاين ⇒ POST updateLabItem في الطابور', () async {
      NetworkStatus.instance.markOnline();
      when(() => ds.getAll()).thenAnswer((_) async => [row('9', 'خادم')]);
      await repo.getAll();
      NetworkStatus.instance.markOffline();

      await repo.update(product(id: '9', name: 'مُعدّل خادم'));
      expect(outbox.entries.any((e) => e.path.contains('updateLabItem/9')),
          isTrue);
    });
  });

  test('create أونلاين بخطأ عابر ⇒ يسقط للطابور (لا يضيع)', () async {
    when(() => ds.create(any())).thenThrow(offline());
    final created = await repo.create(product(name: 'محفوظ'));
    expect(created.id, startsWith('local_'));
    expect(outbox.pendingCount, 1);
  });

  test('تحديث صنف بلا فئة (categoryId=null) ⇒ يرسل category_id فارغاً لا يحذفه '
      'من الجسم (الباك يتجاهل المفتاح الغائب فلا يُصفَّر فعلياً)', () async {
    when(() => ds.update(any(), any()))
        .thenAnswer((_) async => row('9', 'صنف'));
    await repo.update(product(id: '9', name: 'صنف بلا فئة'));

    final captured =
        verify(() => ds.update('9', captureAny())).captured.single
            as Map<String, dynamic>;
    expect(captured.containsKey('category_id'), isTrue);
    expect(captured['category_id'], '');
  });
}
