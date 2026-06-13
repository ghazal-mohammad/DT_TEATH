// ════════════════════════════════════════════════════════════════════════════
// lab_reports_mock_data.dart
//
// بيانات تقرير المخبر الوهمية (مارس 2026) — مُستخرَجة من lab_reports_page.dart
// ضمن تقسيم الصفحات العملاقة. تبقى const حتى ربط الباك.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// بيانات التقرير الشهري (مارس 2026).
class LabReportsMockData {
  const LabReportsMockData._();

  static const int totalOrders = 83;
  static const int completedOnTime = 79;
  static const String avgTime = '2.4h';
  static const String satisfactionRate = '96%';
  static const String periodLabel = '📅 مارس 2026 — التقرير الشهري';

  // Donut chart - الطلبات حسب النوع
  static const List<LabChartSegment> chartSegments = [
    LabChartSegment(label: 'تلبيسات', percentage: 55, count: 46, color: AppColors.statusProgress),
    LabChartSegment(label: 'جسور', percentage: 30, count: 25, color: AppColors.statusInfo),
    LabChartSegment(label: 'أخرى', percentage: 15, count: 12, color: AppColors.dashGreen),
  ];

  // أداء الفريق
  static const List<LabTeamPerf> teamPerformance = [
    LabTeamPerf(name: 'محمد علي', ordersCount: 34, avgTime: '2.1h', progress: 0.85, color1: AppColors.primary, color2: AppColors.statusInfo),
    LabTeamPerf(name: 'سامر حسن', ordersCount: 28, avgTime: '2.6h', progress: 0.70, color1: AppColors.statusProgress, color2: AppColors.progressSoft),
    LabTeamPerf(name: 'ليلى كريم', ordersCount: 21, avgTime: '2.8h', progress: 0.52, color1: AppColors.dashGreen, color2: AppColors.successSoft),
  ];

  // بيانات التقويم - عدد الطلبات لكل يوم
  static const List<int?> calendarData = [
    null, null, null, null, null, null, 1, // أسبوع 1
    2, 4, 3, 5, 3, 2, null,               // أسبوع 2
    null, 3, 4, 12, 5, 3, 2,              // أسبوع 3
    1, 4, 5, 3, 7, 3, null,               // أسبوع 4
    null, 3, null, null, null, null, null, // أسبوع 5
  ];
}

/// شريحة في مخطط الدونات (نوع طلب + نسبته).
class LabChartSegment {
  const LabChartSegment({
    required this.label,
    required this.percentage,
    required this.count,
    required this.color,
  });
  final String label;
  final int percentage;
  final int count;
  final Color color;
}

/// أداء مخبري واحد ضمن قسم "أداء الفريق".
class LabTeamPerf {
  const LabTeamPerf({
    required this.name,
    required this.ordersCount,
    required this.avgTime,
    required this.progress,
    required this.color1,
    required this.color2,
  });
  final String name;
  final int ordersCount;
  final String avgTime;
  final double progress;
  final Color color1;
  final Color color2;
}
