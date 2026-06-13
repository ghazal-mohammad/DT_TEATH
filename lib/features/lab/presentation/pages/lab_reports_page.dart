// ════════════════════════════════════════════════════════════════════════════
// lab_reports_page.dart  — Phase 5.4 ✅
//
// شاشة التقارير — مطابقة 100% لـ HTML المرجعي (pg-lr).
//
// الهيكل:
//   - Report Controls: filter chips (شهري/أسبوعي/يومي/سنوي) + month select + أزرار تصدير
//   - 4 stat cards: طلبات الفترة / مكتمل في الوقت / متوسط الوقت / نسبة الرضا
//   - تقويم الطلبات حسب التاريخ
//   - صف سفلي: Donut Chart (الطلبات حسب النوع) + أداء الفريق (progress bars)
//
// البيانات في data/mock/lab_reports_mock_data.dart والودجات المستقلة في
// widgets/reports/lab_report_widgets.dart (تقسيم الصفحات العملاقة).
//
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — pg-lr
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../../../shared/widgets/primitives/app_button.dart';
import '../../../../shared/widgets/primitives/app_filter_chip.dart';
import '../../data/mock/lab_reports_mock_data.dart';
import '../navigation/lab_sidebar_sections.dart';
import '../widgets/reports/lab_report_widgets.dart';

// ══════════════════════════════════════════════════════════════════════════
//  PAGE
// ══════════════════════════════════════════════════════════════════════════

class LabReportsPage extends StatefulWidget {
  const LabReportsPage({super.key});

  @override
  State<LabReportsPage> createState() => _LabReportsPageState();
}

class _LabReportsPageState extends State<LabReportsPage> {
  int _filterIndex = 0; // 0=شهري 1=أسبوعي 2=يومي 3=سنوي

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppShellLayout(
      system: AppSystemType.lab,
      currentRoute: RouteNames.labReports,
      sections: LabSidebarSections.build(context),
      pageTitle: l10n.labReports,
      pageSubtitle: l10n.labTopbarSubtitle,
      userRole: l10n.roleLabManager,
      body: _LabReportsBody(
        filterIndex: _filterIndex,
        onFilterChanged: (i) => setState(() => _filterIndex = i),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  BODY
// ══════════════════════════════════════════════════════════════════════════

class _LabReportsBody extends StatelessWidget {
  const _LabReportsBody({
    required this.filterIndex,
    required this.onFilterChanged,
  });

  final int filterIndex;
  final ValueChanged<int> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. Report Controls ───────────────────────────────────────
          _buildReportControls(context, l10n, isLight),

          const SizedBox(height: AppSizes.spaceMD),

          // ── 2. Period Label ──────────────────────────────────────────
          Text(
            LabReportsMockData.periodLabel,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isLight ? AppColors.lightText3 : AppColors.darkText3,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: AppSizes.spaceMD),

          // ── 3. Stat Cards ────────────────────────────────────────────
          _buildStatCards(context, l10n, isLight),

          const SizedBox(height: AppSizes.spaceLG),

          // ── 4. Calendar Card ─────────────────────────────────────────
          _buildCalendarCard(context, l10n, isLight),

          const SizedBox(height: AppSizes.spaceLG),

          // ── 5. Bottom Row: Chart + Team ──────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildChartCard(context, isLight)),
                    const SizedBox(width: AppSizes.spaceLG),
                    Expanded(child: _buildTeamCard(context, isLight)),
                  ],
                );
              }
              return Column(
                children: [
                  _buildChartCard(context, isLight),
                  const SizedBox(height: AppSizes.spaceLG),
                  _buildTeamCard(context, isLight),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  Widget _buildReportControls(
      BuildContext context, AppLocalizations l10n, bool isLight) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 650;
        final filterChips = AppFilterChipRow(
          options: [
            l10n.labReportFilterMonthly,
            l10n.labReportFilterWeekly,
            l10n.labReportFilterDaily,
            l10n.labReportFilterYearly,
          ],
          selectedIndex: filterIndex,
          onChanged: onFilterChanged,
        );

        final exportButtons = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton.primary(
              label: l10n.labReportExportPdf,
              onPressed: () {},
              size: AppButtonSize.small,
            ),
            const SizedBox(width: AppSizes.spaceSM),
            AppButton.secondary(
              label: l10n.labReportExportExcel,
              onPressed: () {},
              size: AppButtonSize.small,
            ),
            const SizedBox(width: AppSizes.spaceSM),
            AppButton.secondary(
              label: l10n.labReportSendEmail,
              onPressed: () {},
              size: AppButtonSize.small,
            ),
          ],
        );

        if (isWide) {
          return Row(
            children: [
              filterChips,
              const Spacer(),
              // Month Select
              LabReportMonthDropdown(isLight: isLight),
              const SizedBox(width: AppSizes.spaceSM),
              exportButtons,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            filterChips,
            const SizedBox(height: AppSizes.spaceSM),
            Row(
              children: [
                LabReportMonthDropdown(isLight: isLight),
                const Spacer(),
              ],
            ),
            const SizedBox(height: AppSizes.spaceSM),
            exportButtons,
          ],
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  Widget _buildStatCards(BuildContext context, AppLocalizations l10n, bool isLight) {
    final cards = [
      LabReportStatCard(
        icon: '📋',
        value: '${LabReportsMockData.totalOrders}',
        label: l10n.labReportStatTotal,
        accentColor: AppColors.dashCyan,
        isLight: isLight,
      ),
      LabReportStatCard(
        icon: '✅',
        value: '${LabReportsMockData.completedOnTime}',
        label: l10n.labReportStatCompleted,
        accentColor: AppColors.success,
        isLight: isLight,
      ),
      LabReportStatCard(
        icon: '⏱',
        value: LabReportsMockData.avgTime,
        label: l10n.labReportStatAvgTime,
        accentColor: AppColors.dashOrange,
        isLight: isLight,
      ),
      LabReportStatCard(
        icon: '💎',
        value: LabReportsMockData.satisfactionRate,
        label: l10n.labReportStatSatisfaction,
        accentColor: AppColors.secondary,
        isLight: isLight,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          return Row(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSizes.spaceMD),
                Expanded(child: cards[i]),
              ],
            ],
          );
        }
        return Column(
          children: [
            Row(children: [
              Expanded(child: cards[0]),
              const SizedBox(width: AppSizes.spaceMD),
              Expanded(child: cards[1]),
            ]),
            const SizedBox(height: AppSizes.spaceMD),
            Row(children: [
              Expanded(child: cards[2]),
              const SizedBox(width: AppSizes.spaceMD),
              Expanded(child: cards[3]),
            ]),
          ],
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  Widget _buildCalendarCard(
      BuildContext context, AppLocalizations l10n, bool isLight) {
    return Container(
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spaceLG, AppSizes.spaceLG,
              AppSizes.spaceLG, AppSizes.spaceMD,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('📅 الطلبات حسب التاريخ',
                    style: AppTextStyles.headlineSmall),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'تصدير ←',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      color: isLight
                          ? AppColors.lightText3
                          : AppColors.darkText3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSizes.spaceLG),
            child: LabReportCalendarGrid(isLight: isLight),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  Widget _buildChartCard(BuildContext context, bool isLight) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMD),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الطلبات حسب النوع',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSizes.spaceMD),
          Row(
            children: [
              // Donut SVG-like chart using CustomPaint
              SizedBox(
                width: 86,
                height: 86,
                child: CustomPaint(
                  painter: LabReportDonutPainter(
                    segments: LabReportsMockData.chartSegments,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${LabReportsMockData.totalOrders}',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isLight
                                ? AppColors.lightText1
                                : AppColors.darkText1,
                          ),
                        ),
                        Text(
                          'طلب',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isLight
                                ? AppColors.lightText4
                                : AppColors.darkText4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spaceLG),
              // Legend
              Expanded(
                child: Column(
                  children: LabReportsMockData.chartSegments.map((seg) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: seg.color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(seg.label,
                                style: AppTextStyles.bodySmall),
                          ),
                          Text(
                            '${seg.percentage}%',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isLight
                                  ? AppColors.lightText3
                                  : AppColors.darkText3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${seg.count}',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isLight
                                  ? AppColors.lightText1
                                  : AppColors.darkText1,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  Widget _buildTeamCard(BuildContext context, bool isLight) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMD),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أداء الفريق',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSizes.spaceMD),
          ...LabReportsMockData.teamPerformance.map((t) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(t.name, style: AppTextStyles.bodyMedium),
                      Text(
                        '${t.ordersCount} · ${t.avgTime}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: t.color2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    child: Stack(
                      children: [
                        Container(
                          height: 8,
                          color: isLight
                              ? AppColors.dividerNeutral
                              : Colors.white.withValues(alpha: 0.06),
                        ),
                        FractionallySizedBox(
                          widthFactor: t.progress,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [t.color1, t.color2],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
