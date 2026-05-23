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

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../data/mock/warehouse_pages_mock_data.dart';

// ══════════════════════════════════════════════════════════════════════════
//                              FILTERS
// ══════════════════════════════════════════════════════════════════════════

enum _PaymentStatus { paid, pending }

enum _InvoiceFilter { all, paid, pending }

extension on _InvoiceFilter {
  String get label => switch (this) {
        _InvoiceFilter.all => 'الكل',
        _InvoiceFilter.paid => 'مدفوعة',
        _InvoiceFilter.pending => 'بانتظار',
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
        _buildTabsRow(isLight),
        const SizedBox(height: 14),
        _buildTableSection(isLight),
      ],
    );
  }

  Widget _buildTabsRow(bool isLight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _InvoiceFilter.values.map((f) {
              final n = switch (f) {
                _InvoiceFilter.all => _all.length,
                _InvoiceFilter.paid => _countStatus(_PaymentStatus.paid),
                _InvoiceFilter.pending => _countStatus(_PaymentStatus.pending),
              };
              return _PillChip(
                label: '${f.label}  $n',
                selected: f == _filter,
                onTap: () => setState(() => _filter = f),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${_filtered.length} فاتورة من أصل ${_all.length}',
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: AppEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'لا توجد فواتير',
                message: 'لا يوجد فواتير تطابق الفلتر الحالي',
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
            'فواتير الشراء',
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
            label: '+ إضافة فاتورة',
            onPressed: () {},
            variant: AppButtonVariant.primary,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }

  Widget _buildTable(bool isLight) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.sizeOf(context).width - 80,
        ),
        child: Column(
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
        ),
      ),
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
            badge: 'إجمالي',
            badgeColor: const Color(0xFF2C7FDB),
            valueLine: '$totalCount',
            label: 'فاتورة هذا الشهر',
            icon: Icons.receipt_long_outlined,
            accent: const Color(0xFF2C7FDB),
          ),
          _StatBox(
            isLight: isLight,
            badge: 'مدفوع',
            badgeColor: const Color(0xFF1F9B6E),
            valueLine: _fmtMoney(paidSum),
            label: 'إجمالي المدفوع',
            icon: Icons.check_circle_outline_rounded,
            accent: const Color(0xFF1F9B6E),
          ),
          _StatBox(
            isLight: isLight,
            badge: 'معلق',
            badgeColor: const Color(0xFF7A4FCF),
            valueLine: _fmtMoney(pendingSum),
            label: 'بانتظار الدفع',
            icon: Icons.access_time_rounded,
            accent: const Color(0xFF7A4FCF),
          ),
          _StatBox(
            isLight: isLight,
            badge: '+12%',
            badgeColor: const Color(0xFFE17B2C),
            valueLine: _fmtMoney(purchasesSum),
            label: 'المشتريات الكلية',
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
        child: Row(
          children: [
            Container(width: 4, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
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
                        const Spacer(),
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
      color: isLight ? const Color(0xFFF4F1FB) : AppColors.darkSurface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: const Row(
        children: [
          Expanded(flex: 3, child: _HCell('رقم الفاتورة')),
          Expanded(flex: 3, child: _HCell('المورد')),
          Expanded(flex: 2, child: _HCell('التاريخ')),
          Expanded(flex: 2, child: _HCell('عدد المواد')),
          Expanded(flex: 3, child: _HCell('الإجمالي (ل.س)')),
          Expanded(flex: 2, child: _HCell('الحالة')),
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
            child: Row(
              children: [
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
                const SizedBox(width: 8),
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
    final label = isPaid ? 'مدفوعة' : 'بانتظار الدفع';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                              SMALL PIECES
// ══════════════════════════════════════════════════════════════════════════

class _PillChip extends StatelessWidget {
  const _PillChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = selected
        ? AppColors.primary
        : (isLight ? AppColors.baseComponent : AppColors.darkSurface);
    final fg = selected
        ? Colors.white
        : (isLight ? AppColors.lightText1 : AppColors.darkText1);
    final border = selected
        ? AppColors.primary
        : (isLight ? AppColors.lightBorder : AppColors.darkBorder);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ),
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
