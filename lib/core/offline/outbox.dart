// ════════════════════════════════════════════════════════════════════════════
// outbox.dart
//
// طابور صادر دائم لعمليات الكتابة المؤجَّلة (offline write queue). يحفظ العمليات
// على القرص عبر [LocalStore] فتنجو من إعادة التشغيل، ويكشف عددها المعلّق للـ UI
// عبر ChangeNotifier.
//
// FIFO: تُعاد الإرسال بترتيب الإنشاء (يحافظ على تسلسل التعديلات على نفس الكيان).
// ════════════════════════════════════════════════════════════════════════════

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'local_store.dart';
import 'outbox_entry.dart';

/// طابور دائم لعمليات الكتابة المؤجَّلة.
class Outbox extends ChangeNotifier {
  Outbox(this._store);

  final LocalStore _store;

  static const String _key = 'outbox.v1.queue';

  final List<OutboxEntry> _entries = [];
  bool _loaded = false;

  /// نسخة غير قابلة للتعديل من العمليات المعلّقة (بترتيب FIFO).
  List<OutboxEntry> get entries => List.unmodifiable(_entries);

  /// عدد العمليات المعلّقة (للعرض في UI).
  int get pendingCount => _entries.length;

  /// هل الطابور محمّل من القرص؟
  bool get isLoaded => _loaded;

  /// يحمّل الطابور من القرص مرّة واحدة عند الإقلاع.
  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final raw = await _store.read(_key);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _entries
            ..clear()
            ..addAll(decoded
                .whereType<Map<dynamic, dynamic>>()
                .map((e) => OutboxEntry.fromJson(Map<String, dynamic>.from(e))));
          _sort();
        }
      }
    } catch (_) {
      // طابور تالف ⇒ نبدأ فارغاً بدل الانهيار.
      _entries.clear();
    }
    notifyListeners();
  }

  /// يضيف عملية جديدة ويحفظ.
  Future<void> add(OutboxEntry entry) async {
    _entries.add(entry);
    _sort();
    await _persist();
    notifyListeners();
  }

  /// يزيل عملية بمعرّفها (بعد نجاح إرسالها).
  Future<void> remove(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _persist();
    notifyListeners();
  }

  /// يستبدل عملية بمعرّفها (مثلاً لزيادة عدّاد المحاولات).
  Future<void> update(OutboxEntry entry) async {
    final i = _entries.indexWhere((e) => e.id == entry.id);
    if (i < 0) return;
    _entries[i] = entry;
    await _persist();
    notifyListeners();
  }

  /// يمسح الطابور بالكامل (تسجيل خروج/إعادة ضبط).
  Future<void> clear() async {
    _entries.clear();
    await _store.remove(_key);
    notifyListeners();
  }

  void _sort() =>
      _entries.sort((a, b) => a.createdAt.compareTo(b.createdAt));

  Future<void> _persist() async {
    final rows = _entries.map((e) => e.toJson()).toList();
    await _store.write(_key, jsonEncode(rows));
  }
}
