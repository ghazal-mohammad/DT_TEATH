// ════════════════════════════════════════════════════════════════════════════
// employee_profile.dart
//
// كيان (Entity) الملف الشخصي للموظف — مطابق لـ EmployeeProfileResource
// في باك Laravel (App\Http\Resources\EmployeeProfileResource).
//
// شكل الرد (showProfile / editProfile):
// {
//   "data": {
//     "id": 7,
//     "name": "رامي الصالح",
//     "email": "rami@clinic.com",
//     "phone": "0991234567",
//     "gender": "ذكر",                 // نص جاهز من الباك
//     "role": 5,                        // رقم الدور (5=مخبر، 6=مستودع)
//     "is_active": true,
//     "secondary_phone": "...",
//     "marital_status": "...",
//     "salary": "...",
//     "hire_date": "2023-02-10",
//     "educations": [...], "experiences": [...],
//     "trainings": [...], "skills": [...]
//   }
// }
// ════════════════════════════════════════════════════════════════════════════

import '../../../../core/auth/auth_models.dart';

class EmployeeProfile {
  const EmployeeProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.role,
    required this.isActive,
    required this.secondaryPhone,
    required this.maritalStatus,
    required this.salary,
    required this.hireDate,
    required this.skills,
  });

  final int id;
  final String name;
  final String email;
  final String phone;

  /// "ذكر" / "أنثى" (نص جاهز من الباك) أو فارغ.
  final String gender;

  /// الدور كـ enum — الباك بيرجع `role` كرقم (5/6...).
  final EmployeeRole role;
  final bool isActive;

  final String secondaryPhone;
  final String maritalStatus;
  final String salary;
  final String hireDate;
  final List<String> skills;

  /// بناء من الرد الخام. يتعامل مع التغليف `{ data: {...} }` ومع الكائن المباشر.
  factory EmployeeProfile.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> d =
        json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;

    return EmployeeProfile(
      id: _toInt(d['id']),
      name: _toStr(d['name']),
      email: _toStr(d['email']),
      phone: _toStr(d['phone']),
      gender: _toStr(d['gender']),
      role: EmployeeRole.fromApi(d['role']),
      isActive: d['is_active'] == true || d['is_active'] == 1,
      secondaryPhone: _toStr(d['secondary_phone']),
      maritalStatus: _toStr(d['marital_status']),
      salary: _toStr(d['salary']),
      hireDate: _toStr(d['hire_date']),
      skills: d['skills'] is List
          ? (d['skills'] as List).map((e) => e.toString()).toList()
          : const <String>[],
    );
  }

  static int _toInt(Object? v) {
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static String _toStr(Object? v) => v == null ? '' : v.toString();
}
