// ════════════════════════════════════════════════════════════════════════════
// app_filter_chip_bar.dart
//
// Bar أفقي من filter chips قابل للتكرار — generic widget.
//
// 🎯 الهدف:
//   widget واحد يستخدم في Materials, Orders, Invoices, Notifications.
//   يأخذ generic type T للـ filter values.
//
// 🔮 قابلية التوسيع:
//   - يدعم emoji optional قبل النص
//   - يدعم count badge (مثل "الكل (247)")
//   - يلتفّ تلقائياً على شاشات صغيرة (Wrap)
//
// مثال:
// ```dart
// AppFilterChipBar<MaterialFilter>(
//   options: MaterialFilter.values,
//   activeOption: state.activeFilter,
//   labelBuilder: (f) => f.label(context),
//   countBuilder: (f) => f.countIn(state.materials),
//   emojiBuilder: (f) => f.emoji,
//   onChanged: cubit.setFilter,
// )
// ```
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../primitives/app_filter_chip.dart';

/// Bar من Filter Chips متجاور (يلتفّ تلقائياً).
///
/// **Generic** على نوع الـ option (T) — مثل enum أو String.
class AppFilterChipBar<T> extends StatelessWidget {
  const AppFilterChipBar({
    super.key,
    required this.options,
    required this.activeOption,
    required this.labelBuilder,
    required this.onChanged,
    this.countBuilder,
    this.emojiBuilder,
    this.spacing = 4.0,
    this.runSpacing = 6.0,
  });

  /// كل القيم المتاحة (مثل MaterialFilter.values).
  final List<T> options;

  /// القيمة النشطة حالياً.
  final T activeOption;

  /// كيف يحوّل T إلى نص (يُستخدم context للـ l10n).
  final String Function(T option) labelBuilder;

  /// callback عند اختيار قيمة جديدة.
  final ValueChanged<T> onChanged;

  /// builder اختياري للعدد المعروض بجانب النص (مثل "الكل (247)").
  /// إذا أرجع null، لا يظهر العدد.
  final int? Function(T option)? countBuilder;

  /// builder اختياري لـ emoji قبل النص (مثل "⚠ ينفد").
  /// إذا أرجع null، لا يظهر emoji.
  final String? Function(T option)? emojiBuilder;

  /// المسافة الأفقية بين chips.
  final double spacing;

  /// المسافة العمودية عند الالتفاف.
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: options.map((opt) => _buildChip(context, opt)).toList(),
    );
  }

  /// بناء chip واحد.
  Widget _buildChip(BuildContext context, T option) {
    final label = labelBuilder(option);
    final emoji = emojiBuilder?.call(option);
    final count = countBuilder?.call(option);

    // تركيب النص النهائي: emoji + label + count
    final buffer = StringBuffer();
    if (emoji != null && emoji.isNotEmpty) {
      buffer.write('$emoji ');
    }
    buffer.write(label);
    if (count != null) {
      buffer.write(' ($count)');
    }

    return AppFilterChip(
      label: buffer.toString(),
      isSelected: option == activeOption,
      onTap: () => onChanged(option),
    );
  }
}
