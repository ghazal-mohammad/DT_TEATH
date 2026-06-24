// ════════════════════════════════════════════════════════════════════════════
// lab_stock_state.dart
//
// State غير قابل للتغيير لـ LabStockCubit (single-state، يطابق نمط بقية المخبر).
// يحتوي: مرحلة التحميل + المخزون الخام + الفلتر + البحث + القائمة المُفلترة.
// ملاحظة: الفلترة بالحالة (الكل/منخفض/نافد) لأن الباك لا يصنّف مخزون المخبر بفئات.
// ════════════════════════════════════════════════════════════════════════════

import '../../domain/entities/lab_stock.dart';

enum LabStockStatusPhase { initial, loading, loaded, error }

/// فلتر مخزون المخبر — حسب الحالة (متوفّر فعلياً من الباك).
enum LabStockFilter { all, low, out }

class LabStockState {
  const LabStockState({
    required this.status,
    required this.items,
    required this.filter,
    required this.searchQuery,
    this.errorMessage,
  });

  const LabStockState.initial()
      : status = LabStockStatusPhase.initial,
        items = const [],
        filter = LabStockFilter.all,
        searchQuery = '',
        errorMessage = null;

  final LabStockStatusPhase status;
  final List<LabStock> items;
  final LabStockFilter filter;
  final String searchQuery;
  final String? errorMessage;

  /// المخزون بعد تطبيق الفلتر + البحث (بالاسم)، مع تقديم المنخفض/النافد.
  List<LabStock> get filtered {
    Iterable<LabStock> result = items;

    switch (filter) {
      case LabStockFilter.low:
        result = result.where((s) => s.status == LabStockStatus.low);
      case LabStockFilter.out:
        result = result.where((s) => s.status == LabStockStatus.out);
      case LabStockFilter.all:
        break;
    }

    final q = searchQuery.trim();
    if (q.isNotEmpty) {
      result = result.where((s) => s.material.contains(q));
    }

    final sorted = result.toList();
    // ترتيب: النافد ثم المنخفض ثم المتوفّر، ثم بالاسم.
    int rank(LabStock s) => switch (s.status) {
          LabStockStatus.out => 0,
          LabStockStatus.low => 1,
          LabStockStatus.available => 2,
        };
    sorted.sort((a, b) {
      final r = rank(a).compareTo(rank(b));
      return r != 0 ? r : a.material.compareTo(b.material);
    });
    return sorted;
  }

  int get total => items.length;
  int get lowCount =>
      items.where((s) => s.status == LabStockStatus.low).length;
  int get outCount =>
      items.where((s) => s.status == LabStockStatus.out).length;

  bool get isInitialLoading =>
      status == LabStockStatusPhase.loading && items.isEmpty;

  LabStockState copyWith({
    LabStockStatusPhase? status,
    List<LabStock>? items,
    LabStockFilter? filter,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LabStockState(
      status: status ?? this.status,
      items: items ?? this.items,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
