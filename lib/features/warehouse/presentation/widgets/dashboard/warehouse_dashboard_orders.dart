// ════════════════════════════════════════════════════════════════════════════
// warehouse_dashboard_orders.dart
//
// قسم أحدث الطلبات + الجدول — part of warehouse_dashboard_content.dart (تقسيم
// الصفحات العملاقة). تشارك نفس الاستيرادات المعرّفة في الملف الرئيسي.
//
// مربوط بـ WarehouseRequestsCubit الحقيقي (كان جدولاً ثابتاً بالكامل ببيانات
// وهمية وحالة "جزئي" غير موجودة أصلاً بالباك — أُزيلت الفلاتر المكرَّرة مع
// صفحة الطلبيات الفعلية، وأصبحت الحالة تُعرَض عبر requestStatusStyle الحقيقي).
// اسم القسم "أحدث الطلبات" لا "طلبات اليوم" عمداً: الجدول يعرض آخر N طلب بلا
// تصفية بالتاريخ (تفادياً لقسم فارغ بيوم هادئ)، والشارة تعرض إجمالي الطلبات
// الحقيقي (لا عدد الأسطر المعروضة) — لا تناقض بين العنوان والمحتوى.
// ════════════════════════════════════════════════════════════════════════════

part of 'warehouse_dashboard_content.dart';

// ══════════════════════════════════════════════════════════════════════════
//  4) RECENT ORDERS SECTION
// ══════════════════════════════════════════════════════════════════════════

/// عدد أحدث الطلبات المعروضة بلوحة التحكم (التفاصيل الكاملة بصفحة الطلبيات).
const int _kDashboardOrdersLimit = 6;

class _TodayOrdersSection extends StatelessWidget {
  const _TodayOrdersSection({required this.isLight, required this.requests});

  final bool isLight;
  final List<WarehouseRequest> requests;

  List<WarehouseRequest> get _recent {
    final sorted = [...requests]..sort((a, b) {
        final ad = a.createdAt;
        final bd = b.createdAt;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return bd.compareTo(ad);
      });
    return sorted.take(_kDashboardOrdersLimit).toList();
  }

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.assignment_outlined,
              size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            context.l10n.whRecentOrdersTitle,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isLight ? AppColors.lightText1 : AppColors.darkText1,
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
              context.l10n.whTodayOrdersCount(requests.length),
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.statusProgress,
              ),
            ),
          ),
          const Spacer(),
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
    final rows = _recent;
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
        _OrdersTableHeader(isLight: isLight),
        for (var i = 0; i < rows.length; i++)
          _OrdersTableRow(
            request: rows[i],
            isLight: isLight,
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
          Expanded(flex: 2, child: _Hcell(context.l10n.whReqItems)),
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
    required this.request,
    required this.isLight,
    required this.isLast,
  });
  final WarehouseRequest request;
  final bool isLight;
  final bool isLast;

  String get _materialsSummary {
    final names = [
      ...request.items.map((e) => e.materialName),
      ...request.newItems.map((e) => e.materialName),
    ].where((n) => n.isNotEmpty).toList();
    if (names.isEmpty) return '—';
    if (names.length == 1) return names.first;
    return '${names.first} +${names.length - 1}';
  }

  String get _dateLabel {
    final d = request.createdAt;
    if (d == null) return '—';
    return '${d.day.toString().padLeft(2, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final st = requestStatusStyle(context, request.status);
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
              context.l10n.whReqNumber(request.id),
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isLight ? AppColors.lightText1 : AppColors.darkText1,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _RequesterInitialChip(
                  initial: request.requesterName.isEmpty
                      ? '—'
                      : request.requesterName.characters.first,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    request.requesterName.isEmpty
                        ? '—'
                        : request.requesterName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color:
                          isLight ? AppColors.lightText1 : AppColors.darkText1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _materialsSummary,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                color: isLight ? AppColors.lightText1 : AppColors.darkText1,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${request.itemsCount}',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isLight ? AppColors.lightText1 : AppColors.darkText1,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _dateLabel,
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
              child: _StatusPillSmall(label: st.label, color: st.color),
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
  const _StatusPillSmall({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
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
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
