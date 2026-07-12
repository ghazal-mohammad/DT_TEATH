// ════════════════════════════════════════════════════════════════════════════
// lab_material_requests_state.dart
//
// State لـ LabMaterialRequestsCubit: مرحلة التحميل + الطلبات + الفلتر النشط.
// القائمة المُفلترة computed.
// ════════════════════════════════════════════════════════════════════════════

import '../../domain/entities/lab_material_request.dart';
import '../../domain/entities/warehouse_material_ref.dart';

enum LabMatRequestsStatus { loading, loaded, error }

/// State كامل لصفحة طلبات المواد.
class LabMaterialRequestsState {
  const LabMaterialRequestsState({
    required this.status,
    required this.requests,
    required this.filterIndex,
    this.catalog = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  const LabMaterialRequestsState.initial()
      : status = LabMatRequestsStatus.loading,
        requests = const [],
        filterIndex = 0,
        catalog = const [],
        searchQuery = '',
        errorMessage = null;

  final LabMatRequestsStatus status;
  final List<MatRequest> requests;

  /// كتالوج مواد المستودع (لاختيار مادة موجودة في النموذج).
  final List<WarehouseMaterialRef> catalog;

  /// 0=الكل 1=جديد 2=تم التسليم 3=غير متوفر.
  final int filterIndex;

  /// نص البحث المُوجَّه لهذه الصفحة (يفلتر بالمادة/المعرّف/الشركة).
  final String searchQuery;
  final String? errorMessage;

  /// الطلبات بعد تطبيق فلتر الحالة + نص البحث.
  List<MatRequest> get filtered {
    Iterable<MatRequest> list = requests;
    switch (filterIndex) {
      case 1:
        list = list.where((r) => r.status == MatRequestStatus.newRequest);
      case 2:
        list = list.where((r) => r.status == MatRequestStatus.delivered);
      case 3:
        list = list.where((r) => r.status == MatRequestStatus.unavailable);
    }
    final q = searchQuery.trim();
    if (q.isNotEmpty) {
      list = list.where((r) =>
          r.material.contains(q) ||
          r.id.contains(q) ||
          (r.company?.contains(q) ?? false));
    }
    return list.toList(growable: false);
  }

  LabMaterialRequestsState copyWith({
    LabMatRequestsStatus? status,
    List<MatRequest>? requests,
    int? filterIndex,
    List<WarehouseMaterialRef>? catalog,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LabMaterialRequestsState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      filterIndex: filterIndex ?? this.filterIndex,
      catalog: catalog ?? this.catalog,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
