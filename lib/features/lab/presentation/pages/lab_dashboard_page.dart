import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/current_user.dart';
import '../../../../core/auth/employee_role_label.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/search/app_search_warmup.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/core/mock_user_data.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../../../shared/widgets/layout/app_welcome_hero.dart';
import '../../domain/repositories/lab_orders_repository.dart';
import '../bloc/lab_dashboard_cubit.dart';
import '../bloc/lab_dashboard_state.dart';
import '../navigation/lab_sidebar_sections.dart';
import '../widgets/dashboard/lab_dashboard_orders_table.dart';
import '../widgets/dashboard/lab_dashboard_stat_cards.dart';
import '../widgets/dashboard/lab_ending_today_alert.dart';


class LabDashboardPage extends StatelessWidget {
  const LabDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        // تسخين كاش مركز الأوامر بصمت (مرّة/جلسة) — بحث عالمي فوري من أول دخول.
        AppSearchWarmup.run();
        return LabDashboardCubit(ordersRepository: sl<LabOrdersRepository>())
          ..load();
      },
      child: BlocBuilder<LabDashboardCubit, LabDashboardState>(
        builder: (context, state) {
          final l10n = context.l10n;
          return AppShellLayout(
            system: AppSystemType.lab,
            currentRoute: RouteNames.labDashboard,
            sections: LabSidebarSections.buildWithBadges(
              context,
              newOrdersCount: state.newOrders,
            ),
            pageTitle: l10n.dashboard,
            pageSubtitle: null,
            searchPlaceholder: l10n.labDashboardSearchHint,
            showThemeToggle: false,
            userRole: currentUserRoleLabel(context, fallback: l10n.roleLabManager),
            notificationCount: 0,
            body: state.status == LabDashboardStatus.error && state.orders.isEmpty
                ? _DashboardError(
                    message: state.errorMessage ?? l10n.error,
                    onRetry: () => context.read<LabDashboardCubit>().load(),
                  )
                : _LabDashboardBody(state: state),
          );
        },
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded,
              size: 42,
              color: isLight ? AppColors.lightText3 : AppColors.darkText3),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isLight ? AppColors.lightText2 : AppColors.darkText2,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(context.l10n.retry),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  BODY
// ══════════════════════════════════════════════════════════════════════════

class _LabDashboardBody extends StatelessWidget {
  const _LabDashboardBody({required this.state});

  final LabDashboardState state;

  @override
  Widget build(BuildContext context) {
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
                // ── 1. Greeting bar ─────────────────────────────────────
                _buildWelcomeHero(context),
                const SizedBox(height: AppSizes.spaceLG),

                // ── 2. Stat Cards (أرقام حقيقية) ────────────────────────
                LabDashboardStatCards(
                  dueToday: state.dueToday,
                  ready: state.ready,
                  manufacturing: state.manufacturing,
                  newOrders: state.newOrders,
                ),
                const SizedBox(height: AppSizes.spaceLG),

                // ── 3. Ending Today Alert ───────────────────────────────
                LabEndingTodayAlert(ordersDueToday: state.ordersDueToday),
                const SizedBox(height: AppSizes.spaceLG),

                // ── 4. Orders Table ─────────────────────────────────────
                LabDashboardOrdersTable(
                  orders: state.orders,
                  isLoading: state.isInitialLoading,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// hero الترحيب — الويدجت الموحّد المشترك مع المستودع.
  Widget _buildWelcomeHero(BuildContext context) {
    final l10n = context.l10n;
    return AppWelcomeHero(
      emoji: '🦷',
      greeting: l10n.labGreeting(
          CurrentUser.instance.name ?? MockUserData.labUserName),
      metas: [
        AppHeroMeta(_todayLabel(context), faded: true, dotBefore: false),
        AppHeroMeta(_lastUpdatedLabel(context), faded: true),
      ],
      stats: [
        // المنجزة/الجاهزة — أقرب مقياس حقيقي لـ"تم توصيلها" (لا حالة delivered).
        AppHeroMiniStat(
          icon: Icons.local_shipping_outlined,
          value: '${state.ready}',
          label: l10n.labHeroStatDelivered,
          accent: AppColors.statusSuccess,
          checkmark: true,
        ),
        AppHeroMiniStat(
          icon: Icons.adjust_rounded,
          value: '${state.manufacturing}',
          label: l10n.labHeroStatInProgress,
          accent: AppColors.statusProgress,
        ),
        AppHeroMiniStat(
          icon: Icons.assignment_outlined,
          value: '${state.dueToday}',
          label: l10n.labHeroStatTodayOrders,
          accent: AppColors.primary,
        ),
      ],
    );
  }

  /// اسم اليوم الحقيقي (اليوم الفعلي، لا نص ثابت).
  String _todayLabel(BuildContext context) {
    final l10n = context.l10n;
    final names = [
      l10n.dayMonday,
      l10n.dayTuesday,
      l10n.dayWednesday,
      l10n.dayThursday,
      l10n.dayFriday,
      l10n.daySaturday,
      l10n.daySunday,
    ];
    final now = DateTime.now();
    final dayName = names[now.weekday - 1];
    final date = '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/${now.year}';
    return '$dayName، $date';
  }

  /// "آخر تحديث" حقيقي محسوب من وقت آخر جلب ناجح فعلي، لا نص ثابت.
  String _lastUpdatedLabel(BuildContext context) {
    final l10n = context.l10n;
    final at = state.lastLoadedAt;
    if (at == null) return l10n.labLastUpdatedJustNow;
    final diff = DateTime.now().difference(at);
    if (diff.inMinutes < 1) return l10n.labLastUpdatedJustNow;
    if (diff.inMinutes < 60) return l10n.labLastUpdatedMinutesAgo(diff.inMinutes);
    return l10n.labLastUpdatedHoursAgo(diff.inHours);
  }
}
