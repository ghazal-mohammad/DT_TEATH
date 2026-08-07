import 'package:dt_teeth/core/offline/outbox.dart';
import 'package:dt_teeth/core/offline/outbox_entry.dart';
import 'package:dt_teeth/core/offline/persistent_cache.dart';
import 'package:flutter_test/flutter_test.dart';

import 'in_memory_local_store.dart';

void main() {
  OutboxEntry entry(String id, {DateTime? at, int attempts = 0}) => OutboxEntry(
        id: id,
        resource: 'warehouse_materials',
        method: OutboxMethod.post,
        path: '/api/warehouseManager/addMaterial',
        body: {'name': 'مادة $id'},
        localEntityId: 'local_$id',
        createdAt: at ?? DateTime(2026, 1, 1),
        attempts: attempts,
      );

  group('OutboxEntry serialization', () {
    test('round-trips through JSON بلا فقدان حقول', () {
      final e = entry('1', at: DateTime(2026, 3, 4, 5, 6, 7), attempts: 2);
      final back = OutboxEntry.fromJson(e.toJson());
      expect(back.id, '1');
      expect(back.resource, 'warehouse_materials');
      expect(back.method, OutboxMethod.post);
      expect(back.path, e.path);
      expect(back.body, {'name': 'مادة 1'});
      expect(back.localEntityId, 'local_1');
      expect(back.createdAt, DateTime(2026, 3, 4, 5, 6, 7));
      expect(back.attempts, 2);
    });

    test('DELETE بلا body يبقى null', () {
      final e = OutboxEntry(
        id: 'd',
        resource: 'r',
        method: OutboxMethod.delete,
        path: '/x/1',
        createdAt: DateTime(2026, 1, 1),
      );
      final back = OutboxEntry.fromJson(e.toJson());
      expect(back.method, OutboxMethod.delete);
      expect(back.body, isNull);
    });

    test('method wire mapping', () {
      expect(OutboxMethod.post.wire, 'POST');
      expect(OutboxMethod.put.wire, 'PUT');
      expect(OutboxMethod.delete.wire, 'DELETE');
      expect(OutboxMethodX.fromWire('put'), OutboxMethod.put);
      expect(OutboxMethodX.fromWire('غير معروف'), OutboxMethod.post);
    });
  });

  group('Outbox persistence', () {
    late InMemoryLocalStore store;
    late Outbox outbox;

    setUp(() {
      store = InMemoryLocalStore();
      outbox = Outbox(store);
    });

    test('add/remove يعكسان pendingCount ويُبقيان القرص متزامناً', () async {
      await outbox.add(entry('1'));
      await outbox.add(entry('2'));
      expect(outbox.pendingCount, 2);

      // نسخة جديدة من نفس القرص ⇒ تسترجع نفس العمليات (نجت restart).
      final reloaded = Outbox(store);
      await reloaded.load();
      expect(reloaded.pendingCount, 2);

      await outbox.remove('1');
      expect(outbox.pendingCount, 1);
      expect(outbox.entries.single.id, '2');
    });

    test('load يحافظ على ترتيب FIFO حسب createdAt', () async {
      await outbox.add(entry('late', at: DateTime(2026, 5, 1)));
      await outbox.add(entry('early', at: DateTime(2026, 1, 1)));
      final reloaded = Outbox(store);
      await reloaded.load();
      expect(reloaded.entries.map((e) => e.id).toList(), ['early', 'late']);
    });

    test('load على قرص تالف ⇒ طابور فارغ لا انهيار', () async {
      store.data['outbox.v1.queue'] = '{ليس JSON صالح';
      final ob = Outbox(store);
      await ob.load();
      expect(ob.pendingCount, 0);
    });

    test('clear يُفرِغ الذاكرة والقرص', () async {
      await outbox.add(entry('1'));
      await outbox.clear();
      expect(outbox.pendingCount, 0);
      final reloaded = Outbox(store);
      await reloaded.load();
      expect(reloaded.pendingCount, 0);
    });

    test('notifyListeners يُطلَق عند التغيير', () async {
      var notifications = 0;
      outbox.addListener(() => notifications++);
      await outbox.add(entry('1'));
      await outbox.remove('1');
      expect(notifications, greaterThanOrEqualTo(2));
    });
  });

  group('PersistentCache', () {
    late InMemoryLocalStore store;
    late PersistentCache cache;

    setUp(() {
      store = InMemoryLocalStore();
      cache = PersistentCache(store);
    });

    test('save ثم load يُرجعان نفس الصفوف', () async {
      final rows = [
        {'id': '1', 'name': 'A'},
        {'id': '2', 'name': 'B'},
      ];
      await cache.save('warehouse_materials', rows);
      final back = await cache.load('warehouse_materials');
      expect(back, rows);
    });

    test('load لمورد غير موجود ⇒ null', () async {
      expect(await cache.load('nope'), isNull);
    });

    test('load على بيانات تالفة ⇒ null بلا انهيار', () async {
      store.data['cache.v1.x'] = 'تالف{';
      expect(await cache.load('x'), isNull);
    });

    test('save لا يرمي حتى لو فشل القرص', () async {
      // نحاكي فشل القرص بجعل write يرمي.
      final failing = _FailingWriteStore();
      final c = PersistentCache(failing);
      await expectLater(c.save('r', [{'a': 1}]), completes);
    });

    test('clear يمسح كاش المورد', () async {
      await cache.save('r', [{'a': 1}]);
      await cache.clear('r');
      expect(await cache.load('r'), isNull);
    });
  });
}

class _FailingWriteStore extends InMemoryLocalStore {
  @override
  Future<void> write(String key, String value) async {
    throw StateError('disk full');
  }
}
