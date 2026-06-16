// ════════════════════════════════════════════════════════════════════════════
// lab_orders_state.dart
//
// State غير قابل للتغيير لـ LabOrdersCubit (single-state). يحتوي مرحلة التحميل +
// الطلبات الخام + الفلتر النشط، مع القائمة المُفلترة والعدّادات (computed).
// ════════════════════════════════════════════════════════════════════════════

import '../../domain/entities/lab_order.dart';

enum LabOrdersStatus { initial, loading, loaded, error }

/// State كامل لصفحة طلبات الأطباء.
class LabOrdersState {
  const LabOrdersState({
    required this.status,
    required this.orders,
    required this.filter,
    this.errorMessage,
  });

  const LabOrdersState.initial()
      : status = LabOrdersStatus.initial,
        orders = const [],
        filter = 'all',
        errorMessage = null;

  final LabOrdersStatus status;
  final List<LabOrderFull> orders;

  /// الفلتر النشط: all | urgent | new | manufacturing | ready.
  final String filter;
  final String? errorMessage;

  /// الطلبات بعد تطبيق الفلتر النشط.
  List<LabOrderFull> get filtered {
    switch (filter) {
      case 'urgent':
        return orders.where((o) => o.isUrgent).toList(growable: false);
      case 'new':
        return orders
            .where((o) => o.statusVariant == LabOrderBadgeVariant.newOrder)
            .toList(growable: false);
      case 'manufacturing':
        return orders
            .where(
                (o) => o.statusVariant == LabOrderBadgeVariant.manufacturing)
            .toList(growable: false);
      case 'ready':
        return orders
            .where((o) => o.statusVariant == LabOrderBadgeVariant.ready)
            .toList(growable: false);
      default:
        return orders;
    }
  }

  int get total => orders.length;
  int get urgentCount => orders.where((o) => o.isUrgent).length;
  int get newCount =>
      orders.where((o) => o.statusVariant == LabOrderBadgeVariant.newOrder).length;
  int get mfgCount => orders
      .where((o) => o.statusVariant == LabOrderBadgeVariant.manufacturing)
      .length;
  int get readyCount =>
      orders.where((o) => o.statusVariant == LabOrderBadgeVariant.ready).length;

  LabOrdersState copyWith({
    LabOrdersStatus? status,
    List<LabOrderFull>? orders,
    String? filter,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LabOrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      filter: filter ?? this.filter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
