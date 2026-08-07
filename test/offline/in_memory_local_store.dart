// مخزن محلّي في الذاكرة للاختبارات — يحاكي [LocalStore] بلا SharedPreferences.
import 'package:dt_teeth/core/offline/local_store.dart';

class InMemoryLocalStore implements LocalStore {
  final Map<String, String> data = {};

  /// يحاكي بيانات تالفة (لاختبار مسارات الأخطاء).
  bool throwOnRead = false;

  @override
  Future<String?> read(String key) async {
    if (throwOnRead) throw StateError('read failure');
    return data[key];
  }

  @override
  Future<void> write(String key, String value) async {
    data[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    data.remove(key);
  }
}
