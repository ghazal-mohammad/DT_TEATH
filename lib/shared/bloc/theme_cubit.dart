// ════════════════════════════════════════════════════════════════════════════
// theme_cubit.dart
//
// Cubit بسيط لإدارة تبديل الثيم (Dark ↔ Light) في الـ Runtime.
// نستخدم Cubit بدل BLoC الكامل لأن الحالة بسيطة جداً (2 قيم فقط).
//
// Persistence: يُحفظ اختيار المستخدم باستخدام flutter_secure_storage.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  // الافتراضي: Light Mode — مطابق لـ Design System Contract (2026-05-05).
  // الـ Dark Mode متوفّر كـ toggle بس مش الأولوية.
  ThemeCubit() : super(ThemeMode.light);

  static const _storageKey = 'app_theme_mode';
  static const _storage = FlutterSecureStorage();

  /// تحميل اختيار الثيم المحفوظ عند بدء التطبيق.
  Future<void> loadSavedTheme() async {
    try {
      final saved = await _storage.read(key: _storageKey);
      if (saved == null) return;
      switch (saved) {
        case 'light':
          emit(ThemeMode.light);
        case 'dark':
          emit(ThemeMode.dark);
        case 'system':
          emit(ThemeMode.system);
      }
    } catch (_) {
      // إذا فشل القراءة، نبقى على الافتراضي (light).
    }
  }

  /// تبديل بين فاتح وداكن (الاختيار الأساسي بالواجهة).
  Future<void> toggle() async {
    final next = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    emit(next);
    await _persist(next);
  }

  /// ضبط الثيم يدوياً من صفحة الإعدادات.
  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    await _persist(mode);
  }

  Future<void> _persist(ThemeMode mode) async {
    try {
      await _storage.write(
        key: _storageKey,
        value: switch (mode) {
          ThemeMode.light => 'light',
          ThemeMode.dark => 'dark',
          ThemeMode.system => 'system',
        },
      );
    } catch (_) {
      // تجاهل أخطاء التخزين — الثيم سيتبدل في الذاكرة فقط.
    }
  }
}
