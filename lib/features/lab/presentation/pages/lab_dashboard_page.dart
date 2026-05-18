// ════════════════════════════════════════════════════════════════════════════
// lab_dashboard_page.dart  — Phase 5.1 ✅
//
// صفحة لوحة التحكم الكاملة لنظام المخبر.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/core/mock_user_data.dart';
import '../../../../shared/widgets/data/app_data_table.dart';
import '../../../../shared/widgets/layout/app_dashboard_hero.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../../../shared/widgets/primitives/app_badge.dart';
import '../../../../shared/widgets/primitives/app_button.dart';
import '../../../../shared/widgets/primitives/app_stat_card.dart';
import '../../data/mock/lab_dashboard_mock_data.dart';
import '../navigation/lab_sidebar_sections.dart';

// ══════════════════════════════════════════════════════════════════════════

class LabDashboardPage extends StatelessWidget {
  const LabDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppShellLayout(
      system: AppSystemType.lab,
      currentRoute: RouteNames.labDashboard,
      sections: LabSidebarSections.buildWithBadges(
        context,
        newOrdersCount: LabDashboardMockData.newOrdersCount,
        unreadNotifsCount: 2,
      ),
      pageTitle: l10n.labDashboardTitle,
      pageSubtitle: l10n.labTopbarSubtitle,
      userName: MockUserData.labUserName,
      userRole: l10n.roleLabManager,
      notificationCount: 2,
      body: const _LabDashboardBody(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  BODY
// ══════════════════════════════════════════════════════════════════════════

class _LabDashboardBody extends StatelessWidget {
  const _LabDashboardBody();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, outerConstraints) {
        return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: outerConstraints.maxWidth,
          maxWidth: outerConstraints.maxWidth,
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. Hero ──────────────────────────────────────────────────
          AppDashboardHero(
            title: l10n.labHeroWelcome,
            subtitle: l10n.labHeroSubtitle,
            stats: [
              AppDashboardHeroStat(
                value: '${LabDashboardMockData.todayOrdersCount}',
                label: l10n.labHeroStatTodayOrders,
              ),
              AppDashboardHeroStat(
                value: '${LabDashboardMockData.inProgressCount}',
                label: l10n.labHeroStatInProgress,
              ),
              AppDashboardHeroStat(
                value: '${LabDashboardMockData.completionRate}%',
                label: l10n.labHeroStatCompletionRate,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceLG),

          // ── 2. Stat Cards ────────────────────────────────────────────
          const _StatCardsRow(),
          const SizedBox(height: AppSizes.spaceLG),

          // ── 3. Orders Table ──────────────────────────────────────────
          const _OrdersTableSection(),
          const SizedBox(height: AppSizes.spaceLG),

          // ── 4. Team Table ────────────────────────────────────────────
          const _TeamSection(),
        ],
      ),
      ),
    );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  STAT CARDS ROW
// ══════════════════════════════════════════════════════════════════════════

class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cards = _buildCards(l10n);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        if (isWide) {
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

  List<Widget> _buildCards(AppLocalizations l10n) {
    return [
      AppStatCard(
        icon: AppIcons.labOrders,
        value: '${LabDashboardMockData.newOrdersCount}',
        label: l10n.labStatNewOrders,
        variant: AppStatCardVariant.cyan,
        trend: AppStatTrend.up,
        trendLabel: '+2',
      ),
      AppStatCard(
        icon: AppIcons.clock,
        value: '${LabDashboardMockData.manufacturingCount}',
        label: l10n.labStatManufacturing,
        variant: AppStatCardVariant.gold,
        trend: AppStatTrend.warning,
        trendLabel: '5 عاجل',
      ),
      AppStatCard(
        icon: AppIcons.check,
        value: '${LabDashboardMockData.readyCount}',
        label: l10n.labStatReady,
        variant: AppStatCardVariant.green,
        trend: AppStatTrend.up,
        trendLabel: '+3',
      ),
      AppStatCard(
        icon: AppIcons.urgent,
        value: '${LabDashboardMockData.urgentTodayCount}',
        label: l10n.labStatUrgentToday,
        variant: AppStatCardVariant.red,
        trend: AppStatTrend.down,
        trendLabel: 'تنتهي اليوم',
      ),
    ];
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  ORDERS TABLE SECTION
// ══════════════════════════════════════════════════════════════════════════

class _OrdersTableSection extends StatelessWidget {
  const _OrdersTableSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;

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
                Text(
                  l10n.labOrdersDueToday,
                  style: AppTextStyles.headlineSmall,
                ),
                AppButton.secondary(
                  label: l10n.labOrdersFilterAll,
                  icon: AppIcons.labOrders,
                  onPressed: () => context.go(RouteNames.labOrders),
                  size: AppButtonSize.small,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table
          AppDataTable<LabOrderItem>(
            data: LabDashboardMockData.todayOrders,
            columns: [
              AppDataColumn<LabOrderItem>(
                label: 'رقم الطلب',
                flex: 2,
                cellBuilder: (item) => Text(
                  item.orderId,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
              AppDataColumn<LabOrderItem>(
                label: 'المريض',
                flex: 2,
                cellBuilder: (item) =>
                    Text(item.patientName, style: AppTextStyles.bodyMedium),
              ),
              AppDataColumn<LabOrderItem>(
                label: 'الطبيب',
                flex: 2,
                cellBuilder: (item) =>
                    Text(item.doctorName, style: AppTextStyles.bodyMedium),
              ),
              AppDataColumn<LabOrderItem>(
                label: 'النوع',
                flex: 2,
                cellBuilder: (item) =>
                    Text(item.type, style: AppTextStyles.bodyMedium),
              ),
              AppDataColumn<LabOrderItem>(
                label: 'الموعد',
                flex: 2,
                cellBuilder: (item) =>
                    Text(item.dueDate, style: AppTextStyles.bodySmall),
              ),
              AppDataColumn<LabOrderItem>(
                label: 'الحالة',
                flex: 2,
                cellBuilder: _statusBadge,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(LabOrderItem item) {
    const variantMap = {
      LabOrderBadgeVariant.newOrder: AppBadgeVariant.cyan,
      LabOrderBadgeVariant.manufacturing: AppBadgeVariant.gold,
      LabOrderBadgeVariant.ready: AppBadgeVariant.green,
      LabOrderBadgeVariant.urgent: AppBadgeVariant.redAnimated,
    };
    const textMap = {
      LabOrderBadgeVariant.newOrder: 'جديد',
      LabOrderBadgeVariant.manufacturing: 'قيد التصنيع',
      LabOrderBadgeVariant.ready: 'جاهز',
      LabOrderBadgeVariant.urgent: 'عاجل',
    };
    return AppBadge(
      text: item.isUrgent ? 'عاجل' : (textMap[item.statusVariant] ?? ''),
      variant: item.isUrgent
          ? AppBadgeVariant.redAnimated
          : (variantMap[item.statusVariant] ?? AppBadgeVariant.cyan),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  TEAM SECTION
// ══════════════════════════════════════════════════════════════════════════

class _TeamSection extends StatelessWidget {
  const _TeamSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final team = LabDashboardMockData.team;
    final totalCount = team.length;
    final activeCount = team.where((t) => t.isBusy).length;
    final freeCount = team.where((t) => !t.isBusy).length;

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
              children: [
                Expanded(
                  child: Text(
                    l10n.labTeamTitle,
                    style: AppTextStyles.headlineSmall,
                  ),
                ),
                _miniKpi('$totalCount', l10n.labTeamTotal, AppColors.accent),
                const SizedBox(width: AppSizes.spaceLG),
                _miniKpi('$activeCount', l10n.labTeamActive, AppColors.secondary),
                const SizedBox(width: AppSizes.spaceLG),
                _miniKpi('$freeCount', l10n.labTeamAvailable, AppColors.success),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table
          AppDataTable<LabTechnicianItem>(
            data: team,
            columns: [
              AppDataColumn<LabTechnicianItem>(
                label: l10n.labTeamColumnName,
                flex: 3,
                cellBuilder: (t) => Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          t.name.substring(0, 1),
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t.name,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              AppDataColumn<LabTechnicianItem>(
                label: l10n.labTeamColumnShift,
                flex: 2,
                cellBuilder: (t) =>
                    Text(t.shift, style: AppTextStyles.bodySmall),
              ),
              AppDataColumn<LabTechnicianItem>(
                label: l10n.labTeamColumnCurrentTask,
                flex: 3,
                cellBuilder: (t) =>
                    Text(t.currentTask, style: AppTextStyles.bodyMedium),
              ),
              AppDataColumn<LabTechnicianItem>(
                label: l10n.labTeamColumnStatus,
                flex: 2,
                cellBuilder: (t) => AppBadge(
                  text: t.isBusy ? l10n.labTeamBusy : l10n.labTeamFree,
                  variant:
                      t.isBusy ? AppBadgeVariant.violet : AppBadgeVariant.green,
                ),
              ),
              AppDataColumn<LabTechnicianItem>(
                label: l10n.labTeamColumnAction,
                flex: 2,
                cellBuilder: (t) => t.isBusy
                    ? Text('—', style: AppTextStyles.bodySmall)
                    : AppButton.secondary(
                        label: l10n.labTeamAssign,
                        onPressed: () {},
                        size: AppButtonSize.small,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniKpi(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}
