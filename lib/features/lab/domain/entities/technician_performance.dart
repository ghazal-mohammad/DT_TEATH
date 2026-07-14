// ════════════════════════════════════════════════════════════════════════════
// technician_performance.dart
//
// كيان أداء/تقييم الفنّي — مطابق لـ GET showTechniciansPerformance:
//   { technician_id, name, shift_start, shift_end,
//     total_assigned, total_completed, total_in_progress, period:{from,to} }.
// التقييم = معدّل الإنجاز (المكتمل ÷ المُسنَد) يُحسب أماميًا.
// ════════════════════════════════════════════════════════════════════════════

class TechnicianPerformance {
  const TechnicianPerformance({
    required this.technicianId,
    required this.name,
    required this.shiftStart,
    required this.shiftEnd,
    required this.totalAssigned,
    required this.totalCompleted,
    required this.totalInProgress,
  });

  final int technicianId;
  final String name;

  /// بداية/نهاية دوام اليوم (قد تكون فارغة إن لا دوام اليوم).
  final String shiftStart;
  final String shiftEnd;

  final int totalAssigned;
  final int totalCompleted;
  final int totalInProgress;

  /// معدّل الإنجاز 0.0–1.0 (المكتمل ÷ المُسنَد) — التقييم. 0 إن لا إسناد.
  double get completionRate =>
      totalAssigned == 0 ? 0 : totalCompleted / totalAssigned;

  factory TechnicianPerformance.fromJson(Map<String, dynamic> j) {
    int i(Object? v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
    String s(Object? v) {
      final t = '${v ?? ''}';
      return t.length >= 5 && t.contains(':') ? t.substring(0, 5) : t;
    }

    return TechnicianPerformance(
      technicianId: i(j['technician_id']),
      name: '${j['name'] ?? ''}',
      shiftStart: s(j['shift_start']),
      shiftEnd: s(j['shift_end']),
      totalAssigned: i(j['total_assigned']),
      totalCompleted: i(j['total_completed']),
      totalInProgress: i(j['total_in_progress']),
    );
  }
}
