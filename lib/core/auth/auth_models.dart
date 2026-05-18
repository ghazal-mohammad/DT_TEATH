// ════════════════════════════════════════════════════════════════════════════
// auth_models.dart
//
// النماذج المستخدمة في Auth flow (Phase 3).
// مستقلة عن الـ BLoC — يمكن استخدامها في repositories + state + UI.
//
// الـ Models:
//   - UserRole    → دور المستخدم (lab/warehouse)
//   - AuthUser    → بيانات المستخدم بعد تسجيل الدخول
//   - AuthSession → الـ tokens + معلومات الجلسة
//
// ملاحظة: هذه models بسيطة (بدون Freezed حالياً).
// لو تعقّدت البنية لاحقاً، نحوّلها إلى Freezed classes للـ immutability.
//
// المرجع:
//   - القرار 5 (الأدوار) في الملف التقني
//   - API Contract في API_CONTRACT_AUTH.md
// ════════════════════════════════════════════════════════════════════════════

import '../../shared/widgets/core/app_system_type.dart';

/// أدوار المستخدمين المدعومة في التطبيق.
///
/// الدور يُحدّد من الباك-اند بناءً على الإيميل الذي سجّله المدير.
/// لا يمكن تغييره من الفرونت — هو صلاحية ثابتة.
enum UserRole {
  /// مدير المخبر — وصول كامل لنظام المخبر.
  labManager('lab_manager'),

  /// مدير المستودع — وصول كامل لنظام المستودع.
  warehouseManager('warehouse_manager'),

  /// المدير العام — وصول للنظامين + لوحة إدارة.
  admin('admin'),

  /// طبيب أسنان — ينشئ طلبات مخبر.
  dentist('dentist'),

  /// السكرتيرة — تدير المواعيد.
  secretary('secretary');

  const UserRole(this.apiValue);

  /// القيمة كما ترسلها الـ API (snake_case).
  final String apiValue;

  /// تحويل من string (response الـ API) إلى enum.
  ///
  /// إذا كان الدور غير معروف، يرمي [StateError] بدل null
  /// (لأن دور غير معروف = خطأ برمجي يجب أن يُكتشف فوراً).
  static UserRole fromApi(String value) {
    return UserRole.values.firstWhere(
      (r) => r.apiValue == value,
      orElse: () => throw StateError('Unknown UserRole from API: $value'),
    );
  }
}

/// Extension يوفّر خصائص مفيدة لكل دور.
extension UserRoleX on UserRole {
  /// هل هذا الدور في نظام المخبر؟
  bool get isLab => this == UserRole.labManager;

  /// هل هذا الدور في نظام المستودع؟
  bool get isWarehouse => this == UserRole.warehouseManager;

  /// تحويل الدور إلى النظام الفرعي المرتبط به.
  ///
  /// يستخدم في routing: بعد تسجيل الدخول، نحدد dashboard الصحيح.
  /// لو الدور admin، نرجع lab كافتراضي (يمكن للمستخدم التبديل بعدين).
  AppSystemType toSystemType() {
    switch (this) {
      case UserRole.warehouseManager:
        return AppSystemType.warehouse;
      case UserRole.labManager:
      case UserRole.admin:
      case UserRole.dentist:
      case UserRole.secretary:
        return AppSystemType.lab;
    }
  }

  /// هل يحق لهذا الدور الدخول للنظام الفرعي المحدّد؟
  bool canAccess(AppSystemType system) {
    if (this == UserRole.admin) return true; // admin له كل الصلاحيات
    return toSystemType() == system;
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                            AUTH USER
// ══════════════════════════════════════════════════════════════════════════

/// معلومات المستخدم المسجّل.
///
/// يُنشأ من استجابة `/auth/set-password` أو `/auth/login`.
/// يُحفظ في SecureStorage مع الـ tokens.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
  });

  /// معرّف فريد من الـ DB.
  final String id;

  /// البريد الإلكتروني (ثابت).
  final String email;

  /// الاسم الكامل المعروض في السايدبار.
  final String fullName;

  /// دور المستخدم — يحدّد الصلاحيات والواجهة.
  final UserRole role;

  /// رابط صورة الأفاتار (اختياري).
  final String? avatarUrl;

  /// بناء من JSON (response الـ API).
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: UserRole.fromApi(json['role'] as String),
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  /// تحويل لـ JSON للتخزين المحلي.
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'role': role.apiValue,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthUser &&
          other.id == id &&
          other.email == email &&
          other.fullName == fullName &&
          other.role == role);

  @override
  int get hashCode => Object.hash(id, email, fullName, role);

  @override
  String toString() => 'AuthUser(id: $id, email: $email, role: $role)';
}

// ══════════════════════════════════════════════════════════════════════════
//                          AUTH SESSION
// ══════════════════════════════════════════════════════════════════════════

/// الجلسة الكاملة = tokens + معلومات المستخدم.
///
/// الـ tokens تُحفظ في `FlutterSecureStorage` (مشفّرة).
/// تُستخدم في:
/// - Interceptor لإضافة `Authorization: Bearer <token>` لكل request.
/// - Refresh logic عند انتهاء الـ access token.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.expiresAt,
  });

  /// JWT access token (قصير العمر — ~15 دقيقة).
  final String accessToken;

  /// JWT refresh token (طويل العمر — ~30 يوم).
  final String refreshToken;

  /// المستخدم الحالي.
  final AuthUser user;

  /// متى ينتهي الـ access token (UTC).
  final DateTime expiresAt;

  /// هل الـ token ما زال صالحاً؟
  bool get isValid => DateTime.now().toUtc().isBefore(expiresAt);

  /// هل يجب تجديده قريباً (أقل من دقيقة على الانتهاء)؟
  bool get needsRefresh {
    final remaining = expiresAt.difference(DateTime.now().toUtc());
    return remaining.inSeconds < 60;
  }

  /// بناء من JSON (response `/auth/set-password` أو `/auth/login`).
  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      expiresAt: DateTime.parse(json['expires_at'] as String).toUtc(),
    );
  }

  /// تحويل لـ JSON للتخزين في SecureStorage.
  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'user': user.toJson(),
        'expires_at': expiresAt.toIso8601String(),
      };
}
