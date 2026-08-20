// ════════════════════════════════════════════════════════════════════════════
// lab_invoice_type_chooser_dialog.dart
//
// خطوة اختيار نوع الفاتورة الجديدة — من مواد المستودع، أو من شركة خارجية.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';

enum LabInvoiceType { warehouse, company }

class LabInvoiceTypeChooserDialog extends StatelessWidget {
  const LabInvoiceTypeChooserDialog({super.key});

  static Future<LabInvoiceType?> show(BuildContext context) {
    return showDialog<LabInvoiceType>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => const LabInvoiceTypeChooserDialog(),
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
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.labReqChooseTypeTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
              const SizedBox(height: AppSizes.spaceLG),
              _OptionCard(
                icon: AppIcons.materials,
                title: l10n.labReqFromWarehouseTitle,
                subtitle: l10n.labReqFromWarehouseDesc,
                onTap: () => Navigator.of(context).pop(LabInvoiceType.warehouse),
              ),
              const SizedBox(height: AppSizes.spaceMD),
              _OptionCard(
                icon: AppIcons.supplier,
                title: l10n.labReqFromCompanyTitle,
                subtitle: l10n.labReqFromCompanyDesc,
                onTap: () => Navigator.of(context).pop(LabInvoiceType.company),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.spaceMD),
          decoration: BoxDecoration(
            border: Border.all(color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accent),
              const SizedBox(width: AppSizes.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
                    Text(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
