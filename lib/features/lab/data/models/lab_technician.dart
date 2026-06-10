// ════════════════════════════════════════════════════════════════════════════
// lab_technician.dart
//
// نموذج فني المخبر — مطابق لرد GET /api/labManager/showAllTechnicians.
// الحقول المتوفّرة من الباك فقط: id (employee.id), user_id, name, email,
// role, profile_picture. (لا يوجد دوام/عدد مخابر بالباك.)
// ════════════════════════════════════════════════════════════════════════════

class LabTechnician {
  const LabTechnician({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.profilePicture,
  });

  /// معرّف سجل الموظف (employee.id) — هذا اللي نستعملو عند توكيل طلبية.
  final int id;

  /// معرّف المستخدم (users.id).
  final int userId;

  final String name;
  final String email;

  /// رقم الدور (7 = فني) — كما يرجّعه الباك.
  final int role;

  /// رابط صورة البروفايل (قد يكون null أو صورة افتراضية من الباك).
  final String? profilePicture;

  factory LabTechnician.fromJson(Map<String, dynamic> json) {
    int asInt(Object? v) =>
        v is int ? v : int.tryParse('${v ?? ''}') ?? 0;

    return LabTechnician(
      id: asInt(json['id']),
      userId: asInt(json['user_id']),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: asInt(json['role']),
      profilePicture: json['profile_picture']?.toString(),
    );
  }
}
