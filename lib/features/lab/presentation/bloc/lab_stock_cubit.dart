// ════════════════════════════════════════════════════════════════════════════
// lab_stock_cubit.dart
//
// Cubit لإدارة شاشة مخزون المخبر — تحميل + فلترة/بحث + إضافة/خصم كمية.
// يطابق نمط بقية الـ Cubits (UI → Cubit → Repository → Remote).
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/lab_stock.dart';
import '../../domain/repositories/lab_stock_repository.dart';
import 'lab_stock_state.dart';

/// Cubit إدارة مخزون المخبر.
class LabStockCubit extends Cubit<LabStockState> {
  LabStockCubit({required LabStockRepository repository})
      : _repository = repository,
        super(const LabStockState.initial());

  final LabStockRepository _repository;
  StreamSubscription<List<LabStock>>? _subscription;

  /// تحميل المخزون والاشتراك بالـ stream للتحديث التلقائي.
  Future<void> load() async {
    emit(state.copyWith(status: LabStockStatusPhase.loading, clearError: true));
    try {
      final items = await _repository.getAll();
      emit(state.copyWith(
        status: LabStockStatusPhase.loaded,
        items: items,
        clearError: true,
      ));
      _subscription?.cancel();
      _subscription = _repository.watchAll().listen(
        (list) => emit(state.copyWith(items: list)),
        onError: (Object e) => emit(state.copyWith(
          status: LabStockStatusPhase.error,
          errorMessage: e.toString(),
        )),
      );
    } on Failure catch (f) {
      emit(state.copyWith(
          status: LabStockStatusPhase.error, errorMessage: f.message));
    } catch (e) {
      emit(state.copyWith(
          status: LabStockStatusPhase.error, errorMessage: e.toString()));
    }
  }

  /// تغيير فلتر الحالة.
  void setFilter(LabStockFilter filter) {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter));
  }

  /// تحديث نص البحث.
  void setSearchQuery(String query) {
    if (query == state.searchQuery) return;
    emit(state.copyWith(searchQuery: query));
  }

  /// إضافة كمية لمادة (الـ stream يحدّث القائمة تلقائياً بعد إعادة الجلب).
  /// يرجّع رسالة الخطأ عند الفشل (للعرض)، أو null عند النجاح.
  Future<String?> addQuantity(String id, double quantity, {String? notes}) =>
      _run(() =>
          _repository.addQuantity(id: id, quantity: quantity, notes: notes));

  /// خصم كمية من مادة (تسجيل استهلاك). يرجّع رسالة الخطأ أو null عند النجاح.
  Future<String?> subtractQuantity(String id, double quantity,
          {String? notes}) =>
      _run(() => _repository.subtractQuantity(
          id: id, quantity: quantity, notes: notes));

  /// يشغّل عملية كتابة ويحوّل الفشل لرسالة عرضية دون كسر الـ state.
  Future<String?> _run(Future<void> Function() action) async {
    try {
      await action();
      return null;
    } on Failure catch (f) {
      return f.message;
    } catch (_) {
      return null; // الـ UI يعرض رسالة عامة عند null+فشل.
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
