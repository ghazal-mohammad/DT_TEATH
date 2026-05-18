// ════════════════════════════════════════════════════════════════════════════
// app_form_grid.dart
//
// نظام الشبكة للنماذج — `.g2`, `.g3`
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — الأسطر 821–822
//
// القواعد الأصلية:
//   .g2 { display:grid; grid-template-columns:1fr 1fr; gap:10px }
//   .g3 { display:grid; grid-template-columns:1fr 1fr 1fr; gap:10px }
//
// يُستخدم لتوزيع حقول النموذج أفقياً — مثال:
// [ الاسم الأول ] [ الاسم الأخير ]     ← g2
// [ يوم ] [ شهر ] [ سنة ]              ← g3
//
// يتحوّل تلقائياً إلى عمود واحد في الشاشات الضيقة (responsive).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

/// شبكة حقول نموذج بعدد أعمدة محدّد.
///
/// يدعم الـ responsive — يصبح عموداً واحداً عند `maxWidth < breakpoint`.
class AppFormGrid extends StatelessWidget {
  const AppFormGrid({
    super.key,
    required this.children,
    this.columns = 2,
    this.gap = 10, // CSS gap:10px
    this.breakpoint = 560,
  }) : assert(
         columns >= 1 && columns <= 4,
         'columns must be between 1 and 4',
       );

  /// إنشاء شبكة بعمودين (`.g2`) — الأكثر شيوعاً.
  const AppFormGrid.two({
    super.key,
    required this.children,
    this.gap = 10,
    this.breakpoint = 560,
  }) : columns = 2;

  /// إنشاء شبكة بثلاثة أعمدة (`.g3`).
  const AppFormGrid.three({
    super.key,
    required this.children,
    this.gap = 10,
    this.breakpoint = 560,
  }) : columns = 3;

  final List<Widget> children;
  final int columns;
  final double gap;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // أقل من الـ breakpoint → عمود واحد
        final int actualColumns = constraints.maxWidth < breakpoint
            ? 1
            : columns;

        if (actualColumns == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          );
        }

        final double itemWidth =
            (constraints.maxWidth - (gap * (actualColumns - 1))) /
            actualColumns;

        final List<Widget> rows = [];
        for (int i = 0; i < children.length; i += actualColumns) {
          final List<Widget> rowChildren = [];
          for (int j = 0; j < actualColumns; j++) {
            if (i + j < children.length) {
              rowChildren.add(
                SizedBox(width: itemWidth, child: children[i + j]),
              );
              if (j < actualColumns - 1 && i + j + 1 < children.length) {
                rowChildren.add(SizedBox(width: gap));
              }
            } else {
              // حقل فارغ للحفاظ على الـ alignment
              rowChildren.add(SizedBox(width: itemWidth));
            }
          }
          rows.add(Row(children: rowChildren));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}
