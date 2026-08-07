// ════════════════════════════════════════════════════════════════════════════
// local_store.dart
//
// تجريد بسيط لتخزين مفتاح→نص (JSON) دائم على القرص. الواجهة [LocalStore] تسمح
// باستبدال SharedPreferences بمخزن وهمي في الاختبارات.
//
// يُستخدم كطبقة أساس لـ [PersistentCache] (كاش القراءة) و[Outbox] (طابور الكتابة).
// ════════════════════════════════════════════════════════════════════════════

import 'package:shared_preferences/shared_preferences.dart';

/// عقد تخزين محلّي بسيط (نصوص JSON) — يُنفَّذ فعلياً عبر SharedPreferences،
/// ويُستبدَل بمخزن في الذاكرة للاختبار.
abstract class LocalStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> remove(String key);
}

/// تنفيذ [LocalStore] فوق SharedPreferences.
class SharedPrefsLocalStore implements LocalStore {
  SharedPrefsLocalStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<String?> read(String key) async => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) => _prefs.setString(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);
}
