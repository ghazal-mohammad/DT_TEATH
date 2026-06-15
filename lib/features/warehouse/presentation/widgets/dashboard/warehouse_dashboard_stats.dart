// ════════════════════════════════════════════════════════════════════════════
// warehouse_dashboard_stats.dart
//
// بطاقات الإحصاء — part of warehouse_dashboard_content.dart (تقسيم الصفحات العملاقة).
// تشارك نفس الاستيرادات المعرّفة في الملف الرئيسي.
// ════════════════════════════════════════════════════════════════════════════

part of 'warehouse_dashboard_content.dart';

// ══════════════════════════════════════════════════════════════════════════
//  2) STAT CARDS ROW
// ══════════════════════════════════════════════════════════════════════════

enum _StatVariant { green, purple, orange, blue }

extension on _StatVariant {
  Color get accent => switch (this) {
        _StatVariant.green => AppColors.statusSuccess,
        _StatVariant.purple => AppColors.statusProgress,
        _StatVariant.orange => AppColors.statusWarn,
        _StatVariant.blue => AppColors.statusInfo,
      };

  Color get tint => accent.withValues(alpha: 0.12);
}

class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow({required this.isLight});
  final bool isLight;

  // الترتيب من اليمين لليسار (RTL): إجمالي → الحد الأدنى → الطلبات → المشتريات.
  List<_StatData> _items(BuildContext context) => [
    _StatData(
      variant: _StatVariant.blue,
      badge: '4+',
      value: '247',
      label: context.l10n.whTotalMaterials,
      trend: context.l10n.whTrendThisWeek('4+'),
      trendUp: true,
      icon: Icons.inventory_2_outlined,
    ),
    _StatData(
      variant: _StatVariant.orange,
      badge: context.l10n.whBadgeAlert,
      value: '8',
      label: context.l10n.whStatLowStockShort,
      trend: context.l10n.whNeedsSupply,
      trendUp: false,
      icon: Icons.error_outline,
    ),
    _StatData(
      variant: _StatVariant.purple,
      badge: context.l10n.whBadgeNew,
      value: '9',
      label: context.l10n.whStatPendingSupply,
      trend: context.l10n.whTrendToday('3+'),
      trendUp: true,
      icon: Icons.assignment_outlined,
    ),
    _StatData(
      variant: _StatVariant.green,
      badge: context.l10n.whBadgeThisMonth,
      value: '2.8M',
      label: context.l10n.whStatMonthPurchases,
      trend: context.l10n.whTrendVsLastMonth('+12%'),
      trendUp: true,
      icon: Icons.assignment_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final int cols = c.maxWidth >= 1100
          ? 4
          : c.maxWidth >= 720
              ? 2
              : 1;
      // فرض RTL على الصف لضمان: أول عنصر بالقائمة = يمين الشاشة بصرياً.
      return Directionality(
        textDirection: TextDirection.rtl,
        child: _buildRows(context, cols),
      );
    });
  }

  Widget _buildRows(BuildContext context, int cols) {
    final cards = _items(context)
        .map((d) => _StatCard(isLight: isLight, data: d))
        .toList(growable: false);

    if (cols == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            cards[i],
          ],
        ],
      );
    }

    // عدد الصفوف المطلوب لتغطية كل العناصر.
    final rows = <Widget>[];
    for (var i = 0; i < cards.length; i += cols) {
      if (i > 0) rows.add(const SizedBox(height: 12));
      final rowChildren = <Widget>[];
      for (var j = 0; j < cols; j++) {
        if (j > 0) rowChildren.add(const SizedBox(width: 12));
        if (i + j < cards.length) {
          rowChildren.add(Expanded(child: cards[i + j]));
        } else {
          rowChildren.add(const Expanded(child: SizedBox.shrink()));
        }
      }
      rows.add(IntrinsicHeight(child: Row(children: rowChildren)));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

class _StatData {
  const _StatData({
    required this.variant,
    required this.badge,
    required this.value,
    required this.label,
    required this.trend,
    required this.trendUp,
    required this.icon,
  });

  final _StatVariant variant;
  final String badge;
  final String value;
  final String label;
  final String trend;
  final bool trendUp;
  final IconData icon;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.isLight, required this.data});
  final bool isLight;
  final _StatData data;

  @override
  Widget build(BuildContext context) {
    final accent = data.variant.accent;
    final tint = data.variant.tint;

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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StatBadge(text: data.badge, accent: accent, tint: tint),
                        const Spacer(),
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: tint,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(data.icon, size: 15, color: accent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.value,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                        color: isLight
                            ? AppColors.lightText1
                            : AppColors.darkText1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isLight
                            ? AppColors.lightText3
                            : AppColors.darkText3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          data.trendUp
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 11,
                          color: accent,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            data.trend,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // الشريط الجانبي على يسار البطاقة بصرياً (آخر child في RTL Row).
            Container(width: 4, color: accent),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge(
      {required this.text, required this.accent, required this.tint});
  final String text;
  final Color accent;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: accent,
        ),
      ),
    );
  }
}
