// ════════════════════════════════════════════════════════════════════════════
// lab_dashboard_page.dart  — Phase 5.1 ✅
//
// صفحة لوحة التحكم الكاملة لنظام المخبر.
// الأقسام (بطاقات الإحصاء، تنبيه اليوم، جدول الطلبات) مُستخرَجة كودجات
// مستقلة تحت widgets/dashboard/ — هذه الصفحة تجمّعها فقط.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/auth/current_user.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/core/mock_user_data.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../../../shared/widgets/layout/app_welcome_hero.dart';
import '../../data/mock/lab_dashboard_mock_data.dart';
import '../navigation/lab_sidebar_sections.dart';
import '../widgets/dashboard/lab_dashboard_orders_table.dart';
import '../widgets/dashboard/lab_dashboard_stat_cards.dart';
import '../widgets/dashboard/lab_ending_today_alert.dart';

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
      // العنوان "الصفحة الرئيسية" (مطابق للسايدبار وحسب الاتفاق).
      pageTitle: l10n.dashboard,
      pageSubtitle: null,
      searchPlaceholder: l10n.labDashboardSearchHint,
      showThemeToggle: false,
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
          // ── 1. Greeting bar ─────────────────────────────────────────
          _buildWelcomeHero(context),
          const SizedBox(height: AppSizes.spaceLG),

          // ── 2. Stat Cards ────────────────────────────────────────────
          const LabDashboardStatCards(),
          const SizedBox(height: AppSizes.spaceLG),

          // ── 3. Ending Today Alert ────────────────────────────────────
          const LabEndingTodayAlert(),
          const SizedBox(height: AppSizes.spaceLG),

          // ── 4. Orders Table ──────────────────────────────────────────
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
        // عدد الطلبات الموصّلة للطبيب — مقياس المدير (قرار الفريق:
        // "نسبة الإنجاز" باسم المدير غلط، يُستبدل بعدد الطلبات المنجزة).
        AppHeroMiniStat(
          icon: Icons.local_shipping_outlined,
          value: '31',
          label: l10n.labHeroStatDelivered,
          accent: AppColors.statusSuccess,
          checkmark: true,
        ),
        AppHeroMiniStat(
          icon: Icons.adjust_rounded,
          value: '5',
          label: l10n.labHeroStatInProgress,
          accent: AppColors.statusProgress,
        ),
        AppHeroMiniStat(
          icon: Icons.assignment_outlined,
          value: '12',
          label: l10n.labHeroStatTodayOrders,
          accent: AppColors.primary,
        ),
      ],
    );
  }
}
