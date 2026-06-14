// ════════════════════════════════════════════════════════════════════════════
// lab_mat_request_data.dart
//
// نموذج طلب مادة من المستودع (منظور المخبر) + حالاته + وحدات القياس + بذرة
// بيانات وهمية — مُستخرَجة من lab_material_requests_page.dart ضمن تقسيم الصفحات.
// ════════════════════════════════════════════════════════════════════════════

enum MatRequestStatus { newRequest, delivered, unavailable }

/// طلب مادة واحد أرسله المخبر للمستودع.
class MatRequest {
  const MatRequest({
    required this.id,
    required this.material,
    required this.quantity,
    required this.unit,
    required this.requestedBy,
    required this.date,
    required this.status,
    this.labOrderId,
    this.note,
    this.company,
    this.reason,
  });
  final String id;
  final String material;
  final String quantity;
  final String unit;
  final String requestedBy;
  final String date;
  final MatRequestStatus status;
  final String? labOrderId;
  final String? note;

  /// اسم الشركة المصنّعة (للمواد الجديدة غير الموجودة بالمستودع).
  final String? company;

  /// سبب الطلب — يُعرض للمستودع ليعرف ليش المخبر طالب المادة.
  final String? reason;
}

/// وحدات القياس المتاحة لطلب المواد (نفس وحدات مخزون المخبر).
const List<String> kMatRequestUnits = [
  'علبة',
  'بلوك',
  'كيلو',
  'غرام',
  'قطعة',
  'أنبوب',
  'زجاجة',
];

/// بذرة طلبات المواد (مؤقّتة حتى ربط الـ API).
const List<MatRequest> kLabMatRequestsSeed = [
  MatRequest(
    id: 'MR-001',
    material: 'زركون بلوك A3',
    quantity: '3',
    unit: 'بلوك',
    requestedBy: 'هشام علي',
    date: '2026-05-10',
    status: MatRequestStatus.newRequest,
    labOrderId: 'LAB-143',
  ),
  MatRequest(
    id: 'MR-002',
    material: 'غراء طبي أبيض',
    quantity: '2',
    unit: 'أنبوب',
    requestedBy: 'سامر شماع',
    date: '2026-05-09',
    status: MatRequestStatus.delivered,
    labOrderId: 'LAB-129',
  ),
  MatRequest(
    id: 'MR-003',
    material: 'سيليكون طبع A-Type',
    quantity: '1',
    unit: 'كيلو',
    requestedBy: 'أيار كريم',
    date: '2026-05-09',
    status: MatRequestStatus.unavailable,
    note: 'المادة غير موجودة — طُلبت من المورد',
  ),
  MatRequest(
    id: 'MR-004',
    material: 'أسلاك ربط أورثو',
    quantity: '10',
    unit: 'قطعة',
    requestedBy: 'هشام علي',
    date: '2026-05-08',
    status: MatRequestStatus.delivered,
    labOrderId: 'LAB-182',
  ),
  MatRequest(
    id: 'MR-005',
    material: 'ورنيش PFM',
    quantity: '1',
    unit: 'زجاجة',
    requestedBy: 'سامر شماع',
    date: '2026-05-07',
    status: MatRequestStatus.newRequest,
    labOrderId: 'LAB-168',
  ),
];
