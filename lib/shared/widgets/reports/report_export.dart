// ════════════════════════════════════════════════════════════════════════════
// report_export.dart
//
// تصدير حقيقي لتقارير ReportsView — PDF (خط عربي متّصل RTL) / Excel / بريد
// (mailto بملخّص نصّي). مصدر بيانات واحد لكل الأنظمة (مخبر + مستودع) لأن
// ReportsView يمرّر نماذج عامة (ReportKpi/ReportSegment/ReportDay/ReportTeamRow).
// ════════════════════════════════════════════════════════════════════════════

import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:excel/excel.dart' as xls;
import 'package:file_saver/file_saver.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import 'reports_view.dart';

/// حزمة بيانات تقرير جاهزة للتصدير — نفس النماذج المعروضة في ReportsView.
class ReportExportData {
  const ReportExportData({
    required this.title,
    required this.periodLabel,
    required this.kpis,
    this.segments = const [],
    this.days = const [],
    this.team = const [],
    this.segmentsTitle,
    this.daysTitle,
  });

  final String title;
  final String periodLabel;
  final List<ReportKpi> kpis;
  final List<ReportSegment> segments;
  final List<ReportDay> days;
  final List<ReportTeamRow> team;
  final String? segmentsTitle;
  final String? daysTitle;
}

class ReportExporter {
  ReportExporter._();

  /// إيميل مركز DT.Teeth الثابت — كل تقرير يُرسَل عليه حصراً (المستخدم ما
  /// بيقدر يغيّر الوجهة)، يطابق حقل email بـ admin/updateCenterInfo.
  static const String _centerEmail = 'info@dtteeth.com';

  static pw.Font? _font;

  static Future<pw.Font> _loadFont() async {
    final cached = _font;
    if (cached != null) return cached;
    final data = await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf');
    final font = pw.Font.ttf(data);
    _font = font;
    return font;
  }

  static String _safeName(String title) => title
      .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
      .replaceAll(RegExp(r'\s+'), '_');

  // ── PDF ──────────────────────────────────────────────────────────────────

  static Future<void> exportPdf(ReportExportData data) async {
    final font = await _loadFont();
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font, bold: font),
        build: (context) => [
          pw.Text(data.title,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(data.periodLabel,
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
          if (data.kpis.isNotEmpty) ...[
            pw.SizedBox(height: 18),
            _kpiTable(context, data.kpis),
          ],
          if (data.segments.isNotEmpty) ...[
            pw.SizedBox(height: 18),
            pw.Text(data.segmentsTitle ?? '',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            _segmentsTable(context, data.segments),
          ],
          if (data.team.isNotEmpty) ...[
            pw.SizedBox(height: 18),
            pw.Text('أداء الفريق',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            _teamTable(context, data.team),
          ],
          if (data.days.isNotEmpty) ...[
            pw.SizedBox(height: 18),
            pw.Text(data.daysTitle ?? '',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            _daysTable(context, data.days),
          ],
        ],
      ),
    );

    final bytes = await doc.save();
    await Printing.sharePdf(
        bytes: bytes, filename: '${_safeName(data.title)}.pdf');
  }

  static pw.Widget _kpiTable(pw.Context context, List<ReportKpi> kpis) {
    return pw.TableHelper.fromTextArray(
      context: context,
      headers: kpis.map((k) => k.label).toList(),
      data: [kpis.map((k) => k.value).toList()],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 13),
      cellAlignment: pw.Alignment.center,
      headerAlignment: pw.Alignment.center,
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
    );
  }

  static pw.Widget _segmentsTable(pw.Context context, List<ReportSegment> segs) {
    return pw.TableHelper.fromTextArray(
      context: context,
      headers: const ['البند', 'العدد', 'النسبة'],
      data: [
        for (final s in segs) [s.label, '${s.count}', '${s.percentage}%'],
      ],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 11),
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
    );
  }

  static pw.Widget _daysTable(pw.Context context, List<ReportDay> days) {
    return pw.TableHelper.fromTextArray(
      context: context,
      headers: [for (final d in days) d.label],
      data: [
        [for (final d in days) '${d.count}'],
      ],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
      cellStyle: const pw.TextStyle(fontSize: 11),
      cellAlignment: pw.Alignment.center,
      headerAlignment: pw.Alignment.center,
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
    );
  }

  static pw.Widget _teamTable(pw.Context context, List<ReportTeamRow> team) {
    return pw.TableHelper.fromTextArray(
      context: context,
      headers: const ['الاسم', 'الأداء'],
      data: [for (final t in team) [t.name, t.trailing]],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 11),
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
    );
  }

  // ── Excel ────────────────────────────────────────────────────────────────

  static Future<void> exportExcel(ReportExportData data) async {
    final book = xls.Excel.createExcel();
    final sheetName = book.getDefaultSheet() ?? 'Sheet1';
    final sheet = book[sheetName];

    var row = 0;
    void writeRow(List<Object?> cells, {bool bold = false}) {
      for (var col = 0; col < cells.length; col++) {
        final cell = sheet.cell(
            xls.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
        cell.value = _xlsValue(cells[col]);
        if (bold) {
          cell.cellStyle = xls.CellStyle(bold: true);
        }
      }
      row++;
    }

    writeRow([data.title], bold: true);
    writeRow([data.periodLabel]);
    row++;

    if (data.kpis.isNotEmpty) {
      writeRow([for (final k in data.kpis) k.label], bold: true);
      writeRow([for (final k in data.kpis) k.value]);
      row++;
    }

    if (data.segments.isNotEmpty) {
      writeRow([data.segmentsTitle ?? ''], bold: true);
      writeRow(['البند', 'العدد', 'النسبة'], bold: true);
      for (final s in data.segments) {
        writeRow([s.label, s.count, '${s.percentage}%']);
      }
      row++;
    }

    if (data.team.isNotEmpty) {
      writeRow(['أداء الفريق'], bold: true);
      writeRow(['الاسم', 'الأداء'], bold: true);
      for (final t in data.team) {
        writeRow([t.name, t.trailing]);
      }
      row++;
    }

    if (data.days.isNotEmpty) {
      writeRow([data.daysTitle ?? ''], bold: true);
      writeRow([for (final d in data.days) d.label], bold: true);
      writeRow([for (final d in data.days) d.count]);
    }

    final bytes = book.encode();
    if (bytes == null) return;
    await FileSaver.instance.saveFile(
      name: _safeName(data.title),
      bytes: Uint8List.fromList(bytes),
      fileExtension: 'xlsx',
      mimeType: MimeType.microsoftExcel,
    );
  }

  static xls.CellValue? _xlsValue(Object? v) {
    if (v == null) return null;
    if (v is int) return xls.IntCellValue(v);
    if (v is double) return xls.DoubleCellValue(v);
    return xls.TextCellValue(v.toString());
  }

  // ── بريد (ملخّص نصّي — بلا مرفقات، mailto لا يدعمها) ────────────────────

  static Future<void> emailReport(ReportExportData data) async {
    final buffer = StringBuffer()
      ..writeln(data.title)
      ..writeln(data.periodLabel)
      ..writeln();
    if (data.kpis.isNotEmpty) {
      for (final k in data.kpis) {
        buffer.writeln('${k.label}: ${k.value}');
      }
      buffer.writeln();
    }
    if (data.segments.isNotEmpty) {
      buffer.writeln(data.segmentsTitle ?? '');
      for (final s in data.segments) {
        buffer.writeln('- ${s.label}: ${s.count} (${s.percentage}%)');
      }
    }

    final subject = Uri.encodeComponent(data.title);
    final body = Uri.encodeComponent(buffer.toString());
    final to = Uri.encodeComponent(_centerEmail);
    final gmailUri = Uri.parse(
      'https://mail.google.com/mail/?view=cm&fs=1&to=$to&su=$subject&body=$body',
    );

    // على الويب: mailto غير موثوق — المتصفّح أحياناً "ينجح" (launchUrl يرجع
    // true) لكن فعلياً بيفتح تبويب فاضي يعرض رابط mailto: كنص خام بدل ما
    // يشغّل عميل بريد (تحقّق فعلي 2026-08-14: هيك بالضبط صار). فبدل الاعتماد
    // على قيمة الإرجاع غير الموثوقة، نفتح Gmail بالمتصفّح مباشرة دائماً على
    // الويب — بريد حقيقي شغّال 100% بأي جهاز فيه متصفّح، بلا أي اعتماد على
    // إعداد محلي قد يفشل بصمت.
    if (kIsWeb) {
      final opened =
          await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
      if (!opened) {
        throw StateError('تعذّر فتح Gmail — تحقّق من الاتصال بالإنترنت.');
      }
      return;
    }

    // على الموبايل/الديسكتوب: mailto موثوق (يفتح تطبيق البريد المثبّت فعلياً
    // أو يرجع false بوضوح لو ما في تطبيق بريد مُعرَّف).
    final mailtoUri = Uri(
        scheme: 'mailto', path: _centerEmail, query: 'subject=$subject&body=$body');
    var launched = false;
    try {
      launched = await launchUrl(mailtoUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }
    if (launched) return;

    final openedGmail =
        await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
    if (!openedGmail) {
      throw StateError('تعذّر فتح تطبيق أو صفحة بريد — تحقّق من الاتصال بالإنترنت.');
    }
  }
}
