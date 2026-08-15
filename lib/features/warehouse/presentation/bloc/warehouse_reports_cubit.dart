// ════════════════════════════════════════════════════════════════════════════
// warehouse_reports_cubit.dart
//
// Cubit تقرير مشتريات المستودع: يختار الفترة (شهري/أسبوعي/يومي/سنوي)، يحوّلها
// لنطاق from–to، ويحمّل التقرير. يوافق فترات ReportsView (0..3).
// ════════════════════════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/warehouse_material_requests_report.dart';
import '../../domain/entities/warehouse_purchases_report.dart';
import '../../domain/entities/warehouse_stock_movement_report.dart';
import '../../domain/repositories/warehouse_reports_repository.dart';

enum ReportsStatus { initial, loading, loaded, error }

class WarehouseReportsState extends Equatable {
  const WarehouseReportsState({
    this.status = ReportsStatus.initial,
    this.report,
    this.period = 0,
    this.errorMessage,
    this.stockMovementReport,
    this.stockMovementError,
    this.materialRequestsReport,
    this.materialRequestsError,
  });

  final ReportsStatus status;
  final WarehousePurchasesReport? report;

  /// 0=شهري · 1=أسبوعي · 2=يومي · 3=سنوي (يوافق ReportsView).
  final int period;
  final String? errorMessage;

  /// تبويب حركة المخزون (stock-movement) — تحميل مستقل عن تبويب المشتريات.
  final WarehouseStockMovementReport? stockMovementReport;
  final String? stockMovementError;

  /// تبويب طلبات المواد (material-requests) — تحميل مستقل عن تبويب المشتريات.
  final WarehouseMaterialRequestsReport? materialRequestsReport;
  final String? materialRequestsError;

  WarehouseReportsState copyWith({
    ReportsStatus? status,
    WarehousePurchasesReport? report,
    int? period,
    String? errorMessage,
    WarehouseStockMovementReport? stockMovementReport,
    String? stockMovementError,
    WarehouseMaterialRequestsReport? materialRequestsReport,
    String? materialRequestsError,
  }) =>
      WarehouseReportsState(
        status: status ?? this.status,
        report: report ?? this.report,
        period: period ?? this.period,
        errorMessage: errorMessage ?? this.errorMessage,
        stockMovementReport: stockMovementReport ?? this.stockMovementReport,
        stockMovementError: stockMovementError ?? this.stockMovementError,
        materialRequestsReport:
            materialRequestsReport ?? this.materialRequestsReport,
        materialRequestsError:
            materialRequestsError ?? this.materialRequestsError,
      );

  @override
  List<Object?> get props => [
        status,
        report,
        period,
        errorMessage,
        stockMovementReport,
        stockMovementError,
        materialRequestsReport,
        materialRequestsError,
      ];
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

  /// تبويب حركة المخزون — يستخدم نفس نطاق الفترة الحالية (state.period).
  Future<void> loadStockMovement() async {
    final (from, to) = _range(state.period);
    try {
      final report = await _repo.getStockMovementReport(from: from, to: to);
      emit(state.copyWith(stockMovementReport: report));
    } on Failure catch (f) {
      emit(state.copyWith(stockMovementError: f.message));
    }
  }

  /// تبويب طلبات المواد — يستخدم نفس نطاق الفترة الحالية (state.period).
  Future<void> loadMaterialRequests() async {
    final (from, to) = _range(state.period);
    try {
      final report = await _repo.getMaterialRequestsReport(from: from, to: to);
      emit(state.copyWith(materialRequestsReport: report));
    } on Failure catch (f) {
      emit(state.copyWith(materialRequestsError: f.message));
    }
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
