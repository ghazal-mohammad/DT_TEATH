// ════════════════════════════════════════════════════════════════════════════
// stock_cubit.dart
//
// Cubit إدارة مخزون مادة واحدة (الدفعات): تحميل التفاصيل، إضافة دفعة، تعديل كمية
// دفعة. بعد كل عملية ناجحة يُعيد تحميل التفاصيل ليعكس الحالة الجديدة.
// ════════════════════════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/material_stock.dart';
import '../../domain/repositories/warehouse_stock_repository.dart';

enum StockStatus { initial, loading, loaded, error }

class StockState extends Equatable {
  const StockState({
    this.status = StockStatus.initial,
    this.stock,
    this.busy = false,
    this.errorMessage,
    this.actionError,
  });

  final StockStatus status;
  final MaterialStock? stock;

  /// عملية كتابة (إضافة/تعديل) جارية.
  final bool busy;

  /// خطأ تحميل الصفحة.
  final String? errorMessage;

  /// خطأ آخر عملية كتابة (يُعرَض كتنبيه دون إخفاء القائمة).
  final String? actionError;

  StockState copyWith({
    StockStatus? status,
    MaterialStock? stock,
    bool? busy,
    String? errorMessage,
    String? actionError,
    bool clearActionError = false,
  }) {
    return StockState(
      status: status ?? this.status,
      stock: stock ?? this.stock,
      busy: busy ?? this.busy,
      errorMessage: errorMessage ?? this.errorMessage,
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props =>
      [status, stock, busy, errorMessage, actionError];
}

class StockCubit extends Cubit<StockState> {
  StockCubit(this._repo, this.materialId) : super(const StockState());

  final WarehouseStockRepository _repo;
  final String materialId;

  /// هل تغيّر المخزون خلال حياة هذا الكيوبت؟ (لتحديث قائمة المواد عند الإغلاق.)
  bool changed = false;

  Future<void> load() async {
    emit(state.copyWith(status: StockStatus.loading, clearActionError: true));
    try {
      final stock = await _repo.getStockDetails(materialId);
      emit(state.copyWith(status: StockStatus.loaded, stock: stock));
    } on Failure catch (f) {
      emit(state.copyWith(
          status: StockStatus.error, errorMessage: f.message));
    }
  }

  Future<bool> addBatch({
    required int quantity,
    DateTime? expiryDate,
    String? notes,
  }) async {
    return _run(() => _repo.addBatch(
          materialId: materialId,
          quantity: quantity,
          expiryDate: expiryDate,
          notes: notes,
        ));
  }

  Future<bool> adjustBatch({
    required String batchId,
    required bool isIn,
    required int quantity,
    required StockMovementReason reason,
    String? notes,
  }) async {
    return _run(() => _repo.adjustBatch(
          batchId: batchId,
          isIn: isIn,
          quantity: quantity,
          reason: reason,
          notes: notes,
        ));
  }

  /// ينفّذ عملية كتابة ثم يُعيد تحميل التفاصيل. يُرجع true عند النجاح.
  Future<bool> _run(Future<void> Function() action) async {
    emit(state.copyWith(busy: true, clearActionError: true));
    try {
      await action();
      changed = true;
      await load();
      emit(state.copyWith(busy: false));
      return true;
    } on Failure catch (f) {
      emit(state.copyWith(busy: false, actionError: f.message));
      return false;
    }
  }
}
