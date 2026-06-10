// ════════════════════════════════════════════════════════════════════════════
// auth_repository.dart
//
// عقد (interface) لخدمات المصادقة. الـ presentation بيتعامل مع هاد الـ interface
// فقط — التنفيذ بيكون في data/repositories/auth_repository_impl.dart.
// ════════════════════════════════════════════════════════════════════════════

import '../../../../core/auth/auth_models.dart';

abstract class AuthRepository {
  /// إرسال كود التحقق لإيميل الموظف (للتسجيل لأول مرة).
  Future<void> sendVerification({required String email});

  /// التحقق من كود البريد وتعليم الإيميل كـ"مؤكَّد".
  /// لازم تُستدعى قبل setPassword، وإلا الباك بيرفض بـ"email not verified".
  Future<void> verifyCode({
    required String email,
    required String verificationCode,
  });

  /// تعيين كلمة المرور بعد التحقق من الكود.
  /// عند النجاح: يحفظ التوكن داخلياً في SecureStorage ويرجّع EmployeeUser
  /// (الباك بيرجع توكن جاهز فما في داعي يعيد المستخدم تسجيل دخول).
  Future<EmployeeUser> setPassword({
    required String email,
    required String verificationCode,
    required String password,
  });

  /// تسجيل دخول بإيميل وكلمة مرور.
  /// يحفظ التوكن داخلياً في SecureStorage عند النجاح.
  Future<EmployeeUser> login({
    required String email,
    required String password,
  });

  /// تسجيل خروج. يمسح التوكن من SecureStorage حتى لو فشل طلب الـAPI.
  Future<void> logout();

  // ── Forgot Password (إعادة تعيين كلمة سر لحساب مُفعَّل) ──────────────────

  /// إرسال كود إعادة تعيين كلمة السر لإيميل موجود (لحساب مفعّل).
  Future<void> sendResetCode({required String email});

  /// التحقق من كود إعادة التعيين قبل تعيين كلمة سر جديدة.
  Future<void> verifyResetCode({
    required String email,
    required String verificationCode,
  });

  /// تعيين كلمة سر جديدة بعد التحقق من الكود.
  /// لا يرجّع توكن (الباك يلغي كل التوكنات) — لازم المستخدم يسجّل دخول من جديد.
  Future<void> resetPassword({
    required String email,
    required String password,
  });
}
