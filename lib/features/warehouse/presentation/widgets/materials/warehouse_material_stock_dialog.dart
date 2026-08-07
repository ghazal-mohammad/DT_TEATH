// ════════════════════════════════════════════════════════════════════════════
// warehouse_material_stock_dialog.dart
//
// مودال إدارة مخزون مادة عبر الدفعات (يقابل نظام الباك الحقيقي):
//   • يعرض دفعات المادة (كمية + صلاحية + حالة انتهاء) والإجمالي.
//   • إضافة دفعة جديدة (كمية + صلاحية اختيارية).
//   • تعديل كمية دفعة (إدخال/إخراج) مع سبب الحركة.
//
// يستبدل حوار "الحركة" القديم التفاؤلي الذي كان يعدّل الكمية محلياً بلا ربط.
// يُرجِع true إن تغيّر المخزون (لتحديث قائمة المواد).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection_container.dart';
import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/forms/app_date_picker.dart';
import '../../../../../shared/widgets/forms/app_form_select.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../domain/entities/material_stock.dart';
import '../../../domain/entities/stock_batch.dart';
import '../../../domain/entities/warehouse_material.dart';
import '../../../domain/repositories/warehouse_stock_repository.dart';
import '../../bloc/stock_cubit.dart';

class WarehouseMaterialStockDialog extends StatelessWidget {
  const WarehouseMaterialStockDialog({super.key, required this.material});

  final WarehouseMaterial material;

  /// يفتح المودال ويُرجِع true إن حدث تغيير على المخزون.
  static Future<bool> show(BuildContext context, WarehouseMaterial material) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => WarehouseMaterialStockDialog(material: material),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          StockCubit(sl<WarehouseStockRepository>(), material.id)..load(),
      child: _StockDialogView(material: material),
    );
  }
}

class _StockDialogView extends StatelessWidget {
  const _StockDialogView({required this.material});

  final WarehouseMaterial material;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final l10n = context.l10n;
    return Dialog(
      backgroundColor: isLight ? Colors.white : AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
        child: BlocConsumer<StockCubit, StockState>(
          listenWhen: (p, c) => p.actionError != c.actionError && c.actionError != null,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionError!),
                backgroundColor: AppColors.alertRed,
              ),
            );
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(AppSizes.spaceLG),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(context, isLight, state),
                  const SizedBox(height: AppSizes.spaceMD),
                  Flexible(child: _body(context, isLight, state)),
                  const SizedBox(height: AppSizes.spaceMD),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: AppButton.secondary(
                      label: l10n.cancel,
                      onPressed: () =>
                          Navigator.of(context).pop(context.read<StockCubit>().changed),
                      size: AppButtonSize.small,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header(BuildContext context, bool isLight, StockState state) {
    final l10n = context.l10n;
    final total = state.stock?.totalQuantity ?? material.quantity;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.whStockTitle,
            style: AppTextStyles.headlineSmall.copyWith(
                color: isLight ? AppColors.lightText1 : AppColors.darkText1)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(material.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isLight ? AppColors.lightText2 : AppColors.darkText2)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.dashCyan.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text('${l10n.whStockTotal}: $total ${material.unit}',
                  style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w800, color: AppColors.info)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _body(BuildContext context, bool isLight, StockState state) {
    if (state.status == StockStatus.loading && state.stock == null) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
    }
    if (state.status == StockStatus.error && state.stock == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Text(state.errorMessage ?? '—',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.alertRed)),
        ),
      );
    }
    final batches = state.stock?.batches ?? const <StockBatch>[];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AddBatchCard(unit: material.unit, busy: state.busy),
          const SizedBox(height: AppSizes.spaceMD),
          Text('${context.l10n.whStockBatches} (${batches.length})',
              style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1)),
          const SizedBox(height: 8),
          if (batches.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Text(context.l10n.whStockNoBatches,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.lightText3)),
            )
          else
            ...batches.map((b) =>
                _BatchRow(batch: b, unit: material.unit, isLight: isLight)),
        ],
      ),
    );
  }
}

// ── بطاقة إضافة دفعة ─────────────────────────────────────────────────────────

class _AddBatchCard extends StatefulWidget {
  const _AddBatchCard({required this.unit, required this.busy});
  final String unit;
  final bool busy;

  @override
  State<_AddBatchCard> createState() => _AddBatchCardState();
}

class _AddBatchCardState extends State<_AddBatchCard> {
  final _qtyCtrl = TextEditingController();
  DateTime? _expiry;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final picked = await showAppDatePicker(
      context: context,
      initialDate: _expiry ?? now.add(const Duration(days: 180)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 10)),
      helpText: context.l10n.whStockExpiry,
    );
    if (picked != null && mounted) setState(() => _expiry = picked);
  }

  Future<void> _add() async {
    final qty = int.tryParse(_qtyCtrl.text.trim());
    if (qty == null || qty <= 0) return;
    final ok = await context
        .read<StockCubit>()
        .addBatch(quantity: qty, expiryDate: _expiry);
    if (ok && mounted) {
      _qtyCtrl.clear();
      setState(() => _expiry = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final expiryText = _expiry == null
        ? l10n.whStockExpiryNone
        : '${_expiry!.year}-${_expiry!.month.toString().padLeft(2, '0')}-${_expiry!.day.toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMD),
      decoration: BoxDecoration(
        color: AppColors.dashCyan.withValues(alpha: 0.05),
        border: Border.all(color: AppColors.dashCyan.withValues(alpha: 0.18)),
        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.whStockAddBatch,
              style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w800, color: AppColors.info)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _qtyCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: l10n.whStockBatchQty,
                    suffixText: widget.unit,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSM)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: _pickExpiry,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: l10n.whStockExpiry,
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusSM)),
                    ),
                    child: Text(expiryText,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.lightText2)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppButton.primary(
            label: l10n.whStockAddBatch,
            onPressed: widget.busy ? null : _add,
            size: AppButtonSize.small,
            icon: Icons.add_rounded,
          ),
        ],
      ),
    );
  }
}

// ── صفّ دفعة + زر تعديل ───────────────────────────────────────────────────────

class _BatchRow extends StatelessWidget {
  const _BatchRow(
      {required this.batch, required this.unit, required this.isLight});
  final StockBatch batch;
  final String unit;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final expiryText = batch.expiryDate == null
        ? l10n.whStockExpiryNone
        : '${batch.expiryDate!.year}-${batch.expiryDate!.month.toString().padLeft(2, '0')}-${batch.expiryDate!.day.toString().padLeft(2, '0')}';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${batch.quantity} $unit',
                    style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color:
                            isLight ? AppColors.lightText1 : AppColors.darkText1)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.event_outlined,
                        size: 13, color: AppColors.lightText3),
                    const SizedBox(width: 4),
                    Text(expiryText,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.lightText3)),
                    if (batch.isExpired) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.alertRed.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(l10n.whStockExpired,
                            style: const TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.alertRed)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openAdjust(context),
            icon: const Icon(Icons.tune_rounded, size: 20),
            color: AppColors.primary,
            tooltip: l10n.whStockAdjust,
          ),
        ],
      ),
    );
  }

  Future<void> _openAdjust(BuildContext context) async {
    final cubit = context.read<StockCubit>();
    final params = await showDialog<_AdjustResult>(
      context: context,
      builder: (_) => _AdjustBatchDialog(batch: batch, unit: unit),
    );
    if (params == null) return;
    await cubit.adjustBatch(
      batchId: batch.id,
      isIn: params.isIn,
      quantity: params.quantity,
      reason: params.reason,
    );
  }
}

// ── مودال تعديل كمية دفعة ─────────────────────────────────────────────────────

class _AdjustResult {
  const _AdjustResult(this.isIn, this.quantity, this.reason);
  final bool isIn;
  final int quantity;
  final StockMovementReason reason;
}

class _AdjustBatchDialog extends StatefulWidget {
  const _AdjustBatchDialog({required this.batch, required this.unit});
  final StockBatch batch;
  final String unit;

  @override
  State<_AdjustBatchDialog> createState() => _AdjustBatchDialogState();
}

class _AdjustBatchDialogState extends State<_AdjustBatchDialog> {
  bool _isIn = true;
  final _ctrl = TextEditingController();
  StockMovementReason _reason = StockMovementReason.adjustment;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _reasonLabel(BuildContext context, StockMovementReason r) {
    final l10n = context.l10n;
    return switch (r) {
      StockMovementReason.purchase => l10n.whStockReasonPurchase,
      StockMovementReason.fulfillment => l10n.whStockReasonFulfillment,
      StockMovementReason.expired => l10n.whStockReasonExpired,
      StockMovementReason.adjustment => l10n.whStockReasonAdjustment,
      StockMovementReason.returned => l10n.whStockReasonReturn,
    };
  }

  void _submit() {
    final v = int.tryParse(_ctrl.text.trim());
    if (v == null || v <= 0) {
      setState(() => _error = context.l10n.whMovementInvalid);
      return;
    }
    if (!_isIn && v > widget.batch.quantity) {
      setState(() => _error = context.l10n.whMovementExceeds);
      return;
    }
    Navigator.of(context).pop(_AdjustResult(_isIn, v, _reason));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Dialog(
      backgroundColor: isLight ? Colors.white : AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.whStockAdjust,
                  style: AppTextStyles.headlineSmall.copyWith(
                      color:
                          isLight ? AppColors.lightText1 : AppColors.darkText1)),
              const SizedBox(height: 4),
              Text('${l10n.whStockBatchLabel} · ${widget.batch.quantity} ${widget.unit}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.lightText3)),
              const SizedBox(height: AppSizes.spaceMD),
              Row(
                children: [
                  Expanded(
                    child: _Seg(
                      label: l10n.whStockAdd,
                      icon: Icons.south_west_rounded,
                      color: AppColors.statusSuccess,
                      selected: _isIn,
                      onTap: () => setState(() => _isIn = true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Seg(
                      label: l10n.whStockDeduct,
                      icon: Icons.north_east_rounded,
                      color: AppColors.statusUrgent,
                      selected: !_isIn,
                      onTap: () => setState(() => _isIn = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceMD),
              TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofocus: true,
                decoration: InputDecoration(
                  isDense: true,
                  labelText: l10n.whMovementAmount,
                  suffixText: widget.unit,
                  errorText: _error,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM)),
                ),
              ),
              const SizedBox(height: AppSizes.spaceMD),
              AppFormSelect<StockMovementReason>(
                label: l10n.whStockReason,
                value: _reason,
                options: StockMovementReason.values
                    .map((r) => AppSelectOption<StockMovementReason>(
                        value: r, label: _reasonLabel(context, r)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _reason = v);
                },
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
}

class _Seg extends StatelessWidget {
  const _Seg({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          border: Border.all(
              color: selected ? color : AppColors.lightBorder,
              width: selected ? 2 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: selected ? color : AppColors.lightText3),
            const SizedBox(width: 7),
            Text(label,
                style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: selected ? color : AppColors.lightText2)),
          ],
        ),
      ),
    );
  }
}
