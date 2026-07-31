// ════════════════════════════════════════════════════════════════════════════
// warehouse_invoices_content.dart
//
// محتوى صفحة فواتير المستودع — مطابق لـ mockup التصميم.
//
// 🎯 البنية:
//   1. صف 4 بطاقات إحصائية (إجمالي / مدفوع / معلق / المشتريات الكلية)
//   2. شريط تابات الحالة (الكل / مدفوعة / بانتظار) + عدّاد
//   3. قسم الجدول: عنوان "فواتير الشراء" + زر إضافة فاتورة
//   4. الجدول: رقم الفاتورة | المورد | التاريخ | عدد المواد | الإجمالي | الحالة
//
// ملاحظة: حالة الدفع تُحسب محلياً (heuristic) حتى يصير في backend.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../../../shared/widgets/primitives/app_segmented_tabs.dart';
import '../../../data/mock/warehouse_pages_mock_data.dart';
import 'warehouse_invoice_form_dialog.dart';

// ══════════════════════════════════════════════════════════════════════════
//                              FILTERS
// ══════════════════════════════════════════════════════════════════════════

enum _PaymentStatus { paid, pending }

enum _InvoiceFilter { all, paid, pending }

extension on _InvoiceFilter {
  String label(AppLocalizations l10n) => switch (this) {
        _InvoiceFilter.all => l10n.whFilterAll,
        _InvoiceFilter.paid => l10n.invStatusPaid,
        _InvoiceFilter.pending => l10n.invStatusPending,
      };

  bool matches(_PaymentStatus s) {
    return switch (this) {
      _InvoiceFilter.all => true,
      _InvoiceFilter.paid => s == _PaymentStatus.paid,
      _InvoiceFilter.pending => s == _PaymentStatus.pending,
    };
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                              MAIN CONTENT
// ══════════════════════════════════════════════════════════════════════════

part 'warehouse_invoices_parts.dart';

class WarehouseInvoicesContent extends StatefulWidget {
  const WarehouseInvoicesContent({super.key});

  @override
  State<WarehouseInvoicesContent> createState() =>
      _WarehouseInvoicesContentState();
}

class _WarehouseInvoicesContentState extends State<WarehouseInvoicesContent> {
  _InvoiceFilter _filter = _InvoiceFilter.all;

  /// نأخذ فواتير الشراء فقط (المُطابقة للـ mockup).
  late final List<WarehouseInvoiceItem> _all = WarehouseInvoicesMockData
      .invoices
      .where((i) => i.type == InvoiceType.purchase)
      .toList();

  /// تحديد حالة الدفع محلياً — heuristic: الفواتير الأقدم مدفوعة، الأحدث معلّقة.
  _PaymentStatus _statusOf(WarehouseInvoiceItem i) {
    final idx = _all.indexOf(i);
    return idx < 5 ? _PaymentStatus.paid : _PaymentStatus.pending;
  }

  List<WarehouseInvoiceItem> get _filtered =>
      _all.where((i) => _filter.matches(_statusOf(i))).toList();

  int _countStatus(_PaymentStatus s) =>
      _all.where((i) => _statusOf(i) == s).length;

  double _sumWhere(bool Function(WarehouseInvoiceItem) test) =>
      _all.where(test).fold<double>(0, (acc, i) => acc + i.total);

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatsRow(
          isLight: isLight,
          totalCount: _all.length,
          paidSum: _sumWhere((i) => _statusOf(i) == _PaymentStatus.paid),
          pendingSum: _sumWhere((i) => _statusOf(i) == _PaymentStatus.pending),
          purchasesSum: _all.fold<double>(0, (acc, i) => acc + i.total),
        ),
        const SizedBox(height: 14),
        _buildTabsRow(context, isLight),
        const SizedBox(height: 14),
        _buildTableSection(isLight),
      ],
    );
  }

  Widget _buildTabsRow(BuildContext context, bool isLight) {
    final counts = <_InvoiceFilter, int>{
      _InvoiceFilter.all: _all.length,
      _InvoiceFilter.paid: _countStatus(_PaymentStatus.paid),
      _InvoiceFilter.pending: _countStatus(_PaymentStatus.pending),
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppSegmentedTabs<_InvoiceFilter>(
          values: _InvoiceFilter.values,
          selected: _filter,
          labelOf: (v) => v.label(context.l10n),
          countOf: (v) => counts[v] ?? 0,
          onChanged: (v) => setState(() => _filter = v),
        ),
        const Spacer(),
        Text(
          context.l10n.invCount(_filtered.length, _all.length),
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12,
            color: isLight ? AppColors.lightText3 : AppColors.darkText3,
          ),
        ),
      ],
    );
  }

  Widget _buildTableSection(bool isLight) {
    return Container(
      decoration: BoxDecoration(
        color: isLight ? AppColors.baseComponent : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: Column(
        children: [
          _buildHeader(isLight),
          Divider(
            height: 1,
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          ),
          if (_filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: AppEmptyState(
                icon: Icons.receipt_long_outlined,
                title: context.l10n.invEmptyTitle,
                message: context.l10n.invEmptyMessage,
              ),
            )
          else
            _buildTable(isLight),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isLight) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_outlined,
              size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            context.l10n.invPurchaseInvoices,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isLight ? AppColors.lightText1 : AppColors.darkText1,
            ),
          ),
          const SizedBox(width: 8),
          _CountBadge(count: _all.length),
          const Spacer(),
          AppButton(
            label: '+ ${context.l10n.invAddInvoice}',
            onPressed: () async {
              final added =
                  await WarehouseInvoiceFormDialog.show(context);
              if (added != null && mounted) {
                setState(() => _all.insert(0, added));
              }
            },
            variant: AppButtonVariant.primary,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }

  Widget _buildTable(bool isLight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TableHeader(isLight: isLight),
        for (var i = 0; i < _filtered.length; i++)
          _InvoiceDataRow(
            invoice: _filtered[i],
            status: _statusOf(_filtered[i]),
            isLight: isLight,
            isLast: i == _filtered.length - 1,
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                          STATS ROW
// ══════════════════════════════════════════════════════════════════════════

