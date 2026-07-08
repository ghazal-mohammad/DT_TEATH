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
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/forms/app_form_select.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../domain/entities/warehouse_material_ref.dart';
import 'lab_mat_request_data.dart';

/// نتيجة مودال طلب المادة (القيم المُدخَلة بعد الإرسال).
class LabMaterialRequestResult {
  const LabMaterialRequestResult({
    required this.material,
    required this.quantity,
    required this.unit,
    this.materialId,
    this.company,
    this.reason,
  });

  final String material;
  final String quantity;
  final String unit;

  /// معرّف مادة موجودة من الكتالوج (null = مادة جديدة بالاسم الحر).
  final int? materialId;
  final String? company;
  final String? reason;
}

/// مودال إرسال طلب مادة من المخبر للمستودع. [catalog] كتالوج مواد المستودع
/// لاقتراح مادة موجودة (اختيارية — يعمل النموذج بالإدخال الحر بدونها).
class LabMaterialRequestDialog extends StatefulWidget {
  const LabMaterialRequestDialog({super.key, this.catalog = const []});

  final List<WarehouseMaterialRef> catalog;

  static Future<LabMaterialRequestResult?> show(
    BuildContext context, {
    List<WarehouseMaterialRef> catalog = const [],
  }) {
    return showDialog<LabMaterialRequestResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => LabMaterialRequestDialog(catalog: catalog),
    );
  }

  @override
  State<LabMaterialRequestDialog> createState() =>
      _LabMaterialRequestDialogState();
}

class _LabMaterialRequestDialogState extends State<LabMaterialRequestDialog> {
  final TextEditingController _material = TextEditingController();
  final FocusNode _materialFocus = FocusNode();
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _company = TextEditingController();
  final TextEditingController _reason = TextEditingController();
  String _unit = kMatRequestUnits.first;
  String? _materialError;
  String? _quantityError;

  /// معرّف مادة مختارة من الكتالوج (null = مادة جديدة بالاسم الحر).
  int? _selectedMaterialId;

  @override
  void dispose() {
    _material.dispose();
    _materialFocus.dispose();
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
      materialId: _selectedMaterialId,
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
              _materialField(l10n, isLight),
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
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(9),
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
                inputFormatters: [LengthLimitingTextInputFormatter(120)],
                decoration: _decoration(),
              ),
              const SizedBox(height: AppSizes.spaceMD),
              _label(l10n.labReqFieldReason, isLight),
              const SizedBox(height: 6),
              TextField(
                controller: _reason,
                maxLines: 2,
                inputFormatters: [LengthLimitingTextInputFormatter(300)],
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

  /// حقل المادة: combobox يبحث في كتالوج المستودع مع السماح بإدخال حر (مادة
  /// جديدة). اختيار عنصر من الكتالوج يضبط [_selectedMaterialId] ويملأ الوحدة.
  Widget _materialField(AppLocalizations l10n, bool isLight) {
    // بلا كتالوج → حقل نصّي حر بسيط (سلوك سابق).
    if (widget.catalog.isEmpty) {
      return TextField(
        controller: _material,
        focusNode: _materialFocus,
        autofocus: true,
        inputFormatters: [LengthLimitingTextInputFormatter(120)],
        decoration: _decoration(errorText: _materialError),
      );
    }
    return RawAutocomplete<WarehouseMaterialRef>(
      textEditingController: _material,
      focusNode: _materialFocus,
      optionsBuilder: (value) {
        final q = value.text.trim();
        if (q.isEmpty) return const Iterable<WarehouseMaterialRef>.empty();
        return widget.catalog.where((m) => m.name.contains(q));
      },
      displayStringForOption: (m) => m.name,
      onSelected: (m) {
        setState(() {
          _selectedMaterialId = m.materialId;
          if (kMatRequestUnits.contains(m.unit)) _unit = m.unit;
          _materialError = null;
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: true,
          inputFormatters: [LengthLimitingTextInputFormatter(120)],
          decoration: _decoration(
            errorText: _materialError,
            hintText: l10n.labReqMaterialPickHint,
          ),
          onChanged: _onMaterialChanged,
          onSubmitted: (_) => onFieldSubmitted(),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: AlignmentDirectional.topStart,
          child: Material(
            elevation: 4,
            color: isLight ? Colors.white : AppColors.darkBg1,
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220, maxWidth: 440),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, i) {
                  final m = options.elementAt(i);
                  return ListTile(
                    dense: true,
                    title: Text(m.name),
                    subtitle: m.unit.isEmpty ? null : Text(m.unit),
                    onTap: () => onSelected(m),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// عند تغيّر النص بعد اختيار مادة: إن اختلف عن اسمها ⇒ مادة جديدة (نُلغي المعرّف).
  void _onMaterialChanged(String v) {
    if (_selectedMaterialId == null) return;
    final sel =
        widget.catalog.where((m) => m.materialId == _selectedMaterialId);
    if (sel.isEmpty || v.trim() != sel.first.name) {
      setState(() => _selectedMaterialId = null);
    }
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
