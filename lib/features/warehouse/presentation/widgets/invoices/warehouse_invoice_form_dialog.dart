// ════════════════════════════════════════════════════════════════════════════
// warehouse_invoice_form_dialog.dart
//
// Dialog لإضافة فاتورة شراء جديدة. modal مركزي بسيط مع validation.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/forms/app_date_picker.dart';
import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../data/mock/warehouse_pages_mock_data.dart';

class WarehouseInvoiceFormDialog extends StatefulWidget {
  const WarehouseInvoiceFormDialog({super.key});

  static Future<WarehouseInvoiceItem?> show(BuildContext context) {
    return showDialog<WarehouseInvoiceItem>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => const WarehouseInvoiceFormDialog(),
    );
  }

  @override
  State<WarehouseInvoiceFormDialog> createState() =>
      _WarehouseInvoiceFormDialogState();
}

class _WarehouseInvoiceFormDialogState
    extends State<WarehouseInvoiceFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final _invoiceNumberCtrl = TextEditingController();
  final _supplierCtrl = TextEditingController();
  final _itemsCountCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    // pre-fill رقم الفاتورة تلقائياً
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    _invoiceNumberCtrl.text =
        'INV-${DateTime.now().year}-${ts.substring(ts.length - 4)}';
  }

  @override
  void dispose() {
    _invoiceNumberCtrl.dispose();
    _supplierCtrl.dispose();
    _itemsCountCtrl.dispose();
    _totalCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showAppDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final invoice = WarehouseInvoiceItem(
      id: 'i_${DateTime.now().millisecondsSinceEpoch}',
      invoiceNumber: _invoiceNumberCtrl.text.trim(),
      type: InvoiceType.purchase,
      materialName: '—',
      quantity: _itemsCountCtrl.text.trim(),
      unit: 'صنف',
      unitPrice: 0,
      total: double.tryParse(_totalCtrl.text.trim()) ?? 0,
      date: _formatDate(_date),
      supplier: _supplierCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    Navigator.of(context).pop(invoice);
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
      backgroundColor:
          isLight ? AppColors.baseComponent : AppColors.darkSurface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(isLight: isLight, onClose: () => Navigator.pop(context)),
                const SizedBox(height: 14),
                AppFormField(
                  label: context.l10n.invColNumber,
                  controller: _invoiceNumberCtrl,
                  required: true,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? context.l10n.fieldRequired
                      : null,
                ),
                AppFormField(
                  label: context.l10n.invFormSupplier,
                  controller: _supplierCtrl,
                  required: true,
                  hint: context.l10n.invFormSupplierHint,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? context.l10n.fieldRequired
                      : null,
                ),
                // التاريخ — حقل قراءة فقط يفتح date picker.
                _DateField(
                  label: context.l10n.invFormDate,
                  isLight: isLight,
                  valueText: _formatDate(_date),
                  onTap: _pickDate,
                ),
                Row(
                  children: [
                    Expanded(
                      child: AppFormField(
                        label: context.l10n.invColItemCount,
                        controller: _itemsCountCtrl,
                        required: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return context.l10n.fieldRequired;
                          }
                          final n = int.tryParse(v.trim());
                          if (n == null || n <= 0) {
                            return context.l10n.fieldInvalidNumber;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppFormField(
                        label: context.l10n.invColTotalSyp,
                        controller: _totalCtrl,
                        required: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return context.l10n.fieldRequired;
                          }
                          final n = double.tryParse(v.trim());
                          if (n == null || n <= 0) {
                            return context.l10n.fieldInvalidAmount;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                AppFormField(
                  label: context.l10n.invFormNotes,
                  controller: _notesCtrl,
                  hint: context.l10n.fieldOptional,
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // RTL: أوّل child = يمين. الزر الأساسي على اليسار → آخر.
                    Expanded(
                      child: AppButton(
                        label: context.l10n.cancel,
                        onPressed: () => Navigator.pop(context),
                        variant: AppButtonVariant.secondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppButton(
                        label: context.l10n.invFormSave,
                        onPressed: _submit,
                        variant: AppButtonVariant.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isLight, required this.onClose});
  final bool isLight;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // RTL: العنوان أول → يمين، زر إغلاق آخر → يسار.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.invFormTitle,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color:
                      isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                context.l10n.invFormSubtitle,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  color:
                      isLight ? AppColors.lightText3 : AppColors.darkText3,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onClose,
          icon: Icon(
            Icons.close_rounded,
            size: 20,
            color: isLight ? AppColors.lightText2 : AppColors.darkText2,
          ),
          splashRadius: 18,
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.isLight,
    required this.valueText,
    required this.onTap,
  });

  final String label;
  final bool isLight;
  final String valueText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text1 = isLight ? AppColors.lightText1 : AppColors.darkText1;
    final text2 = isLight ? AppColors.lightText2 : AppColors.darkText2;
    final bg = isLight ? const Color(0xFFF8F9FC) : AppColors.darkBg2;
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: text2,
              ),
            ),
          ),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
              decoration: BoxDecoration(
                color: bg,
                border: Border.all(color: AppColors.lightBorder),
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              ),
              child: Row(
                children: [
                  // RTL: التاريخ نص → يمين، الأيقونة → يسار.
                  Expanded(
                    child: Text(
                      valueText,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: text1,
                      ),
                    ),
                  ),
                  Icon(Icons.calendar_today_outlined, size: 16, color: text2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
