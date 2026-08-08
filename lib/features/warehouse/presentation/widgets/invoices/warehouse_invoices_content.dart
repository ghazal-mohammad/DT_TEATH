// ════════════════════════════════════════════════════════════════════════════
// warehouse_invoices_content.dart
//
// فواتير الشراء الواردة للمستودع — **مربوطة بالباك** (showAllPurchaseInvoices).
// كل فاتورة = مورّد + تاريخ + إجمالي + بنود؛ العرض ببطاقات + مودال تفاصيل.
// إنشاء/تعديل الفاتورة عبر WarehousePurchaseInvoiceFormDialog.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../bloc/purchase_invoices_cubit.dart';
import '../../../domain/entities/purchase_invoice.dart';
import 'warehouse_invoice_details_dialog.dart';
import 'warehouse_purchase_invoice_form_dialog.dart';

/// تنسيق مبلغ بفواصل آلاف.
String formatMoney(num v) {
  final s = v.toStringAsFixed(0);
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

class WarehouseInvoicesContent extends StatelessWidget {
  const WarehouseInvoicesContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return BlocBuilder<PurchaseInvoicesCubit, PurchaseInvoicesState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Spacer(),
                AppButton(
                  label: '+ ${context.l10n.invAddInvoice}',
                  onPressed: () => _openCreate(context),
                  variant: AppButtonVariant.primary,
                  size: AppButtonSize.small,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _statsRow(context, state, isLight),
            const SizedBox(height: 16),
            _body(context, state, isLight),
          ],
        );
      },
    );
  }

  Future<void> _openCreate(BuildContext context) async {
    final result = await WarehousePurchaseInvoiceFormDialog.show(context);
    if (result == null || !context.mounted) return;
    final cubit = context.read<PurchaseInvoicesCubit>();
    final ok = await cubit.create(
      supplierName: result.supplierName,
      invoiceDate: result.invoiceDate,
      items: result.items,
      notes: result.notes,
    );
    if (!context.mounted) return;
    _showResultSnackBar(
        context, ok, context.l10n.invCreateSuccess, cubit.state.actionError);
  }

  static Future<void> openEdit(BuildContext context, PurchaseInvoice invoice) async {
    final result = await WarehousePurchaseInvoiceFormDialog.show(
      context,
      initialInvoice: invoice,
    );
    if (result == null || !context.mounted) return;
    final cubit = context.read<PurchaseInvoicesCubit>();
    final ok = await cubit.update(
      invoice.id,
      supplierName: result.supplierName,
      invoiceDate: result.invoiceDate,
      notes: result.notes,
    );
    if (!context.mounted) return;
    _showResultSnackBar(
        context, ok, context.l10n.invUpdateSuccess, cubit.state.actionError);
  }

  static void _showResultSnackBar(BuildContext context, bool ok,
      String successMessage, String? errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? successMessage : (errorMessage ?? successMessage)),
      backgroundColor: ok ? AppColors.statusSuccess : AppColors.alertRed,
    ));
  }

  Widget _statsRow(
      BuildContext context, PurchaseInvoicesState state, bool isLight) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            icon: Icons.receipt_long_outlined,
            value: state.count.toString(),
            label: l10n.invStatThisMonth,
            accent: AppColors.statusInfo,
            isLight: isLight,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatBox(
            icon: Icons.payments_outlined,
            value: formatMoney(state.totalAmount),
            label: l10n.invGrandTotalLabel,
            accent: AppColors.statusSuccess,
            isLight: isLight,
          ),
        ),
      ],
    );
  }

  Widget _body(
      BuildContext context, PurchaseInvoicesState state, bool isLight) {
    if (state.status == InvoicesStatus.loading && state.invoices.isEmpty) {
      return const Padding(
          padding: EdgeInsets.all(48),
          child: Center(child: CircularProgressIndicator()));
    }
    if (state.status == InvoicesStatus.error && state.invoices.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(36),
        child: Center(
          child: Text(state.errorMessage ?? '—',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.alertRed)),
        ),
      );
    }
    if (state.invoices.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: AppEmptyState(
          icon: Icons.receipt_long_outlined,
          title: context.l10n.invEmptyTitle,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final inv in state.invoices) ...[
          _InvoiceCard(invoice: inv, isLight: isLight),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
    required this.isLight,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color accent;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.darkSurface,
        border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 19, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isLight
                            ? AppColors.lightText1
                            : AppColors.darkText1)),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.lightText3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.invoice, required this.isLight});
  final PurchaseInvoice invoice;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final txt1 = isLight ? AppColors.lightText1 : AppColors.darkText1;
    final txt3 = isLight ? AppColors.lightText3 : AppColors.darkText3;
    final date = invoice.invoiceDate;
    final dateStr = date == null
        ? '—'
        : '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return InkWell(
      onTap: () => WarehouseInvoiceDetailsDialog.show(context, invoice),
      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : AppColors.darkSurface,
          border: Border.all(
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      invoice.supplierName.isEmpty
                          ? l10n.invInvoiceNumber(invoice.id)
                          : invoice.supplierName,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w800, color: txt1)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.event_outlined, size: 13, color: txt3),
                      const SizedBox(width: 4),
                      Text(dateStr,
                          style: AppTextStyles.bodySmall.copyWith(color: txt3)),
                      const SizedBox(width: 12),
                      Icon(Icons.inventory_2_outlined, size: 13, color: txt3),
                      const SizedBox(width: 4),
                      Text(l10n.invItemsCountLabel(invoice.itemsCount),
                          style: AppTextStyles.bodySmall.copyWith(color: txt3)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${formatMoney(invoice.totalAmount)} ل.س',
                    style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.statusSuccess)),
                const SizedBox(height: 2),
                Text(l10n.invDetailsTitle,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
