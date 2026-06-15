// ════════════════════════════════════════════════════════════════════════════
// lab_products_cubit.dart
//
// Cubit لإدارة state صفحة منتجات المخبر — يطابق نمط MaterialsCubit.
// المسؤوليات: تحميل الكتالوج، البحث، إنشاء/تعديل منتج، الاشتراك بالـ stream.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/lab_product.dart';
import '../../domain/repositories/lab_products_repository.dart';
import 'lab_products_state.dart';

/// Cubit لإدارة صفحة منتجات المخبر.
class LabProductsCubit extends Cubit<LabProductsState> {
  LabProductsCubit({required LabProductsRepository repository})
      : _repository = repository,
        super(const LabProductsState.initial());

  final LabProductsRepository _repository;
  StreamSubscription<List<LabProduct>>? _subscription;

  /// يبدأ تحميل الكتالوج ويشترك بالـ stream للتحديث التلقائي.
  Future<void> load() async {
    emit(state.copyWith(status: LabProductsStatus.loading, clearError: true));
    try {
      final products = await _repository.getAll();
      emit(state.copyWith(
        status: LabProductsStatus.loaded,
        products: products,
        clearError: true,
      ));
      _subscription?.cancel();
      _subscription = _repository.watchAll().listen(
        (list) => emit(state.copyWith(products: list)),
        onError: (Object e) => emit(state.copyWith(
          status: LabProductsStatus.error,
          errorMessage: e.toString(),
        )),
      );
    } catch (e) {
      emit(state.copyWith(
        status: LabProductsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// تحديث نص البحث.
  void setSearchQuery(String query) {
    if (query == state.searchQuery) return;
    emit(state.copyWith(searchQuery: query));
  }

  /// إنشاء منتج جديد (الـ stream يحدّث القائمة تلقائياً).
  Future<void> create(LabProduct product) async {
    try {
      await _repository.create(product);
    } catch (e) {
      emit(state.copyWith(
        status: LabProductsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// تحديث منتج موجود.
  Future<void> update(LabProduct product) async {
    try {
      await _repository.update(product);
    } catch (e) {
      emit(state.copyWith(
        status: LabProductsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
