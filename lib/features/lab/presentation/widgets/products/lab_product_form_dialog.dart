// ════════════════════════════════════════════════════════════════════════════
// lab_product_form_dialog.dart
//
// مودال إضافة/تعديل منتج المخبر + نتيجته — مُستخرَج من lab_products_page.dart
// ضمن تقسيم الصفحات العملاقة.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/forms/app_form_select.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import 'lab_product_data.dart';

/// نتيجة مودال المنتج (القيم المُدخَلة بعد الحفظ).
class LabProductFormResult {
  LabProductFormResult({
    required this.name,
    required this.type,
    required this.material,
    required this.price,
    required this.productionDays,
  });

  final String name;
  final String type;
  final String material;
  final int price;
  final int productionDays;
}

/// مودال إضافة/تعديل منتج. مرّر [existing] للتعديل أو null للإضافة.
class LabProductFormDialog extends StatefulWidget {
  const LabProductFormDialog({super.key, this.existing});
  final LabProduct? existing;

  static Future<LabProductFormResult?> show(
    BuildContext context,
    LabProduct? existing,
  ) {
    return showDialog<LabProductFormResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => LabProductFormDialog(existing: existing),
    );
  }

  @override
  State<LabProductFormDialog> createState() => _LabProductFormDialogState();
}

class _LabProductFormDialogState extends State<LabProductFormDialog> {
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _days;
  late String _type;
  late String _material;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _price = TextEditingController(text: e?.price.toString() ?? '');
    _days = TextEditingController(text: e?.productionDays.toString() ?? '');
    _type = e?.type ?? kProductTypes.first;
    _material = e?.material ?? kProductMaterials.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _days.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = context.l10n;
    if (_name.text.trim().isEmpty) {
      setState(() => _nameError = l10n.labProdNameRequired);
      return;
    }
    Navigator.of(context).pop(LabProductFormResult(
      name: _name.text.trim(),
      type: _type,
      material: _material,
      price: int.tryParse(_price.text.trim()) ?? 0,
      productionDays: int.tryParse(_days.text.trim()) ?? 0,
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
                widget.existing == null
                    ? l10n.labProdAddTitle
                    : l10n.labProdEditTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
              const SizedBox(height: AppSizes.spaceLG),
              _label(l10n.labProdFieldName, isLight),
              const SizedBox(height: 6),
              TextField(
                controller: _name,
                autofocus: true,
                decoration: _decoration(errorText: _nameError),
              ),
              const SizedBox(height: AppSizes.spaceMD),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label(l10n.labProdFieldType, isLight),
                        const SizedBox(height: 6),
                        _dropdown(
                          value: _type,
                          items: kProductTypes,
                          onChanged: (v) => setState(() => _type = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label(l10n.labProdFieldMaterial, isLight),
                        const SizedBox(height: 6),
                        _dropdown(
                          value: _material,
                          items: kProductMaterials,
                          onChanged: (v) => setState(() => _material = v!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceMD),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label(l10n.labProdFieldPrice, isLight),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _price,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: _decoration(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label(l10n.labProdFieldDuration, isLight),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _days,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: _decoration(),
                        ),
                      ],
                    ),
                  ),
                ],
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
                    label: l10n.save,
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

  InputDecoration _decoration({String? errorText}) => InputDecoration(
        errorText: errorText,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        ),
      );

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final bool isLight =
        Theme.of(context).brightness == Brightness.light;
    return AppDropdownMenuTheme(
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: _decoration(),
        dropdownColor: isLight ? Colors.white : AppColors.darkBg1,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        items: [
          for (final item in items)
            DropdownMenuItem(value: item, child: Text(item)),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
