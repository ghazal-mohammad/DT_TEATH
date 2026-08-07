// ════════════════════════════════════════════════════════════════════════════
// persistent_cache.dart
//
// كاش قراءة دائم لكل مورد (repository): يحفظ آخر قائمة JSON معروفة على القرص،
// فتبقى بعد إعادة تشغيل التطبيق. يتيح عرض آخر بيانات معروفة عند غياب الاتصال
// بدل شاشة فارغة/خطأ.
//
// عام (generic): يخزّن `List<Map<String,dynamic>>` الخام (JSON الباك) تحت مفتاح
// مورد، فيُعيد الـ repository بناء الكيانات منه بنفس مُحوِّل _fromJson.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:convert';

import 'local_store.dart';

/// كاش قراءة دائم لقوائم JSON، مفهرس بمفتاح مورد.
class PersistentCache {
  PersistentCache(this._store);

  final LocalStore _store;

  static const String _prefix = 'cache.v1.';

  String _key(String resource) => '$_prefix$resource';

  /// يحفظ قائمة JSON الخام لمورد (يتجاهل الأخطاء بصمت — الكاش مساعِد لا حرِج).
  Future<void> save(String resource, List<Map<String, dynamic>> rows) async {
    try {
      await _store.write(_key(resource), jsonEncode(rows));
    } catch (_) {
      // فشل الحفظ لا يجب أن يُفشل عملية القراءة الأصلية.
    }
  }

  /// يقرأ آخر قائمة JSON محفوظة لمورد (`null` إن لا يوجد أو تلِف).
  Future<List<Map<String, dynamic>>?> load(String resource) async {
    try {
      final raw = await _store.read(_key(resource));
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(growable: false);
    } catch (_) {
      return null; // بيانات تالفة ⇒ كأنها غير موجودة.
    }
  }

  /// يمسح كاش مورد واحد.
  Future<void> clear(String resource) => _store.remove(_key(resource));
}
