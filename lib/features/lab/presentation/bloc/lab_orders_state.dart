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
    this.searchQuery = '',
    this.errorMessage,
  });

  const LabOrdersState.initial()
      : status = LabOrdersStatus.initial,
        orders = const [],
        filter = 'all',
        todayOnly = false,
        todayOrders = const [],
        searchQuery = '',
        errorMessage = null;

  final LabOrdersStatus status;
  final List<LabOrderFull> orders;

  /// وضع "طلبات اليوم" (showAllTodayLabOrders) — يعرض [todayOrders] بدل [orders].
  final bool todayOnly;
  final List<LabOrderFull> todayOrders;

  /// الفلتر النشط: all | urgent | new | manufacturing | ready.
  final String filter;

  /// نص البحث المُوجَّه (رقم الطلب/الطبيب/النوع/المادة).
  final String searchQuery;
  final String? errorMessage;

  /// المصدر النشط حسب وضع اليوم.
  List<LabOrderFull> get _source => todayOnly ? todayOrders : orders;

  /// الطلبات بعد تطبيق فلتر الحالة + نص البحث (على المصدر النشط).
  List<LabOrderFull> get filtered {
    Iterable<LabOrderFull> src = _source;
    switch (filter) {
      case 'urgent':
        src = src.where((o) => o.isUrgent);
      case 'new':
        src = src.where((o) => o.statusVariant == LabOrderBadgeVariant.newOrder);
      case 'manufacturing':
        src = src
            .where((o) => o.statusVariant == LabOrderBadgeVariant.manufacturing);
      case 'ready':
        src = src.where((o) => o.statusVariant == LabOrderBadgeVariant.ready);
    }
    final q = searchQuery.trim();
    if (q.isNotEmpty) {
      src = src.where((o) =>
          o.id.contains(q) ||
          o.doctor.contains(q) ||
          o.type.contains(q) ||
          o.material.contains(q));
    }
    return src.toList(growable: false);
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
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LabOrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      filter: filter ?? this.filter,
      todayOnly: todayOnly ?? this.todayOnly,
      todayOrders: todayOrders ?? this.todayOrders,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
