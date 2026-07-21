// ════════════════════════════════════════════════════════════════════════════
// lab_dashboard_page.dart
//
// صفحة لوحة التحكم لنظام المخبر. الأقسام (بطاقات الإحصاء، تنبيه اليوم، جدول
// الطلبات) ودجات مستقلة تحت widgets/dashboard/.
//
// العدّادات (البطاقات + hero + شارة السايدبار) محسوبة من الطلبات الحقيقية عبر
// LabDashboardCubit (لا من mock ولا من عدّادات الباك التي ترجع أصفاراً).
// جدول الطلبات وتنبيه اليوم ما زالا على بيانات تصميمية مؤقّتاً (بند تالٍ).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/current_user.dart';
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

// ══════════════════════════════════════════════════════════════════════════

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
              unreadNotifsCount: 2,
            ),
            pageTitle: l10n.dashboard,
            pageSubtitle: null,
            searchPlaceholder: l10n.labDashboardSearchHint,
            showThemeToggle: false,
            userRole: l10n.roleLabManager,
            notificationCount: 2,
            body: _LabDashboardBody(state: state),
          );
        },
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
                const LabEndingTodayAlert(),
                const SizedBox(height: AppSizes.spaceLG),

                // ── 4. Orders Table ─────────────────────────────────────
                const LabDashboardOrdersTable(),
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
      statusText: l10n.systemAllNormal,
      metas: const [
        AppHeroMeta('الاثنين، 18 مايو', faded: true),
        AppHeroMeta('آخر تحديث: منذ 3 دقيقة', faded: true),
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
}
