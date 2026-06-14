// ════════════════════════════════════════════════════════════════════════════
// lab_mat_request_dialog.dart
//
// مودال "طلب مادة جديدة" من المخبر للمستودع (اسم/كمية+وحدة/شركة/سبب) ونتيجته.
// قرار الفريق 2026-06-12: المادة غير الموجودة بالمستودع تُطلب بهذا الفورم وتظهر
// عند المستودع كمادة معلّقة بانتظار الإضافة. مُستخرَج من lab_material_requests_page.
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

/// نتيجة مودال طلب المادة (القيم المُدخَلة بعد الإرسال).
class LabMaterialRequestResult {
  const LabMaterialRequestResult({
    required this.material,
    required this.quantity,
    required this.unit,
    this.company,
    this.reason,
  });

  final String material;
  final String quantity;
  final String unit;
  final String? company;
  final String? reason;
}

/// مودال إرسال طلب مادة جديدة من المخبر للمستودع.
class LabMaterialRequestDialog extends StatefulWidget {
  const LabMaterialRequestDialog({super.key});

  static Future<LabMaterialRequestResult?> show(BuildContext context) {
    return showDialog<LabMaterialRequestResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => const LabMaterialRequestDialog(),
    );
  }

  @override
  State<LabMaterialRequestDialog> createState() =>
      _LabMaterialRequestDialogState();
}

class _LabMaterialRequestDialogState extends State<LabMaterialRequestDialog> {
  final TextEditingController _material = TextEditingController();
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _company = TextEditingController();
  final TextEditingController _reason = TextEditingController();
  String _unit = kMatRequestUnits.first;
  String? _materialError;
  String? _quantityError;

  @override
  void dispose() {
    _material.dispose();
    _quantity.dispose();
    _company.dispose();
    _reason.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = context.l10n;
    final name = _material.text.trim();
    final qty = int.tryParse(_quantity.text.trim()) ?? 0;
    setState(() {
      _materialError = name.isEmpty ? l10n.labReqMaterialRequired : null;
      _quantityError = qty <= 0 ? l10n.labReqQuantityRequired : null;
    });
    if (_materialError != null || _quantityError != null) return;
    final company = _company.text.trim();
    final reason = _reason.text.trim();
    Navigator.of(context).pop(LabMaterialRequestResult(
      material: name,
      quantity: '$qty',
      unit: _unit,
      company: company.isEmpty ? null : company,
      reason: reason.isEmpty ? null : reason,
    ));
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.labReqNewRequest,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
              const SizedBox(height: AppSizes.spaceLG),
              _label(l10n.labReqFieldMaterial, isLight),
              const SizedBox(height: 6),
              TextField(
                controller: _material,
                autofocus: true,
                decoration: _decoration(errorText: _materialError),
              ),
              const SizedBox(height: AppSizes.spaceMD),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label(l10n.colQuantity, isLight),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _quantity,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: _decoration(errorText: _quantityError),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label(l10n.labReqFieldUnit, isLight),
                        const SizedBox(height: 6),
                        AppDropdownMenuTheme(
                          child: DropdownButtonFormField<String>(
                            initialValue: _unit,
                            isExpanded: true,
                            decoration: _decoration(),
                            dropdownColor:
                                isLight ? Colors.white : AppColors.darkBg1,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusLG),
                            items: [
                              for (final u in kMatRequestUnits)
                                DropdownMenuItem(value: u, child: Text(u)),
                            ],
                            onChanged: (v) =>
                                setState(() => _unit = v ?? _unit),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceMD),
              _label(l10n.labReqFieldCompany, isLight),
              const SizedBox(height: 6),
              TextField(
                controller: _company,
                decoration: _decoration(),
              ),
              const SizedBox(height: AppSizes.spaceMD),
              _label(l10n.labReqFieldReason, isLight),
              const SizedBox(height: 6),
              TextField(
                controller: _reason,
                maxLines: 2,
                decoration: _decoration(hintText: l10n.labReqReasonHint),
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

  Widget _label(String text, bool isLight) => Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: isLight ? AppColors.lightText1 : AppColors.darkText1,
        ),
      );

  InputDecoration _decoration({String? errorText, String? hintText}) =>
      InputDecoration(
        errorText: errorText,
        hintText: hintText,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        ),
      );
}
