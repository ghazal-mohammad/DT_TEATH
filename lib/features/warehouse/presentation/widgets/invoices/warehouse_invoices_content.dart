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
        _InvoiceSegmentedTabs(
          values: _InvoiceFilter.values,
          counts: counts,
          selected: _filter,
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

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.isLight,
    required this.totalCount,
    required this.paidSum,
    required this.pendingSum,
    required this.purchasesSum,
  });

  final bool isLight;
  final int totalCount;
  final double paidSum;
  final double pendingSum;
  final double purchasesSum;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 1080
          ? 4
          : c.maxWidth >= 620
              ? 2
              : 1;
      return GridView.count(
        crossAxisCount: cols,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: switch (cols) { 4 => 1.8, 2 => 2.4, _ => 3.2 },
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _StatBox(
            isLight: isLight,
            badge: context.l10n.invBadgeTotal,
            badgeColor: const Color(0xFF2C7FDB),
            valueLine: '$totalCount',
            label: context.l10n.invStatThisMonth,
            icon: Icons.receipt_long_outlined,
            accent: const Color(0xFF2C7FDB),
          ),
          _StatBox(
            isLight: isLight,
            badge: context.l10n.invBadgePaid,
            badgeColor: const Color(0xFF1F9B6E),
            valueLine: _fmtMoney(paidSum),
            label: context.l10n.invStatPaidTotal,
            icon: Icons.check_circle_outline_rounded,
            accent: const Color(0xFF1F9B6E),
          ),
          _StatBox(
            isLight: isLight,
            badge: context.l10n.invBadgePending,
            badgeColor: const Color(0xFF7A4FCF),
            valueLine: _fmtMoney(pendingSum),
            label: context.l10n.invStatPendingPay,
            icon: Icons.access_time_rounded,
            accent: const Color(0xFF7A4FCF),
          ),
          _StatBox(
            isLight: isLight,
            badge: '+12%',
            badgeColor: const Color(0xFFE17B2C),
            valueLine: _fmtMoney(purchasesSum),
            label: context.l10n.invStatTotalPurchases,
            icon: Icons.trending_up_rounded,
            accent: const Color(0xFFE17B2C),
          ),
        ],
      );
    });
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.isLight,
    required this.badge,
    required this.badgeColor,
    required this.valueLine,
    required this.label,
    required this.icon,
    required this.accent,
  });

  final bool isLight;
  final String badge;
  final Color badgeColor;
  final String valueLine;
  final String label;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isLight ? AppColors.baseComponent : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        // RTL: أوّل child=يمين، آخر=يسار. لتثبيت stripe يسار → آخر child.
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // RTL: لتثبيت icon يمين و badge يسار → [icon, Spacer, badge].
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, size: 17, color: accent),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusFull),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      valueLine,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                        color: isLight
                            ? AppColors.lightText1
                            : AppColors.darkText1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isLight
                            ? AppColors.lightText3
                            : AppColors.darkText3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(width: 4, color: accent),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                              TABLE
// ══════════════════════════════════════════════════════════════════════════

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.isLight});
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isLight ? AppColors.tableHeader : AppColors.darkSurface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          Expanded(flex: 3, child: _HCell(context.l10n.invColNumber)),
          Expanded(flex: 3, child: _HCell(context.l10n.invFormSupplier)),
          Expanded(flex: 2, child: _HCell(context.l10n.invFormDate)),
          Expanded(flex: 2, child: _HCell(context.l10n.invColItemCount)),
          Expanded(flex: 3, child: _HCell(context.l10n.invColTotalSyp)),
          Expanded(flex: 2, child: _HCell(context.l10n.colStatus)),
        ],
      ),
    );
  }
}

class _HCell extends StatelessWidget {
  const _HCell(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.lightText3,
      ),
    );
  }
}

class _InvoiceDataRow extends StatelessWidget {
  const _InvoiceDataRow({
    required this.invoice,
    required this.status,
    required this.isLight,
    required this.isLast,
  });

  final WarehouseInvoiceItem invoice;
  final _PaymentStatus status;
  final bool isLight;
  final bool isLast;

  String get _supplierInitial {
    final s = invoice.supplier?.trim() ?? '';
    if (s.isEmpty) return '?';
    return s.characters.firstOrNull ?? '?';
  }

  @override
  Widget build(BuildContext context) {
    final txt1 = isLight ? AppColors.lightText1 : AppColors.darkText1;
    final txt3 = isLight ? AppColors.lightText3 : AppColors.darkText3;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast
                ? Colors.transparent
                : (isLight ? AppColors.lightBorder : AppColors.darkBorder),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              invoice.invoiceNumber,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: txt1,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            // RTL: اسم المورد يمين، avatar يسار → [Flexible(text), SizedBox, avatar].
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    invoice.supplier ?? '—',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: txt1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    _supplierInitial,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              invoice.date,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12.5,
                color: txt3,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              invoice.quantity,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: txt1,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _fmtMoney(invoice.total),
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: txt1,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: _PaymentPill(status: status),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentPill extends StatelessWidget {
  const _PaymentPill({required this.status});
  final _PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final isPaid = status == _PaymentStatus.paid;
    final color = isPaid ? const Color(0xFF1F9B6E) : const Color(0xFF7A4FCF);
    final label =
        isPaid ? context.l10n.invStatusPaid : context.l10n.invStatPendingPay;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      // RTL: النص يمين، dot يسار → [Text, SizedBox, dot].
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                              SMALL PIECES
// ══════════════════════════════════════════════════════════════════════════

// ── Filter pills (النشط dark navy + count badge داخل الكبسولة) ─────────
class _InvoiceSegmentedTabs extends StatelessWidget {
  const _InvoiceSegmentedTabs({
    required this.values,
    required this.counts,
    required this.selected,
    required this.onChanged,
  });

  final List<_InvoiceFilter> values;
  final Map<_InvoiceFilter, int> counts;
  final _InvoiceFilter selected;
  final ValueChanged<_InvoiceFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: values.map((v) {
        final isActive = v == selected;
        final bg = isActive
            ? AppColors.primary
            : (isLight ? const Color(0xFFF1EDE6) : AppColors.darkBg2);
        final labelColor = isActive
            ? Colors.white
            : (isLight ? AppColors.lightText1 : AppColors.darkText1);
        final countBg = isActive
            ? Colors.white.withValues(alpha: 0.18)
            : (isLight ? Colors.white : AppColors.darkBg1);
        final countColor = isActive
            ? Colors.white
            : (isLight ? AppColors.lightText3 : AppColors.darkText3);
        return InkWell(
          onTap: () => onChanged(v),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.fromLTRB(6, 4, 12, 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: countBg,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(
                    '${counts[v] ?? 0}',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: countColor,
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  v.label(context.l10n),
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: labelColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEFE3FA),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF7A4FCF),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                              HELPERS
// ══════════════════════════════════════════════════════════════════════════

/// تنسيق رقم بفواصل الآلاف (e.g., 6110000 → "6,110,000").
String _fmtMoney(double value) {
  final asInt = value.round();
  final s = asInt.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
    buffer.write(s[i]);
  }
  return buffer.toString();
}
