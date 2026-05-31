// ════════════════════════════════════════════════════════════════════════════
// profile_repository.dart
//
// عقد (interface) لخدمة الملف الشخصي للموظف. الـ presentation بيتعامل مع
// هذا الـ interface فقط — التنفيذ في data/repositories/profile_repository_impl.dart.
// ════════════════════════════════════════════════════════════════════════════

import '../entities/edit_profile_payload.dart';
import '../entities/employee_profile.dart';

abstract class ProfileRepository {
  /// جلب ملف الموظف الحالي (يعتمد على التوكن المحفوظ).
  Future<EmployeeProfile> getProfile();

  /// تعديل ملف الموظف الحالي وإرجاع النسخة المحدّثة.
  Future<EmployeeProfile> updateProfile(EditProfilePayload payload);
}
