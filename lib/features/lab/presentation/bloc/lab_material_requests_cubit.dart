// ════════════════════════════════════════════════════════════════════════════
// lab_material_requests_cubit.dart
//
// Cubit لإدارة شاشة طلبات المواد — تحميل + فلترة + إرسال طلب جديد.
// يطابق نمط بقية الـ Cubits (UI → Cubit → Repository).
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/lab_material_request.dart';
import '../../domain/repositories/lab_material_requests_repository.dart';
import 'lab_material_requests_state.dart';

/// Cubit إدارة طلبات المواد من المستودع.
class LabMaterialRequestsCubit extends Cubit<LabMaterialRequestsState> {
  LabMaterialRequestsCubit({required LabMaterialRequestsRepository repository})
      : _repository = repository,
        super(const LabMaterialRequestsState.initial());

  final LabMaterialRequestsRepository _repository;
  StreamSubscription<List<MatRequest>>? _subscription;

  /// تحميل الطلبات. عند إعادة الزيارة يعرض الكاش فوراً (بلا شيمر) ثم يحدّث
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

    // كتالوج مواد المستودع (مرة) لاقتراحات النموذج — لا يحجب عرض الطلبات،
    // وفشله لا يكسر الصفحة (النموذج يعمل بالإدخال الحر بلا كتالوج).
    if (state.catalog.isEmpty) {
      try {
        final catalog = await _repository.getWarehouseMaterials();
        emit(state.copyWith(catalog: catalog));
      } catch (_) {/* تجاهل بصمت */}
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

  /// إرسال طلب مادة جديد؛ يُدرَج بأعلى القائمة ويُعاد الفلتر لـ "الكل".
  /// يُرجع true عند النجاح، أو false مع تعبئة errorMessage عند الفشل.
  Future<bool> addRequest({
    required String material,
    required String quantity,
    required String unit,
    int? materialId,
    String? company,
    String? reason,
  }) async {
    try {
      await _repository.addRequest(
        material: material,
        quantity: quantity,
        unit: unit,
        materialId: materialId,
        company: company,
        reason: reason,
      );
      emit(state.copyWith(filterIndex: 0, clearError: true)); // ليظهر الطلب الجديد مباشرة
      return true;
    } catch (e) {
      emit(state.copyWith(errorMessage: userMessageFromError(e)));
      return false;
    }
  }

  /// حذف طلب مواد (الـ stream يحدّث القائمة تلقائياً). يُرجع true عند النجاح.
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
