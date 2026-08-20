// ════════════════════════════════════════════════════════════════════════════
// lab_material_requests_cubit.dart
//
// Cubit لإدارة شاشة فواتير طلب المواد — تحميل + فلترة + إنشاء فاتورة جديدة.
// يطابق نمط بقية الـ Cubits (UI → Cubit → Repository).
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/lab_material_request.dart';
import '../../domain/repositories/lab_material_requests_repository.dart';
import 'lab_material_requests_state.dart';

/// Cubit إدارة فواتير طلب المواد من المستودع.
class LabMaterialRequestsCubit extends Cubit<LabMaterialRequestsState> {
  LabMaterialRequestsCubit({required LabMaterialRequestsRepository repository})
      : _repository = repository,
        super(const LabMaterialRequestsState.initial());

  final LabMaterialRequestsRepository _repository;
  StreamSubscription<List<MatRequest>>? _subscription;

  /// تحميل الفواتير. عند إعادة الزيارة يعرض الكاش فوراً (بلا شيمر) ثم يحدّث
  /// صامتاً (stale-while-revalidate)، ويشترك بالـ stream للتحديث التلقائي.
  Future<void> load() async {
    final cached = _repository.cached;
    if (cached != null) {
      emit(state.copyWith(
          status: LabMatRequestsStatus.loaded,
          requests: cached,
          clearError: true));
    } else {
      emit(state.copyWith(
          status: LabMatRequestsStatus.loading, clearError: true));
    }
    try {
      final requests = await _repository.getAll();
      emit(state.copyWith(
        status: LabMatRequestsStatus.loaded,
        requests: requests,
        clearError: true,
      ));
    } catch (e) {
      if (cached == null) {
        emit(state.copyWith(
          status: LabMatRequestsStatus.error,
          errorMessage: userMessageFromError(e),
        ));
      }
    }
    _subscription?.cancel();
    _subscription = _repository.watchAll().listen(
      (list) => emit(state.copyWith(requests: list)),
      onError: (Object e) => emit(state.copyWith(
        status: LabMatRequestsStatus.error,
        errorMessage: userMessageFromError(e),
      )),
    );

    await loadCatalog();
  }

  /// تحميل كتالوج مواد المستودع (لفورم "من المستودع"). فشله لا يكسر الصفحة —
  /// بس يظهر بـ catalogError كي تعرضه فورم "من المستودع" بوضوح مع زر إعادة
  /// محاولة، بدل الاختفاء الصامت.
  Future<void> loadCatalog() async {
    try {
      final catalog = await _repository.getWarehouseMaterials();
      emit(state.copyWith(catalog: catalog, clearCatalogError: true));
    } catch (e) {
      emit(state.copyWith(catalogError: userMessageFromError(e)));
    }
  }

  /// تغيير الفلتر النشط (0=الكل 1=جديد 2=تم التسليم 3=غير متوفر).
  void setFilter(int index) {
    if (index == state.filterIndex) return;
    emit(state.copyWith(filterIndex: index));
  }

  /// تحديث نص البحث المُوجَّه لهذه الصفحة.
  void setSearchQuery(String query) {
    if (query == state.searchQuery) return;
    emit(state.copyWith(searchQuery: query));
  }

  /// إرسال فاتورة من مواد كتالوج المستودع. يُرجع true عند النجاح.
  Future<bool> addRequestFromWarehouse({
    required List<({int materialId, int quantity, String? notes})> items,
    String? notes,
  }) async {
    try {
      await _repository.addRequestFromWarehouse(items: items, notes: notes);
      emit(state.copyWith(filterIndex: 0, clearError: true));
      return true;
    } catch (e) {
      emit(state.copyWith(errorMessage: userMessageFromError(e)));
      return false;
    }
  }

  /// إرسال فاتورة من مواد شركة خارجية. يُرجع true عند النجاح.
  Future<bool> addRequestFromCompany({
    required String companyName,
    required List<({String materialName, int quantity, String unit, String? reason})> items,
    String? notes,
  }) async {
    try {
      await _repository.addRequestFromCompany(
        companyName: companyName,
        items: items,
        notes: notes,
      );
      emit(state.copyWith(filterIndex: 0, clearError: true));
      return true;
    } catch (e) {
      emit(state.copyWith(errorMessage: userMessageFromError(e)));
      return false;
    }
  }

  /// حذف فاتورة (الـ stream يحدّث القائمة تلقائياً). يُرجع true عند النجاح.
  Future<bool> delete(String id) async {
    try {
      await _repository.delete(id);
      return true;
    } catch (e) {
      emit(state.copyWith(errorMessage: userMessageFromError(e)));
      return false;
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
