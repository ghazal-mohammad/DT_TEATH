// ════════════════════════════════════════════════════════════════════════════
// lab_technician.dart
//
// نموذج فني المخبر — مطابق لرد GET /api/labManager/showAllTechnicians
// (تحقّق فعلي 2026-06-24 عبر TechnicianResource الجديد).
//
// الحقول المتوفّرة من الباك: id, name, email, phone, is_active (نص عربي
// "يعمل"/"لا يعمل")، schedule[] (مواعيد الدوام — قد تكون فارغة).
// أُزيلت user_id/role/profile_picture (لم يعد الباك يرجّعها).
// ════════════════════════════════════════════════════════════════════════════

class LabTechnician {
  const LabTechnician({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.isActive,
    this.schedule = const [],
  });

  /// معرّف سجل الموظف (employee.id).
  final int id;

  final String name;
  final String email;
  final String phone;

  /// هل المخبري على رأس عمله؟ (مشتق من نص is_active العربي).
  final bool isActive;

  /// مواعيد الدوام كما يرجّعها الباك (قد تكون فارغة — جدول جديد).
  final List<Map<String, dynamic>> schedule;

  factory LabTechnician.fromJson(Map<String, dynamic> json) {
    int asInt(Object? v) => v is int ? v : int.tryParse('${v ?? ''}') ?? 0;

    // الباك يرجّع is_active كنص عربي ("يعمل"/"لا يعمل") أو bool احتياطاً.
    final rawActive = json['is_active'];
    final bool active = rawActive is bool
        ? rawActive
        : '${rawActive ?? ''}'.trim() == 'يعمل';

    final rawSchedule = json['schedule'];
    final schedule = rawSchedule is List
        ? rawSchedule
            .whereType<Map<dynamic, dynamic>>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : <Map<String, dynamic>>[];

    return LabTechnician(
      id: asInt(json['id']),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      isActive: active,
      schedule: schedule,
    );
  }
}
