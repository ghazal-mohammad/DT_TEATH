// ════════════════════════════════════════════════════════════════════════════
// lab_notifications_filter_row.dart
//
// شريط فلاتر الإشعارات (تبويبات + "تحديد الكل كمقروء") وعنوان القسم الزمني
// — مُستخرَجان من lab_notifications_page.dart ضمن تقسيم الصفحات.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/primitives/app_segmented_tabs.dart';

/// شريط فلاتر الإشعارات + رابط "تحديد الكل كمقروء".
class LabNotificationsFilterRow extends StatelessWidget {
  const LabNotificationsFilterRow({
    super.key,
    required this.current,
    required this.total,
    required this.unread,
    required this.urgent,
    required this.orders,
    required this.materials,
    required this.systemCount,
    required this.onChange,
    required this.onMarkAllRead,
  });

  final String current;
  final int total;
  final int unread;
  final int urgent;
  final int orders;
  final int materials;
  final int systemCount;
  final ValueChanged<String> onChange;
  final VoidCallback onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Row(
      children: [
        // tabs (RTL start = right visual)
        Flexible(
          child: AppSegmentedTabs<String>(
            values: const [
              'all',
              'unread',
              'urgent',
              'order',
              'material',
              'system',
            ],
            selected: current,
            labelOf: (v) => switch (v) {
              'unread' => context.l10n.notifFilterUnread,
              'urgent' => context.l10n.priorityUrgent,
              'order' => context.l10n.notifFilterOrders,
              'material' => context.l10n.notifFilterMaterials,
              'system' => context.l10n.notifFilterSystem,
              _ => context.l10n.notifFilterAll,
            },
            countOf: (v) => switch (v) {
              'unread' => unread,
              'urgent' => urgent,
              'order' => orders,
              'material' => materials,
              'system' => systemCount,
              _ => total,
            },
            onChanged: onChange,
          ),
        ),
        const Spacer(),
        const SizedBox(width: 12),
        // mark all read (left visual)
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onMarkAllRead,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isLight ? Colors.white : AppColors.darkBg1,
                border: Border.all(
                    color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.done_all_rounded,
                      size: 14,
                      color: isLight ? AppColors.primary : AppColors.brand),
                  const SizedBox(width: 5),
                  Text(
                    context.l10n.notifMarkAllRead,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// عنوان قسم زمني (اليوم / أمس) بخط فاصل.
class LabNotificationsSectionHeading extends StatelessWidget {
  const LabNotificationsSectionHeading({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isLight ? AppColors.lightText3 : AppColors.darkText3,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
