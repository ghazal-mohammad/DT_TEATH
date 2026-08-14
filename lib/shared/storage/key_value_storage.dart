// ════════════════════════════════════════════════════════════════════════════
// key_value_storage.dart
//
// تجريد صغير لتخزين تفضيلات محلية (key → value) خلف interface بسيط، حتى يمكن
// حَقن تخزين وهمي (in-memory) بالاختبارات بدل [FlutterSecureStorage] الحقيقي.
// نفس فكرة ThemeCubit/TextScaleCubit لكن قابلة للاختبار.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class KeyValueStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

/// التنفيذ الحقيقي — يغلّف [FlutterSecureStorage] (نفس نمط ThemeCubit).
class SecureKeyValueStorage implements KeyValueStorage {
  const SecureKeyValueStorage();

  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}
