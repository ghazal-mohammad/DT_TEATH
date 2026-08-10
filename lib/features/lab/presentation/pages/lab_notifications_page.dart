// ════════════════════════════════════════════════════════════════════════════
// lab_notifications_page.dart  — الإشعارات
//
//   - شريط فلاتر (الكل / غير مقروءة / عاجل / طلبات / مواد / نظام) + counts
//   - "تحديد الكل كمقروء"
//   - أقسام زمنية (اليوم / أمس) + بطاقات إشعارات
//
// المعمارية: UI → LabNotificationsCubit → LabNotificationsRepository.
// النموذج في domain/entities/lab_notification.dart، والستايل/البطاقة/الفلاتر
// في widgets/notifications/.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/employee_role_label.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../data/repositories/mock_lab_notifications_repository.dart';
import '../bloc/lab_notifications_cubit.dart';
import '../bloc/lab_notifications_state.dart';
import '../navigation/lab_sidebar_sections.dart';
import '../widgets/notifications/lab_notification_card.dart';
import '../widgets/notifications/lab_notification_data.dart';
import '../widgets/notifications/lab_notifications_filter_row.dart';

/// صفحة إشعارات المخبر — تُنشئ [LabNotificationsCubit] وتزوّده للـ subtree.
class LabNotificationsPage extends StatelessWidget {
  const LabNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LabNotificationsCubit(
        repository: MockLabNotificationsRepository(),
      )..load(),
      child: BlocBuilder<LabNotificationsCubit, LabNotificationsState>(
        builder: (context, state) {
          return AppShellLayout(
            system: AppSystemType.lab,
            currentRoute: RouteNames.labNotifications,
            sections: LabSidebarSections.buildWithBadges(
              context,
              newOrdersCount: 4,
              unreadNotifsCount: state.unread,
            ),
            pageTitle: context.l10n.notifications,
            pageSubtitle: null,
            searchPlaceholder: context.l10n.notifSearchHint,
            showThemeToggle: false,
            userRole: currentUserRoleLabel(context, fallback: context.l10n.roleLabManager),
            notificationCount: state.unread,
            body: _NotificationsBody(state: state),
          );
        },
      ),
    );
  }
}

class _NotificationsBody extends StatelessWidget {
  const _NotificationsBody({required this.state});

  final LabNotificationsState state;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final cubit = context.read<LabNotificationsCubit>();
    final today = state.today;
    final yesterday = state.yesterday;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter row + mark all read
          LabNotificationsFilterRow(
            current: state.filter,
            total: state.total,
            unread: state.unread,
            urgent: state.kindCount(NotificationKind.urgent),
            orders: state.kindCount(NotificationKind.order),
            materials: state.kindCount(NotificationKind.material),
            systemCount: state.kindCount(NotificationKind.system),
            onChange: cubit.setFilter,
            onMarkAllRead: cubit.markAllRead,
          ),
          const SizedBox(height: AppSizes.spaceLG),
          if (today.isNotEmpty) ...[
            LabNotificationsSectionHeading(label: context.l10n.sectionToday),
            const SizedBox(height: 10),
            for (final n in today) ...[
              LabNotificationCard(item: n),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: AppSizes.spaceMD),
          ],
          if (yesterday.isNotEmpty) ...[
            LabNotificationsSectionHeading(
                label: context.l10n.sectionYesterday),
            const SizedBox(height: 10),
            for (final n in yesterday) ...[
              LabNotificationCard(item: n),
              const SizedBox(height: 10),
            ],
          ],
          if (state.filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.notifications_none_rounded,
                        size: 48, color: AppColors.iconMutedLight),
                    const SizedBox(height: AppSizes.spaceMD),
                    Text(
                      context.l10n.notifEmptyInCategory,
                      style: AppTextStyles.bodyMedium.copyWith(
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
    );
  }
}
