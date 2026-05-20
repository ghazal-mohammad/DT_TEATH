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
}
