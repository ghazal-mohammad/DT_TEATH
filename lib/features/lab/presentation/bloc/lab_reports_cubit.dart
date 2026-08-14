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

  /// يجلب تقرير [period] عند تاريخ إرساء [anchorDate] (أو الحاليّين بالحالة
  /// لو لم يُمرَّرا). [anchorDate] = null ⇒ الباك يفترض اليوم (الفترة الحالية).
  /// يعرض شيمر أثناء التحميل.
  Future<void> load([ReportPeriod? period, DateTime? anchorDate]) async {
    final p = period ?? state.period;
    // بدون anchorDate صريح: نحافظ على تاريخ الإرساء الحالي بالحالة (قد يكون
    // null = اليوم، أو تاريخاً اختاره المستخدم سابقاً).
    final d = anchorDate ?? state.anchorDate;
    emit(state.copyWith(
      status: LabReportsStatus.loading,
      period: p,
      anchorDate: d,
      clearAnchorDate: d == null,
      clearError: true,
    ));
    try {
      final report =
          await _repository.getReport(p, date: d == null ? null : _ymd(d));
      emit(state.copyWith(status: LabReportsStatus.loaded, report: report));
    } catch (e) {
      emit(state.copyWith(
        status: LabReportsStatus.error,
        errorMessage: userMessageFromError(e),
      ));
    }
  }

  /// تغيير الفترة (شهري/أسبوعي/يومي/سنوي) وإعادة الجلب (يحافظ على تاريخ
  /// الإرساء الحالي).
  void setPeriod(ReportPeriod period) {
    if (period == state.period && state.status == LabReportsStatus.loaded) {
      return;
    }
    load(period);
  }

  /// ينتقل لتاريخ إرساء محدّد (null = اليوم) لنفس الفترة الحالية ويعيد الجلب.
  void setAnchorDate(DateTime? date) => load(state.period, date);

  /// الفترة السابقة (شهر/أسبوع/يوم/سنة سابقة حسب [LabReportsState.period]).
  void previousPeriod() => setAnchorDate(_shiftAnchor(-1));

  /// الفترة التالية — لا تتجاوز اليوم (لا تقارير مستقبلية).
  void nextPeriod() {
    final next = _shiftAnchor(1);
    final today = _todayOnly();
    if (!next.isBefore(today)) {
      setAnchorDate(null); // رجوع لـ"اليوم" (السلوك الافتراضي).
    } else {
      setAnchorDate(next);
    }
  }

  /// رجوع فوري لتقرير الفترة الحالية (اليوم).
  void resetToToday() => setAnchorDate(null);

  DateTime get _effectiveAnchor => state.anchorDate ?? DateTime.now();

  DateTime _todayOnly() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _shiftAnchor(int direction) {
    final a = _effectiveAnchor;
    switch (state.period) {
      case ReportPeriod.daily:
        return a.add(Duration(days: direction));
      case ReportPeriod.weekly:
        return a.add(Duration(days: 7 * direction));
      case ReportPeriod.monthly:
        return DateTime(a.year, a.month + direction, a.day);
      case ReportPeriod.yearly:
        return DateTime(a.year + direction, a.month, a.day);
    }
  }

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
