// ════════════════════════════════════════════════════════════════════════════
// warehouse_reports_content.dart
//
// محتوى صفحة تقارير المستودع — مطابق لـ mockup التصميم.
//
// 🎯 البنية:
//   1. شريط التصدير + اختيار الفترة (يومي/أسبوعي/شهري/سنوي)
//   2. ترويسة التقرير: شهر + تاريخ الإنشاء
//   3. صف 4 بطاقات إحصائية (مدة التوريد، نسبة التوريد، استهلاك، إجمالي)
//   4. صفّ بطاقتين: donut توزع الاستهلاك + شبكة الأيام
// ════════════════════════════════════════════════════════════════════════════

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';

// ══════════════════════════════════════════════════════════════════════════
//                             VIEW RANGE
// ══════════════════════════════════════════════════════════════════════════

enum _ReportRange { daily, weekly, monthly, yearly }

extension on _ReportRange {
  String get label => switch (this) {
        _ReportRange.daily => 'يومي',
        _ReportRange.weekly => 'أسبوعي',
        _ReportRange.monthly => 'شهري',
        _ReportRange.yearly => 'سنوي',
      };
}

// ══════════════════════════════════════════════════════════════════════════
//                            MAIN CONTENT
// ══════════════════════════════════════════════════════════════════════════

class WarehouseReportsContent extends StatefulWidget {
  const WarehouseReportsContent({super.key});

  @override
  State<WarehouseReportsContent> createState() =>
      _WarehouseReportsContentState();
}

class _WarehouseReportsContentState extends State<WarehouseReportsContent> {
  _ReportRange _range = _ReportRange.monthly;

  // الفترة الحالية (mock — مطابق للـ design).
  static const _periodLabel = 'مارس 2026';
  static const _generatedAt = '22 مايو 2026';
  static const _daysInMonth = 31;

  // الأيام ذات النشاط (highlighted) — مطابق للـ mockup.
  static const _highlightedDays = {9, 11, 17, 24, 26};

  // توزّع الاستهلاك حسب الفئة — مطابق للـ mockup.
  static const _categoryShares = <_CategoryShare>[
    _CategoryShare(label: 'مستهلكات', percent: 42, color: Color(0xFF1A1C4E)),
    _CategoryShare(label: 'مواد طبية', percent: 28, color: Color(0xFF7A4FCF)),
    _CategoryShare(label: 'أدوية', percent: 18, color: Color(0xFF2C7FDB)),
    _CategoryShare(label: 'معادن', percent: 12, color: Color(0xFF1F9B6E)),
  ];

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Toolbar(
          range: _range,
          onRangeChange: (r) => setState(() => _range = r),
          isLight: isLight,
        ),
        const SizedBox(height: 16),
        _ReportHeader(
          period: _periodLabel,
          generatedAt: _generatedAt,
          isLight: isLight,
        ),
        const SizedBox(height: 14),
        _StatsRow(isLight: isLight),
        const SizedBox(height: 14),
        _BottomRow(
          isLight: isLight,
          shares: _categoryShares,
          daysInMonth: _daysInMonth,
          highlighted: _highlightedDays,
        ),
        const SizedBox(height: 14),
        _PerformanceRow(isLight: isLight),
      ],
    );
  }
}

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
                'أداء الموردين',
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
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: text1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${data.invoices} فاتورة · متوسط ${data.avgDays} يوم',
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
                  fontSize: 12.5,
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
                  size: 18, color: Color(0xFFE17B2C)),
              const SizedBox(width: 6),
              Text(
                'أكثر المواد استهلاكاً',
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
                  color: const Color(0xFFEFE3FA),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: const Text(
                  '5',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7A4FCF),
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {},
                child: Text(
                  'التقرير الكامل',
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
                  fontSize: 13.5,
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
        color: isLight ? const Color(0xFFEFF2FB) : AppColors.darkBg2,
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
        label: 'تصدير PDF',
        onPressed: () {},
        variant: AppButtonVariant.primary,
        size: AppButtonSize.small,
      ),
    );
    final excelBtn = IntrinsicWidth(
      child: AppButton(
        label: 'تصدير Excel',
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
              fontSize: 12.5,
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
            label: _ReportRange.values[i].label,
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
          '$period — التقرير الشهري',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isLight ? AppColors.lightText1 : AppColors.darkText1,
          ),
        ),
        const Spacer(),
        Text(
          'تم إنشاء التقرير $generatedAt',
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
        children: const [
          _StatBox(
            badge: '-0.4 يوم',
            badgeColor: Color(0xFFE17B2C),
            value: '1.8',
            valueSuffix: 'يوم',
            label: 'متوسط مدة التوريد',
            icon: Icons.access_time_rounded,
            accent: Color(0xFFE17B2C),
          ),
          _StatBox(
            badge: '+2%',
            badgeColor: Color(0xFF1F9B6E),
            value: '94',
            valueSuffix: '%',
            label: 'نسبة التوريد',
            icon: Icons.check_rounded,
            accent: Color(0xFF1F9B6E),
          ),
          _StatBox(
            badge: 'هذا الشهر',
            badgeColor: Color(0xFF7A4FCF),
            value: '156',
            label: 'مادة استُهلكت',
            icon: Icons.trending_up_rounded,
            accent: Color(0xFF7A4FCF),
          ),
          _StatBox(
            badge: '4+',
            badgeColor: Color(0xFF2C7FDB),
            value: '247',
            label: 'إجمالي المواد',
            icon: Icons.inventory_2_outlined,
            accent: Color(0xFF2C7FDB),
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

// ══════════════════════════════════════════════════════════════════════════
//                          4) BOTTOM ROW (donut + calendar)
// ══════════════════════════════════════════════════════════════════════════

class _BottomRow extends StatelessWidget {
  const _BottomRow({
    required this.isLight,
    required this.shares,
    required this.daysInMonth,
    required this.highlighted,
  });
  final bool isLight;
  final List<_CategoryShare> shares;
  final int daysInMonth;
  final Set<int> highlighted;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final isNarrow = c.maxWidth < 920;
      final donut = _DonutCard(isLight: isLight, shares: shares);
      final calendar = _CalendarCard(
        isLight: isLight,
        daysInMonth: daysInMonth,
        highlighted: highlighted,
      );
      if (isNarrow) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [donut, const SizedBox(height: 14), calendar],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: calendar),
          const SizedBox(width: 14),
          Expanded(child: donut),
        ],
      );
    });
  }
}

// ── Donut card ──────────────────────────────────────────────────────────

class _CategoryShare {
  const _CategoryShare({
    required this.label,
    required this.percent,
    required this.color,
  });
  final String label;
  final int percent;
  final Color color;
}

class _DonutCard extends StatelessWidget {
  const _DonutCard({required this.isLight, required this.shares});
  final bool isLight;
  final List<_CategoryShare> shares;

  @override
  Widget build(BuildContext context) {
    return _Card(
      isLight: isLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.donut_large_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'توزّع الاستهلاك حسب الفئة',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: CustomPaint(
              painter: _DonutPainter(shares: shares),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '100%',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isLight
                            ? AppColors.lightText1
                            : AppColors.darkText1,
                      ),
                    ),
                    Text(
                      'من الاستهلاك',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 11,
                        color: isLight
                            ? AppColors.lightText3
                            : AppColors.darkText3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...shares.map((s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: s.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.label,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isLight
                              ? AppColors.lightText1
                              : AppColors.darkText1,
                        ),
                      ),
                    ),
                    Text(
                      '${s.percent}%',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isLight
                            ? AppColors.lightText3
                            : AppColors.darkText3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${s.percent}',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: s.color,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.shares});
  final List<_CategoryShare> shares;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const thickness = 22.0;
    final rect = Rect.fromCircle(center: center, radius: radius - thickness / 2);

    final total = shares.fold<int>(0, (a, s) => a + s.percent);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.butt;

    var startAngle = -math.pi / 2;
    for (final s in shares) {
      final sweep = (s.percent / total) * 2 * math.pi;
      paint.color = s.color;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      !identical(old.shares, shares);
}

// ── Calendar card ───────────────────────────────────────────────────────

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.isLight,
    required this.daysInMonth,
    required this.highlighted,
  });
  final bool isLight;
  final int daysInMonth;
  final Set<int> highlighted;

  static const _weekdayLabels = [
    'أحد',
    'إثنين',
    'ثلاثاء',
    'أربعاء',
    'خميس',
    'جمعة',
    'سبت',
  ];

  @override
  Widget build(BuildContext context) {
    return _Card(
      isLight: isLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.event_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'توزع طلبات التوريد على أيام الشهر',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color:
                        isLight ? AppColors.lightText1 : AppColors.darkText1,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFE3FA),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  '$daysInMonth يوم',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7A4FCF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // أيام الأسبوع
          Row(
            children: _weekdayLabels
                .map((d) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          d,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isLight
                                ? AppColors.lightText3
                                : AppColors.darkText3,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          _CalendarGrid(
            isLight: isLight,
            daysInMonth: daysInMonth,
            highlighted: highlighted,
          ),
          const SizedBox(height: 10),
          _HeatmapLegend(isLight: isLight),
        ],
      ),
    );
  }
}

/// مفتاح ألوان heatmap التقويم: أقل ▢▢▢▣ أكثر.
/// RTL: "أقل" يمين، "أكثر" يسار، المربعات بينهن من فاتح إلى navy.
class _HeatmapLegend extends StatelessWidget {
  const _HeatmapLegend({required this.isLight});
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final colors = [
      isLight ? const Color(0xFFEFF2FB) : AppColors.darkBg2,
      isLight ? const Color(0xFFE9ECFB) : AppColors.darkBg2,
      isLight ? const Color(0xFFC8D2F2) : AppColors.darkSurface,
      AppColors.primary,
    ];
    return Row(
      // start في RTL = اليمين. الكلسسر يمتد لجهة اليمين تحت الكاليندر.
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'أقل',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 11,
            color: isLight ? AppColors.lightText3 : AppColors.darkText3,
          ),
        ),
        const SizedBox(width: 6),
        for (final c in colors) ...[
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
                width: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 3),
        ],
        const SizedBox(width: 3),
        Text(
          'أكثر',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 11,
            color: isLight ? AppColors.lightText3 : AppColors.darkText3,
          ),
        ),
      ],
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.isLight,
    required this.daysInMonth,
    required this.highlighted,
  });
  final bool isLight;
  final int daysInMonth;
  final Set<int> highlighted;

  @override
  Widget build(BuildContext context) {
    // 5 صفوف لتغطية 31 يوم (مارس 2026 يبدأ من الأحد للتبسيط، مطابق للـ mockup).
    // count + activityMap = mock values matching mockup numbers.
    final activity = <int, int>{
      1: 5,
      2: 7,
      4: 5,
      5: 2,
      6: 6,
      7: 7,
      9: 17, // highlighted
      11: 26, // highlighted
      12: 12,
      13: 13,
      15: 14,
      16: 5,
      17: 9, // highlighted
      18: 4,
      19: 20,
      20: 21,
      22: 3,
      23: 4,
      24: 24, // highlighted
      25: 25,
      26: 11, // highlighted
      27: 5,
      28: 8,
    };

    // 6 أسطر بطول 7 = 42 cell. أول 31 منهن تمثل أيام مارس.
    final rows = <Widget>[];
    for (var week = 0; week < 5; week++) {
      final cells = <Widget>[];
      for (var dow = 0; dow < 7; dow++) {
        final day = week * 7 + dow + 1;
        if (day > daysInMonth) {
          cells.add(const Expanded(child: SizedBox(height: 46)));
        } else {
          final isHi = highlighted.contains(day);
          final n = activity[day] ?? 0;
          cells.add(Expanded(
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: _DayCell(
                day: day,
                count: n,
                highlighted: isHi,
                isLight: isLight,
              ),
            ),
          ));
        }
      }
      rows.add(Row(children: cells));
    }
    return Column(children: rows);
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.count,
    required this.highlighted,
    required this.isLight,
  });
  final int day;
  final int count;
  final bool highlighted;
  final bool isLight;

  // 4 شدّات لـ heatmap: 0=أبيض/شفاف، 1=فاتح جداً، 2=متوسط، 3=navy.
  int get _level {
    if (highlighted) return 3;
    if (count == 0) return 0;
    if (count <= 5) return 1;
    if (count <= 10) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final lvl = _level;
    final bg = switch (lvl) {
      3 => AppColors.primary,
      2 => isLight ? const Color(0xFFC8D2F2) : AppColors.darkSurface,
      1 => isLight ? const Color(0xFFE9ECFB) : AppColors.darkBg2,
      _ => Colors.transparent,
    };
    final isDark = lvl == 3;
    final fgPrimary = isDark
        ? Colors.white
        : (isLight ? AppColors.lightText1 : AppColors.darkText1);
    final fgSecondary = isDark
        ? Colors.white.withValues(alpha: 0.8)
        : (isLight ? AppColors.lightText3 : AppColors.darkText3);

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: Text(
              '$day',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: fgSecondary,
              ),
            ),
          ),
          Text(
            count > 0 ? '$count' : '0',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: fgPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                              REUSABLE PIECES
// ══════════════════════════════════════════════════════════════════════════

class _Card extends StatelessWidget {
  const _Card({required this.isLight, required this.child});
  final bool isLight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      decoration: BoxDecoration(
        color: isLight ? AppColors.baseComponent : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: child,
    );
  }
}

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
