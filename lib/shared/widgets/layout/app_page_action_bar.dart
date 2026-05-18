// ════════════════════════════════════════════════════════════════════════════
// app_page_action_bar.dart
//
// Toolbar أعلى الصفحات — يجمع filter chips على اليسار + actions على اليمين.
//
// 🎯 الهدف:
//   نمط متكرر في Materials, Orders, Invoices: شريط chips + زر إضافة.
//   هذا الـ widget يوحّد الـ layout والـ responsive behavior.
//
// 🔮 قابلية التوسيع:
//   - يقبل أي عدد من actions (List<Widget>)
//   - يقبل أي filter widget (مثل AppFilterChipBar أو tabs أو dropdown)
//   - على شاشات ضيقة: actions تنزل تحت filters
//
// تركيبة الـ HTML الأصلية:
//   <div style="display:flex;justify-content:space-between;
//               align-items:center;margin-bottom:16px">
//     <div class="fc-row"> ... filters ... </div>
//     <button class="btn btn-p btn-sm"> + إضافة </button>
//   </div>
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

/// Toolbar عرضي يجمع filter widget + actions.
class AppPageActionBar extends StatelessWidget {
  const AppPageActionBar({
    super.key,
    required this.filter,
    this.actions = const [],
    this.bottomMargin = 16.0,
    this.stackBreakpoint = 700.0,
    this.actionsSpacing = 8.0,
  });

  /// الـ widget الأيمن (filter chips، tabs، إلخ).
  final Widget filter;

  /// قائمة actions على اليسار (أزرار إضافة، تصدير، إلخ).
  final List<Widget> actions;

  /// margin سفلي افتراضي قبل المحتوى التالي.
  final double bottomMargin;

  /// نقطة التحوّل لـ stacked layout (تحتها → Column).
  final double stackBreakpoint;

  /// المسافة بين actions.
  final double actionsSpacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsetsDirectional.only(bottom: bottomMargin),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isStacked = constraints.maxWidth < stackBreakpoint;
          if (isStacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                filter,
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildActionsRow(),
                ],
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: filter),
              if (actions.isNotEmpty) ...[
                const SizedBox(width: 12),
                _buildActionsRow(),
              ],
            ],
          );
        },
      ),
    );
  }

  /// بناء صف الـ actions مع spacing بينها.
  Widget _buildActionsRow() {
    if (actions.length == 1) return actions.first;

    final children = <Widget>[];
    for (var i = 0; i < actions.length; i++) {
      children.add(actions[i]);
      if (i < actions.length - 1) {
        children.add(SizedBox(width: actionsSpacing));
      }
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
