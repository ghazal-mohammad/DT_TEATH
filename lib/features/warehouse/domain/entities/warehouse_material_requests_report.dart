// ════════════════════════════════════════════════════════════════════════════
// warehouse_material_requests_report.dart
//
// تقرير طلبات المواد — يقابل ReportController::materialRequests (الباك، قُرئ
// الكونترولر مباشرة 2026-08-15). كان بلا مستهلك بالفرونت قبل هالمراجعة.
//
// ⚠️ باغ حقيقي بالباك (موثَّق، لا يُصلَح من الفرونت — القراءة فقط):
// الكونترولر يفلتر status=='fulfilled' لكن القيمة الحقيقية بـ enum
// material_requests.status هي 'completed' (لا 'fulfilled' أصلاً) ⇒
// fulfilled_count/fulfillment_rate يرجعوا 0 دائماً مهما كانت البيانات
// الحقيقية. نعرض ما يرجعه الباك بأمانة.
// ════════════════════════════════════════════════════════════════════════════

/// تجميع حسب طالب الطلب (by_requester بالباك).
class RequesterBucket {
  const RequesterBucket({
    required this.requester,
    required this.totalRequests,
    required this.fulfilled,
    required this.rejected,
    required this.pending,
  });

  final String requester;
  final int totalRequests;
  final int fulfilled;
  final int rejected;
  final int pending;

  factory RequesterBucket.fromJson(Map<String, dynamic> j) => RequesterBucket(
        requester: (j['requester'] ?? '—').toString(),
        totalRequests: _toInt(j['total_requests']),
        fulfilled: _toInt(j['fulfilled']),
        rejected: _toInt(j['rejected']),
        pending: _toInt(j['pending']),
      );

  static int _toInt(Object? v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
}

/// سطر طلب واحد ضمن التقرير (requests بالباك).
class MaterialRequestReportRow {
  const MaterialRequestReportRow({
    required this.id,
    required this.requester,
    required this.status,
    required this.itemsCount,
    this.createdAt,
  });

  final String id;
  final String requester;
  final String status;
  final int itemsCount;
  final DateTime? createdAt;

  factory MaterialRequestReportRow.fromJson(Map<String, dynamic> j) =>
      MaterialRequestReportRow(
        id: '${j['id'] ?? ''}',
        requester: (j['requester'] ?? '—').toString(),
        status: (j['status'] ?? '').toString(),
        itemsCount: _toInt(j['items_count']),
        createdAt: j['created_at'] == null
            ? null
            : DateTime.tryParse(j['created_at'].toString()),
      );

  static int _toInt(Object? v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
}

class WarehouseMaterialRequestsReport {
  const WarehouseMaterialRequestsReport({
    required this.totalRequests,
    required this.fulfilledCount,
    required this.rejectedCount,
    required this.pendingCount,
    required this.fulfillmentRate,
    required this.byRequester,
    required this.requests,
  });

  final int totalRequests;
  final int fulfilledCount;
  final int rejectedCount;
  final int pendingCount;

  /// نص جاهز من الباك (مثل "0%")، لا رقم — يُعرَض كما هو.
  final String fulfillmentRate;
  final List<RequesterBucket> byRequester;
  final List<MaterialRequestReportRow> requests;

  factory WarehouseMaterialRequestsReport.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final summary = data['summary'] is Map
        ? Map<String, dynamic>.from(data['summary'] as Map)
        : const <String, dynamic>{};
    return WarehouseMaterialRequestsReport(
      totalRequests: _toInt(summary['total_requests']),
      fulfilledCount: _toInt(summary['fulfilled_count']),
      rejectedCount: _toInt(summary['rejected_count']),
      pendingCount: _toInt(summary['pending_count']),
      fulfillmentRate: (summary['fulfillment_rate'] ?? '0%').toString(),
      byRequester: (data['by_requester'] is List)
          ? (data['by_requester'] as List)
              .whereType<Map<dynamic, dynamic>>()
              .map((e) => RequesterBucket.fromJson(Map<String, dynamic>.from(e)))
              .toList(growable: false)
          : const [],
      requests: (data['requests'] is List)
          ? (data['requests'] as List)
              .whereType<Map<dynamic, dynamic>>()
              .map((e) =>
                  MaterialRequestReportRow.fromJson(Map<String, dynamic>.from(e)))
              .toList(growable: false)
          : const [],
    );
  }

  static int _toInt(Object? v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
}
