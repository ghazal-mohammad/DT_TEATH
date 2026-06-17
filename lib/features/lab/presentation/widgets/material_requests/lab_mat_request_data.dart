// ════════════════════════════════════════════════════════════════════════════
// lab_mat_request_data.dart
//
// وحدات القياس لطلب المواد + إعادة تصدير كيان الطلب.
// MatRequest و MatRequestStatus انتقلا إلى domain/entities/lab_material_request.dart،
// والبذرة إلى data/repositories/mock_lab_material_requests_repository.dart.
// نعيد تصدير الكيان هنا كي تبقى الملفات المستوردة (البطاقة) تعمل دون تعديل.
// ════════════════════════════════════════════════════════════════════════════

export '../../../domain/entities/lab_material_request.dart'
    show MatRequest, MatRequestStatus;

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
