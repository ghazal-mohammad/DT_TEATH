// ════════════════════════════════════════════════════════════════════════════
// warehouse_request.dart
//
// طلب مواد وارد إلى المستودع (من المخبر/العيادة) — يقابل MaterialRequestResource.
// طلب واحد يحوي عدّة عناصر: مواد موجودة (items) ومواد جديدة مقترحة (new_items).
// المستودع يلبّي الطلب كاملاً (خصم FIFO) أو يرفضه.
// ════════════════════════════════════════════════════════════════════════════

/// حالة طلب المواد (تطابق قيم status في الباك: enum material_requests.status
/// = new|pending|completed|cancelled|rejected — من migration الباك مباشرة).
enum WarehouseRequestStatus {
  newReq,
  inProgress,
  completed,
  rejected,
  cancelled,
  unknown
}

WarehouseRequestStatus warehouseRequestStatusFromApi(String v) {
  switch (v.trim().toLowerCase()) {
    case 'new':
      return WarehouseRequestStatus.newReq;
    // الباك أعاد تسمية in_progress ⇒ pending (تحقّق مباشر من migration الباك
    // بتاريخ 2026-08-14) — القيمة الفعلية بالـ enum صارت pending.
    case 'pending':
      return WarehouseRequestStatus.inProgress;
    case 'completed':
      return WarehouseRequestStatus.completed;
    case 'rejected':
      return WarehouseRequestStatus.rejected;
    case 'cancelled':
      return WarehouseRequestStatus.cancelled;
    default:
      return WarehouseRequestStatus.unknown;
  }
}

extension WarehouseRequestStatusX on WarehouseRequestStatus {
  /// هل يمكن تلبية هذا الطلب؟ (new أو pending) — يطابق
  /// MaterialRequestController::fulfill (['new', 'pending']).
  bool get canFulfill =>
      this == WarehouseRequestStatus.newReq ||
      this == WarehouseRequestStatus.inProgress;

  /// هل يمكن رفض هذا الطلب؟ (new أو pending) — يطابق
  /// MaterialRequestController::reject (['new', 'pending']).
  bool get canReject =>
      this == WarehouseRequestStatus.newReq ||
      this == WarehouseRequestStatus.inProgress;

  /// هل يمكن تحويله إلى "قيد المعالجة"؟ (new فقط) — يطابق
  /// MaterialRequestController::markPending (status !== 'new' يُرفض).
  bool get canMarkPending => this == WarehouseRequestStatus.newReq;
}

/// عنصر مادة موجودة ضمن الطلب.
class WarehouseRequestItem {
  const WarehouseRequestItem({
    required this.id,
    required this.materialName,
    required this.quantityRequested,
    required this.status,
    this.notes,
  });

  final String id;
  final String materialName;
  final int quantityRequested;
  final String status;
  final String? notes;

  factory WarehouseRequestItem.fromJson(Map<String, dynamic> j) =>
      WarehouseRequestItem(
        id: '${j['id'] ?? ''}',
        materialName: (j['material'] ?? '').toString(),
        quantityRequested: _toInt(j['quantity_requested']),
        status: (j['status'] ?? '').toString(),
        notes: (j['notes']?.toString().isEmpty ?? true)
            ? null
            : j['notes'].toString(),
      );

  static int _toInt(Object? v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
}

/// عنصر مادة جديدة مقترحة (غير موجودة بعد في كتالوج المستودع).
class WarehouseNewItem {
  const WarehouseNewItem({
    required this.id,
    required this.materialName,
    required this.quantity,
    required this.unit,
    this.companyName,
    this.reason,
    this.status,
  });

  final String id;
  final String materialName;
  final int quantity;
  final String unit;
  final String? companyName;
  final String? reason;
  final String? status;

  factory WarehouseNewItem.fromJson(Map<String, dynamic> j) => WarehouseNewItem(
        id: '${j['id'] ?? ''}',
        materialName: (j['material_name'] ?? '').toString(),
        quantity: _toInt(j['quantity']),
        unit: (j['unit'] ?? '').toString(),
        companyName: _nn(j['company_name']),
        reason: _nn(j['reason']),
        status: _nn(j['status']),
      );

  static int _toInt(Object? v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
  static String? _nn(Object? v) =>
      (v == null || v.toString().isEmpty) ? null : v.toString();
}

/// طلب مواد كامل.
class WarehouseRequest {
  const WarehouseRequest({
    required this.id,
    required this.status,
    required this.requesterName,
    required this.requesterType,
    required this.items,
    required this.newItems,
    this.notes,
    this.createdAt,
  });

  final String id;
  final WarehouseRequestStatus status;
  final String requesterName;
  final String requesterType;
  final List<WarehouseRequestItem> items;
  final List<WarehouseNewItem> newItems;
  final String? notes;
  final DateTime? createdAt;

  /// إجمالي عدد العناصر (موجودة + جديدة).
  int get itemsCount => items.length + newItems.length;

  factory WarehouseRequest.fromJson(Map<String, dynamic> j) {
    final requester = j['requester'] is Map
        ? Map<String, dynamic>.from(j['requester'] as Map)
        : const <String, dynamic>{};
    return WarehouseRequest(
      id: '${j['id'] ?? ''}',
      status: warehouseRequestStatusFromApi('${j['status'] ?? ''}'),
      requesterName: (requester['name'] ?? '').toString(),
      requesterType: (j['requester_type'] ?? '').toString(),
      items: _list(j['items'])
          .map(WarehouseRequestItem.fromJson)
          .toList(growable: false),
      newItems: _list(j['new_items'])
          .map(WarehouseNewItem.fromJson)
          .toList(growable: false),
      notes: (j['notes']?.toString().isEmpty ?? true)
          ? null
          : j['notes'].toString(),
      createdAt: DateTime.tryParse('${j['created_at'] ?? ''}'),
    );
  }

  static List<Map<String, dynamic>> _list(Object? v) => (v is List)
      ? v
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList()
      : const [];
}
