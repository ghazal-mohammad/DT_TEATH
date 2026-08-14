// ════════════════════════════════════════════════════════════════════════════
// lab_settings_prefs_cubit.dart
//
// Cubit لتفضيلات شاشة إعدادات المخبر المحلية بالكامل (لا مقابل لها بالباك
// حالياً): الحفظ التلقائي + مفاتيح تفضيلات الإشعارات السبعة. تُحفظ فعلياً
// محلياً عبر KeyValueStorage (نفس نمط ThemeCubit/CompactViewCubit) بدل ما
// تُصفَّر عند كل زيارة للشاشة — بس بلا أي ادّعاء إنها بتتحكم بتسليم إشعار
// حقيقي أو حفظ تلقائي فعلي؛ هاد يحتاج endpoints غير موجودة بالباك بعد.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/storage/key_value_storage.dart';

/// مفاتيح تفضيلات الإشعارات السبعة بتبويب الإشعارات.
enum LabNotifPref { urgent, newOrders, lowStock, warehouse, team, emailSummary, sounds }

class LabSettingsPrefsState {
  const LabSettingsPrefsState({
    this.autosave = true,
    this.urgent = true,
    this.newOrders = true,
    this.lowStock = true,
    this.warehouse = true,
    this.team = false,
    this.emailSummary = true,
    this.sounds = false,
  });

  final bool autosave;
  final bool urgent;
  final bool newOrders;
  final bool lowStock;
  final bool warehouse;
  final bool team;
  final bool emailSummary;
  final bool sounds;

  bool notif(LabNotifPref pref) => switch (pref) {
        LabNotifPref.urgent => urgent,
        LabNotifPref.newOrders => newOrders,
        LabNotifPref.lowStock => lowStock,
        LabNotifPref.warehouse => warehouse,
        LabNotifPref.team => team,
        LabNotifPref.emailSummary => emailSummary,
        LabNotifPref.sounds => sounds,
      };

  LabSettingsPrefsState copyWith({
    bool? autosave,
    bool? urgent,
    bool? newOrders,
    bool? lowStock,
    bool? warehouse,
    bool? team,
    bool? emailSummary,
    bool? sounds,
  }) {
    return LabSettingsPrefsState(
      autosave: autosave ?? this.autosave,
      urgent: urgent ?? this.urgent,
      newOrders: newOrders ?? this.newOrders,
      lowStock: lowStock ?? this.lowStock,
      warehouse: warehouse ?? this.warehouse,
      team: team ?? this.team,
      emailSummary: emailSummary ?? this.emailSummary,
      sounds: sounds ?? this.sounds,
    );
  }

  LabSettingsPrefsState withNotif(LabNotifPref pref, bool value) => switch (pref) {
        LabNotifPref.urgent => copyWith(urgent: value),
        LabNotifPref.newOrders => copyWith(newOrders: value),
        LabNotifPref.lowStock => copyWith(lowStock: value),
        LabNotifPref.warehouse => copyWith(warehouse: value),
        LabNotifPref.team => copyWith(team: value),
        LabNotifPref.emailSummary => copyWith(emailSummary: value),
        LabNotifPref.sounds => copyWith(sounds: value),
      };
}

class LabSettingsPrefsCubit extends Cubit<LabSettingsPrefsState> {
  LabSettingsPrefsCubit({KeyValueStorage storage = const SecureKeyValueStorage()})
      : _storage = storage,
        super(const LabSettingsPrefsState());

  final KeyValueStorage _storage;

  static const _autosaveKey = 'lab_settings_autosave';
  static String _notifKey(LabNotifPref p) => 'lab_settings_notif_${p.name}';

  Future<void> loadSaved() async {
    try {
      var s = state;
      final autosave = await _storage.read(_autosaveKey);
      if (autosave != null) s = s.copyWith(autosave: autosave == 'true');
      for (final p in LabNotifPref.values) {
        final v = await _storage.read(_notifKey(p));
        if (v != null) s = s.withNotif(p, v == 'true');
      }
      emit(s);
    } catch (_) {
      // فشل القراءة → نبقى على الافتراضي.
    }
  }

  Future<void> setAutosave(bool value) async {
    emit(state.copyWith(autosave: value));
    try {
      await _storage.write(_autosaveKey, value.toString());
    } catch (_) {/* تجاهل أخطاء التخزين */}
  }

  Future<void> setNotif(LabNotifPref pref, bool value) async {
    emit(state.withNotif(pref, value));
    try {
      await _storage.write(_notifKey(pref), value.toString());
    } catch (_) {/* تجاهل أخطاء التخزين */}
  }
}
