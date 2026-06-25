// ════════════════════════════════════════════════════════════════════════════
// profile_repository.dart
//
// عقد (interface) لخدمة الملف الشخصي للموظف. الـ presentation بيتعامل مع
// هذا الـ interface فقط — التنفيذ في data/repositories/profile_repository_impl.dart.
// ════════════════════════════════════════════════════════════════════════════

import '../entities/edit_profile_payload.dart';
import '../entities/employee_profile.dart';

abstract class ProfileRepository {
  /// آخر ملف مُحمَّل للمستخدم الحالي إن وُجد (للعرض الفوري عند إعادة زيارة
  /// الصفحة)، أو null إن لم يُحمَّل بعد أو تغيّر المستخدم.
  EmployeeProfile? get cachedProfile;

  /// جلب ملف الموظف الحالي من الباك (يعتمد على التوكن المحفوظ) ويحدّث الكاش.
  Future<EmployeeProfile> getProfile();

  /// تعديل ملف الموظف الحالي وإرجاع النسخة المحدّثة (يحدّث الكاش).
  Future<EmployeeProfile> updateProfile(EditProfilePayload payload);
}
