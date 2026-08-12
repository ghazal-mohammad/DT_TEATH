// ════════════════════════════════════════════════════════════════════════════
// lab_technician_view_data.dart
//
// نماذج عرض إدارة المخبريين (حالة المخبري + عنصر الجدول) — مُستخرَجة من
// lab_technicians_page.dart ليشاركها كلٌّ من الصفحة وودجات الجدول.
//
// ملاحظة: الحقول غير المتوفّرة بالباك (الدوام/المهمة) تُدار محلياً. حالة
// "نشط/متاح/استراحة" حُذفت (2026-08) — كانت وهمية بالكامل، لا تُحفظ ولا تعكس
// شيئاً حقيقياً، وتُصفَّر عند كل إعادة تحميل.
// ════════════════════════════════════════════════════════════════════════════

/// عنصر عرض لمخبري واحد في الجدول (مبني من نموذج الباك LabTechnician).
class TechnicianItem {
  TechnicianItem({
    required this.id,
    required this.name,
    required this.role,
    required this.shift,
    required this.currentTask,
    required this.taskCount,
    required this.initials,
  });

  /// معرّف الفنّي (employee.id) — لتحرير الجدول عبر الباك.
  final int id;

  String name;
  String role;
  String shift;
  String currentTask;
  int taskCount;
  String initials;
}
