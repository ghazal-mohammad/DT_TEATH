// ════════════════════════════════════════════════════════════════════════════
// warehouse_invoices_parts.dart
//
// أجزاء عرض جدول/إحصاءات الفواتير — مُستخرَجة من warehouse_invoices_content.dart
// ضمن تقسيم الملفات العملاقة (>25KB). part-of: تبقى private وتشارك الاستيرادات.
// ════════════════════════════════════════════════════════════════════════════

part of 'warehouse_invoices_content.dart';

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
            badgeColor: AppColors.statusInfo,
            valueLine: '$totalCount',
            label: context.l10n.invStatThisMonth,
            icon: Icons.receipt_long_outlined,
            accent: AppColors.statusInfo,
          ),
          _StatBox(
            isLight: isLight,
            badge: context.l10n.invBadgePaid,
            badgeColor: AppColors.statusSuccess,
            valueLine: _fmtMoney(paidSum),
            label: context.l10n.invStatPaidTotal,
            icon: Icons.check_circle_outline_rounded,
            accent: AppColors.statusSuccess,
          ),
          _StatBox(
            isLight: isLight,
            badge: context.l10n.invBadgePending,
            badgeColor: AppColors.statusProgress,
            valueLine: _fmtMoney(pendingSum),
            label: context.l10n.invStatPendingPay,
            icon: Icons.access_time_rounded,
            accent: AppColors.statusProgress,
          ),
          _StatBox(
            isLight: isLight,
            badge: '+12%',
            badgeColor: AppColors.statusWarn,
            valueLine: _fmtMoney(purchasesSum),
            label: context.l10n.invStatTotalPurchases,
            icon: Icons.trending_up_rounded,
            accent: AppColors.statusWarn,
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
                              fontSize: 11,
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
                fontSize: 13,
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
                fontSize: 13,
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
    final color = isPaid ? AppColors.statusSuccess : AppColors.statusProgress;
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
              fontSize: 12,
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


class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.statusProgressBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.statusProgress,
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
