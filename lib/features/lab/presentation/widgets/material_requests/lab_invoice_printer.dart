// ════════════════════════════════════════════════════════════════════════════
// lab_invoice_printer.dart
//
// توليد وطباعة PDF لفاتورة طلب مواد — نفس نمط report_export.dart (خط عربي
// RTL متّصل، pdf+printing الموجودتان أصلاً بـ pubspec.yaml).
// ════════════════════════════════════════════════════════════════════════════

import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../domain/entities/lab_material_request.dart';

class LabInvoicePrinter {
  LabInvoicePrinter._();

  static pw.Font? _font;

  static Future<pw.Font> _loadFont() async {
    final cached = _font;
    if (cached != null) return cached;
    final data = await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf');
    final font = pw.Font.ttf(data);
    _font = font;
    return font;
  }

  /// يبني بايتات PDF للفاتورة — مستخرَجة منفصلة عن [print] كي تكون قابلة
  /// للاختبار الآلي (Printing.layoutPdf بيفتح حوار نظام حقيقي غير قابل للاختبار).
  static Future<Uint8List> buildPdfBytes(MatRequest invoice) async {
    final font = await _loadFont();
    final doc = pw.Document();
    final isFromCompany = invoice.isFromCompany;

    doc.addPage(
      pw.Page(
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font, bold: font),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('فاتورة #${invoice.id}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('التاريخ: ${invoice.date}    مقدّم الطلب: ${invoice.requestedBy}',
                style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
            pw.SizedBox(height: 18),
            if (!isFromCompany)
              pw.TableHelper.fromTextArray(
                context: context,
                headers: const ['المادة', 'الكمية', 'ملاحظة'],
                data: [for (final it in invoice.items) [it.materialName, '${it.quantityRequested}', it.notes ?? '']],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                cellStyle: const pw.TextStyle(fontSize: 11),
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              )
            else
              pw.TableHelper.fromTextArray(
                context: context,
                headers: const ['المادة', 'الكمية', 'الوحدة', 'الشركة', 'السبب'],
                data: [
                  for (final it in invoice.newItems)
                    [it.materialName, '${it.quantity}', it.unit, it.companyName ?? '', it.reason ?? ''],
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                cellStyle: const pw.TextStyle(fontSize: 11),
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              ),
            if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
              pw.SizedBox(height: 14),
              pw.Text('ملاحظات: ${invoice.notes}', style: const pw.TextStyle(fontSize: 11)),
            ],
          ],
        ),
      ),
    );

    return doc.save();
  }

  /// يفتح حوار الطباعة الأصلي للمتصفح/النظام (طباعة فعلية أو حفظ PDF).
  static Future<void> print(MatRequest invoice) async {
    final bytes = await buildPdfBytes(invoice);
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: 'فاتورة_${invoice.id}.pdf',
    );
  }
}
