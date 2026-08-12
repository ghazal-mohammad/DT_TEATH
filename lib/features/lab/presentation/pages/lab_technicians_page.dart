// ════════════════════════════════════════════════════════════════════════════
// lab_technicians_page.dart  — إدارة المخبريين
//
// شاشة إدارة المخبريين:
//   - 3 stat cards (الإجمالي / يعمل الآن / جاهز للتوكيل)
//   - جدول فريق المخبر (المخبري / الدوام / المهمة / الحالة / توكيل + pause/play)
//   - مودال "توكيل طلبية"
//   ملاحظة: لا يوجد "إضافة مخبري" هنا — إضافة الموظفين من صلاحيات الأدمن فقط.
//
// المعمارية: UI → LabTechniciansCubit → LabRepository (جلب الفنيين من الباك).
// النماذج/البطاقات/الجدول في widgets/technicians/.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/employee_role_label.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/feedback/glass_toast.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../../../shared/widgets/loading/app_shimmer_card.dart';
import '../../../../shared/widgets/loading/app_shimmer_table.dart';
import '../../domain/repositories/lab_orders_repository.dart';
import '../../domain/repositories/lab_repository.dart';
import '../bloc/lab_technicians_cubit.dart';
import '../bloc/lab_technicians_state.dart';
import '../navigation/lab_sidebar_sections.dart';
import '../widgets/assign_order_dialog.dart';
import '../widgets/technicians/lab_technician_performance.dart';
import '../widgets/technicians/lab_technician_stats.dart';
import '../widgets/technicians/lab_technician_table.dart';
import '../widgets/technicians/lab_technician_view_data.dart';
import '../widgets/technicians/technician_schedule_dialog.dart';

/// صفحة إدارة المخبريين — تُنشئ [LabTechniciansCubit] وتزوّده للـ subtree.
class LabTechniciansPage extends StatelessWidget {
  const LabTechniciansPage({super.key});

  /// التسمية المترجمة لدور المخبري (الباك يرجّع الاسم فقط).
  static String _roleLabel(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar'
          ? 'فني'
          : 'Technician';

  @override
  Widget build(BuildContext context) {
    // نحسب التسميات المترجمة هنا (context صالح للقراءة)، ونمرّرها للـ create
    // كقيم ملتقطة — ممنوع قراءة Localizations داخل callback الـ create نفسه.
    final roleLabel = _roleLabel(context);
    final pendingLabel = context.l10n.labTechPendingAssign;
    return BlocProvider(
      create: (_) => LabTechniciansCubit(
        repository: sl<LabRepository>(),
        ordersRepository: sl<LabOrdersRepository>(),
      )..load(roleLabel: roleLabel, pendingLabel: pendingLabel),
      child: BlocBuilder<LabTechniciansCubit, LabTechniciansState>(
        builder: (context, state) {
          return AppShellLayout(
            system: AppSystemType.lab,
            currentRoute: RouteNames.labTechnicians,
            sections: LabSidebarSections.buildWithBadges(
              context,
              newOrdersCount: 4,
              unreadNotifsCount: 2,
            ),
            pageTitle: context.l10n.labManageTechnicians,
            pageSubtitle: null,
            searchPlaceholder: context.l10n.techSearchHint,
            onSearchChanged: (q) =>
                context.read<LabTechniciansCubit>().setSearchQuery(q),
            showThemeToggle: false,
            userRole: currentUserRoleLabel(context, fallback: context.l10n.roleLabManager),
            notificationCount: 2,
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, LabTechniciansState state) {
    if (state.status == LabTechniciansStatus.loading) {
      // Skeleton فوري بدل spinner يحجب الصفحة (أول طلب Laravel بطيء).
      return const SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                    child: AppShimmerCard(
                        layout: AppShimmerCardLayout.statCard)),
                SizedBox(width: AppSizes.spaceMD),
                Expanded(
                    child: AppShimmerCard(
                        layout: AppShimmerCardLayout.statCard)),
                SizedBox(width: AppSizes.spaceMD),
                Expanded(
                    child: AppShimmerCard(
                        layout: AppShimmerCardLayout.statCard)),
              ],
            ),
            SizedBox(height: AppSizes.spaceLG),
            AppShimmerTable(
              columns: [
                AppShimmerTableColumn.wide,
                AppShimmerTableColumn.text,
                AppShimmerTableColumn.text,
                AppShimmerTableColumn.badge,
                AppShimmerTableColumn.actions,
              ],
              rowCount: 6,
            ),
          ],
        ),
      );
    }
    if (state.status == LabTechniciansStatus.error) {
      return _TechsError(
        message: state.errorMessage ?? context.l10n.error,
        onRetry: () => context.read<LabTechniciansCubit>().load(
              roleLabel: _roleLabel(context),
              pendingLabel: context.l10n.labTechPendingAssign,
            ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabTechnicianStatsRow(total: state.total),
          const SizedBox(height: AppSizes.spaceLG),
          LabTechnicianTeamTable(
            technicians: state.filteredTechnicians,
            onAssign: (tech) => _onAssign(context, state, tech),
            onEditSchedule: (tech) => _onEditSchedule(context, tech),
          ),
          // تقرير أداء/تقييم الفنّيين (يظهر عند توفّر بيانات من الباك).
          if (state.performance.isNotEmpty) ...[
            const SizedBox(height: AppSizes.spaceLG),
            LabTechnicianPerformanceSection(items: state.performance),
          ],
        ],
      ),
    );
  }

  Future<void> _onAssign(
    BuildContext context,
    LabTechniciansState state,
    TechnicianItem tech,
  ) async {
    final cubit = context.read<LabTechniciansCubit>();
    final orderId = await AssignOrderDialog.show(
      context,
      technicianName: tech.name,
      orders: state.orders,
    );
    if (orderId == null) return;
    final ok = await cubit.assign(tech, orderId);
    if (!ok && context.mounted) {
      GlassToast.show(context, message: cubit.state.errorMessage ?? context.l10n.error);
    }
  }

  /// يفتح محرّر جدول الدوام؛ عند الحفظ الناجح يعيد جلب الفنّيين (الكاش أُبطل)
  /// ويعرض إشعاراً.
  Future<void> _onEditSchedule(
    BuildContext context,
    TechnicianItem tech,
  ) async {
    final cubit = context.read<LabTechniciansCubit>();
    final savedText = context.l10n.techScheduleSaved;
    final roleLabel = _roleLabel(context);
    final pendingLabel = context.l10n.labTechPendingAssign;

    final bool? ok = await TechnicianScheduleDialog.show(
      context,
      id: tech.id,
      name: tech.name,
    );
    if (ok != true) return;
    // إشعار النظام الموحّد (GlassToast) بدل SnackBar — قبل إعادة الجلب فالسياق حيّ.
    if (context.mounted) {
      GlassToast.show(
        context,
        message: savedText,
        icon: Icons.check_circle_rounded,
      );
    }
    await cubit.load(roleLabel: roleLabel, pendingLabel: pendingLabel);
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  ERROR STATE — فشل جلب الفنيين من الباك
// ══════════════════════════════════════════════════════════════════════════

class _TechsError extends StatelessWidget {
  const _TechsError({required this.message, required this.onRetry});

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
            style: AppTextStyles.bodyMedium.copyWith(
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
