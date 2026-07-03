// ════════════════════════════════════════════════════════════════════════════
// materials_cubit.dart
//
// Cubit لإدارة state صفحة Materials.
//
// 🎯 المسؤوليات:
//   1. تحميل المواد من الـ repository
//   2. تطبيق الفلتر النشط
//   3. تطبيق نص البحث (search)
//   4. عمليات CRUD (create, update, delete)
//   5. الـ loading / error states
//
// 🔮 قابلية التوسيع:
//   - أضف operation جديد = method جديد + emit جديد
//   - الـ filter + searchQuery منفصلين عن البيانات → سهل تركيب فلاتر
//   - الـ stream subscription auto-refreshes UI عند تغيير DB
//
// نمط معماري:
//   Cubit single-state — state واحد يحتوي كل المعلومات (data + filter + query).
//   استخدمنا Cubit (مش Bloc) لأن الأحداث بسيطة (لا نحتاج event sourcing).
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/material_filter.dart';
import '../../domain/entities/warehouse_material.dart';
import '../../domain/repositories/warehouse_materials_repository.dart';
import 'materials_state.dart';

/// Cubit لإدارة Materials Page.
class MaterialsCubit extends Cubit<MaterialsState> {
  MaterialsCubit({
    required WarehouseMaterialsRepository repository,
  })  : _repository = repository,
        super(const MaterialsState.initial());

  final WarehouseMaterialsRepository _repository;
  StreamSubscription<List<WarehouseMaterial>>? _subscription;

  // ────────────────────────────────────────────────────────────────────────
  //                              LOAD
  // ────────────────────────────────────────────────────────────────────────

  /// يبدأ تحميل المواد ويشترك بـ stream للتحديث التلقائي.
  Future<void> load() async {
    emit(state.copyWith(status: MaterialsStatus.loading, clearError: true));
    try {
      final materials = await _repository.getAll();
      emit(state.copyWith(
        status: MaterialsStatus.loaded,
        materials: materials,
        clearError: true,
      ));

      // اشتراك بالـ stream للتحديث التلقائي عند CRUD
      _subscription?.cancel();
      _subscription = _repository.watchAll().listen(
        (list) => emit(state.copyWith(materials: list)),
        onError: (Object error) => emit(
          state.copyWith(
            status: MaterialsStatus.error,
            errorMessage: error.toString(),
          ),
        ),
      );
    } catch (e) {
      emit(state.copyWith(
        status: MaterialsStatus.error,
        errorMessage: userMessageFromError(e),
      ));
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          FILTER & SEARCH
  // ────────────────────────────────────────────────────────────────────────

  /// تغيير الفلتر النشط.
  void setFilter(MaterialFilter filter) {
    if (filter == state.activeFilter) return;
    emit(state.copyWith(activeFilter: filter));
  }

  /// تحديث نص البحث (يُطبَّق فوق الفلتر الحالي).
  void setSearchQuery(String query) {
    if (query == state.searchQuery) return;
    emit(state.copyWith(searchQuery: query));
  }

  /// مسح البحث والفلتر.
  void clearFilters() {
    emit(state.copyWith(
      activeFilter: MaterialFilter.all,
      searchQuery: '',
    ));
  }

  // ────────────────────────────────────────────────────────────────────────
  //                              CRUD
  // ────────────────────────────────────────────────────────────────────────

  /// إنشاء مادة جديدة.
  Future<void> create(WarehouseMaterial material) async {
    try {
      await _repository.create(material);
      // الـ stream subscription بـ load() رح يحدّث الـ list تلقائياً
    } catch (e) {
      emit(state.copyWith(
        status: MaterialsStatus.error,
        errorMessage: userMessageFromError(e),
      ));
    }
  }

  /// تحديث مادة موجودة.
  Future<void> update(WarehouseMaterial material) async {
    try {
      await _repository.update(material);
    } catch (e) {
      emit(state.copyWith(
        status: MaterialsStatus.error,
        errorMessage: userMessageFromError(e),
      ));
    }
  }

  /// حذف مادة بالـ id.
  Future<void> delete(String id) async {
    try {
      await _repository.delete(id);
    } catch (e) {
      emit(state.copyWith(
        status: MaterialsStatus.error,
        errorMessage: userMessageFromError(e),
      ));
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  //                              CLEANUP
  // ────────────────────────────────────────────────────────────────────────

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
