// ════════════════════════════════════════════════════════════════════════════
// lab_reports_cubit.dart — يجلب تقرير المخبر للفترة المختارة (reports).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/lab_report.dart';
import '../../domain/repositories/lab_reports_repository.dart';
import 'lab_reports_state.dart';

class LabReportsCubit extends Cubit<LabReportsState> {
  LabReportsCubit({required LabReportsRepository repository})
      : _repository = repository,
        super(const LabReportsState.initial());

  final LabReportsRepository _repository;

  /// يجلب تقرير [period] (أو الفترة الحالية). يعرض شيمر أثناء التحميل.
  Future<void> load([ReportPeriod? period]) async {
    final p = period ?? state.period;
    emit(state.copyWith(
        status: LabReportsStatus.loading, period: p, clearError: true));
    try {
      final report = await _repository.getReport(p);
      emit(state.copyWith(status: LabReportsStatus.loaded, report: report));
    } catch (e) {
      emit(state.copyWith(
        status: LabReportsStatus.error,
        errorMessage: userMessageFromError(e),
      ));
    }
  }

  /// تغيير الفترة (شهري/أسبوعي/يومي/سنوي) وإعادة الجلب.
  void setPeriod(ReportPeriod period) {
    if (period == state.period && state.status == LabReportsStatus.loaded) {
      return;
    }
    load(period);
  }
}
