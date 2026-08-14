// ════════════════════════════════════════════════════════════════════════════
// lab_reports_state.dart — State لـ LabReportsCubit (فترة + تقرير + مرحلة).
// ════════════════════════════════════════════════════════════════════════════

import '../../domain/entities/lab_report.dart';

enum LabReportsStatus { loading, loaded, error }

class LabReportsState {
  const LabReportsState({
    required this.status,
    required this.period,
    this.anchorDate,
    this.report,
    this.errorMessage,
  });

  const LabReportsState.initial()
      : status = LabReportsStatus.loading,
        period = ReportPeriod.monthly,
        anchorDate = null,
        report = null,
        errorMessage = null;

  final LabReportsStatus status;
  final ReportPeriod period;

  /// تاريخ إرساء الفترة المُرسَل للباك (`date`). null = اليوم (السلوك
  /// الافتراضي: "شهري" يعني الشهر الحالي، إلخ) — بلا تغيير عن السابق.
  final DateTime? anchorDate;
  final LabReport? report;
  final String? errorMessage;

  LabReportsState copyWith({
    LabReportsStatus? status,
    ReportPeriod? period,
    DateTime? anchorDate,
    bool clearAnchorDate = false,
    LabReport? report,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LabReportsState(
      status: status ?? this.status,
      period: period ?? this.period,
      anchorDate:
          clearAnchorDate ? null : (anchorDate ?? this.anchorDate),
      report: report ?? this.report,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
