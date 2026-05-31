// ════════════════════════════════════════════════════════════════════════════
// auth_models.dart
//
// نماذج Auth الفعلية المطابقة لـ response باك Laravel
// (App\Http\Controllers\Auth\EmployeeAuthController).
//
// شكل response الـ login:
// {
//   "message": "Login successful.",
//   "user": {
//     "id": 1,
//     "name": "Sara Warehouse",
//     "email": "sara.warehouse@clinic.com",
//     "role": 6,                     // role ID رقمي (6 = مدير المستودع)
//     "is_active": true,
//     "token": "7|abc...",
//     "token_type": "Bearer"
//   }
// }
// ════════════════════════════════════════════════════════════════════════════

import '../../shared/bloc/mock_system_cubit.dart';

// ══════════════════════════════════════════════════════════════════════════
//                            EMPLOYEE ROLE
// ══════════════════════════════════════════════════════════════════════════

/// أدوار الموظفين المعروفة (مطابقة لـ labels من PHP enum في الباك).
enum EmployeeRole {
  labManager,
  warehouseManager,
  admin,
  secretary,
  dentist,
  unknown;

  /// تحويل قيمة `role` من response الباك إلى enum.
  ///
  /// الباك بيرجع label() من PHP enum بالعربية افتراضياً:
  ///   "مدير المخبر" / "مدير المستودع" / "مدير النظام" / "سكرتيرة" / "طبيب أسنان"
  /// وممكن يرجع labelEn() بالإنجليزية:
  ///   "Lab Manager" / "Warehouse Manager" / "Administrator" / ...
  /// كمان نتعامل مع snake_case (LAB_MANAGER) احتياطاً.
  static EmployeeRole fromApiLabel(String? label) {
    if (label == null) return EmployeeRole.unknown;
    final normalized =
        label.trim().toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
    return switch (normalized) {
      // English labels
      'labmanager' => EmployeeRole.labManager,
      'warehousemanager' => EmployeeRole.warehouseManager,
      'admin' || 'administrator' => EmployeeRole.admin,
      'secretary' => EmployeeRole.secretary,
      'dentist' || 'doctor' => EmployeeRole.dentist,
      // Arabic labels (من PHP enum label())
      'مديرالمخبر' => EmployeeRole.labManager,
      'مديرالمستودع' => EmployeeRole.warehouseManager,
      'مديرالنظام' => EmployeeRole.admin,
      'سكرتيرة' || 'سكرتير' => EmployeeRole.secretary,
      'طبيبأسنان' || 'طبيب' => EmployeeRole.dentist,
      _ => EmployeeRole.unknown,
    };
  }

  /// تحويل `role` من response الباك إلى enum عندما يرجع كـ**رقم** (role ID).
  ///
  /// الخريطة الرسمية من GET /api/roles:
  ///   1=مدير النظام  2=طبيب أسنان  3=سكرتيرة  4=مريض
  ///   5=مدير المخبر  6=مدير المستودع  7=فني  8=مساعد
  ///
  /// نهتم فقط بـ labManager(5) + warehouseManager(6) + admin(1) — الباقي unknown.
  static EmployeeRole fromApiId(int id) => switch (id) {
        1 => EmployeeRole.admin,
        5 => EmployeeRole.labManager,
        6 => EmployeeRole.warehouseManager,
        _ => EmployeeRole.unknown,
      };

  /// مُحلّل آمن: الباك بيرجع `role` كرقم (مثل 5)، بس نتعامل احتياطاً مع
  /// النص (label) ومع رقم على شكل نص ("5").
  static EmployeeRole fromApi(Object? raw) {
    if (raw is num) return fromApiId(raw.toInt());
    if (raw is String) {
      final asInt = int.tryParse(raw.trim());
      if (asInt != null) return fromApiId(asInt);
      return fromApiLabel(raw);
    }
    return EmployeeRole.unknown;
  }

  /// النظام الفرعي المرتبط بالدور (للتوجيه بعد login).
  SystemRole toSystemRole() => switch (this) {
        EmployeeRole.labManager => SystemRole.lab,
        EmployeeRole.warehouseManager => SystemRole.warehouse,
        EmployeeRole.admin => SystemRole.lab, // افتراضي للأدمن
        _ => SystemRole.none,
      };

  /// هل هذا الدور مسموح له بدخول التطبيق؟
  /// حالياً Lab + Warehouse + Admin فقط.
  bool get isAuthorized =>
      this == EmployeeRole.labManager ||
      this == EmployeeRole.warehouseManager ||
      this == EmployeeRole.admin;
}

// ══════════════════════════════════════════════════════════════════════════
//                            EMPLOYEE USER
// ══════════════════════════════════════════════════════════════════════════

/// بيانات الموظف المسجّل + التوكن.
class EmployeeUser {
  const EmployeeUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.token,
    this.tokenType = 'Bearer',
  });

  final int id;
  final String name;
  final String email;
  final EmployeeRole role;
  final bool isActive;
  final String token;
  final String tokenType;

  /// بناء من JSON. ياخد إما الـ root response أو الـ`user` فقط.
  factory EmployeeUser.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> u = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json;

    return EmployeeUser(
      id: (u['id'] as num).toInt(),
      name: (u['name'] ?? '') as String,
      email: (u['email'] ?? '') as String,
      role: EmployeeRole.fromApi(u['role']),
      isActive: (u['is_active'] ?? true) as bool,
      token: (u['token'] ?? '') as String,
      tokenType: (u['token_type'] ?? 'Bearer') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'is_active': isActive,
        'token': token,
        'token_type': tokenType,
      };

  @override
  String toString() =>
      'EmployeeUser(id: $id, email: $email, role: $role, active: $isActive)';
}
