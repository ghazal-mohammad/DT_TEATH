// ════════════════════════════════════════════════════════════════════════════
// lab_products_state.dart
//
// State غير قابل للتغيير لـ LabProductsCubit (single-state، يطابق MaterialsState).
// يحتوي: مرحلة التحميل + الكتالوج الخام + نص البحث + القائمة المُفلترة (computed).
// ════════════════════════════════════════════════════════════════════════════

import '../../domain/entities/lab_product.dart';

/// مرحلة تحميل كتالوج المنتجات.
enum LabProductsStatus { initial, loading, loaded, error }

/// State كامل لصفحة منتجات المخبر.
class LabProductsState {
  const LabProductsState({
    required this.status,
    required this.products,
    required this.searchQuery,
    this.errorMessage,
  });

  const LabProductsState.initial()
      : status = LabProductsStatus.initial,
        products = const [],
        searchQuery = '',
        errorMessage = null;

  final LabProductsStatus status;
  final List<LabProduct> products;
  final String searchQuery;
  final String? errorMessage;

  /// الكتالوج بعد تطبيق البحث (يطابق الاسم أو النوع).
  List<LabProduct> get filtered {
    final q = searchQuery.trim();
    if (q.isEmpty) return products;
    return products
        .where((p) => p.name.contains(q) || p.type.contains(q))
        .toList(growable: false);
  }

  bool get isInitialLoading =>
      status == LabProductsStatus.loading && products.isEmpty;

  LabProductsState copyWith({
    LabProductsStatus? status,
    List<LabProduct>? products,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LabProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
