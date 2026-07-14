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
import '../../../../core/domain/work_schedule.dart';

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
    required this.educations,
    required this.experiences,
    required this.trainings,
    this.profilePicture = '',
    this.address = '',
    this.dateOfBirth = '',
    this.schedule = const [],
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
  final List<Education> educations;
  final List<Experience> experiences;
  final List<Training> trainings;

  /// رابط/مسار صورة البروفايل من الباك.
  final String profilePicture;

  /// العنوان وتاريخ الميلاد — `showProfile` بالباك ما يرجّعهما **بعد**؛
  /// جاهزان فاللحظة اللي يُضافان لـ EmployeeProfileResource.
  final String address;
  final String dateOfBirth;

  /// جدول الدوام الحقيقي من الباك (schedule[] — أيام وأوقات العمل).
  final List<WorkShift> schedule;

  /// بناء من الرد الخام. يتعامل مع التغليف `{ data: {...} }` ومع الكائن المباشر.
  factory EmployeeProfile.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> d =
        json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;

    List<T> parseList<T>(Object? raw, T Function(Map<String, dynamic>) fromMap) {
      if (raw is! List) return <T>[];
      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }

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
      educations: parseList(d['educations'], Education.fromJson),
      experiences: parseList(d['experiences'], Experience.fromJson),
      trainings: parseList(d['trainings'], Training.fromJson),
      profilePicture:
          _toStr(d['profile_picture'] ?? d['profile_picture_url']),
      address: _toStr(d['address']),
      dateOfBirth: _toStr(d['date_of_birth']),
      schedule: d['schedule'] is List
          ? (d['schedule'] as List)
              .whereType<Map<dynamic, dynamic>>()
              .map((e) => WorkShift.fromRaw(Map<String, dynamic>.from(e)))
              .whereType<WorkShift>()
              .toList()
          : const <WorkShift>[],
    );
  }

  static int _toInt(Object? v) {
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static String _toStr(Object? v) => v == null ? '' : v.toString();
}

/// شهادة علمية ضمن ملف الموظف.
class Education {
  const Education({
    required this.degree,
    required this.institution,
    required this.completionDate,
    required this.grade,
  });

  final String degree;
  final String institution;
  final String completionDate; // yyyy-MM-dd
  final String grade;

  factory Education.fromJson(Map<String, dynamic> j) => Education(
        degree: EmployeeProfile._toStr(j['degree']),
        institution: EmployeeProfile._toStr(j['institution']),
        completionDate: EmployeeProfile._toStr(j['completion_date']),
        grade: EmployeeProfile._toStr(j['grade']),
      );
}

/// خبرة عملية ضمن ملف الموظف.
class Experience {
  const Experience({
    required this.title,
    required this.company,
    required this.startDate,
    required this.endDate,
  });

  final String title;
  final String company;
  final String startDate; // yyyy-MM-dd
  final String endDate; // yyyy-MM-dd

  factory Experience.fromJson(Map<String, dynamic> j) => Experience(
        title: EmployeeProfile._toStr(j['title']),
        company: EmployeeProfile._toStr(j['company']),
        startDate: EmployeeProfile._toStr(j['start_date']),
        endDate: EmployeeProfile._toStr(j['end_date']),
      );
}

/// دورة تدريبية ضمن ملف الموظف.
class Training {
  const Training({
    required this.courseTitle,
    required this.trainer,
    required this.courseDate,
  });

  final String courseTitle;
  final String trainer;
  final String courseDate; // yyyy-MM-dd

  factory Training.fromJson(Map<String, dynamic> j) => Training(
        courseTitle: EmployeeProfile._toStr(j['course_title']),
        trainer: EmployeeProfile._toStr(j['trainer']),
        courseDate: EmployeeProfile._toStr(j['course_date']),
      );
}
