// ════════════════════════════════════════════════════════════════════════════
// lab_invoice_from_company_dialog.dart
//
// فورم "فاتورة من شركة" — اسم شركة واحد + قائمة مواد قابلة للتكرار (اسم/كمية/
// وحدة/سبب لكل صف). اسم الشركة يتكرّر تلقائياً بكل عنصر بجسم الطلب (يبنيه
// الـ Repository، هالفورم بس بيجمع البيانات).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/forms/app_form_select.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import 'lab_mat_request_data.dart';

class LabInvoiceFromCompanyResult {
  const LabInvoiceFromCompanyResult({required this.companyName, required this.items, this.notes});
  final String companyName;
  final List<({String materialName, int quantity, String unit, String? reason})> items;
  final String? notes;
}

class LabInvoiceFromCompanyDialog extends StatefulWidget {
  const LabInvoiceFromCompanyDialog({super.key});

  static Future<LabInvoiceFromCompanyResult?> show(BuildContext context) {
    return showDialog<LabInvoiceFromCompanyResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => const LabInvoiceFromCompanyDialog(),
    );
  }

  @override
  State<LabInvoiceFromCompanyDialog> createState() => _LabInvoiceFromCompanyDialogState();
}

class _MaterialRow {
  _MaterialRow()
      : nameController = TextEditingController(),
        quantityController = TextEditingController(),
        reasonController = TextEditingController(),
        unit = kMatRequestUnits.first;
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController reasonController;
  String unit;

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    reasonController.dispose();
  }
}

class _LabInvoiceFromCompanyDialogState extends State<LabInvoiceFromCompanyDialog> {
  final TextEditingController _company = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  final List<_MaterialRow> _rows = [_MaterialRow()];
  String? _companyError;
  String? _rowsError;

  @override
  void dispose() {
    _company.dispose();
    _notes.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _addRow() => setState(() => _rows.add(_MaterialRow()));

  void _removeRow(int i) {
    if (_rows.length <= 1) return;
    setState(() {
      _rows.removeAt(i).dispose();
    });
  }

  void _submit() {
    final l10n = context.l10n;
    final company = _company.text.trim();
    setState(() {
      _companyError = company.isEmpty ? l10n.labReqCompanyNameRequired : null;
    });
    final items = <({String materialName, int quantity, String unit, String? reason})>[];
    var hasPartialRow = false;
    for (final row in _rows) {
      final name = row.nameController.text.trim();
      final qtyText = row.quantityController.text.trim();
      final qty = int.tryParse(qtyText) ?? 0;
      if (name.isEmpty && qtyText.isEmpty) continue; // صف فارغ بالكامل — تجاهل بصمت
      if (name.isEmpty || qty <= 0) {
        hasPartialRow = true;
        continue;
      }
      final reason = row.reasonController.text.trim();
      items.add((materialName: name, quantity: qty, unit: row.unit, reason: reason.isEmpty ? null : reason));
    }
    setState(() {
      _rowsError = hasPartialRow
          ? l10n.labReqQuantityRequired
          : (items.isEmpty ? l10n.labReqAtLeastOneItemRequired : null);
    });
    if (_companyError != null || _rowsError != null) return;
    final notes = _notes.text.trim();
    Navigator.of(context).pop(
      LabInvoiceFromCompanyResult(companyName: company, items: items, notes: notes.isEmpty ? null : notes),
    );
  }

  InputDecoration _decoration({String? errorText, String? hintText}) => InputDecoration(
        errorText: errorText,
        hintText: hintText,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSM)),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Dialog(
      backgroundColor: isLight ? Colors.white : AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.labReqFromCompanyTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
              const SizedBox(height: AppSizes.spaceLG),
              TextField(
                key: const Key('company_name_field'),
                controller: _company,
                inputFormatters: [LengthLimitingTextInputFormatter(120)],
                decoration: _decoration(errorText: _companyError, hintText: l10n.labReqFieldCompany),
              ),
              const SizedBox(height: AppSizes.spaceLG),
              for (var i = 0; i < _rows.length; i++) ...[
                _materialRow(context, i, isLight),
                const SizedBox(height: AppSizes.spaceMD),
              ],
              if (_rowsError != null)
                Text(_rowsError!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
              TextButton.icon(
                onPressed: _addRow,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.labReqAddMaterialRow),
              ),
              const SizedBox(height: AppSizes.spaceMD),
              TextField(
                controller: _notes,
                maxLines: 2,
                inputFormatters: [LengthLimitingTextInputFormatter(300)],
                decoration: _decoration(hintText: l10n.labReqNotesOptional),
              ),
              const SizedBox(height: AppSizes.spaceLG),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton.secondary(
                    label: l10n.cancel,
                    onPressed: () => Navigator.of(context).pop(),
                    size: AppButtonSize.small,
                  ),
                  const SizedBox(width: 10),
                  AppButton.primary(
                    label: l10n.labReqSubmit,
                    onPressed: _submit,
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

  Widget _materialRow(BuildContext context, int i, bool isLight) {
    final l10n = context.l10n;
    final row = _rows[i];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                key: Key('material_name_$i'),
                controller: row.nameController,
                inputFormatters: [LengthLimitingTextInputFormatter(120)],
                decoration: _decoration(hintText: l10n.labReqFieldMaterial),
              ),
            ),
            const SizedBox(width: AppSizes.spaceSM),
            Expanded(
              flex: 2,
              child: TextField(
                key: Key('material_qty_$i'),
                controller: row.quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _decoration(hintText: l10n.colQuantity),
              ),
            ),
            const SizedBox(width: AppSizes.spaceSM),
            Expanded(
              flex: 2,
              child: AppDropdownMenuTheme(
                child: DropdownButtonFormField<String>(
                  initialValue: row.unit,
                  isExpanded: true,
                  decoration: _decoration(),
                  dropdownColor: isLight ? Colors.white : AppColors.darkBg1,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                  items: [for (final u in kMatRequestUnits) DropdownMenuItem(value: u, child: Text(u))],
                  onChanged: (v) => setState(() => row.unit = v ?? row.unit),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: _rows.length > 1 ? () => _removeRow(i) : null,
              tooltip: l10n.labReqRemoveRow,
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spaceSM),
        TextField(
          key: Key('material_reason_$i'),
          controller: row.reasonController,
          inputFormatters: [LengthLimitingTextInputFormatter(200)],
          decoration: _decoration(hintText: l10n.labReqReasonHint),
        ),
      ],
    );
  }
}
