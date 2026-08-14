// ════════════════════════════════════════════════════════════════════════════
// lab_orders_filter_bar.dart
//
// شريط فلاتر طلبات الأطباء (عدّاد + تبويبات الكل/جديد/تصنيع/جاهز)
// — مُستخرَج من lab_orders_page.dart ضمن تقسيم الصفحات.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/primitives/app_segmented_tabs.dart';

/// شريط الفلاتر العلوي لشبكة طلبات الأطباء.
class LabOrdersFilterBar extends StatelessWidget {
  const LabOrdersFilterBar({
    super.key,
    required this.total,
    required this.shown,
    required this.newCount,
    required this.mfgCount,
    required this.readyCount,
    required this.current,
    required this.onChange,
  });

  final int total;
  final int shown;
  final int newCount;
  final int mfgCount;
  final int readyCount;
  final String current;
  final ValueChanged<String> onChange;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Row(
      children: [
        Text(
          context.l10n.labOrdersCountOfTotal('$shown', '$total'),
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isLight ? AppColors.lightText3 : AppColors.darkText3,
          ),
        ),
        const Spacer(),
        AppSegmentedTabs<String>(
          values: const ['all', 'new', 'manufacturing', 'ready'],
          selected: current,
          labelOf: (v) => switch (v) {
            'new' => context.l10n.labOrdersFilterNew,
            'manufacturing' => context.l10n.labOrdersFilterManufacturing,
            'ready' => context.l10n.labOrdersFilterReady,
            _ => context.l10n.labOrdersFilterAll,
          },
          countOf: (v) => switch (v) {
            'new' => newCount,
            'manufacturing' => mfgCount,
            'ready' => readyCount,
            _ => total,
          },
          onChanged: onChange,
        ),
      ],
    );
  }
}
