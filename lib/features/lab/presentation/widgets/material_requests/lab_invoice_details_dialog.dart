// ════════════════════════════════════════════════════════════════════════════
// lab_invoice_details_dialog.dart
//
// عرض تفاصيل فاتورة كاملة (كل items[]/newItems[]) — بلا أزرار إجراء تنفيذ
// (المخبر هون هو مُنشئ الفاتورة مو مُنفّذها). زر طباعة اختياري.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../domain/entities/lab_material_request.dart';

class LabInvoiceDetailsDialog extends StatelessWidget {
  const LabInvoiceDetailsDialog({super.key, required this.invoice, this.onPrint});

  final MatRequest invoice;
  final VoidCallback? onPrint;

  static Future<void> show(BuildContext context, MatRequest invoice, {VoidCallback? onPrint}) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => LabInvoiceDetailsDialog(invoice: invoice, onPrint: onPrint),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Dialog(
      backgroundColor: isLight ? Colors.white : AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.labReqInvoiceNumber(invoice.id),
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                      ),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              Text(l10n.labReqDetailsTitle, style: AppTextStyles.bodySmall),
              const SizedBox(height: AppSizes.spaceMD),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final it in invoice.items)
                      _row(context, it.materialName, '${it.quantityRequested}', notes: it.notes),
                    for (final it in invoice.newItems)
                      _row(context, it.materialName, '${it.quantity} ${it.unit}',
                          company: it.companyName, notes: it.reason),
                  ],
                ),
              ),
              if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.spaceMD),
                Text(invoice.notes!, style: AppTextStyles.bodySmall),
              ],
              const SizedBox(height: AppSizes.spaceLG),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onPrint != null)
                    AppButton.secondary(label: l10n.labReqPrint, onPressed: onPrint, size: AppButtonSize.small),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String name, String qty, {String? company, String? notes}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceSM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                if (company != null) Text(company, style: AppTextStyles.bodySmall),
                if (notes != null) Text(notes, style: AppTextStyles.bodySmall.copyWith(color: AppColors.statusInfo)),
              ],
            ),
          ),
          Text(qty, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
