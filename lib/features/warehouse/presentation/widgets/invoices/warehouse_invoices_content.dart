// ════════════════════════════════════════════════════════════════════════════
// warehouse_invoices_content.dart
//
// المحتوى الكامل لصفحة الفواتير — Phase 4.5 مكتملة.
//
// 🎯 الهدف:
//   - 3 filter chips (الكل / شراء / استخدام)
//   - Layout بعمودين: قائمة الفواتير + ملخص الأسبوع
//   - قائمة: تاريخ + نوع + مادة + كمية + إجمالي
//   - ملخص الأسبوع: 3 أرقام (شراء / استخدام / خسارة)
//   - Modal: إضافة فاتورة جديدة
//
// المرجع: DT_Teeth_Warehouse_v6_Enhanced.html — pg-inv
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'package:flutter/services.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../shared/widgets/forms/app_form_select.dart' show AppFormSelect, AppSelectOption;
import '../../../../../shared/widgets/layout/app_page_action_bar.dart';
import '../../../../../shared/widgets/primitives/app_badge.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../../../shared/widgets/primitives/app_filter_chip.dart';
import '../../../../warehouse/data/mock/warehouse_pages_mock_data.dart';

// ══════════════════════════════════════════════════════════════════════════
//                          MAIN CONTENT
// ══════════════════════════════════════════════════════════════════════════

class WarehouseInvoicesContent extends StatefulWidget {
  const WarehouseInvoicesContent({super.key});

  @override
  State<WarehouseInvoicesContent> createState() =>
      _WarehouseInvoicesContentState();
}

class _WarehouseInvoicesContentState extends State<WarehouseInvoicesContent> {
  // 0=الكل، 1=شراء، 2=استخدام
  int _filterIndex = 0;

  List<WarehouseInvoiceItem> get _filtered {
    switch (_filterIndex) {
      case 1:
        return WarehouseInvoicesMockData.invoices
            .where((i) => i.type == InvoiceType.purchase)
            .toList();
      case 2:
        return WarehouseInvoicesMockData.invoices
            .where((i) => i.type == InvoiceType.usage)
            .toList();
      default:
        return WarehouseInvoicesMockData.invoices;
    }
  }

  @override
  Widget build(BuildContext context) {
    const double sideWidth = 260;
    final bool isWide = MediaQuery.sizeOf(context).width >= 1000;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Toolbar ─────────────────────────────────────────────────
        AppPageActionBar(
          filter: _buildFilterChips(context),
          actions: [
            AppButton(
              label: '+ ${context.l10n.whInvoiceAdd}',
              onPressed: () => _showAddInvoiceDialog(context),
              variant: AppButtonVariant.primary,
              size: AppButtonSize.small,
            ),
          ],
        ),

        // ── Main Layout ──────────────────────────────────────────────
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInvoicesList(context)),
              const SizedBox(width: 16),
              SizedBox(
                width: sideWidth,
                child: _buildWeeklySummary(context),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildInvoicesList(context),
              const SizedBox(height: 16),
              _buildWeeklySummary(context),
            ],
          ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          FILTER CHIPS
  // ────────────────────────────────────────────────────────────────────────

  Widget _buildFilterChips(BuildContext context) {
    final labels = [
      context.l10n.whFilterAll,
      context.l10n.whInvoiceFilterPurchase,
      context.l10n.whInvoiceFilterUsage,
    ];

    return AppFilterChipRow(
      options: labels,
      selectedIndex: _filterIndex,
      onChanged: (i) => setState(() => _filterIndex = i),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          INVOICES LIST
  // ────────────────────────────────────────────────────────────────────────

  Widget _buildInvoicesList(BuildContext context) {
    final invoices = _filtered;
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (invoices.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: AppEmptyState(
          icon: Icons.receipt_long_outlined,
          title: context.l10n.emptyNoInvoicesTitle,
          message: context.l10n.emptyNoInvoicesMessage,
          actionLabel: context.l10n.whInvoiceAdd,
          onActionTap: () => _showAddInvoiceDialog(context),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isLight ? AppColors.baseComponent : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTableHeader(context, isLight),
          ...invoices.map((inv) => _buildInvoiceRow(context, inv, isLight)),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context, bool isLight) {
    final style = TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: 11.5,
      fontWeight: FontWeight.w700,
      color: isLight ? AppColors.lightText4 : AppColors.darkText4,
      letterSpacing: 0.8,
    );

    return Container(
      decoration: BoxDecoration(
        color: isLight ? const Color(0x1ABED8FA) : const Color(0x0F9EFBEC),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusMD),
          topRight: Radius.circular(AppSizes.radiusMD),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text('التاريخ', style: style)),
            Expanded(flex: 1, child: Text('النوع', style: style)),
            Expanded(flex: 3, child: Text(context.l10n.whMaterialName, style: style)),
            Expanded(flex: 1, child: Text(context.l10n.whMaterialQuantity, style: style)),
            Expanded(flex: 2, child: Text('الإجمالي', style: style, textAlign: TextAlign.left)),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(
      BuildContext context, WarehouseInvoiceItem inv, bool isLight) {
    final borderColor =
        isLight ? AppColors.lightBorder : AppColors.darkBorder;
    final textStyle = TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: isLight ? AppColors.lightText1 : AppColors.darkText1,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          // التاريخ
          Expanded(
            flex: 2,
            child: Text(
              inv.date,
              style: textStyle.copyWith(
                fontSize: 13,
                color: isLight ? AppColors.lightText3 : AppColors.darkText3,
              ),
            ),
          ),

          // النوع
          Expanded(
            flex: 1,
            child: AppBadge(
              text: inv.type == InvoiceType.purchase
                  ? context.l10n.whInvoiceFilterPurchase
                  : context.l10n.whInvoiceFilterUsage,
              variant: inv.type == InvoiceType.purchase
                  ? AppBadgeVariant.cyan
                  : AppBadgeVariant.violet,
            ),
          ),

          // المادة
          Expanded(
            flex: 3,
            child: Text(inv.materialName, style: textStyle),
          ),

          // الكمية
          Expanded(
            flex: 1,
            child: Text(
              '${inv.quantity} ${inv.unit}',
              style: textStyle.copyWith(fontSize: 13),
            ),
          ),

          // الإجمالي
          Expanded(
            flex: 2,
            child: Text(
              '${_formatNumber(inv.total)} ل.ل.',
              style: textStyle.copyWith(
                fontWeight: FontWeight.w800,
                color: inv.type == InvoiceType.purchase
                    ? AppColors.dashCyan
                    : AppColors.dashGreen,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          WEEKLY SUMMARY
  // ────────────────────────────────────────────────────────────────────────

  Widget _buildWeeklySummary(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      decoration: BoxDecoration(
        color: isLight ? AppColors.baseComponent : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // عنوان
          Text(
            context.l10n.whInvoiceWeekSummary,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isLight ? AppColors.lightText1 : AppColors.darkText1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.whInvoiceWeekly,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              color: isLight ? AppColors.lightText3 : AppColors.darkText3,
            ),
          ),

          const SizedBox(height: 20),

          // إجمالي شراء
          _summaryRow(
            context,
            label: context.l10n.whInvoiceTotalPurchase,
            value: _formatNumber(WarehouseInvoicesMockData.weeklyPurchaseTotal),
            color: AppColors.dashCyan,
            icon: Icons.shopping_cart_outlined,
            isLight: isLight,
          ),
          const SizedBox(height: 16),

          // إجمالي استخدام
          _summaryRow(
            context,
            label: context.l10n.whInvoiceTotalUsage,
            value: _formatNumber(WarehouseInvoicesMockData.weeklyUsageTotal),
            color: AppColors.dashGreen,
            icon: Icons.medical_services_outlined,
            isLight: isLight,
          ),
          const SizedBox(height: 16),

          // خسارة
          _summaryRow(
            context,
            label: context.l10n.whInvoiceTotalLoss,
            value: _formatNumber(WarehouseInvoicesMockData.weeklyLossTotal),
            color: AppColors.dashPink,
            icon: Icons.warning_amber_outlined,
            isLight: isLight,
          ),

          const SizedBox(height: 20),

          // زر تصدير PDF
          AppButton(
            label: context.l10n.whInvoiceExportPdf,
            onPressed: () {},
            variant: AppButtonVariant.secondary,
            icon: Icons.picture_as_pdf_outlined,
            expanded: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    required bool isLight,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  color: isLight ? AppColors.lightText3 : AppColors.darkText3,
                ),
              ),
              Text(
                '$value ل.ل.',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          ADD INVOICE DIALOG
  // ────────────────────────────────────────────────────────────────────────

  Future<void> _showAddInvoiceDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => const _AddInvoiceDialog(),
    );
  }

  String _formatNumber(double n) {
    final int v = n.toInt();
    final str = v.toString();
    final buf = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return buf.toString();
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  ADD INVOICE DIALOG
// ════════════════════════════════════════════════════════════════════════════

class _AddInvoiceDialog extends StatefulWidget {
  const _AddInvoiceDialog();

  @override
  State<_AddInvoiceDialog> createState() => _AddInvoiceDialogState();
}

class _AddInvoiceDialogState extends State<_AddInvoiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _materialCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _supplierCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  InvoiceType _type = InvoiceType.purchase;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _materialCtrl.dispose();
    _quantityCtrl.dispose();
    _priceCtrl.dispose();
    _supplierCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 520,
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 650),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLight
                ? [AppColors.baseComponent, const Color(0xFFF5F8FF)]
                : [AppColors.modalDarkStart, AppColors.modalDarkEnd],
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSizes.spaceLG),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'فاتورة شراء جديدة',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isLight
                            ? AppColors.lightText1
                            : AppColors.darkText1,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color:
                          isLight ? AppColors.lightText3 : AppColors.darkText3,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
            ),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.spaceLG),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // النوع
                      AppFormSelect<InvoiceType>(
                        label: 'نوع الفاتورة',
                        value: _type,
                        options: const [
                          AppSelectOption(
                              value: InvoiceType.purchase, label: 'شراء'),
                          AppSelectOption(
                              value: InvoiceType.usage, label: 'استخدام'),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _type = v);
                        },
                      ),
                      const SizedBox(height: 14),

                      // تاريخ التسليم
                      _buildDatePicker(context, isLight),
                      const SizedBox(height: 14),

                      // المادة
                      AppFormField(
                        label: context.l10n.whMaterialName,
                        hint: 'اسم المادة',
                        controller: _materialCtrl,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 14),

                      // الكمية والسعر
                      Row(
                        children: [
                          Expanded(
                            child: AppFormField(
                              label: context.l10n.whMaterialQuantity,
                              hint: '0',
                              controller: _quantityCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'مطلوب' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppFormField(
                              label: 'السعر (ل.ل.)',
                              hint: '0',
                              controller: _priceCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // المورد (للشراء فقط)
                      if (_type == InvoiceType.purchase) ...[
                        AppFormField(
                          label: context.l10n.whMaterialSupplier,
                          hint: 'اسم المورد',
                          controller: _supplierCtrl,
                        ),
                        const SizedBox(height: 14),
                      ],

                      // ملاحظات
                      AppFormField(
                        label: context.l10n.whMaterialNotes,
                        hint: 'ملاحظات إضافية (اختياري)',
                        controller: _notesCtrl,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Divider(
              height: 1,
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(AppSizes.spaceLG),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: context.l10n.cancel,
                      onPressed: () => Navigator.pop(context),
                      variant: AppButtonVariant.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: context.l10n.save,
                      onPressed: _onSave,
                      variant: AppButtonVariant.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, bool isLight) {
    final labelColor =
        isLight ? AppColors.lightText3 : AppColors.darkText3;
    final textColor =
        isLight ? AppColors.lightText1 : AppColors.darkText1;
    final borderColor =
        isLight ? AppColors.lightBorder : AppColors.darkBorder;
    final bgColor = isLight
        ? const Color(0x0A1A1C4E)
        : const Color(0x0AFFFFFF);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            'تاريخ التسليم',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
        ),
        InkWell(
          onTap: () => _pickDate(context),
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 16, color: labelColor),
                const SizedBox(width: 8),
                Text(
                  '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pop(context);
    }
  }
}
