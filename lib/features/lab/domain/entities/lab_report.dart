// ════════════════════════════════════════════════════════════════════════════
// lab_report.dart
//
// كيان تقرير المخبر التحليلي — مطابق لـ GET /api/labManager/reports:
//   { period{type,from,to,label}, kpis{average_completion_hours,
//     completed_on_time,total_orders}, orders_by_day[]{day,day_ar,count},
//     team_performance[]{technician_id,name,completed_orders,average_hours},
//     orders_by_type[]{type,type_ar,count,percentage} }.
// نقي (pure Dart).
// ════════════════════════════════════════════════════════════════════════════

/// فترة التقرير — القيمة تطابق باراميتر period بالباك.
enum ReportPeriod { daily, weekly, monthly, yearly }

extension ReportPeriodX on ReportPeriod {
  String get apiValue => name;
}

/// عدد الطلبات في يوم أسبوع واحد.
class ReportDayCount {
  const ReportDayCount({required this.dayAr, required this.count});
  final String dayAr;
  final int count;
}

/// أداء فنّي ضمن التقرير (مكتمل + متوسط ساعات).
class ReportTeamPerf {
  const ReportTeamPerf({
    required this.technicianId,
    required this.name,
    required this.completedOrders,
    required this.averageHours,
  });
  final int technicianId;
  final String name;
  final int completedOrders;
  final double averageHours;
}

/// عدد/نسبة الطلبات حسب نوع التعويض.
class ReportTypeCount {
  const ReportTypeCount({
    required this.typeAr,
    required this.count,
    required this.percentage,
  });
  final String typeAr;
  final int count;
  final int percentage;
}

/// التقرير الكامل لفترة مختارة.
class LabReport {
  const LabReport({
    required this.periodLabel,
    required this.totalOrders,
    required this.completedOnTime,
    required this.avgCompletionHours,
    required this.ordersByDay,
    required this.teamPerformance,
    required this.ordersByType,
  });

  final String periodLabel;
  final int totalOrders;
  final int completedOnTime;
  final double avgCompletionHours;
  final List<ReportDayCount> ordersByDay;
  final List<ReportTeamPerf> teamPerformance;
  final List<ReportTypeCount> ordersByType;

  /// نسبة الإنجاز في الوقت (مكتمل بالوقت ÷ إجمالي) — تُحسب أماميًا للعرض.
  int get onTimePercent =>
      totalOrders == 0 ? 0 : ((completedOnTime / totalOrders) * 100).round();

  factory LabReport.fromJson(Map<String, dynamic> root) {
    final d = root['data'] is Map
        ? Map<String, dynamic>.from(root['data'] as Map)
        : root;

    int i(Object? v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
    double dbl(Object? v) =>
        v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;

    final period = d['period'] is Map
        ? Map<String, dynamic>.from(d['period'] as Map)
        : const <String, dynamic>{};
    final kpis = d['kpis'] is Map
        ? Map<String, dynamic>.from(d['kpis'] as Map)
        : const <String, dynamic>{};

    List<T> list<T>(Object? raw, T Function(Map<String, dynamic>) f) =>
        raw is List
            ? raw
                .whereType<Map<dynamic, dynamic>>()
                .map((e) => f(Map<String, dynamic>.from(e)))
                .toList()
            : <T>[];

    return LabReport(
      periodLabel: '${period['label'] ?? ''}',
      totalOrders: i(kpis['total_orders']),
      completedOnTime: i(kpis['completed_on_time']),
      avgCompletionHours: dbl(kpis['average_completion_hours']),
      ordersByDay: list(
        d['orders_by_day'],
        (m) => ReportDayCount(
          dayAr: '${m['day_ar'] ?? m['day'] ?? ''}',
          count: i(m['count']),
        ),
      ),
      teamPerformance: list(
        d['team_performance'],
        (m) => ReportTeamPerf(
          technicianId: i(m['technician_id']),
          name: '${m['name'] ?? ''}',
          completedOrders: i(m['completed_orders']),
          averageHours: dbl(m['average_hours']),
        ),
      ),
      ordersByType: list(
        d['orders_by_type'],
        (m) => ReportTypeCount(
          typeAr: '${m['type_ar'] ?? m['type'] ?? ''}',
          count: i(m['count']),
          percentage: i(m['percentage']),
        ),
      ),
    );
  }
}
