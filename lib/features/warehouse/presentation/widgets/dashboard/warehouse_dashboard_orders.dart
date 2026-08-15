// ════════════════════════════════════════════════════════════════════════════
// warehouse_dashboard_orders.dart
//
// قسم طلبات اليوم + الجدول — part of warehouse_dashboard_content.dart (تقسيم الصفحات العملاقة).
// تشارك نفس الاستيرادات المعرّفة في الملف الرئيسي.
// ════════════════════════════════════════════════════════════════════════════

part of 'warehouse_dashboard_content.dart';

// ══════════════════════════════════════════════════════════════════════════
//  4) TODAY ORDERS SECTION
// ══════════════════════════════════════════════════════════════════════════

enum _OrderTab { all, isNew, partial, fulfilled }

extension on _OrderTab {
  String label(BuildContext context) => switch (this) {
        _OrderTab.all => context.l10n.notifFilterAll,
        _OrderTab.isNew => context.l10n.whOrderFilterNew,
        _OrderTab.partial => context.l10n.whOrderPartial,
        _OrderTab.fulfilled => context.l10n.whOrderFulfilled,
      };
}

enum _OrderRowStatus { isNew, partial, fulfilled }

extension on _OrderRowStatus {
  String label(BuildContext context) => switch (this) {
        _OrderRowStatus.isNew => context.l10n.whOrderFilterNew,
        _OrderRowStatus.partial => context.l10n.whOrderPartial,
        _OrderRowStatus.fulfilled => context.l10n.whOrderFulfilled,
      };

  Color get color => switch (this) {
        _OrderRowStatus.isNew => AppColors.statusInfo,
        _OrderRowStatus.partial => AppColors.statusProgress,
        _OrderRowStatus.fulfilled => AppColors.statusSuccess,
      };
}

class _OrderRow {
  const _OrderRow({
    required this.id,
    required this.requesterInitial,
    required this.requester,
    required this.material,
    required this.quantity,
    required this.date,
    required this.status,
  });
  final String id;
  final String requesterInitial;
  final String requester;
  final String material;
  final String quantity;
  final String date;
  final _OrderRowStatus status;
}

const _todayOrders = <_OrderRow>[
  _OrderRow(
    id: 'REQ-1024',
    requesterInitial: 'م',
    requester: 'مخبر التعويضات',
    material: 'سيراميك زيركون',
    quantity: '10 قطعة',
    date: '27-03-2026',
    status: _OrderRowStatus.isNew,
  ),
  _OrderRow(
    id: 'REQ-1023',
    requesterInitial: 'ع',
    requester: 'عيادة د. سارة',
    material: 'قفازات لاتكس',
    quantity: '5 صناديق',
    date: '27-03-2026',
    status: _OrderRowStatus.partial,
  ),
  _OrderRow(
    id: 'REQ-1022',
    requesterInitial: 'م',
    requester: 'مخبر التعويضات',
    material: 'PFM Alloy',
    quantity: '15 قطعة',
    date: '26-03-2026',
    status: _OrderRowStatus.fulfilled,
  ),
  _OrderRow(
    id: 'REQ-1021',
    requesterInitial: 'ع',
    requester: 'عيادة د. خالد',
    material: 'حقن بنج موضعي',
    quantity: '20 حقنة',
    date: '26-03-2026',
    status: _OrderRowStatus.isNew,
  ),
  _OrderRow(
    id: 'REQ-1020',
    requesterInitial: 'ا',
    requester: 'السكرتارية',
    material: 'أكواب بلاستيكية',
    quantity: '5 علب',
    date: '25-03-2026',
    status: _OrderRowStatus.fulfilled,
  ),
  _OrderRow(
    id: 'REQ-1019',
    requesterInitial: 'م',
    requester: 'مخبر التعويضات',
    material: 'E-max Press',
    quantity: '8 قطعة',
    date: '25-03-2026',
    status: _OrderRowStatus.partial,
  ),
];

int _countOrders(_OrderTab t) {
  switch (t) {
    case _OrderTab.all:
      return _todayOrders.length;
    case _OrderTab.isNew:
      return _todayOrders
          .where((o) => o.status == _OrderRowStatus.isNew)
          .length;
    case _OrderTab.partial:
      return _todayOrders
          .where((o) => o.status == _OrderRowStatus.partial)
          .length;
    case _OrderTab.fulfilled:
      return _todayOrders
          .where((o) => o.status == _OrderRowStatus.fulfilled)
          .length;
  }
}

class _TodayOrdersSection extends StatefulWidget {
  const _TodayOrdersSection({required this.isLight});
  final bool isLight;

  @override
  State<_TodayOrdersSection> createState() => _TodayOrdersSectionState();
}

class _TodayOrdersSectionState extends State<_TodayOrdersSection> {
  _OrderTab _tab = _OrderTab.all;

  List<_OrderRow> get _filtered {
    switch (_tab) {
      case _OrderTab.all:
        return _todayOrders;
      case _OrderTab.isNew:
        return _todayOrders
            .where((o) => o.status == _OrderRowStatus.isNew)
            .toList();
      case _OrderTab.partial:
        return _todayOrders
            .where((o) => o.status == _OrderRowStatus.partial)
            .toList();
      case _OrderTab.fulfilled:
        return _todayOrders
            .where((o) => o.status == _OrderRowStatus.fulfilled)
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isLight
            ? AppColors.baseComponent
            : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
          color: widget.isLight
              ? AppColors.lightBorder
              : AppColors.darkBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          const _SectionDivider(),
          _buildTable(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // كل شي على سطر واحد: العنوان + الـ badge (يمين) + الـ chips + "عرض الكل" (يسار).
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.assignment_outlined,
              size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            context.l10n.labTodayOrders,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: widget.isLight
                  ? AppColors.lightText1
                  : AppColors.darkText1,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.statusProgressBg,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: Text(
              context.l10n.whTodayOrdersCount(_todayOrders.length),
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.statusProgress,
              ),
            ),
          ),
          const Spacer(),
          AppSegmentedTabs<_OrderTab>(
            values: _OrderTab.values,
            selected: _tab,
            labelOf: (t) => t.label(context),
            countOf: (t) => _countOrders(t),
            onChanged: (t) => setState(() => _tab = t),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: () => context.go(RouteNames.warehouseOrders),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              '${context.l10n.viewAll} ←',
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    final rows = _filtered;
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: Text(
            context.l10n.whOrdersEmptyFilter,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              color: AppColors.lightText3,
            ),
          ),
        ),
      );
    }
    return Column(
      children: [
        _OrdersTableHeader(isLight: widget.isLight),
        for (var i = 0; i < rows.length; i++)
          _OrdersTableRow(
            row: rows[i],
            isLight: widget.isLight,
            isLast: i == rows.length - 1,
          ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();
  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Divider(
      height: 1,
      thickness: 1,
      color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
    );
  }
}

// ── Orders Table ───────────────────────────────────────────────────────

class _OrdersTableHeader extends StatelessWidget {
  const _OrdersTableHeader({required this.isLight});
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    // رأس الجدول باللون الأزرق المعتمد بـ Design Guide (BED8FA).
    final bg = isLight ? AppColors.tableHeader : AppColors.darkSurface;
    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          Expanded(flex: 2, child: _Hcell(context.l10n.whOrderNumber)),
          Expanded(flex: 3, child: _Hcell(context.l10n.whOrderRequesterParty)),
          Expanded(flex: 3, child: _Hcell(context.l10n.colMaterial)),
          Expanded(flex: 2, child: _Hcell(context.l10n.colQuantity)),
          Expanded(flex: 3, child: _Hcell(context.l10n.whOrderDate)),
          Expanded(flex: 2, child: _Hcell(context.l10n.whOrderStatus)),
        ],
      ),
    );
  }
}

class _Hcell extends StatelessWidget {
  const _Hcell(this.text);
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

class _OrdersTableRow extends StatelessWidget {
  const _OrdersTableRow({
    required this.row,
    required this.isLight,
    required this.isLast,
  });
  final _OrderRow row;
  final bool isLight;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLight
                ? (isLast ? Colors.transparent : AppColors.lightBorder)
                : (isLast ? Colors.transparent : AppColors.darkBorder),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              row.id,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isLight
                    ? AppColors.lightText1
                    : AppColors.darkText1,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _RequesterInitialChip(initial: row.requesterInitial),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    row.requester,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isLight
                          ? AppColors.lightText1
                          : AppColors.darkText1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              row.material,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                color: isLight
                    ? AppColors.lightText1
                    : AppColors.darkText1,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.quantity,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isLight
                    ? AppColors.lightText1
                    : AppColors.darkText1,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              row.date,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                color: AppColors.lightText3,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: _StatusPillSmall(status: row.status),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequesterInitialChip extends StatelessWidget {
  const _RequesterInitialChip({required this.initial});
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        initial,
        style: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _StatusPillSmall extends StatelessWidget {
  const _StatusPillSmall({required this.status});
  final _OrderRowStatus status;

  @override
  Widget build(BuildContext context) {
    final c = status.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              status.label(context),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: c,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
