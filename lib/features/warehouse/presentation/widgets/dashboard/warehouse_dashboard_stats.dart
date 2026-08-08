// ════════════════════════════════════════════════════════════════════════════
// warehouse_dashboard_stats.dart
//
// 3 أقسام مؤشّرات المخزون — part of warehouse_dashboard_content.dart.
// تُطابق مباشرة الباك الجديد (2026-08-08): الأكثر طلباً / قريبة الانتهاء /
// منخفضة المخزون. لا "إجمالي مواد" ولا "قيمة مخزون" — الباك لم يعد يوفّرهما.
// تشارك نفس الاستيرادات المعرّفة في الملف الرئيسي.
// ════════════════════════════════════════════════════════════════════════════

part of 'warehouse_dashboard_content.dart';

class _InventorySectionsRow extends StatelessWidget {
  const _InventorySectionsRow({
    required this.isLight,
    this.summary,
    this.isError = false,
  });

  final bool isLight;
  final InventorySummary? summary;

  /// فشل التحميل (لا كاش متاح) — يعرض رسالة بدل انتظار لا ينتهي.
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sections = [
      _InventorySection(
        isLight: isLight,
        isError: isError,
        icon: Icons.trending_up_rounded,
        accent: AppColors.statusInfo,
        title: l10n.whInvMostRequestedTitle,
        count: summary?.mostRequested.length,
        rows: (summary?.mostRequested ?? const [])
            .take(5)
            .map<Widget>((m) => _InfoRow(
                  isLight: isLight,
                  title: m.name,
                  subtitle: '${m.totalQuantity} ${m.unit}',
                  badge: l10n.whTodayOrdersCount(m.requestCount),
                  badgeColor: AppColors.statusInfo,
                ))
            .toList(),
      ),
      _InventorySection(
        isLight: isLight,
        isError: isError,
        icon: Icons.timer_outlined,
        accent: AppColors.statusWarn,
        title: l10n.whExpiringTitle,
        count: summary?.expiringCount,
        rows: (summary?.expiringBatches ?? const [])
            .take(5)
            .map<Widget>((b) => _InfoRow(
                  isLight: isLight,
                  title: b.name,
                  subtitle: '${b.quantity} ${b.unit}',
                  badge: l10n.whInvDaysRemaining(b.daysRemaining),
                  badgeColor: b.daysRemaining <= 7
                      ? AppColors.alertRed
                      : AppColors.statusWarn,
                ))
            .toList(),
      ),
      _InventorySection(
        isLight: isLight,
        isError: isError,
        icon: Icons.error_outline_rounded,
        accent: AppColors.statusUrgent,
        title: l10n.whInvLowStockTitle,
        count: summary?.lowStockCount,
        rows: (summary?.lowStockItems ?? const [])
            .take(5)
            .map<Widget>((m) => _InfoRow(
                  isLight: isLight,
                  title: m.name,
                  subtitle: '${m.totalQuantity} ${m.unit}',
                  badge: m.isOut ? l10n.whStatusOut : l10n.whStatusLow,
                  badgeColor: m.isOut
                      ? AppColors.alertRed
                      : AppColors.statusUrgent,
                ))
            .toList(),
      ),
    ];

    return LayoutBuilder(builder: (context, c) {
      final int cols = c.maxWidth >= 1100 ? 3 : (c.maxWidth >= 720 ? 2 : 1);
      if (cols == 1) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < sections.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              sections[i],
            ],
          ],
        );
      }
      final rows = <Widget>[];
      for (var i = 0; i < sections.length; i += cols) {
        if (i > 0) rows.add(const SizedBox(height: 12));
        final rowChildren = <Widget>[];
        for (var j = 0; j < cols; j++) {
          if (j > 0) rowChildren.add(const SizedBox(width: 12));
          rowChildren.add(i + j < sections.length
              ? Expanded(child: sections[i + j])
              : const Expanded(child: SizedBox.shrink()));
        }
        rows.add(IntrinsicHeight(child: Row(children: rowChildren)));
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
    });
  }
}

class _InventorySection extends StatelessWidget {
  const _InventorySection({
    required this.isLight,
    required this.icon,
    required this.accent,
    required this.title,
    required this.count,
    required this.rows,
    this.isError = false,
  });

  final bool isLight;
  final IconData icon;
  final Color accent;
  final String title;
  final int? count;
  final List<Widget> rows;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLight ? AppColors.baseComponent : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: accent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: isLight
                            ? AppColors.lightText1
                            : AppColors.darkText1)),
              ),
              if (count != null) _CountBadge(count: count!, accent: accent),
            ],
          ),
          const SizedBox(height: 10),
          if (isError)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(context.l10n.error,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.alertRed)),
            )
          else if (count == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(context.l10n.whInvNoItems,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.lightText3)),
            )
          else
            ...rows,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.isLight,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
  });

  final bool isLight;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isLight
                            ? AppColors.lightText1
                            : AppColors.darkText1)),
                Text(subtitle,
                    style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 11,
                        color: AppColors.lightText3)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: Text(badge,
                style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: badgeColor)),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.accent});
  final int count;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
      child: Text('$count',
          style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white)),
    );
  }
}
