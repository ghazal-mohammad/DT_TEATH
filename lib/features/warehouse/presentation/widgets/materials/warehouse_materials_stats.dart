// ════════════════════════════════════════════════════════════════════════════
// warehouse_materials_stats.dart
//
// صف بطاقات الإحصاء — part of warehouse_materials_content.dart (تقسيم الصفحات العملاقة).
// ════════════════════════════════════════════════════════════════════════════

part of 'warehouse_materials_content.dart';

// ══════════════════════════════════════════════════════════════════════════
//                          1) STATS ROW
// ══════════════════════════════════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.materials,
    required this.lowStockIds,
    required this.isLight,
  });
  final List<WarehouseMaterial> materials;
  final Set<String> lowStockIds;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final statuses = {
      for (final m in materials) m.id: _effectiveStatus(m, lowStockIds),
    };
    final outCount = materials
        .where((m) =>
            statuses[m.id] == MaterialStatus.outOfStock ||
            statuses[m.id] == MaterialStatus.expired)
        .length;
    final lowCount =
        materials.where((m) => statuses[m.id] == MaterialStatus.low).length;
    final availCount = materials
        .where((m) =>
            statuses[m.id] == MaterialStatus.available ||
            statuses[m.id] == MaterialStatus.expiringSoon)
        .length;
    final total = materials.length;

    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 980
          ? 4
          : c.maxWidth >= 600
              ? 2
              : 1;
      return GridView.count(
        crossAxisCount: cols,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: switch (cols) { 4 => 1.7, 2 => 2.3, _ => 3.0 },
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _StatBox(
            isLight: isLight,
            badge: context.l10n.profileBadgeAlert,
            badgeColor: AppColors.statusProgress,
            value: '$outCount',
            label: context.l10n.whStatOutMaterials,
            icon: Icons.access_time_rounded,
            accent: AppColors.statusProgress,
          ),
          _StatBox(
            isLight: isLight,
            badge: context.l10n.profileBadgeAlert,
            badgeColor: AppColors.statusWarn,
            value: '$lowCount',
            label: context.l10n.whStatLowMaterials,
            icon: Icons.warning_amber_rounded,
            accent: AppColors.statusWarn,
          ),
          _StatBox(
            isLight: isLight,
            badge: context.l10n.whStatusAvailable,
            badgeColor: AppColors.statusSuccess,
            value: '$availCount',
            label: context.l10n.whStatAvailMaterials,
            icon: Icons.check_rounded,
            accent: AppColors.statusSuccess,
          ),
          _StatBox(
            isLight: isLight,
            badge: context.l10n.whBadgeTotal,
            badgeColor: AppColors.statusInfo,
            value: '$total',
            label: context.l10n.whStatTotalMaterials,
            icon: Icons.inventory_2_outlined,
            accent: AppColors.statusInfo,
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
    required this.value,
    required this.label,
    required this.icon,
    required this.accent,
  });

  final bool isLight;
  final String badge;
  final Color badgeColor;
  final String value;
  final String label;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isLight ? AppColors.baseComponent : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border:
            Border.all(color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
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
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
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
                        const Spacer(),
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
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
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
                      label,
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
