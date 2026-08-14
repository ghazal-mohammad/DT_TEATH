// اختبار: LabSettingsPrefsCubit — تفضيلات إعدادات المخبر (الحفظ التلقائي +
// 7 مفاتيح الإشعارات) تُحفظ فعلياً محلياً، لا تُصفَّر عند إعادة البناء.

import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/features/lab/presentation/bloc/lab_settings_prefs_cubit.dart';
import 'package:dt_teeth/shared/storage/key_value_storage.dart';

class _FakeStorage implements KeyValueStorage {
  final Map<String, String> data = {};
  @override
  Future<String?> read(String key) async => data[key];
  @override
  Future<void> write(String key, String value) async => data[key] = value;
}

void main() {
  test('القيم الافتراضية تطابق تصميم الشاشة الأصلي', () {
    final cubit = LabSettingsPrefsCubit(storage: _FakeStorage());
    expect(cubit.state.autosave, isTrue);
    expect(cubit.state.urgent, isTrue);
    expect(cubit.state.newOrders, isTrue);
    expect(cubit.state.lowStock, isTrue);
    expect(cubit.state.warehouse, isTrue);
    expect(cubit.state.team, isFalse);
    expect(cubit.state.emailSummary, isTrue);
    expect(cubit.state.sounds, isFalse);
  });

  test('setAutosave يبدّل ويحفظ', () async {
    final storage = _FakeStorage();
    final cubit = LabSettingsPrefsCubit(storage: storage);
    await cubit.setAutosave(false);
    expect(cubit.state.autosave, isFalse);
    expect(storage.data['lab_settings_autosave'], 'false');
  });

  test('setNotif يبدّل مفتاحاً واحداً بلا تأثير على الباقي', () async {
    final cubit = LabSettingsPrefsCubit(storage: _FakeStorage());
    await cubit.setNotif(LabNotifPref.team, true);
    expect(cubit.state.team, isTrue);
    expect(cubit.state.urgent, isTrue); // ما تغيّر
  });

  test('loadSaved يسترجع كل القيم المحفوظة من نفس التخزين', () async {
    final storage = _FakeStorage();
    final first = LabSettingsPrefsCubit(storage: storage);
    await first.setAutosave(false);
    await first.setNotif(LabNotifPref.sounds, true);
    await first.setNotif(LabNotifPref.urgent, false);

    final second = LabSettingsPrefsCubit(storage: storage);
    await second.loadSaved();
    expect(second.state.autosave, isFalse);
    expect(second.state.sounds, isTrue);
    expect(second.state.urgent, isFalse);
    expect(second.state.team, isFalse); // لم يُغيَّر، يبقى الافتراضي
  });
}
