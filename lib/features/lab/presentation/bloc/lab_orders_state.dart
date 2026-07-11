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
    this.todayOnly = false,
    this.todayOrders = const [],
    this.errorMessage,
  });

  const LabOrdersState.initial()
      : status = LabOrdersStatus.initial,
        orders = const [],
        filter = 'all',
        todayOnly = false,
        todayOrders = const [],
        errorMessage = null;

  final LabOrdersStatus status;
  final List<LabOrderFull> orders;

  /// وضع "طلبات اليوم" (showAllTodayLabOrders) — يعرض [todayOrders] بدل [orders].
  final bool todayOnly;
  final List<LabOrderFull> todayOrders;

  /// الفلتر النشط: all | urgent | new | manufacturing | ready.
  final String filter;
  final String? errorMessage;

  /// المصدر النشط حسب وضع اليوم.
  List<LabOrderFull> get _source => todayOnly ? todayOrders : orders;

  /// الطلبات بعد تطبيق الفلتر النشط (على المصدر النشط).
  List<LabOrderFull> get filtered {
    final src = _source;
    switch (filter) {
      case 'urgent':
        return src.where((o) => o.isUrgent).toList(growable: false);
      case 'new':
        return src
            .where((o) => o.statusVariant == LabOrderBadgeVariant.newOrder)
            .toList(growable: false);
      case 'manufacturing':
        return src
            .where(
                (o) => o.statusVariant == LabOrderBadgeVariant.manufacturing)
            .toList(growable: false);
      case 'ready':
        return src
            .where((o) => o.statusVariant == LabOrderBadgeVariant.ready)
            .toList(growable: false);
      default:
        return src;
    }
  }

  int get total => _source.length;
  int get urgentCount => _source.where((o) => o.isUrgent).length;
  int get newCount => _source
      .where((o) => o.statusVariant == LabOrderBadgeVariant.newOrder)
      .length;
  int get mfgCount => _source
      .where((o) => o.statusVariant == LabOrderBadgeVariant.manufacturing)
      .length;
  int get readyCount => _source
      .where((o) => o.statusVariant == LabOrderBadgeVariant.ready)
      .length;

  LabOrdersState copyWith({
    LabOrdersStatus? status,
    List<LabOrderFull>? orders,
    String? filter,
    bool? todayOnly,
    List<LabOrderFull>? todayOrders,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LabOrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      filter: filter ?? this.filter,
      todayOnly: todayOnly ?? this.todayOnly,
      todayOrders: todayOrders ?? this.todayOrders,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
