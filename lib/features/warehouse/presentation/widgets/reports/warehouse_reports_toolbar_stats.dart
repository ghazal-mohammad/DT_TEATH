// ════════════════════════════════════════════════════════════════════════════
// warehouse_reports_toolbar_stats.dart
//
// شريط الأدوات + ترويسة التقرير + بطاقات الإحصاء — part of warehouse_reports_content.dart (تقسيم الصفحات العملاقة).
// ════════════════════════════════════════════════════════════════════════════

part of 'warehouse_reports_content.dart';

// ══════════════════════════════════════════════════════════════════════════
//                          1) TOOLBAR
// ══════════════════════════════════════════════════════════════════════════

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.range,
    required this.onRangeChange,
    required this.isLight,
  });
  final _ReportRange range;
  final ValueChanged<_ReportRange> onRangeChange;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    // RTL: أوّل=يمين، آخر=يسار.
    // المطلوب فيزيائياً (RTL):
    //   [pills المدى يمين] ............. [تصدير PDF + Excel + مارس 2026 يسار]
    // → ترتيب children: [pills, Spacer, exportItems].
    //
    // ⚠️ ملاحظة مهمة: AppButton بدون icon بيلفّ النص بـ Center، يلي
    // بياخد كل المساحة المتاحة لما يكون داخل Flexible/Expanded. لازم
    // كل button بـ IntrinsicWidth حتى ياخد حجمه الطبيعي.
    final pdfBtn = IntrinsicWidth(
      child: AppButton(
        label: context.l10n.reportExportPdf,
        onPressed: () {},
        variant: AppButtonVariant.primary,
        size: AppButtonSize.small,
      ),
    );
    final excelBtn = IntrinsicWidth(
      child: AppButton(
        label: context.l10n.reportExportExcel,
        onPressed: () {},
        variant: AppButtonVariant.secondary,
        size: AppButtonSize.small,
      ),
    );
    final dateBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isLight ? AppColors.baseComponent : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      // RTL داخل الكبسولة: النص يمين، الأيقونة يسار → [Text, SizedBox, Icon].
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'مارس 2026',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isLight ? AppColors.lightText1 : AppColors.darkText1,
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.access_time_rounded,
              size: 14,
              color: isLight ? AppColors.lightText3 : AppColors.darkText3),
        ],
      ),
    );

    // RTL: pills tabs — أوّل=يمين، آخر=يسار.
    // المطلوب: يومي يمين، أسبوعي، شهري(نشط)، سنوي يسار.
    // → ترتيب children بـ Row.values = [daily, weekly, monthly, yearly] ✓.
    final rangePills = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _ReportRange.values.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          _PillChip(
            label: _ReportRange.values[i].label(context.l10n),
            selected: _ReportRange.values[i] == range,
            onTap: () => onRangeChange(_ReportRange.values[i]),
          ),
        ],
      ],
    );

    return LayoutBuilder(builder: (context, c) {
      // على شاشة ضيقة جداً، خلّيهن stacked
      if (c.maxWidth < 720) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            rangePills,
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [pdfBtn, const SizedBox(width: 8), excelBtn,
                  const SizedBox(width: 8), dateBadge],
            ),
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // اليمين (start في RTL): الـ pills
          rangePills,
          const Spacer(),
          // اليسار (end في RTL): التصدير + الفترة
          pdfBtn,
          const SizedBox(width: 8),
          excelBtn,
          const SizedBox(width: 8),
          dateBadge,
        ],
      );
    });
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                          2) REPORT HEADER
// ══════════════════════════════════════════════════════════════════════════

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({
    required this.period,
    required this.generatedAt,
    required this.isLight,
  });
  final String period;
  final String generatedAt;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.description_outlined,
            size: 18, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          context.l10n.reportMonthlyTitle(period),
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isLight ? AppColors.lightText1 : AppColors.darkText1,
          ),
        ),
        const Spacer(),
        Text(
          context.l10n.reportGeneratedAt(generatedAt),
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12,
            color: isLight ? AppColors.lightText3 : AppColors.darkText3,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                          3) STATS ROW
// ══════════════════════════════════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.isLight});
  final bool isLight;

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
        childAspectRatio: switch (cols) { 4 => 1.85, 2 => 2.4, _ => 3.0 },
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _StatBox(
            badge: '-0.4 ${context.l10n.reportUnitDay}',
            badgeColor: AppColors.statusWarn,
            value: '1.8',
            valueSuffix: context.l10n.reportUnitDay,
            label: context.l10n.reportStatAvgSupplyTime,
            icon: Icons.access_time_rounded,
            accent: AppColors.statusWarn,
          ),
          _StatBox(
            badge: '+2%',
            badgeColor: AppColors.statusSuccess,
            value: '94',
            valueSuffix: '%',
            label: context.l10n.reportStatSupplyRate,
            icon: Icons.check_rounded,
            accent: AppColors.statusSuccess,
          ),
          _StatBox(
            badge: context.l10n.profileBadgeThisMonth,
            badgeColor: AppColors.statusProgress,
            value: '156',
            label: context.l10n.reportStatConsumed,
            icon: Icons.trending_up_rounded,
            accent: AppColors.statusProgress,
          ),
          _StatBox(
            badge: '4+',
            badgeColor: AppColors.statusInfo,
            value: '247',
            label: context.l10n.reportStatTotalMaterials,
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
    required this.badge,
    required this.badgeColor,
    required this.value,
    this.valueSuffix,
    required this.label,
    required this.icon,
    required this.accent,
  });

  final String badge;
  final Color badgeColor;
  final String value;
  final String? valueSuffix;
  final String label;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
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
                              fontSize: 11,
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          value,
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                            color: isLight
                                ? AppColors.lightText1
                                : AppColors.darkText1,
                          ),
                        ),
                        if (valueSuffix != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            valueSuffix!,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isLight
                                  ? AppColors.lightText3
                                  : AppColors.darkText3,
                            ),
                          ),
                        ],
                      ],
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

