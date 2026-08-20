// ════════════════════════════════════════════════════════════════════════════
// lab_material_request.dart
//
// كيان domain لفاتورة طلب مواد أرسلها المخبر للمستودع (منظور المخبر). نقي
// (pure Dart). فاتورة واحدة تحمل عدّة عناصر — إما items[] (مواد من كتالوج
// المستودع) أو newItems[] (مواد جديدة من شركة خارجية)، أبداً الاثنين سوا
// (قرار معتمد). يطابق تماماً شكل WarehouseRequest بجهة المستودع لنفس المورد
// الخلفي (MaterialRequestResource).
// ════════════════════════════════════════════════════════════════════════════

// القيم الخمس تطابق enum الحالة الفعلي بالباك: new/pending/completed/
// rejected/cancelled (تحقّق 2026-08-14) — كل حالة باك تُميَّز بحالة فرونت
// مستقلة (بلا fallback مشترك) كي تُعرض شارة مختلفة لكل منها.
enum MatRequestStatus { newRequest, inProgress, delivered, unavailable, cancelled }

/// عنصر مادة من كتالوج المستودع ضمن الفاتورة (مسار items[] بالباك).
class MatRequestItem {
  const MatRequestItem({
    required this.id,
    required this.materialName,
    required this.quantityRequested,
    this.notes,
  });

  final String id;
  final String materialName;
  final int quantityRequested;
  final String? notes;
}

/// عنصر مادة جديدة من شركة خارجية ضمن الفاتورة (مسار new_items[] بالباك).
class MatRequestNewItem {
  const MatRequestNewItem({
    required this.id,
    required this.materialName,
    required this.quantity,
    required this.unit,
    this.companyName,
    this.reason,
  });

  final String id;
  final String materialName;
  final int quantity;
  final String unit;
  final String? companyName;
  final String? reason;
}

/// فاتورة طلب مواد كاملة أرسلها المخبر للمستودع.
class MatRequest {
  const MatRequest({
    required this.id,
    required this.status,
    required this.requestedBy,
    required this.requesterType,
    required this.date,
    required this.items,
    required this.newItems,
    this.notes,
  });

  final String id;
  final MatRequestStatus status;
  final String requestedBy;
  final String requesterType;
  final String date;

  /// ملاحظة عامة على الفاتورة (top-level notes بجسم الطلب/الرد).
  final String? notes;

  /// مواد من كتالوج المستودع — فارغة لفاتورة "من شركة".
  final List<MatRequestItem> items;

  /// مواد جديدة من شركة خارجية — فارغة لفاتورة "من مستودع".
  final List<MatRequestNewItem> newItems;

  int get itemsCount => items.length + newItems.length;
  bool get isFromWarehouse => items.isNotEmpty;
  bool get isFromCompany => newItems.isNotEmpty;
}
