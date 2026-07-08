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
    this.errorMessage,
  });

  const LabMaterialRequestsState.initial()
      : status = LabMatRequestsStatus.loading,
        requests = const [],
        filterIndex = 0,
        catalog = const [],
        errorMessage = null;

  final LabMatRequestsStatus status;
  final List<MatRequest> requests;

  /// كتالوج مواد المستودع (لاختيار مادة موجودة في النموذج).
  final List<WarehouseMaterialRef> catalog;

  /// 0=الكل 1=جديد 2=تم التسليم 3=غير متوفر.
  final int filterIndex;
  final String? errorMessage;

  /// الطلبات بعد تطبيق الفلتر النشط.
  List<MatRequest> get filtered {
    switch (filterIndex) {
      case 1:
        return requests
            .where((r) => r.status == MatRequestStatus.newRequest)
            .toList(growable: false);
      case 2:
        return requests
            .where((r) => r.status == MatRequestStatus.delivered)
            .toList(growable: false);
      case 3:
        return requests
            .where((r) => r.status == MatRequestStatus.unavailable)
            .toList(growable: false);
      default:
        return requests;
    }
  }

  LabMaterialRequestsState copyWith({
    LabMatRequestsStatus? status,
    List<MatRequest>? requests,
    int? filterIndex,
    List<WarehouseMaterialRef>? catalog,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LabMaterialRequestsState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      filterIndex: filterIndex ?? this.filterIndex,
      catalog: catalog ?? this.catalog,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
