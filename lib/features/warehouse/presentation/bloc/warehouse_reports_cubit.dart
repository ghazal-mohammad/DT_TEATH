// ════════════════════════════════════════════════════════════════════════════
// warehouse_reports_cubit.dart
//
// Cubit تقرير مشتريات المستودع: يختار الفترة (شهري/أسبوعي/يومي/سنوي)، يحوّلها
// لنطاق from–to، ويحمّل التقرير. يوافق فترات ReportsView (0..3).
// ════════════════════════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/warehouse_purchases_report.dart';
import '../../domain/repositories/warehouse_reports_repository.dart';

enum ReportsStatus { initial, loading, loaded, error }

class WarehouseReportsState extends Equatable {
  const WarehouseReportsState({
    this.status = ReportsStatus.initial,
    this.report,
    this.period = 0,
    this.errorMessage,
  });

  final ReportsStatus status;
  final WarehousePurchasesReport? report;

  /// 0=شهري · 1=أسبوعي · 2=يومي · 3=سنوي (يوافق ReportsView).
  final int period;
  final String? errorMessage;

  WarehouseReportsState copyWith({
    ReportsStatus? status,
    WarehousePurchasesReport? report,
    int? period,
    String? errorMessage,
  }) =>
      WarehouseReportsState(
        status: status ?? this.status,
        report: report ?? this.report,
        period: period ?? this.period,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, report, period, errorMessage];
}

class WarehouseReportsCubit extends Cubit<WarehouseReportsState> {
  WarehouseReportsCubit(this._repo) : super(const WarehouseReportsState());

  final WarehouseReportsRepository _repo;

  Future<void> load([int? period]) async {
    final p = period ?? state.period;
    emit(state.copyWith(status: ReportsStatus.loading, period: p));
    final (from, to) = _range(p);
    try {
      final report = await _repo.getPurchasesReport(from: from, to: to);
      emit(state.copyWith(status: ReportsStatus.loaded, report: report));
    } on Failure catch (f) {
      emit(state.copyWith(
          status: ReportsStatus.error, errorMessage: f.message));
    }
  }

  void changePeriod(int period) {
    if (period == state.period) return;
    load(period);
  }

  /// يحوّل مؤشّر الفترة إلى نطاق (from, to).
  (DateTime, DateTime) _range(int period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (period) {
      case 1: // أسبوعي — آخر 7 أيام.
        return (today.subtract(const Duration(days: 6)), today);
      case 2: // يومي — اليوم.
        return (today, today);
      case 3: // سنوي — من بداية السنة.
        return (DateTime(now.year, 1, 1), today);
      case 0: // شهري — من بداية الشهر.
      default:
        return (DateTime(now.year, now.month, 1), today);
    }
  }
}
