// ════════════════════════════════════════════════════════════════════════════
// materials_state.dart
//
// Immutable state class لـ MaterialsCubit.
//
// 🎯 الهدف:
//   تمثيل كامل state الصفحة في كائن واحد:
//   - الـ status (initial / loading / loaded / error)
//   - البيانات الخام (materials)
//   - الفلتر النشط + نص البحث
//   - الـ filtered list (computed)
//
// لماذا single-state؟
//   مع Cubit، الـ states المتعدّدة (sealed classes) تُعقّد الـ UI لأنه
//   لازم BlocBuilder يعالج كل case. الـ single state أبسط ويسمح بـ
//   `state.materials` مباشرة في كل widget.
// ════════════════════════════════════════════════════════════════════════════

import '../../domain/entities/material_filter.dart';
import '../../domain/entities/material_status.dart';
import '../../domain/entities/warehouse_material.dart';

/// مرحلة تحميل بيانات Materials.
enum MaterialsStatus { initial, loading, loaded, error }

/// State كامل لصفحة Materials.
class MaterialsState {
  const MaterialsState({
    required this.status,
    required this.materials,
    required this.activeFilter,
    required this.searchQuery,
    this.errorMessage,
  });

  /// الـ initial state عند تشغيل التطبيق.
  const MaterialsState.initial()
    : status = MaterialsStatus.initial,
      materials = const [],
      activeFilter = MaterialFilter.all,
      searchQuery = '',
      errorMessage = null;

  /// مرحلة التحميل الحالية.
  final MaterialsStatus status;

  /// قائمة المواد الكاملة من الـ repository.
  final List<WarehouseMaterial> materials;

  /// الفلتر النشط في الـ chips bar.
  final MaterialFilter activeFilter;

  /// نص البحث الحالي.
  final String searchQuery;

  /// رسالة الخطأ (إذا status == error).
  final String? errorMessage;

  // ────────────────────────────────────────────────────────────────────────
  //                          COMPUTED PROPERTIES
  // ────────────────────────────────────────────────────────────────────────

  /// قائمة المواد بعد تطبيق الفلتر + البحث.
  ///
  /// **خوارزمية الترتيب**:
  /// 1. الفلتر النشط أولاً
  /// 2. نص البحث (case-insensitive، يطابق name و supplier)
  /// 3. الترتيب: critical low أولاً (لجذب الانتباه)
  List<WarehouseMaterial> get filteredMaterials {
    var result = activeFilter.apply(materials);

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase().trim();
      result = result
          .where((m) {
            final inName = m.name.toLowerCase().contains(query);
            final inSupplier =
                m.supplier?.toLowerCase().contains(query) ?? false;
            return inName || inSupplier;
          })
          .toList(growable: false);
    }

    // ترتيب: المواد الحرجة أولاً، ثم بـ name
    final sorted = List<WarehouseMaterial>.from(result);
    sorted.sort((a, b) {
      final aPriority = a.status.priority;
      final bPriority = b.status.priority;
      if (aPriority != bPriority) return bPriority.compareTo(aPriority);
      return a.name.compareTo(b.name);
    });
    return sorted;
  }

  /// هل القائمة فاضية؟ (إما أصلاً أو بعد فلترة).
  bool get isEmpty => filteredMaterials.isEmpty;

  /// هل التحميل الأولي قيد التنفيذ؟
  bool get isInitialLoading =>
      status == MaterialsStatus.loading && materials.isEmpty;

  // ────────────────────────────────────────────────────────────────────────
  //                          COPY WITH
  // ────────────────────────────────────────────────────────────────────────

  /// ينتج نسخة جديدة مع تحديث بعض الحقول.
  ///
  /// ملاحظة على [errorMessage]:
  ///   نمط `copyWith(errorMessage: null)` في Dart يحافظ على القيمة القديمة
  ///   (لأن null يعني "ما تغيّرت"). لمسح الخطأ بشكل صريح، استخدم
  ///   `copyWith(clearError: true)`.
  MaterialsState copyWith({
    MaterialsStatus? status,
    List<WarehouseMaterial>? materials,
    MaterialFilter? activeFilter,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MaterialsState(
      status: status ?? this.status,
      materials: materials ?? this.materials,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
