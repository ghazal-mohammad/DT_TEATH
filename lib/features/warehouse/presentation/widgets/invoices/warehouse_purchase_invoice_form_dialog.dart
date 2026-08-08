// ════════════════════════════════════════════════════════════════════════════
// warehouse_purchase_invoice_form_dialog.dart
//
// Dialog لإضافة/تعديل فاتورة شراء. مطابق لعقد الباك (StorePurchaseInvoiceRequest):
//   • الإضافة: مورّد + تاريخ + ملاحظات؟ + بنود (مادة/كمية/سعر/صلاحية؟) — يُنشئ
//     دفعات مخزون جديدة تلقائياً بالباك.
//   • التعديل: مورّد/تاريخ/ملاحظات فقط — الباك لا يدعم تعديل البنود بعد الإنشاء.
//
// لا يستدعي الـ Cubit مباشرة (نفس نمط WarehouseMaterialFormDialog) — يُرجِع
// [PurchaseInvoiceFormResult] للمستدعي كي يستدعي cubit.create/update بنفسه،
// لأن showDialog يضع البناء خارج شجرة أي BlocProvider محلي للصفحة.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/di/injection_container.dart';
import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/forms/app_date_picker.dart';
import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../shared/widgets/forms/app_form_select.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../domain/entities/purchase_invoice.dart';
import '../../../domain/entities/warehouse_material.dart';
import '../../../domain/repositories/warehouse_materials_repository.dart';

/// نتيجة الفورم — يقرّرها المستدعي: إنشاء (بنود) أو تعديل (بلا بنود).
class PurchaseInvoiceFormResult {
  const PurchaseInvoiceFormResult.create({
    required this.supplierName,
    required this.invoiceDate,
    required this.items,
    this.notes,
  }) : isEdit = false;

  const PurchaseInvoiceFormResult.edit({
    required this.supplierName,
    required this.invoiceDate,
    this.notes,
  })  : items = const [],
        isEdit = true;

  final bool isEdit;
  final String supplierName;
  final DateTime invoiceDate;
  final String? notes;
  final List<PurchaseInvoiceItemInput> items;
}

class WarehousePurchaseInvoiceFormDialog extends StatefulWidget {
  const WarehousePurchaseInvoiceFormDialog({super.key, this.initialInvoice});

  /// الفاتورة الأصلية للتعديل (null للإضافة).
  final PurchaseInvoice? initialInvoice;

  static Future<PurchaseInvoiceFormResult?> show(
    BuildContext context, {
    PurchaseInvoice? initialInvoice,
  }) {
    return showDialog<PurchaseInvoiceFormResult>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) =>
          WarehousePurchaseInvoiceFormDialog(initialInvoice: initialInvoice),
    );
  }

  @override
  State<WarehousePurchaseInvoiceFormDialog> createState() =>
      _WarehousePurchaseInvoiceFormDialogState();
}

class _ItemRow {
  _ItemRow()
      : qtyCtrl = TextEditingController(),
        priceCtrl = TextEditingController();

  WarehouseMaterial? material;
  final TextEditingController qtyCtrl;
  final TextEditingController priceCtrl;
  DateTime? expirationDate;

  void dispose() {
    qtyCtrl.dispose();
    priceCtrl.dispose();
  }
}

class _WarehousePurchaseInvoiceFormDialogState
    extends State<WarehousePurchaseInvoiceFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _supplierCtrl;
  late final TextEditingController _notesCtrl;
  late DateTime _invoiceDate;
  final List<_ItemRow> _items = [];

  List<WarehouseMaterial> _materials = const [];
  bool _loadingMaterials = true;
  String? _itemsError;

  bool get _isEditing => widget.initialInvoice != null;

  @override
  void initState() {
    super.initState();
    final inv = widget.initialInvoice;
    _supplierCtrl = TextEditingController(text: inv?.supplierName ?? '');
    _notesCtrl = TextEditingController(text: inv?.notes ?? '');
    _invoiceDate = inv?.invoiceDate ?? DateTime.now();
    if (!_isEditing) _items.add(_ItemRow());
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    try {
      final list = await sl<WarehouseMaterialsRepository>().getAll();
      if (!mounted) return;
      setState(() {
        _materials = list;
        _loadingMaterials = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMaterials = false);
    }
  }

  @override
  void dispose() {
    _supplierCtrl.dispose();
    _notesCtrl.dispose();
    for (final row in _items) {
      row.dispose();
    }
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          VALIDATION & SUBMIT
  // ────────────────────────────────────────────────────────────────────────

  void _submit() {
    final formValid = _formKey.currentState?.validate() ?? false;
    setState(() => _itemsError = null);

    if (!_isEditing) {
      if (_items.isEmpty) {
        setState(() => _itemsError = context.l10n.invFormItemsRequired);
        return;
      }
      final inputs = <PurchaseInvoiceItemInput>[];
      for (final row in _items) {
        final material = row.material;
        final qty = int.tryParse(row.qtyCtrl.text.trim());
        final price = double.tryParse(row.priceCtrl.text.trim());
        if (material == null || qty == null || qty <= 0 || price == null) {
          setState(() => _itemsError = context.l10n.invFormQuantityInvalid);
          return;
        }
        inputs.add(PurchaseInvoiceItemInput(
          materialId: material.id,
          materialName: material.name,
          quantity: qty,
          unitPrice: price,
          expirationDate: row.expirationDate,
        ));
      }
      if (!formValid) return;
      Navigator.of(context).pop(PurchaseInvoiceFormResult.create(
        supplierName: _supplierCtrl.text.trim(),
        invoiceDate: _invoiceDate,
        items: inputs,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      ));
      return;
    }

    if (!formValid) return;
    Navigator.of(context).pop(PurchaseInvoiceFormResult.edit(
      supplierName: _supplierCtrl.text.trim(),
      invoiceDate: _invoiceDate,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    ));
  }

  Future<void> _pickInvoiceDate() async {
    final now = DateTime.now();
    final picked = await showAppDatePicker(
      context: context,
      initialDate: _invoiceDate,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      helpText: context.l10n.invFormDate,
    );
    if (picked != null && mounted) setState(() => _invoiceDate = picked);
  }

  Future<void> _pickExpiry(_ItemRow row) async {
    final now = DateTime.now();
    final picked = await showAppDatePicker(
      context: context,
      initialDate: row.expirationDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 10)),
      helpText: context.l10n.whStockExpiry,
    );
    if (picked != null && mounted) setState(() => row.expirationDate = picked);
  }

  void _addRow() => setState(() => _items.add(_ItemRow()));

  void _removeRow(_ItemRow row) => setState(() {
        _items.remove(row);
        row.dispose();
      });

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
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 760),
        child: _buildContainer(context, isLight),
      ),
    );
  }

  Widget _buildContainer(BuildContext context, bool isLight) {
    return Container(
      decoration: BoxDecoration(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, isLight),
            Flexible(child: _buildBody(context, isLight)),
            _buildFooter(context, isLight),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isLight) {
    final l10n = context.l10n;
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
                  _isEditing ? l10n.edit : l10n.invFormTitle,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isEditing ? l10n.invPurchaseInvoices : l10n.invFormSubtitle,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isLight ? AppColors.lightText3 : AppColors.darkText3,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(100),
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.lightBorder.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, size: 17),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isLight) {
    final l10n = context.l10n;
    final dateStr = '${_invoiceDate.year}-'
        '${_invoiceDate.month.toString().padLeft(2, '0')}-'
        '${_invoiceDate.day.toString().padLeft(2, '0')}';
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppFormField(
              label: l10n.invFormSupplier,
              hint: l10n.invFormSupplierHint,
              controller: _supplierCtrl,
              required: true,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.errorRequired : null,
            ),
            _buildDateField(context, isLight, dateStr),
            AppFormField(
              label: l10n.invFormNotes,
              controller: _notesCtrl,
              maxLines: 2,
            ),
            const SizedBox(height: 6),
            if (_isEditing)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTintCool2,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                ),
                child: Text(l10n.invFormItemsLockedNotice,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.lightText3)),
              )
            else
              _buildItemsSection(context, isLight),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context, bool isLight, String dateStr) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.invFormDate,
              style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isLight ? AppColors.lightText2 : AppColors.darkText2)),
          const SizedBox(height: 5),
          InkWell(
            onTap: _pickInvoiceDate,
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            child: InputDecorator(
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8F9FC),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  borderSide: const BorderSide(color: AppColors.lightBorder),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_outlined,
                      size: 17, color: AppColors.lightText3),
                  const SizedBox(width: 8),
                  Text(dateStr,
                      style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 15,
                          color: isLight
                              ? AppColors.lightText1
                              : AppColors.darkText1)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(BuildContext context, bool isLight) {
    final l10n = context.l10n;
    final total = _items.fold<double>(0, (sum, row) {
      final qty = int.tryParse(row.qtyCtrl.text.trim()) ?? 0;
      final price = double.tryParse(row.priceCtrl.text.trim()) ?? 0;
      return sum + (qty * price);
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l10n.invFormItemsTitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isLight
                          ? AppColors.lightText1
                          : AppColors.darkText1)),
            ),
            TextButton.icon(
              onPressed: _addRow,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(l10n.invFormAddItem),
            ),
          ],
        ),
        if (_loadingMaterials)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          for (final row in _items) _buildItemRow(context, isLight, row),
        if (_itemsError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 6),
            child: Text(_itemsError!,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.alertRed)),
          ),
        const SizedBox(height: 4),
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
              Text(total.toStringAsFixed(0),
                  style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.statusSuccess)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(BuildContext context, bool isLight, _ItemRow row) {
    final l10n = context.l10n;
    final expiryText = row.expirationDate == null
        ? l10n.whStockExpiryNone
        : '${row.expirationDate!.year}-'
            '${row.expirationDate!.month.toString().padLeft(2, '0')}-'
            '${row.expirationDate!.day.toString().padLeft(2, '0')}';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppFormSelect<WarehouseMaterial>(
                  label: l10n.invFormMaterialLabel,
                  value: row.material,
                  hint: l10n.invFormMaterialHint,
                  options: _materials
                      .map((m) => AppSelectOption<WarehouseMaterial>(
                          value: m, label: m.name))
                      .toList(),
                  onChanged: (m) => setState(() {
                    row.material = m;
                    if (m != null && row.priceCtrl.text.trim().isEmpty) {
                      row.priceCtrl.text = m.pricePerUnit.toStringAsFixed(0);
                    }
                  }),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _removeRow(row),
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                color: AppColors.alertRed,
                tooltip: l10n.delete,
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: row.qtyCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: l10n.invFormQuantityLabel,
                    suffixText: row.material?.unit,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSM)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: row.priceCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: l10n.invUnitPriceLabel,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSM)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _pickExpiry(row),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            child: InputDecorator(
              decoration: InputDecoration(
                isDense: true,
                labelText: l10n.whStockExpiry,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM)),
              ),
              child: Text(expiryText,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.lightText2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isLight) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AppButton(
            label: l10n.cancel,
            onPressed: () => Navigator.of(context).pop(),
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.small,
          ),
          const SizedBox(width: 7),
          AppButton(
            label: l10n.invFormSave,
            onPressed: _submit,
            variant: AppButtonVariant.primary,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }
}
