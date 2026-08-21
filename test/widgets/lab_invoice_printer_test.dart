// اختبار بنائي فقط: التأكد إن بناء مستند PDF لفاتورة (بعناصر متعددة) ما بيرمي
// استثناء — بلا اختبار سلوك الطباعة الفعلي (Printing.layoutPdf بيفتح حوار
// نظام حقيقي، غير قابل للاختبار الآلي بنفس أسلوب report_export.dart الحالي
// يلي ما إله اختبار مماثل لنفس السبب).

import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/features/lab/domain/entities/lab_material_request.dart';
import 'package:dt_teeth/features/lab/presentation/widgets/material_requests/lab_invoice_printer.dart';

void main() {
  // مطلوبة كي يعمل rootBundle.load بالاختبار (تحميل الخط) — بلا هذا السطر
  // بيرمي "Binding has not yet been initialized" لأنه ما في flutter_test_config.dart
  // بالمشروع يستدعيها تلقائياً.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('buildDocument لفاتورة مستودع بعدة مواد — يبني PDF بلا استثناء', () async {
    const req = MatRequest(
      id: '1',
      status: MatRequestStatus.newRequest,
      requestedBy: 'أحمد',
      requesterType: 'lab',
      date: '2026-08-19',
      notes: 'ملاحظة',
      items: [
        MatRequestItem(id: '1', materialName: 'زركون', quantityRequested: 10),
        MatRequestItem(id: '2', materialName: 'جبس', quantityRequested: 5),
      ],
      newItems: [],
    );
    final bytes = await LabInvoicePrinter.buildPdfBytes(req);
    expect(bytes, isNotEmpty);
  });

  test('buildDocument لفاتورة شركة — يبني PDF بلا استثناء', () async {
    const req = MatRequest(
      id: '2',
      status: MatRequestStatus.newRequest,
      requestedBy: 'سارة',
      requesterType: 'lab',
      date: '2026-08-19',
      items: [],
      newItems: [
        MatRequestNewItem(id: '1', materialName: 'صمغ', quantity: 3, unit: 'علبة', companyName: 'دنتال', reason: 'سبب'),
      ],
    );
    final bytes = await LabInvoicePrinter.buildPdfBytes(req);
    expect(bytes, isNotEmpty);
  });
}
