// ════════════════════════════════════════════════════════════════════════════
// app_segmented_tabs.dart
//
// شريط تابات موحّد (Segmented Tabs) — الستايل المرجعي المعتمد بين النظامين.
//
// 🎯 المصدر البصري:
//   شريط "الحالة" في صفحة مواد المستودع (warehouse_materials_content):
//   - حاوية زرقاء فاتحة (#DCE5F4) بزوايا 12 و padding 3
//   - التاب النشط: كبسولة بيضاء بزوايا 9 وخط w800
//   - العدّاد بجانب النص بلون lightText3
//
// قاعدة التوحيد:
//   أي شريط فلاتر/تابات في المخبر أو المستودع يجب أن يستخدم هذا الـ widget —
//   ممنوع إعادة بناء الستايل محلياً داخل الصفحات.
//
// مثال:
// ```dart
// AppSegmentedTabs<MyFilter>(
//   values: MyFilter.values,
//   selected: _filter,
//   labelOf: (f) => f.label(context.l10n),
//   countOf: (f) => _countFor(f),
//   onChanged: (f) => setState(() => _filter = f),
// )
// ```
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// شريط تابات موحّد — generic على نوع القيمة [T] (enum أو String).
class AppSegmentedTabs<T> extends StatelessWidget {
  const AppSegmentedTabs({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    this.countOf,
  });

  /// كل القيم المتاحة (مثل MyFilter.values).
  final List<T> values;

  /// القيمة النشطة حالياً.
  final T selected;

  /// تحويل القيمة إلى نص العرض (يُستخدم l10n من الـ caller).
  final String Function(T value) labelOf;

  /// callback عند اختيار قيمة جديدة.
  final ValueChanged<T> onChanged;

  /// builder اختياري للعدّاد بجانب النص — إذا أرجع null لا يظهر عدّاد.
  final int? Function(T value)? countOf;

  // ── الستايل المرجعي (من شريط مواد المستودع) ─────────────────────────────
  static const Color _lightTrackBg = Color(0xFFDCE5F4); // الشريط الأزرق الفاتح

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    // Align يمنع تمدد الشريط على كامل العرض لما يكون الأب stretch/tight.
    return Align(
      alignment: AlignmentDirectional.centerStart,
      heightFactor: 1,
      child: _buildTrack(context, isLight),
    );
  }

  Widget _buildTrack(BuildContext context, bool isLight) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isLight ? _lightTrackBg : AppColors.darkBg2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: values.map((v) {
          final bool isActive = v == selected;
          final int? count = countOf?.call(v);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: InkWell(
              borderRadius: BorderRadius.circular(9),
              onTap: () => onChanged(v),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  // النشط: أبيض هادئ داخل الشريط الأزرق (الغامق: سطح أفتح).
                  color: isActive
                      ? (isLight ? Colors.white : AppColors.darkSurface)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      labelOf(v),
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13,
                        fontWeight:
                            isActive ? FontWeight.w800 : FontWeight.w600,
                        color: isLight
                            ? AppColors.lightText1
                            : AppColors.darkText1,
                      ),
                    ),
                    if (count != null) ...[
                      const SizedBox(width: 5),
                      Text(
                        '$count',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isLight
                              ? AppColors.lightText3
                              : AppColors.darkText3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
