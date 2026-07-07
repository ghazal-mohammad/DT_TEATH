// ════════════════════════════════════════════════════════════════════════════
// lab_products_table.dart
//
// جدول كتالوج منتجات المخبر (اسم/نوع/مادة/سعر/مدة + تعديل) — مُستخرَج من
// lab_products_page.dart ضمن تقسيم الصفحات العملاقة.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/data/app_data_table.dart';
import '../../../domain/entities/lab_product.dart';

/// جدول عرض كتالوج المنتجات مع زر تعديل لكل صف.
class LabProductsTable extends StatelessWidget {
  const LabProductsTable({
    super.key,
    required this.products,
    required this.onEdit,
    required this.onDelete,
  });

  final List<LabProduct> products;
  final void Function(LabProduct) onEdit;
  final void Function(LabProduct) onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.darkBg1,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceLG),
        child: AppDataTable<LabProduct>(
          data: products,
          headerBackground: isLight ? AppColors.tableHeader : AppColors.darkBg2,
          emptyMessage: l10n.labProdEmpty,
          emptyIcon: Icons.category_outlined,
          columns: [
            AppDataColumn<LabProduct>(
              label: l10n.labProdFieldName,
              flex: 3,
              cellBuilder: (p) => Text(
                p.name,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
            ),
            AppDataColumn<LabProduct>(
              label: l10n.labProdColType,
              flex: 2,
              cellBuilder: (p) =>
                  Text(p.type, style: AppTextStyles.bodyMedium),
            ),
            AppDataColumn<LabProduct>(
              label: l10n.colMaterial,
              flex: 2,
              cellBuilder: (p) =>
                  Text(p.material, style: AppTextStyles.bodyMedium),
            ),
            AppDataColumn<LabProduct>(
              label: l10n.labProdColPrice,
              flex: 2,
              cellBuilder: (p) => Text(
                _formatPrice(p.price),
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
            ),
            AppDataColumn<LabProduct>(
              label: l10n.labProdColDuration,
              flex: 2,
              cellBuilder: (p) => Text(
                '${p.productionDays} ${l10n.labProdDaysUnit}',
                style: AppTextStyles.bodySmall,
              ),
            ),
            AppDataColumn<LabProduct>(
              label: '',
              flex: 2,
              cellBuilder: (p) => Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _IconAction(
                    icon: Icons.edit_outlined,
                    tooltip: l10n.labProdEditTitle,
                    onTap: () => onEdit(p),
                  ),
                  const SizedBox(width: AppSizes.spaceSM),
                  _IconAction(
                    icon: Icons.delete_outline_rounded,
                    tooltip: l10n.delete,
                    danger: true,
                    onTap: () => onDelete(p),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  /// نمط الحذف — لون أحمر للأيقونة (إجراء حذر).
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Semantics(
          button: true,
          label: tooltip,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 32,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isLight ? Colors.white : AppColors.darkBg1,
                border: Border.all(
                    color:
                        isLight ? AppColors.lightBorder : AppColors.darkBorder),
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              ),
              child: Icon(
                icon,
                size: 17,
                color: danger
                    ? AppColors.alertRed
                    : (isLight ? AppColors.lightText2 : AppColors.darkText2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
