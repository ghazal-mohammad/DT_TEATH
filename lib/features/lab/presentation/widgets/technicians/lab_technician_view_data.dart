// ════════════════════════════════════════════════════════════════════════════
// lab_technician_view_data.dart
//
// نماذج عرض إدارة المخبريين (حالة المخبري + عنصر الجدول) — مُستخرَجة من
// lab_technicians_page.dart ليشاركها كلٌّ من الصفحة وودجات الجدول.
//
// ملاحظة: الحقول غير المتوفّرة بالباك (الدوام/المهمة/الحالة) تُدار محلياً.
// ════════════════════════════════════════════════════════════════════════════

/// حالة المخبري في جدول الفريق.
enum TechnicianStatus { active, available, onBreak }

/// عنصر عرض لمخبري واحد في الجدول (مبني من نموذج الباك LabTechnician).
class TechnicianItem {
  TechnicianItem({
    required this.name,
    required this.role,
    required this.shift,
    required this.currentTask,
    required this.taskCount,
    required this.status,
    required this.initials,
  });

  String name;
  String role;
  String shift;
  String currentTask;
  int taskCount;
  TechnicianStatus status;
  String initials;
}
