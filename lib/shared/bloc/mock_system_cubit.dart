// ════════════════════════════════════════════════════════════════════════════
// mock_system_cubit.dart
//
// Cubit لإدارة "النظام الحالي" الذي يستخدمه المستخدم (المخبر / المستودع).
//
// 🎯 الهدف:
//   في غياب الـ Backend، نحتاج آلية تسمح للمستخدم باختيار النظام بعد تسجيل
//   الدخول، ثم التبديل بينهما بسهولة. هذا Cubit يحفظ الاختيار في
//   SharedPreferences حتى يبقى ثابتاً بين الجلسات.
//
// 🔮 الانتقال للـ Backend:
//   عند جاهزية الـ API، يتم استبدال هذا Cubit بـ AuthCubit الذي يقرأ الدور
//   من JWT token. الـ UI لن يتغيّر — فقط مصدر البيانات.
//
// التصميم:
//   - State = SystemRole (enum)
//   - الافتراضي: none (لم يُختر بعد)
//   - بعد تسجيل الدخول، المستخدم يختار من SystemSelectionPage
//   - يمكن التبديل لاحقاً عبر SystemSwitcherChip في كل dashboard
//
// الاستخدام:
//   context.read<MockSystemCubit>().selectSystem(SystemRole.lab);
//   context.read<MockSystemCubit>().toggle();   // تبديل بين النظامين
//   context.read<MockSystemCubit>().clear();    // عند تسجيل الخروج
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// مفتاح التخزين في SharedPreferences.
const String _kSystemRoleKey = 'app.mock_system.role';

/// أدوار الأنظمة المتاحة في المشروع.
///
/// هذا enum مؤقّت لمحاكاة الأدوار بدون باك آند. عند جاهزية الـ Backend،
/// سيتم استبداله بـ UserRole كامل من JWT.
enum SystemRole {
  /// لم يُختر أي نظام بعد (الحالة الأولية بعد Login).
  none('none'),

  /// نظام المخبر — لرئيس المخبر.
  lab('lab'),

  /// نظام المستودع — لرئيس المستودع.
  warehouse('warehouse');

  const SystemRole(this.code);

  /// الكود المخزّن في SharedPreferences.
  final String code;

  /// تحويل من كود إلى enum. يرجع [none] إذا لم يُتعرف على الكود.
  static SystemRole fromCode(String? code) {
    return SystemRole.values.firstWhere(
      (r) => r.code == code,
      orElse: () => SystemRole.none,
    );
  }

  /// هل تم اختيار نظام فعلياً؟
  bool get isSelected => this != SystemRole.none;
}

/// Cubit يدير النظام الحالي (Lab / Warehouse) مع persistence.
class MockSystemCubit extends Cubit<SystemRole> {
  /// ينشئ [MockSystemCubit] بحالة افتراضية ([SystemRole.none]).
  ///
  /// استخدم [MockSystemCubit.loadSaved] لاستعادة الاختيار المحفوظ.
  MockSystemCubit() : super(SystemRole.none);

  /// يحمّل النظام المحفوظ من SharedPreferences.
  ///
  /// يُستدعى عادةً في `main()` قبل تشغيل `runApp()`.
  Future<void> loadSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedCode = prefs.getString(_kSystemRoleKey);
      if (savedCode != null) {
        final role = SystemRole.fromCode(savedCode);
        emit(role);
      }
    } catch (_) {
      // فشل القراءة — نبقى على [SystemRole.none].
    }
  }

  /// يعيّن النظام الحالي ويحفظه.
  Future<void> selectSystem(SystemRole role) async {
    if (state == role) return; // لا تغيير
    emit(role);
    await _persist(role.code);
  }

  /// يبدّل بين [SystemRole.lab] و [SystemRole.warehouse].
  ///
  /// إذا كانت الحالة الحالية [SystemRole.none]، يختار [SystemRole.lab].
  Future<void> toggle() async {
    final SystemRole next = switch (state) {
      SystemRole.lab => SystemRole.warehouse,
      SystemRole.warehouse => SystemRole.lab,
      SystemRole.none => SystemRole.lab,
    };
    await selectSystem(next);
  }

  /// يمسح الاختيار (عند تسجيل الخروج).
  Future<void> clear() async {
    emit(SystemRole.none);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kSystemRoleKey);
    } catch (_) {
      // تجاهل أخطاء التخزين.
    }
  }

  /// هل النظام الحالي هو المخبر؟
  bool get isLab => state == SystemRole.lab;

  /// هل النظام الحالي هو المستودع؟
  bool get isWarehouse => state == SystemRole.warehouse;

  /// يحفظ في SharedPreferences.
  Future<void> _persist(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSystemRoleKey, code);
    } catch (_) {
      // فشل الحفظ — نتجاهل.
    }
  }
}
