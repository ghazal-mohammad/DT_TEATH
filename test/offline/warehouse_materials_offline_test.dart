import 'package:dio/dio.dart';
import 'package:dt_teeth/core/network/network_status.dart';
import 'package:dt_teeth/core/offline/outbox.dart';
import 'package:dt_teeth/core/offline/outbox_entry.dart';
import 'package:dt_teeth/core/offline/persistent_cache.dart';
import 'package:dt_teeth/features/warehouse/data/datasources/warehouse_materials_remote_datasource.dart';
import 'package:dt_teeth/features/warehouse/data/repositories/remote_warehouse_materials_repository.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/material_category.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/warehouse_material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'in_memory_local_store.dart';

class _MockRemote extends Mock implements WarehouseMaterialsRemoteDataSource {}

void main() {
  late _MockRemote remote;
  late InMemoryLocalStore store;
  late PersistentCache cache;
  late Outbox outbox;
  late RemoteWarehouseMaterialsRepository repo;

  Map<String, dynamic> row(String id, String name) => {
        'id': id,
        'name': name,
        'company_name': 'شركة',
        'price_per_unit': 100,
        'unit': 'قطعة',
        'category': 'clinic',
        'total_stock': 5,
        'batches_count': 1,
      };

  WarehouseMaterial material({String id = '', String name = 'مادة'}) =>
      WarehouseMaterial(
        id: id,
        name: name,
        companyName: 'شركة',
        category: MaterialCategory.clinic,
        quantity: 5,
        unit: 'قطعة',
        pricePerUnit: 100,
      );

  DioException offline() => DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
      );

  setUp(() async {
    remote = _MockRemote();
    store = InMemoryLocalStore();
    cache = PersistentCache(store);
    outbox = Outbox(store);
    await outbox.load();
    repo = RemoteWarehouseMaterialsRepository(
      remote,
      cache,
      outbox,
      networkStatus: NetworkStatus.instance,
    );
    NetworkStatus.instance.markOnline();
  });

  group('القراءة', () {
    test('getAll ينجح ⇒ يحفظ نسخة دائمة', () async {
      when(() => remote.getAll())
          .thenAnswer((_) async => [row('1', 'A'), row('2', 'B')]);
      final list = await repo.getAll();
      expect(list.map((m) => m.name), ['A', 'B']);
      expect(await cache.load('warehouse_materials'), isNotNull);
    });

    test('getAll أوفلاين ⇒ يُرجع آخر نسخة دائمة بدل خطأ', () async {
      // أول جلب ناجح يملأ الكاش.
      when(() => remote.getAll()).thenAnswer((_) async => [row('1', 'A')]);
      await repo.getAll();

      // ثم انقطاع الشبكة.
      when(() => remote.getAll()).thenThrow(offline());
      final list = await repo.getAll();
      expect(list.single.name, 'A'); // لم يفشل، أعاد المخزّن.
    });

    test('getAll أوفلاين بلا كاش ⇒ يرمي فشلاً', () async {
      when(() => remote.getAll()).thenThrow(offline());
      expect(repo.getAll(), throwsA(anything));
    });
  });

  group('الكتابة الأوفلاين تُدرَج في الطابور بلا فقدان', () {
    setUp(() => NetworkStatus.instance.markOffline());
    tearDown(() => NetworkStatus.instance.markOnline());

    test('create أوفلاين ⇒ عنصر تفاؤلي + عملية POST في الطابور', () async {
      final created = await repo.create(material(name: 'جديد'));
      expect(created.id, startsWith('local_'));
      expect(outbox.pendingCount, 1);
      expect(outbox.entries.single.method.wire, 'POST');
      verifyNever(() => remote.create(any()));
    });

    test('تعديل عنصر محلّي غير مُزامَن ⇒ يحدّث جسم POST لا يضيف PUT', () async {
      final created = await repo.create(material(name: 'أول'));
      await repo.update(created.copyWith(name: 'مُعدّل'));
      expect(outbox.pendingCount, 1); // لا تزال عملية واحدة (POST).
      expect(outbox.entries.single.body!['name'], 'مُعدّل');
    });

    test('حذف عنصر محلّي غير مُزامَن ⇒ يلغي عملية الإنشاء المعلّقة', () async {
      final created = await repo.create(material(name: 'مؤقت'));
      await repo.delete(created.id);
      expect(outbox.pendingCount, 0);
    });

    test('تعديل عنصر موجود بالباك أوفلاين ⇒ عملية PUT', () async {
      // نزرع عنصراً "خادمياً" في الذاكرة عبر جلب ناجح مسبق.
      NetworkStatus.instance.markOnline();
      when(() => remote.getAll()).thenAnswer((_) async => [row('9', 'خادم')]);
      await repo.getAll();
      NetworkStatus.instance.markOffline();

      await repo.update(material(id: '9', name: 'مُعدّل خادم'));
      expect(outbox.entries.any((e) => e.method.wire == 'PUT'), isTrue);
    });

    test('الطابور ينجو من إعادة التشغيل (نفس القرص)', () async {
      await repo.create(material(name: 'باقٍ'));
      final reloaded = Outbox(store);
      await reloaded.load();
      expect(reloaded.pendingCount, 1);
    });
  });

  test('create أونلاين ينجح ⇒ لا شيء في الطابور', () async {
    when(() => remote.create(any())).thenAnswer((_) async => row('7', 'صار'));
    final created = await repo.create(material(name: 'صار'));
    expect(created.id, '7');
    expect(outbox.pendingCount, 0);
  });

  test('create أونلاين بخطأ عابر ⇒ يسقط للطابور (لا يضيع)', () async {
    when(() => remote.create(any())).thenThrow(offline());
    final created = await repo.create(material(name: 'محفوظ'));
    expect(created.id, startsWith('local_'));
    expect(outbox.pendingCount, 1);
  });

  test('حذف أونلاين ⇒ إلغاء تفعيل (updateStatus) لا حذف صلب', () async {
    when(() => remote.getAll()).thenAnswer((_) async => [row('5', 'قابل')]);
    await repo.getAll();
    when(() => remote.updateStatus('5', false)).thenAnswer((_) async {});

    await repo.delete('5');
    verify(() => remote.updateStatus('5', false)).called(1);
    expect(outbox.pendingCount, 0);
  });

  test('حذف أوفلاين لعنصر خادمي ⇒ عملية updateStatus(is_active=false) في الطابور',
      () async {
    when(() => remote.getAll()).thenAnswer((_) async => [row('5', 'قابل')]);
    await repo.getAll();
    NetworkStatus.instance.markOffline();

    await repo.delete('5');
    final entry = outbox.entries.single;
    expect(entry.method.wire, 'POST');
    expect(entry.path, contains('updateStatus/5'));
    expect(entry.body!['is_active'], false);
    NetworkStatus.instance.markOnline();
  });
}
