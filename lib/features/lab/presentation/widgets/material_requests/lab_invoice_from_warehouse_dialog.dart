// ════════════════════════════════════════════════════════════════════════════
// lab_invoice_from_warehouse_dialog.dart
//
// فورم "فاتورة من مواد المستودع" — يسمح باختيار عدّة مواد من كتالوج المستودع
// وتحديد كمية لكل واحدة (سلة)، ثم إرسالها كفاتورة واحدة (items[]).
// نفس ستايل lab_mat_request_dialog.dart القديم (الآن محذوف).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../domain/entities/warehouse_material_ref.dart';

class LabInvoiceFromWarehouseResult {
  const LabInvoiceFromWarehouseResult({required this.items, this.notes});
  final List<({int materialId, int quantity, String? notes})> items;
  final String? notes;
}

class LabInvoiceFromWarehouseDialog extends StatefulWidget {
  const LabInvoiceFromWarehouseDialog({
    super.key,
    required this.catalog,
    this.catalogError,
    required this.onRetryCatalog,
  });

  final List<WarehouseMaterialRef> catalog;
  final String? catalogError;
  final VoidCallback onRetryCatalog;

  static Future<LabInvoiceFromWarehouseResult?> show(
    BuildContext context, {
    required List<WarehouseMaterialRef> catalog,
    String? catalogError,
    required VoidCallback onRetryCatalog,
  }) {
    return showDialog<LabInvoiceFromWarehouseResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => LabInvoiceFromWarehouseDialog(
        catalog: catalog,
        catalogError: catalogError,
        onRetryCatalog: onRetryCatalog,
      ),
    );
  }

  @override
  State<LabInvoiceFromWarehouseDialog> createState() => _LabInvoiceFromWarehouseDialogState();
}

class _CartRow {
  _CartRow(this.material) : quantityController = TextEditingController();
  final WarehouseMaterialRef material;
  final TextEditingController quantityController;
}

class _LabInvoiceFromWarehouseDialogState extends State<LabInvoiceFromWarehouseDialog> {
  final TextEditingController _search = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  final List<_CartRow> _cart = [];
  String? _errorText;

  @override
  void dispose() {
    _search.dispose();
    _notes.dispose();
    for (final row in _cart) {
      row.quantityController.dispose();
    }
    super.dispose();
  }

  Set<int> get _inCartIds => _cart.map((r) => r.material.materialId).toSet();

  List<WarehouseMaterialRef> get _filtered {
    final q = _search.text.trim();
    final inCart = _inCartIds;
    final base = widget.catalog.where((m) => !inCart.contains(m.materialId));
    if (q.isEmpty) return base.toList();
    return base.where((m) => m.name.contains(q)).toList();
  }

  /// إن كانت كل مواد الكتالوج مضافة للسلة أصلاً، لا داعي لعرض حقل البحث/القائمة.
  bool get _hasAvailableMaterials {
    final inCart = _inCartIds;
    return widget.catalog.any((m) => !inCart.contains(m.materialId));
  }

  void _addToCart(WarehouseMaterialRef m) {
    setState(() {
      _cart.add(_CartRow(m));
      _search.clear();
      _errorText = null;
    });
  }

  void _removeFromCart(_CartRow row) {
    setState(() {
      row.quantityController.dispose();
      _cart.remove(row);
    });
  }

  void _submit() {
    final l10n = context.l10n;
    if (_cart.isEmpty) {
      setState(() => _errorText = l10n.labReqAtLeastOneItemRequired);
      return;
    }
    final items = <({int materialId, int quantity, String? notes})>[];
    for (final row in _cart) {
      final qty = int.tryParse(row.quantityController.text.trim()) ?? 0;
      if (qty <= 0) {
        setState(() => _errorText = l10n.labReqQuantityRequired);
        return;
      }
      items.add((materialId: row.material.materialId, quantity: qty, notes: null));
    }
    final notes = _notes.text.trim();
    Navigator.of(context).pop(
      LabInvoiceFromWarehouseResult(items: items, notes: notes.isEmpty ? null : notes),
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
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.labReqFromWarehouseTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
              const SizedBox(height: AppSizes.spaceMD),
              if (widget.catalogError != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSizes.spaceMD),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(widget.catalogError!, style: const TextStyle(color: AppColors.error))),
                      TextButton(onPressed: widget.onRetryCatalog, child: Text(l10n.labReqCatalogRetry)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.spaceMD),
              ],
              if (_hasAvailableMaterials) ...[
                TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: l10n.labReqSearchMaterialHint,
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSM)),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSizes.spaceSM),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 140),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filtered.length,
                    itemBuilder: (context, i) {
                      final m = _filtered[i];
                      return ListTile(
                        dense: true,
                        title: Text(m.name),
                        subtitle: m.unit.isEmpty ? null : Text(m.unit),
                        trailing: TextButton(
                          onPressed: () => _addToCart(m),
                          child: Text(l10n.labReqAddToInvoice),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSizes.spaceMD),
                const Divider(height: 1),
                const SizedBox(height: AppSizes.spaceMD),
              ],
              Flexible(
                child: _cart.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceLG),
                        child: Text(l10n.labReqInvoiceItemsEmpty, textAlign: TextAlign.center),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: _cart.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spaceSM),
                        itemBuilder: (context, i) {
                          final row = _cart[i];
                          return Row(
                            children: [
                              Expanded(child: Text(row.material.name)),
                              SizedBox(
                                width: 90,
                                child: TextField(
                                  controller: row.quantityController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: l10n.colQuantity,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSM)),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () => _removeFromCart(row),
                                tooltip: l10n.labReqRemoveRow,
                              ),
                            ],
                          );
                        },
                      ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: AppSizes.spaceSM),
                Text(_errorText!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
              ],
              const SizedBox(height: AppSizes.spaceMD),
              TextField(
                controller: _notes,
                maxLines: 2,
                inputFormatters: [LengthLimitingTextInputFormatter(300)],
                decoration: InputDecoration(
                  hintText: l10n.labReqNotesOptional,
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSM)),
                ),
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
}
