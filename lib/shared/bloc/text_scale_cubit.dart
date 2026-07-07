// ════════════════════════════════════════════════════════════════════════════
// text_scale_cubit.dart
//
// Cubit لإدارة حجم خط الواجهة (ميزة وصولية) — يختاره المستخدم من الإعدادات.
//
// يُطبَّق عبر MediaQuery.textScaler على مستوى MaterialApp فقط، فلا يمسّ أي ودجت
// أو مكوّن أو تصميم أو ملف — كل النصوص تكبر/تصغر تلقائياً بنسبة موحّدة.
//
// Persistence: يُحفظ الاختيار عبر flutter_secure_storage (نفس نمط ThemeCubit).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// مستويات حجم الخط المتاحة (معامل ضرب على textScaler).
enum AppTextScale { small, normal, large, xlarge }

extension AppTextScaleX on AppTextScale {
  /// معامل التكبير المطبَّق على كل نصوص التطبيق.
  double get factor => switch (this) {
        AppTextScale.small => 0.90,
        AppTextScale.normal => 1.0,
        AppTextScale.large => 1.15,
        AppTextScale.xlarge => 1.30,
      };

  /// المفتاح المُخزَّن (ثابت عبر الإصدارات).
  String get storageKey => switch (this) {
        AppTextScale.small => 'small',
        AppTextScale.normal => 'normal',
        AppTextScale.large => 'large',
        AppTextScale.xlarge => 'xlarge',
      };
}

/// Cubit لإدارة حجم الخط. الحالة = المستوى المختار (الافتراضي normal).
class TextScaleCubit extends Cubit<AppTextScale> {
  TextScaleCubit() : super(AppTextScale.normal);

  static const _storageKey = 'app_text_scale';
  static const _storage = FlutterSecureStorage();

  /// تحميل الاختيار المحفوظ عند بدء التطبيق.
  Future<void> loadSaved() async {
    try {
      final saved = await _storage.read(key: _storageKey);
      if (saved == null) return;
      for (final s in AppTextScale.values) {
        if (s.storageKey == saved) {
          emit(s);
          return;
        }
      }
    } catch (_) {
      // فشل القراءة → نبقى على الافتراضي (normal).
    }
  }

  /// ضبط حجم الخط من الإعدادات (يُحفظ فوراً).
  Future<void> setScale(AppTextScale scale) async {
    if (scale == state) return;
    emit(scale);
    try {
      await _storage.write(key: _storageKey, value: scale.storageKey);
    } catch (_) {
      // تجاهل أخطاء التخزين — يبقى الاختيار في الذاكرة.
    }
  }
}
