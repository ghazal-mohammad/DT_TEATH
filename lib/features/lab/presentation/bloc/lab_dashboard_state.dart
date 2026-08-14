// ════════════════════════════════════════════════════════════════════════════
// lab_dashboard_state.dart
//
// State لوحة تحكم المخبر — عدّادات محسوبة من قائمة الطلبات الحقيقية المربوطة
// بالباك (بدل أرقام mock، وبدل عدّادات الباك التي ترجع أصفاراً).
// ════════════════════════════════════════════════════════════════════════════

import '../../domain/entities/lab_order.dart';

enum LabDashboardStatus { initial, loading, loaded, error }

class LabDashboardState {
  const LabDashboardState({
    required this.status,
    this.orders = const [],
    this.errorMessage,
    this.lastLoadedAt,
  });

  const LabDashboardState.initial()
      : status = LabDashboardStatus.initial,
        orders = const [],
        errorMessage = null,
        lastLoadedAt = null;

  final LabDashboardStatus status;
  final List<LabOrderFull> orders;
  final String? errorMessage;

  /// وقت آخر جلب ناجح للطلبات — تُستخدم لعرض "آخر تحديث" حقيقي بالـ hero
  /// (بدل نص ثابت). null قبل أول جلب ناجح.
  final DateTime? lastLoadedAt;

  // ── عدّادات مشتقّة من الطلبات الحقيقية ────────────────────────────────────
  int get total => orders.length;

  int get newOrders => orders
      .where((o) => o.statusVariant == LabOrderBadgeVariant.newOrder)
      .length;

  int get manufacturing => orders
      .where((o) => o.statusVariant == LabOrderBadgeVariant.manufacturing)
      .length;

  int get ready =>
      orders.where((o) => o.statusVariant == LabOrderBadgeVariant.ready).length;

  /// الطلبات التي موعد تسليمها اليوم (delivery_date_requested == تاريخ اليوم).
  List<LabOrderFull> get ordersDueToday {
    final now = DateTime.now();
    final today = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    return orders.where((o) => o.date == today).toList();
  }

  int get dueToday => ordersDueToday.length;

  bool get isInitialLoading =>
      status == LabDashboardStatus.loading && orders.isEmpty;

  LabDashboardState copyWith({
    LabDashboardStatus? status,
    List<LabOrderFull>? orders,
    String? errorMessage,
    bool clearError = false,
    DateTime? lastLoadedAt,
  }) {
    return LabDashboardState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastLoadedAt: lastLoadedAt ?? this.lastLoadedAt,
    );
  }
}
