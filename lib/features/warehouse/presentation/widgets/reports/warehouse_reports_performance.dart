// ════════════════════════════════════════════════════════════════════════════
// warehouse_reports_performance.dart
//
// أداء الموردين + أكثر المواد استهلاكاً — part of warehouse_reports_content.dart (تقسيم الصفحات العملاقة).
// ════════════════════════════════════════════════════════════════════════════

part of 'warehouse_reports_content.dart';

// ══════════════════════════════════════════════════════════════════════════
//             5) PERFORMANCE ROW (Suppliers + Top Materials)
// ══════════════════════════════════════════════════════════════════════════

class _PerformanceRow extends StatelessWidget {
  const _PerformanceRow({required this.isLight});
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final suppliers = _SuppliersCard(isLight: isLight);
    final materials = _TopMaterialsCard(isLight: isLight);
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth < 920) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [materials, const SizedBox(height: 14), suppliers],
        );
      }
      // RTL: أوّل=يمين. المطلوب: أكثر المواد يمين، أداء الموردين يسار.
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: materials),
          const SizedBox(width: 14),
          Expanded(child: suppliers),
        ],
      );
    });
  }
}

// ── Suppliers performance card ──────────────────────────────────────────

class _SupplierData {
  const _SupplierData({
    required this.rank,
    required this.name,
    required this.invoices,
    required this.avgDays,
    required this.totalLabel,
    required this.barFraction,
  });
  final int rank;
  final String name;
  final int invoices;
  final double avgDays;
  final String totalLabel; // e.g. "1.25M"
  final double barFraction; // 0..1
}

class _SuppliersCard extends StatelessWidget {
  const _SuppliersCard({required this.isLight});
  final bool isLight;

  static const _data = <_SupplierData>[
    _SupplierData(
      rank: 1,
      name: 'دنتسبلاي',
      invoices: 8,
      avgDays: 2.1,
      totalLabel: '1.25M',
      barFraction: 0.58,
    ),
    _SupplierData(
      rank: 2,
      name: 'إيفوكلار',
      invoices: 6,
      avgDays: 1.8,
      totalLabel: '2.15M',
      barFraction: 1.00,
    ),
    _SupplierData(
      rank: 3,
      name: 'ميديكال+',
      invoices: 5,
      avgDays: 1.2,
      totalLabel: '0.45M',
      barFraction: 0.21,
    ),
    _SupplierData(
      rank: 4,
      name: '3M ESPE',
      invoices: 4,
      avgDays: 2.5,
      totalLabel: '0.89M',
      barFraction: 0.41,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _Card(
      isLight: isLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // RTL: الأيقونة يمين، النص يساره → [Icon, SizedBox, Text].
          Row(
            children: [
              const Icon(Icons.assessment_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                context.l10n.reportSuppliersPerf,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._data.map((s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _SupplierRow(isLight: isLight, data: s),
              )),
        ],
      ),
    );
  }
}

class _SupplierRow extends StatelessWidget {
  const _SupplierRow({required this.isLight, required this.data});
  final bool isLight;
  final _SupplierData data;

  @override
  Widget build(BuildContext context) {
    final text1 = isLight ? AppColors.lightText1 : AppColors.darkText1;
    final text3 = isLight ? AppColors.lightText3 : AppColors.darkText3;
    // RTL: rank يمين، اسم+sub وسط، total+bar يسار.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── دائرة الترتيب (rank) ──
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            '${data.rank}',
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // ── اسم + subtitle ──
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.name,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: text1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                context.l10n.reportSupplierSubtitle(data.invoices, data.avgDays),
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 11,
                  color: text3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // ── bar + المبلغ ──
        Expanded(
          flex: 4,
          // RTL: المبلغ يمين، الـ bar يسار → [Text(amount), SizedBox, Bar].
          child: Row(
            children: [
              Text(
                data.totalLabel,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: text1,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HBar(
                  fraction: data.barFraction,
                  color: AppColors.primary,
                  isLight: isLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Top Consumed Materials card ─────────────────────────────────────────

class _MaterialUsage {
  const _MaterialUsage({
    required this.name,
    required this.category,
    required this.count,
    required this.barFraction,
  });
  final String name;
  final String category;
  final int count;
  final double barFraction;
}

class _TopMaterialsCard extends StatelessWidget {
  const _TopMaterialsCard({required this.isLight});
  final bool isLight;

  static const _data = <_MaterialUsage>[
    _MaterialUsage(
      name: 'قفازات لاتكس M',
      category: 'مستهلكات',
      count: 34,
      barFraction: 1.00,
    ),
    _MaterialUsage(
      name: 'حقن بنج موضعي',
      category: 'أدوية',
      count: 28,
      barFraction: 0.82,
    ),
    _MaterialUsage(
      name: 'سيراميك زيركون',
      category: 'مواد طبية',
      count: 22,
      barFraction: 0.65,
    ),
    _MaterialUsage(
      name: 'PFM Alloy',
      category: 'معادن',
      count: 19,
      barFraction: 0.56,
    ),
    _MaterialUsage(
      name: 'سيليكون طبع',
      category: 'مستهلكات',
      count: 15,
      barFraction: 0.44,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _Card(
      isLight: isLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // الترويسة: نجمة + عنوان + badge عدد على اليمين، التقرير الكامل على اليسار.
          Row(
            children: [
              const Icon(Icons.star_border_rounded,
                  size: 18, color: AppColors.statusWarn),
              const SizedBox(width: 6),
              Text(
                context.l10n.reportTopMaterials,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.statusProgressBg,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: const Text(
                  '5',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.statusProgress,
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {},
                child: Text(
                  context.l10n.reportFullReport,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isLight ? AppColors.lightText3 : AppColors.darkText3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._data.map((m) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _MaterialRow(isLight: isLight, data: m),
              )),
        ],
      ),
    );
  }
}

class _MaterialRow extends StatelessWidget {
  const _MaterialRow({required this.isLight, required this.data});
  final bool isLight;
  final _MaterialUsage data;

  @override
  Widget build(BuildContext context) {
    final text1 = isLight ? AppColors.lightText1 : AppColors.darkText1;
    final text3 = isLight ? AppColors.lightText3 : AppColors.darkText3;
    // RTL: اسم+فئة يمين، bar وسط، count يسار.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.name,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: text1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.category,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 11,
                  color: text3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          // RTL: count يسار، bar يمتد إلى يمين الـ count.
          // → ترتيب children: [Bar, SizedBox, Text(count)] فيُصبح count على اليسار.
          child: Row(
            children: [
              Expanded(
                child: _HBar(
                  fraction: data.barFraction,
                  color: AppColors.primary,
                  isLight: isLight,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 28,
                child: Text(
                  '${data.count}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: text1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Horizontal bar (used by both performance cards) ─────────────────────
class _HBar extends StatelessWidget {
  const _HBar({
    required this.fraction,
    required this.color,
    required this.isLight,
  });
  final double fraction;
  final Color color;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final f = fraction.clamp(0.0, 1.0);
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: isLight ? AppColors.surfaceTintCool4 : AppColors.darkBg2,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        // في RTL، FractionallySizedBox مع alignment.centerEnd يبدأ من يمين الـ track.
        alignment: AlignmentDirectional.centerStart,
        widthFactor: f,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

