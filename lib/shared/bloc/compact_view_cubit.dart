// ════════════════════════════════════════════════════════════════════════════
// compact_view_cubit.dart
//
// Cubit لإدارة تفضيل "العرض المضغوط" (إظهار مزيد من البيانات بالشاشة الواحدة)
// — يُختار من الإعدادات. يُطبَّق عبر Theme.visualDensity على مستوى MaterialApp
// (نفس نمط TextScaleCubit مع textScaler): كل ودجتات Material (أزرار، حقول،
// صفوف قوائم...) تصغر padding/height تلقائياً بلا لمس أي ملف تصميم.
//
// Persistence: عبر KeyValueStorage (نفس نمط ThemeCubit/TextScaleCubit، لكن
// قابل للحقن للاختبار).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/key_value_storage.dart';

class CompactViewCubit extends Cubit<bool> {
  CompactViewCubit({KeyValueStorage storage = const SecureKeyValueStorage()})
      : _storage = storage,
        super(false);

  final KeyValueStorage _storage;
  static const _storageKey = 'app_compact_view';

  /// تحميل الاختيار المحفوظ عند بدء التطبيق.
  Future<void> loadSaved() async {
    try {
      final saved = await _storage.read(_storageKey);
      if (saved == null) return;
      emit(saved == 'true');
    } catch (_) {
      // فشل القراءة → نبقى على الافتراضي (false).
    }
  }

  /// ضبط العرض المضغوط من الإعدادات (يُحفظ فوراً).
  Future<void> setCompact(bool compact) async {
    if (compact == state) return;
    emit(compact);
    try {
      await _storage.write(_storageKey, compact.toString());
    } catch (_) {
      // تجاهل أخطاء التخزين — يبقى الاختيار بالذاكرة.
    }
  }
}
