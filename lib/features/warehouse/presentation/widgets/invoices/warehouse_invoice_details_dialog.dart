// ════════════════════════════════════════════════════════════════════════════
// warehouse_invoice_details_dialog.dart
//
// تفاصيل فاتورة شراء: المورّد + التاريخ + البنود (مادة/كمية/سعر/إجمالي) + الإجمالي.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../domain/entities/purchase_invoice.dart';
import 'warehouse_invoices_content.dart';

class WarehouseInvoiceDetailsDialog extends StatelessWidget {
  const WarehouseInvoiceDetailsDialog({super.key, required this.invoice});

  final PurchaseInvoice invoice;

  static Future<void> show(BuildContext context, PurchaseInvoice invoice) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => WarehouseInvoiceDetailsDialog(invoice: invoice),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final date = invoice.invoiceDate;
    final dateStr = date == null
        ? '—'
        : '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return Dialog(
      backgroundColor: isLight ? Colors.white : AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.invDetailsTitle,
                  style: AppTextStyles.headlineSmall.copyWith(
                      color:
                          isLight ? AppColors.lightText1 : AppColors.darkText1)),
              const SizedBox(height: 4),
              Text(
                  '${l10n.invSupplierLabel}: '
                  '${invoice.supplierName.isEmpty ? "—" : invoice.supplierName} · $dateStr',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.lightText3)),
              if (invoice.createdBy != null)
                Text('${l10n.invCreatedByLabel}: ${invoice.createdBy}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.lightText3)),
              const SizedBox(height: AppSizes.spaceMD),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final it in invoice.items)
                        _itemRow(context, it, isLight),
                      if (invoice.notes != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceTintCool2,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusSM),
                          ),
                          child: Text(invoice.notes!,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.lightText2)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceMD),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.statusSuccess.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(l10n.invLineTotalLabel,
                          style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isLight
                                  ? AppColors.lightText1
                                  : AppColors.darkText1)),
                    ),
                    Text('${formatMoney(invoice.totalAmount)} ل.س',
                        style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.statusSuccess)),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spaceMD),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton.secondary(
                    label: l10n.cancel,
                    onPressed: () => Navigator.of(context).pop(),
                    size: AppButtonSize.small,
                  ),
                  const SizedBox(width: 8),
                  AppButton.primary(
                    label: l10n.edit,
                    icon: Icons.edit_outlined,
                    onPressed: () {
                      Navigator.of(context).pop();
                      WarehouseInvoicesContent.openEdit(context, invoice);
                    },
                    size: AppButtonSize.small,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemRow(
      BuildContext context, PurchaseInvoiceItem it, bool isLight) {
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(it.materialName.isEmpty ? '—' : it.materialName,
                    style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isLight
                            ? AppColors.lightText1
                            : AppColors.darkText1)),
                Text(
                    '${it.quantity} ${it.unit} · '
                    '${l10n.invUnitPriceLabel} ${formatMoney(it.unitPrice)}',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.lightText3, fontSize: 11.5)),
              ],
            ),
          ),
          Text('${formatMoney(it.totalPrice)} ل.س',
              style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w800, color: AppColors.primary)),
        ],
      ),
    );
  }
}
