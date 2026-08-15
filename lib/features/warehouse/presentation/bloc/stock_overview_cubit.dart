// ════════════════════════════════════════════════════════════════════════════
// stock_overview_cubit.dart
//
// Cubit نظرة عامة على مخزون كل المواد (showAllStock) + سجل حركة المخزون
// (showStockLogs) بفلتر مادة اختياري. منفصل عن StockCubit (يدير مادة واحدة).
// ════════════════════════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/stock_overview.dart';
import '../../domain/repositories/warehouse_stock_repository.dart';

enum StockOverviewStatus { initial, loading, loaded, error }

class StockOverviewState extends Equatable {
  const StockOverviewState({
    this.status = StockOverviewStatus.initial,
    this.overview = const [],
    this.logs = const [],
    this.logsFilterMaterialId,
    this.errorMessage,
  });

  final StockOverviewStatus status;
  final List<StockOverviewItem> overview;
  final List<StockLogEntry> logs;

  /// null = بلا فلتر (كل المواد).
  final String? logsFilterMaterialId;
  final String? errorMessage;

  StockOverviewState copyWith({
    StockOverviewStatus? status,
    List<StockOverviewItem>? overview,
    List<StockLogEntry>? logs,
    String? logsFilterMaterialId,
    bool clearLogsFilter = false,
    String? errorMessage,
  }) {
    return StockOverviewState(
      status: status ?? this.status,
      overview: overview ?? this.overview,
      logs: logs ?? this.logs,
      logsFilterMaterialId: clearLogsFilter
          ? null
          : (logsFilterMaterialId ?? this.logsFilterMaterialId),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, overview, logs, logsFilterMaterialId, errorMessage];
}

class StockOverviewCubit extends Cubit<StockOverviewState> {
  StockOverviewCubit(this._repo) : super(const StockOverviewState());

  final WarehouseStockRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(status: StockOverviewStatus.loading));
    try {
      final overview = await _repo.getAllStock();
      final logs =
          await _repo.getLogs(materialId: state.logsFilterMaterialId);
      emit(state.copyWith(
        status: StockOverviewStatus.loaded,
        overview: overview,
        logs: logs,
      ));
    } on Failure catch (f) {
      emit(state.copyWith(
          status: StockOverviewStatus.error, errorMessage: f.message));
    }
  }

  /// يصفّي السجل بمادة محدّدة (null ⇒ يلغي الفلتر) ويعيد تحميله فقط.
  Future<void> setLogsFilter(String? materialId) async {
    emit(state.copyWith(
      logsFilterMaterialId: materialId,
      clearLogsFilter: materialId == null,
    ));
    try {
      final logs = await _repo.getLogs(materialId: materialId);
      emit(state.copyWith(logs: logs));
    } on Failure catch (f) {
      emit(state.copyWith(errorMessage: f.message));
    }
  }
}
