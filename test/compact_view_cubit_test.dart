// اختبار: CompactViewCubit — تفضيل "العرض المضغوط" يُحفظ فعلياً محلياً
// (بدل بيانات حالة محلية تُصفَّر عند إعادة البناء).

import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/shared/bloc/compact_view_cubit.dart';
import 'package:dt_teeth/shared/storage/key_value_storage.dart';

class _FakeStorage implements KeyValueStorage {
  final Map<String, String> data = {};
  @override
  Future<String?> read(String key) async => data[key];
  @override
  Future<void> write(String key, String value) async => data[key] = value;
}

void main() {
  test('الحالة الافتراضية false (عرض عادي)', () {
    final cubit = CompactViewCubit(storage: _FakeStorage());
    expect(cubit.state, isFalse);
  });

  test('setCompact يبدّل الحالة فوراً ويحفظها', () async {
    final storage = _FakeStorage();
    final cubit = CompactViewCubit(storage: storage);
    await cubit.setCompact(true);
    expect(cubit.state, isTrue);
    expect(storage.data['app_compact_view'], 'true');
    await cubit.setCompact(false);
    expect(cubit.state, isFalse);
    expect(storage.data['app_compact_view'], 'false');
  });

  test('loadSaved يسترجع القيمة المحفوظة من نفس التخزين', () async {
    final storage = _FakeStorage();
    final first = CompactViewCubit(storage: storage);
    await first.setCompact(true);

    final second = CompactViewCubit(storage: storage);
    expect(second.state, isFalse); // قبل التحميل
    await second.loadSaved();
    expect(second.state, isTrue);
  });

  test('loadSaved بلا قيمة محفوظة ⇒ يبقى على الافتراضي بلا انهيار', () async {
    final cubit = CompactViewCubit(storage: _FakeStorage());
    await cubit.loadSaved();
    expect(cubit.state, isFalse);
  });
}
