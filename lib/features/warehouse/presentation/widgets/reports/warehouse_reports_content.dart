// ════════════════════════════════════════════════════════════════════════════
// warehouse_reports_content.dart
//
// المحتوى الكامل لصفحة التقارير — Phase 4.6 مكتملة.
//
// 🎯 الهدف:
//   - Tab bar: أكثر 10 مواد | المالي
//   - Tab 1: جدول المواد الأكثر طلباً + bar chart شهري
//   - Tab 2: ملخص مالي (3 أرقام) + زر تصدير
//
// المرجع: DT_Teeth_Warehouse_v6_Enhanced.html — pg-rep
// ════════════════════════════════════════════════════════════════════════════

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../shared/widgets/data/app_data_table.dart';
import '../../../../../shared/widgets/primitives/app_badge.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../../warehouse/data/mock/warehouse_pages_mock_data.dart';

// ══════════════════════════════════════════════════════════════════════════
//                          MAIN CONTENT
// ══════════════════════════════════════════════════════════════════════════

class WarehouseReportsContent extends StatefulWidget {
  const WarehouseReportsContent({super.key});

  @override
  State<WarehouseReportsContent> createState() =>
      _WarehouseReportsContentState();
}

class _WarehouseReportsContentState extends State<WarehouseReportsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Tab Bar ──────────────────────────────────────────────────
        _buildTabBar(context, isLight),
        const SizedBox(height: 20),

        // ── Tab Content ──────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildTopMaterialsTab(context, isLight),
              _buildFinancialTab(context, isLight),
            ],
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          TAB BAR
  // ────────────────────────────────────────────────────────────────────────

  Widget _buildTabBar(BuildContext context, bool isLight) {
    final borderColor = isLight ? AppColors.lightBorder : AppColors.darkBorder;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        color: isLight ? AppColors.baseComponent : AppColors.darkSurface,
      ),
      child: TabBar(
        controller: _tabController,
        labelStyle: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelColor:
            isLight ? AppColors.lightText1 : AppColors.darkText1,
        unselectedLabelColor:
            isLight ? AppColors.lightText3 : AppColors.darkText3,
        indicator: BoxDecoration(
          color: isLight
              ? const Color(0x1ABED8FA)
              : const Color(0x1A9EFBEC),
          borderRadius: BorderRadius.circular(AppSizes.radiusMD - 2),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: context.l10n.whReportTabTopMaterials),
          Tab(text: context.l10n.whReportTabFinancial),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          TAB 1: TOP MATERIALS
  // ────────────────────────────────────────────────────────────────────────

  Widget _buildTopMaterialsTab(BuildContext context, bool isLight) {
    final bool isWide = MediaQuery.sizeOf(context).width >= 1100;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toolbar
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.whReportTopMaterialsTitle,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color:
                      isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
            ),
            AppButton(
              label: context.l10n.whReportExport,
              onPressed: () {},
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.small,
              icon: Icons.download_outlined,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Layout (جدول + bar chart)
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildTopMaterialsTable(context, isLight)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildBarChart(context, isLight)),
            ],
          )
        else
          Column(
            children: [
              _buildTopMaterialsTable(context, isLight),
              const SizedBox(height: 16),
              _buildBarChart(context, isLight),
            ],
          ),
      ],
      ),
    );
  }

  Widget _buildTopMaterialsTable(BuildContext context, bool isLight) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AppDataTable<ReportTopMaterial>(
      data: WarehouseReportsMockData.topMaterials,
      columns: [
        // الترتيب
        AppDataColumn<ReportTopMaterial>(
          label: context.l10n.whReportRank,
          width: 60,
          cellBuilder: (m) => _RankBadge(rank: m.rank),
        ),
        // المادة
        AppDataColumn<ReportTopMaterial>(
          label: context.l10n.whMaterialName,
          flex: 3,
          cellBuilder: (m) => Text(
            m.name,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isLight ? AppColors.lightText1 : AppColors.darkText1,
            ),
          ),
        ),
        // الفئة
        AppDataColumn<ReportTopMaterial>(
          label: context.l10n.whMaterialCategory,
          flex: 2,
          cellBuilder: (m) => AppBadge(
            text: m.category,
            variant: _categoryVariant(m.category),
          ),
        ),
        // الطلبات
        AppDataColumn<ReportTopMaterial>(
          label: context.l10n.whReportRequestCount,
          width: 80,
          cellBuilder: (m) => Text(
            m.requestCount.toString(),
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.dashCyan,
            ),
          ),
        ),
        // التكلفة
        AppDataColumn<ReportTopMaterial>(
          label: context.l10n.whReportCost,
          flex: 2,
          cellBuilder: (m) => Text(
            '${_fmt(m.cost)} ل.ل.',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isLight ? AppColors.lightText1 : AppColors.darkText1,
            ),
          ),
        ),
      ],
    );
      },
    );
  }

  AppBadgeVariant _categoryVariant(String cat) {
    switch (cat) {
      case 'أدوية':
        return AppBadgeVariant.violet;
      case 'مواد طبية':
        return AppBadgeVariant.cyan;
      default:
        return AppBadgeVariant.green;
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          BAR CHART
  // ────────────────────────────────────────────────────────────────────────

  Widget _buildBarChart(BuildContext context, bool isLight) {
    final data = WarehouseReportsMockData.monthlyOrders;
    final maxCount = data.map((d) => d.count).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      decoration: BoxDecoration(
        color: isLight ? AppColors.baseComponent : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.whReportMonthlyOrders,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isLight ? AppColors.lightText1 : AppColors.darkText1,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxCount + 10).toDouble(),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= data.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            data[idx].month,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 11,
                              color: isLight
                                  ? AppColors.lightText3
                                  : AppColors.darkText3,
                            ),
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 10,
                          color: isLight
                              ? AppColors.lightText4
                              : AppColors.darkText4,
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: isLight
                        ? AppColors.lightBorder
                        : AppColors.darkBorder,
                    strokeWidth: 0.5,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  data.length,
                  (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[i].count.toDouble(),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColors.warehouseSystem.withValues(alpha: 0.4),
                            AppColors.warehouseSystem,
                          ],
                        ),
                        width: 22,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          TAB 2: FINANCIAL
  // ────────────────────────────────────────────────────────────────────────

  Widget _buildFinancialTab(BuildContext context, bool isLight) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          children: [
            Expanded(
              child: Text(
                'الملخص المالي',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color:
                      isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
            ),
            AppButton(
              label: context.l10n.whReportExport,
              onPressed: () {},
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.small,
              icon: Icons.download_outlined,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 3 financial cards
        LayoutBuilder(
          builder: (context, constraints) {
            final crossCount = constraints.maxWidth >= 800 ? 3 : 1;
            return GridView.count(
              crossAxisCount: crossCount,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: crossCount == 3 ? 1.6 : 3.5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _financialCard(
                  context,
                  isLight: isLight,
                  label: context.l10n.whReportWeeklyPurchases,
                  value: _fmt(WarehouseReportsMockData.weeklyPurchases),
                  icon: Icons.shopping_cart_outlined,
                  color: AppColors.dashCyan,
                ),
                _financialCard(
                  context,
                  isLight: isLight,
                  label: context.l10n.whReportUsageCost,
                  value: _fmt(WarehouseReportsMockData.usageCost),
                  icon: Icons.medical_services_outlined,
                  color: AppColors.dashGreen,
                ),
                _financialCard(
                  context,
                  isLight: isLight,
                  label: context.l10n.whReportExpiredLoss,
                  value: _fmt(WarehouseReportsMockData.expiredLoss),
                  icon: Icons.warning_amber_outlined,
                  color: AppColors.dashPink,
                ),
              ],
            );
          },
        ),
      ],
      ),
    );
  }

  Widget _financialCard(
    BuildContext context, {
    required bool isLight,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      decoration: BoxDecoration(
        color: isLight ? AppColors.baseComponent : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            '$value ل.ل.',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              color: isLight ? AppColors.lightText3 : AppColors.darkText3,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          HELPERS
  // ────────────────────────────────────────────────────────────────────────

  String _fmt(double n) {
    final str = n.toInt().toString();
    final buf = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return buf.toString();
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  RANK BADGE — شارة الترتيب
// ════════════════════════════════════════════════════════════════════════════

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (rank == 1) {
      color = AppColors.dashAmber;
    } else if (rank == 2) {
      color = AppColors.darkText3;
    } else if (rank == 3) {
      color = AppColors.dashOrange;
    } else {
      color = AppColors.dashCyan;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Text(
          rank.toString(),
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ),
    );
  }
}
