// ════════════════════════════════════════════════════════════════════════════
// inventory_cubit.dart
//
// Cubit مؤشّرات المخزون للوحة المستودع: يحمّل الملخّص مرّة عند فتح اللوحة.
// عند الفشل تبقى البطاقات بلا قيم حيّة (تعرض placeholder) دون كسر اللوحة.
// ════════════════════════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/inventory_summary.dart';
import '../../domain/repositories/warehouse_inventory_repository.dart';

enum InventoryStatus { initial, loading, loaded, error }

class InventoryState extends Equatable {
  const InventoryState({
    this.status = InventoryStatus.initial,
    this.summary,
    this.lastLoadedAt,
  });

  final InventoryStatus status;
  final InventorySummary? summary;

  /// وقت آخر تحميل ناجح فعلي — لعرض "آخر تحديث" حقيقي بهيرو اللوحة (لا نص
  /// ثابت)، بنفس اتفاقية LabDashboardState.lastLoadedAt.
  final DateTime? lastLoadedAt;

  InventoryState copyWith({
    InventoryStatus? status,
    InventorySummary? summary,
    DateTime? lastLoadedAt,
  }) =>
      InventoryState(
        status: status ?? this.status,
        summary: summary ?? this.summary,
        lastLoadedAt: lastLoadedAt ?? this.lastLoadedAt,
      );

  @override
  List<Object?> get props => [status, summary, lastLoadedAt];
}

class InventoryCubit extends Cubit<InventoryState> {
  InventoryCubit(this._repo) : super(const InventoryState());

  final WarehouseInventoryRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(status: InventoryStatus.loading));
    try {
      final summary = await _repo.getSummary();
      emit(state.copyWith(
        status: InventoryStatus.loaded,
        summary: summary,
        lastLoadedAt: DateTime.now(),
      ));
    } on Failure {
      emit(state.copyWith(status: InventoryStatus.error));
    }
  }
}
