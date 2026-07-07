// ════════════════════════════════════════════════════════════════════════════
// app_text_size_selector.dart
//
// مُنتقي حجم الخط (وصولية) الموحّد — يُستخدم في إعدادات المخبر والمستودع معاً.
// أربع بطاقات (صغير/عادي/كبير/أكبر) تُطبَّق فوراً على كل التطبيق عبر
// TextScaleCubit (MediaQuery.textScaler) بلا مسّ أي ودجت أو تصميم.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/build_context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../bloc/text_scale_cubit.dart';

/// صف من أربع بطاقات لاختيار حجم الخط — يتفاعل مع [TextScaleCubit].
class AppTextSizeSelector extends StatelessWidget {
  const AppTextSizeSelector({super.key, required this.isLight});

  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final AppTextScale current = context.watch<TextScaleCubit>().state;
    final options = <(String, AppTextScale)>[
      (context.l10n.settingsTextSizeSmall, AppTextScale.small),
      (context.l10n.settingsTextSizeNormal, AppTextScale.normal),
      (context.l10n.settingsTextSizeLarge, AppTextScale.large),
      (context.l10n.settingsTextSizeXLarge, AppTextScale.xlarge),
    ];
    return Row(
      children: [
        for (int i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSizes.spaceSM),
          Expanded(
            child: _TextSizeChip(
              label: options[i].$1,
              level: options[i].$2,
              selected: options[i].$2 == current,
              isLight: isLight,
              onTap: () =>
                  context.read<TextScaleCubit>().setScale(options[i].$2),
            ),
          ),
        ],
      ],
    );
  }
}

/// بطاقة حجم واحد — تعرض "أ" بحجم متدرّج + التسمية، مع تمييز المختار.
class _TextSizeChip extends StatelessWidget {
  const _TextSizeChip({
    required this.label,
    required this.level,
    required this.selected,
    required this.isLight,
    required this.onTap,
  });

  final String label;
  final AppTextScale level;
  final bool selected;
  final bool isLight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = isLight ? AppColors.primary : AppColors.brand;
    final Color textColor = isLight
        ? AppColors.lightText1
        : AppColors.darkText1;
    // معاينة "أ" بتدرّج واضح حسب المستوى (13→25).
    final double previewSize = 13 + level.index * 4;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        value: selected ? 'محدّد' : 'غير محدّد',
        onTapHint: 'تغيير حجم الخط',
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceMD),
            decoration: BoxDecoration(
              color: selected
                  ? accent.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              border: Border.all(
                color: selected
                    ? accent
                    : (isLight ? AppColors.lightBorder : AppColors.darkBorder),
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'أ',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontWeight: FontWeight.w800,
                    fontSize: previewSize,
                    color: selected ? accent : textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: textColor,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
