// ════════════════════════════════════════════════════════════════════════════
// warehouse_material_form_dialog.dart
//
// Dialog لإضافة/تعديل مادة. يفتح على شكل modal مركزي.
//
// 🎯 الهدف:
//   form كامل مع validation لكل حقل، يدير حالتين (create / edit)
//   ويرجع الـ entity النهائي عند الـ Save.
//
// 🔮 قابلية التوسيع:
//   - أضف حقل جديد: TextField + validator + map إلى WarehouseMaterial
//   - الـ form key يضمن validation موحّد
//   - الـ initialMaterial لو موجود → mode تعديل، وإلا mode إضافة
//
// المرجع: HTML lines 1117-1140 (.modal CSS)
//
// طريقة الاستخدام:
// ```dart
// final result = await WarehouseMaterialFormDialog.show(
//   context,
//   initialMaterial: m, // null للإضافة
// );
// if (result != null) cubit.create(result); // أو update
// ```
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'package:flutter/services.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../shared/widgets/forms/app_date_picker.dart';
import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../shared/widgets/forms/app_form_select.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../domain/entities/material_category.dart';
import '../../../domain/entities/warehouse_material.dart';

part 'warehouse_material_form_parts.dart';

/// Dialog لإضافة أو تعديل مادة.
///
/// يستدعى عبر `WarehouseMaterialFormDialog.show(context)`.
/// يرجع [WarehouseMaterial] جديد/معدّل، أو null لو أُلغي.
class WarehouseMaterialFormDialog extends StatefulWidget {
  const WarehouseMaterialFormDialog({
    super.key,
    this.initialMaterial,
  });

  /// المادة الأولية للتعديل (null للإضافة).
  final WarehouseMaterial? initialMaterial;

  /// Helper لفتح الـ dialog.
  static Future<WarehouseMaterial?> show(
    BuildContext context, {
    WarehouseMaterial? initialMaterial,
  }) {
    return showDialog<WarehouseMaterial>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => WarehouseMaterialFormDialog(
        initialMaterial: initialMaterial,
      ),
    );
  }

  @override
  State<WarehouseMaterialFormDialog> createState() =>
      _WarehouseMaterialFormDialogState();
}

class _WarehouseMaterialFormDialogState
    extends State<WarehouseMaterialFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _minStockCtrl;
  late final TextEditingController _supplierCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _notesCtrl;

  MaterialCategory _category = MaterialCategory.consumables;
  DateTime? _expiryDate;

  // اقتراحات أسماء المواد الشائعة — قابلة للبحث عبر Autocomplete.
  static const _materialNameSuggestions = <String>[
    'سيراميك زيركون',
    'PFM Alloy',
    'E-max Press',
    'قفازات لاتكس',
    'حقن بنج موضعي',
    'أكواب بلاستيكية',
    'مادة تشكيل',
    'سيليكون طبع',
    'كمامات جراحية',
    'شاش طبي',
    'كحول طبي',
    'محلول معقم',
    'إبر تخدير',
    'خيوط جراحية',
    'مرايا فحص',
    'مساحيق تلميع',
    'راتنج مركّب',
    'أكريليك',
    'جبس طبي',
    'برك حشو',
  ];

  // وحدات شائعة للقائمة المنسدلة.
  static const _unitOptions = <String>[
    'قطعة',
    'علبة',
    'صندوق',
    'كيلو',
    'جرام',
    'لتر',
    'مللي',
    'حقنة',
    'كيس',
    'زجاجة',
    'لفّة',
  ];

  bool get _isEditing => widget.initialMaterial != null;

  @override
  void initState() {
    super.initState();
    final m = widget.initialMaterial;
    _nameCtrl = TextEditingController(text: m?.name ?? '');
    _quantityCtrl = TextEditingController(text: m?.quantity.toString() ?? '');
    _unitCtrl = TextEditingController(text: m?.unit ?? '');
    _minStockCtrl = TextEditingController(text: m?.minStock.toString() ?? '');
    _supplierCtrl = TextEditingController(text: m?.supplier ?? '');
    _priceCtrl =
        TextEditingController(text: m?.price?.toStringAsFixed(0) ?? '');
    _notesCtrl = TextEditingController(text: m?.notes ?? '');
    _category = m?.category ?? MaterialCategory.consumables;
    _expiryDate = m?.expiryDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _quantityCtrl.dispose();
    _unitCtrl.dispose();
    _minStockCtrl.dispose();
    _supplierCtrl.dispose();
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          VALIDATION & SUBMIT
  // ────────────────────────────────────────────────────────────────────────

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showAppDatePicker(
      context: context,
      initialDate: _expiryDate ?? now.add(const Duration(days: 30)),
      firstDate: now.subtract(const Duration(days: 365 * 2)),
      lastDate: now.add(const Duration(days: 365 * 10)),
      helpText: context.l10n.whMaterialExpiryDate,
    );
    if (picked != null && mounted) {
      setState(() => _expiryDate = picked);
    }
  }


  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final result = WarehouseMaterial(
      id: widget.initialMaterial?.id ?? '',
      name: _nameCtrl.text.trim(),
      category: _category,
      quantity: int.parse(_quantityCtrl.text.trim()),
      unit: _unitCtrl.text.trim(),
      minStock: int.parse(_minStockCtrl.text.trim()),
      expiryDate: _expiryDate,
      supplier: _supplierCtrl.text.trim().isEmpty
          ? null
          : _supplierCtrl.text.trim(),
      price: _priceCtrl.text.trim().isEmpty
          ? null
          : double.parse(_priceCtrl.text.trim()),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    Navigator.of(context).pop(result);
  }

  // ────────────────────────────────────────────────────────────────────────
  //                              BUILD
  // ────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 610,
          maxHeight: 720,
        ),
        child: _buildContainer(context, isLight),
      ),
    );
  }

  Widget _buildContainer(BuildContext context, bool isLight) {
    return Container(
      decoration: BoxDecoration(
        // dark gradient في dark mode، solid white في light
        gradient: isLight
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.modalDarkStart, AppColors.modalDarkEnd],
              ),
        color: isLight ? AppColors.baseComponent : null,
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          width: AppSizes.borderThin,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 80,
            offset: const Offset(0, 40),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
        child: Stack(
          children: [
            // ::before — gradient line في الأعلى
            // ملاحظة RTL: full-width line — متماثل، آمن للـ RTL.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.dashCyan,
                      AppColors.info,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context, isLight),
                Flexible(child: _buildBody(context, isLight)),
                _buildFooter(context, isLight),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Header — title + close button.
  Widget _buildHeader(BuildContext context, bool isLight) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isEditing
                      ? context.l10n.edit
                      : context.l10n.whMaterialsAdd,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.whMaterialsTitle,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                    color: isLight ? AppColors.lightText3 : AppColors.darkText3,
                  ),
                ),
              ],
            ),
          ),
          _CloseButton(
            onTap: () => Navigator.of(context).pop(),
            isLight: isLight,
          ),
        ],
      ),
    );
  }

  /// Body — الحقول.
  Widget _buildBody(BuildContext context, bool isLight) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildNameAutocomplete(context, isLight),
            AppFormSelect<MaterialCategory>(
              label: context.l10n.whMaterialCategory,
              value: _category,
              options: MaterialCategory.values
                  .map((c) => AppSelectOption<MaterialCategory>(
                        value: c,
                        label: c.label(context),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
            Row(
              children: [
                Expanded(
                  child: AppFormField(
                    label: context.l10n.whMaterialQuantity,
                    controller: _quantityCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => _intValidator(context, v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppFormSelect<String>(
                    label: context.l10n.whMaterialUnit,
                    value: _unitCtrl.text.isEmpty ? null : _unitCtrl.text,
                    hint: context.l10n.whMaterialUnitHint,
                    options: _unitOptions
                        .map((u) =>
                            AppSelectOption<String>(value: u, label: u))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _unitCtrl.text = v);
                    },
                    validator: (v) =>
                        (v == null || v.isEmpty) ? context.l10n.errorRequired : null,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: AppFormField(
                    label: context.l10n.whMaterialMinStock,
                    controller: _minStockCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => _intValidator(context, v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildExpiryField(context, isLight)),
              ],
            ),
            AppFormField(
              label: context.l10n.whMaterialSupplier,
              controller: _supplierCtrl,
            ),
            AppFormField(
              label: context.l10n.whMaterialPrice,
              controller: _priceCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              validator: (v) => _optionalDoubleValidator(context, v),
            ),
            AppFormField(
              label: context.l10n.whMaterialNotes,
              controller: _notesCtrl,
              maxLines: 3,
              minLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  /// حقل اسم المادة — Autocomplete بحث مع قائمة اقتراحات.
  Widget _buildNameAutocomplete(BuildContext context, bool isLight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.whMaterialName,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: isLight ? AppColors.lightText2 : AppColors.darkText2,
          ),
        ),
        const SizedBox(height: 5),
        Autocomplete<String>(
          initialValue: TextEditingValue(text: _nameCtrl.text),
          optionsBuilder: (TextEditingValue tev) {
            final q = tev.text.trim();
            if (q.isEmpty) return _materialNameSuggestions;
            return _materialNameSuggestions
                .where((s) => s.contains(q));
          },
          onSelected: (String selection) {
            _nameCtrl.text = selection;
          },
          fieldViewBuilder:
              (context, controller, focusNode, onFieldSubmitted) {
            // مزامنة محتوى الـ controller الداخلي مع _nameCtrl.
            controller.addListener(() {
              if (_nameCtrl.text != controller.text) {
                _nameCtrl.text = controller.text;
              }
            });
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              validator: (v) => _requiredValidator(context, v),
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 15,
                color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                height: 1.3,
              ),
              decoration: InputDecoration(
                hintText: context.l10n.fieldWriteOrPick,
                hintStyle: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 15,
                  color: isLight ? AppColors.lightText4 : AppColors.darkText4,
                ),
                filled: true,
                fillColor: AppColors.surfaceTintCool2,
                suffixIcon: Icon(Icons.search,
                    size: 18, color: AppColors.lightText3),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  borderSide: const BorderSide(color: AppColors.lightBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  borderSide: const BorderSide(color: AppColors.lightBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.6),
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: AlignmentDirectional.topStart,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240, maxWidth: 420),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, i) {
                      final opt = options.elementAt(i);
                      return InkWell(
                        onTap: () => onSelected(opt),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          color: Colors.white,
                          child: Text(
                            opt,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 14,
                              color: AppColors.lightText1,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// حقل تاريخ الانتهاء (مع date picker).
  Widget _buildExpiryField(BuildContext context, bool isLight) {
    final dateText = _expiryDate == null
        ? '—'
        : '${_expiryDate!.year}-${_expiryDate!.month.toString().padLeft(2, '0')}-${_expiryDate!.day.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.whMaterialExpiryDate,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: isLight ? AppColors.lightText2 : AppColors.darkText2,
          ),
        ),
        const SizedBox(height: 5),
        InkWell(
          onTap: _pickExpiryDate,
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.dashCyan.withValues(alpha: 0.04),
              border: Border.all(
                color: AppColors.dashCyan.withValues(alpha: 0.13),
                width: AppSizes.borderThin,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dateText,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _expiryDate == null
                          ? (isLight
                              ? AppColors.lightText4
                              : AppColors.darkText4)
                          : (isLight
                              ? AppColors.lightText1
                              : AppColors.darkText1),
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: isLight ? AppColors.lightText3 : AppColors.darkText3,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Footer — أزرار Cancel + Save.
  Widget _buildFooter(BuildContext context, bool isLight) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AppButton(
            label: context.l10n.cancel,
            onPressed: () => Navigator.of(context).pop(),
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.small,
          ),
          const SizedBox(width: 7),
          AppButton(
            label: context.l10n.save,
            onPressed: _submit,
            variant: AppButtonVariant.primary,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                          CLOSE BUTTON
// ══════════════════════════════════════════════════════════════════════════

