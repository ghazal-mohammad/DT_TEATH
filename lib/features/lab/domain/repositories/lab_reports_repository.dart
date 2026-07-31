// ════════════════════════════════════════════════════════════════════════════
// lab_reports_repository.dart
//
// عقد الوصول لتقرير المخبر التحليلي (reports). تنفيذ Remote يستبدل أي Mock.
// ════════════════════════════════════════════════════════════════════════════

import '../entities/lab_report.dart';

abstract class LabReportsRepository {
  /// يجلب تقرير الفترة المحدّدة. [date] اختياري (yyyy-MM-dd) — الباك يفترض اليوم.
  Future<LabReport> getReport(ReportPeriod period, {String? date});
}
