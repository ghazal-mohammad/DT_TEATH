// ════════════════════════════════════════════════════════════════════════════
// warehouse_materials_filters.dart
//
// شريط فلاتر التصنيفات — part of warehouse_materials_content.dart (تقسيم الصفحات العملاقة).
// ════════════════════════════════════════════════════════════════════════════

part of 'warehouse_materials_content.dart';

// ══════════════════════════════════════════════════════════════════════════
//                          2) CATEGORY FILTER BAR
// ══════════════════════════════════════════════════════════════════════════

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({
    required this.active,
    required this.onChange,
    required this.total,
    required this.afterFilter,
    required this.isLight,
  });

  final _CategoryFilter active;
  final ValueChanged<_CategoryFilter> onChange;
  final int total;
  final int afterFilter;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _CategoryFilter.values
                .map((f) => _PillChip(
                      label: f.label(context.l10n),
                      selected: f == active,
                      onTap: () => onChange(f),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          context.l10n.whMaterialsCount(afterFilter, total),
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12,
            color: isLight ? AppColors.lightText3 : AppColors.darkText3,
          ),
        ),
      ],
    );
  }
}

class _PillChip extends StatelessWidget {
  const _PillChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = selected
        ? AppColors.primary
        : (isLight ? AppColors.baseComponent : AppColors.darkSurface);
    final fg = selected
        ? Colors.white
        : (isLight ? AppColors.lightText1 : AppColors.darkText1);
    final border = selected
        ? AppColors.primary
        : (isLight ? AppColors.lightBorder : AppColors.darkBorder);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ),
    );
  }
}

