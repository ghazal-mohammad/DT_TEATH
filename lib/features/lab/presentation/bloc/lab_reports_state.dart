// ════════════════════════════════════════════════════════════════════════════
// lab_reports_state.dart — State لـ LabReportsCubit (فترة + تقرير + مرحلة).
// ════════════════════════════════════════════════════════════════════════════

import '../../domain/entities/lab_report.dart';

enum LabReportsStatus { loading, loaded, error }

class LabReportsState {
  const LabReportsState({
    required this.status,
    required this.period,
    this.report,
    this.errorMessage,
  });

  const LabReportsState.initial()
      : status = LabReportsStatus.loading,
        period = ReportPeriod.monthly,
        report = null,
        errorMessage = null;

  final LabReportsStatus status;
  final ReportPeriod period;
  final LabReport? report;
  final String? errorMessage;

  LabReportsState copyWith({
    LabReportsStatus? status,
    ReportPeriod? period,
    LabReport? report,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LabReportsState(
      status: status ?? this.status,
      period: period ?? this.period,
      report: report ?? this.report,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
