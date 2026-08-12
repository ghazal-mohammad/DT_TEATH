// ════════════════════════════════════════════════════════════════════════════
// lab_dashboard_orders_table.dart
//
// قسم جدول "طلبات اليوم" في لوحة تحكم المخبر — مع شريط فلترة وحالات.
// مُستخرَج من lab_dashboard_page.dart ضمن تقسيم الصفحات العملاقة لودجات.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/data/app_data_table.dart';
import '../../../../../shared/widgets/primitives/app_segmented_tabs.dart';
import '../../../domain/entities/lab_order.dart';

/// جدول طلبات اليوم مع شريط فلترة (الكل/جديد/قيد التصنيع/جاهز).
class LabDashboardOrdersTable extends StatefulWidget {
  const LabDashboardOrdersTable({
    super.key,
    required this.orders,
    this.isLoading = false,
  });

  /// الطلبات الحقيقية (من LabDashboardCubit/LabOrdersRepository) — لا mock.
  final List<LabOrderFull> orders;
  final bool isLoading;

  @override
  State<LabDashboardOrdersTable> createState() =>
      _LabDashboardOrdersTableState();
}

class _LabDashboardOrdersTableState extends State<LabDashboardOrdersTable> {
  String _activeFilter = 'all';

  List<LabOrderFull> get _filtered {
    final all = widget.orders;
    switch (_activeFilter) {
      case 'new':
        return all
            .where((o) => o.statusVariant == LabOrderBadgeVariant.newOrder)
            .toList();
      case 'manufacturing':
        return all
            .where(
              (o) => o.statusVariant == LabOrderBadgeVariant.manufacturing,
            )
            .toList();
      case 'ready':
        return all
            .where((o) => o.statusVariant == LabOrderBadgeVariant.ready)
            .toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = widget.orders;
    final counts = {
      'new': all
          .where((o) => o.statusVariant == LabOrderBadgeVariant.newOrder)
          .length,
      'manufacturing': all
          .where((o) => o.statusVariant == LabOrderBadgeVariant.manufacturing)
          .length,
      'ready': all
          .where((o) => o.statusVariant == LabOrderBadgeVariant.ready)
          .length,
    };
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.darkBg1,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spaceLG,
              AppSizes.spaceLG,
              AppSizes.spaceLG,
              AppSizes.spaceMD,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 20,
                  color: isLight ? AppColors.primary : AppColors.darkText1,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.labTodayOrders,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isLight
                        ? AppColors.statusProgressBg
                        : AppColors.darkChipVioletBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    context.l10n.labOrdersCount('${all.length}'),
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isLight
                          ? AppColors.primary
                          : AppColors.darkChipVioletText,
                    ),
                  ),
                ),
                const Spacer(),
                // tabs — الستايل الموحّد (نفس شريط المستودع)
                AppSegmentedTabs<String>(
                  values: const ['all', 'new', 'manufacturing', 'ready'],
                  selected: _activeFilter,
                  labelOf: (v) => switch (v) {
                    'new' => context.l10n.labOrdersFilterNew,
                    'manufacturing' =>
                      context.l10n.labOrdersFilterManufacturing,
                    'ready' => context.l10n.labOrdersFilterReady,
                    _ => context.l10n.labOrdersFilterAll,
                  },
                  countOf: (v) =>
                      v == 'all' ? all.length : (counts[v] ?? 0),
                  onChanged: (v) => setState(() => _activeFilter = v),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => context.go(RouteNames.labOrders),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      '${context.l10n.viewAll} ←',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isLight ? AppColors.primary : AppColors.brand,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table
          AppDataTable<LabOrderFull>(
            data: _filtered,
            isLoading: widget.isLoading,
            emptyMessage: context.l10n.labOrdersEmpty,
            // موحّد مع المستودع: tableHeader (#BED8FA) بالفاتح.
            headerBackground:
                isLight ? AppColors.tableHeader : AppColors.darkBg2,
            columns: [
              AppDataColumn<LabOrderFull>(
                label: context.l10n.colOrderNumber,
                flex: 2,
                cellBuilder: (item) => Text(
                  item.id,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                  ),
                ),
              ),
              AppDataColumn<LabOrderFull>(
                label: context.l10n.colDoctor,
                flex: 2,
                cellBuilder: (item) => _doctorCell(item.doctor, isLight),
              ),
              AppDataColumn<LabOrderFull>(
                label: context.l10n.colType,
                flex: 2,
                cellBuilder: (item) =>
                    Text(item.type, style: AppTextStyles.bodyMedium),
              ),
              AppDataColumn<LabOrderFull>(
                label: context.l10n.colMaterial,
                flex: 2,
                cellBuilder: (item) => Text(
                  item.material.isEmpty ? '—' : item.material,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              AppDataColumn<LabOrderFull>(
                label: context.l10n.colTooth,
                flex: 2,
                cellBuilder: (item) => Text(
                  item.tooth.isEmpty ? '—' : item.tooth,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              AppDataColumn<LabOrderFull>(
                label: context.l10n.colDate,
                flex: 2,
                cellBuilder: (item) =>
                    Text(item.date, style: AppTextStyles.bodySmall),
              ),
              AppDataColumn<LabOrderFull>(
                label: context.l10n.colPriority,
                flex: 2,
                cellBuilder: (item) =>
                    _priorityCell(context, item.isUrgent, isLight),
              ),
              AppDataColumn<LabOrderFull>(
                label: context.l10n.colStatus,
                flex: 2,
                cellBuilder: (item) => _statusBadge(context, item, isLight),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _doctorCell(String name, bool isLight) {
    // name مثل "د. سارة س" → نعرضو كامل، الـ avatar يستخدم آخر جزء (س)
    final parts =
        name.split(' ').where((p) => p.isNotEmpty).toList(growable: false);
    final String displayName = parts.join(' ');
    final String lastSegment = parts.isNotEmpty ? parts.last : name;
    final String initial =
        lastSegment.isNotEmpty ? lastSegment.characters.first : '';

    // التصميم المرجعي: الـ avatar يمين (نقطة بداية القراءة بالـ RTL)
    // ثم اسم الطبيب يسار → [avatar, SizedBox, Text].
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isLight ? AppColors.statusInfoBg : AppColors.darkChipBlueBg,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isLight ? AppColors.primary : AppColors.darkChipBlueText,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            displayName,
            style: AppTextStyles.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// الباك لا يعرف إلا حالتين (isUrgent bool) — لا "متوسطة" حقيقية. موحّد مع
  /// شارة العجلة بالبطاقة (lab_order_card.dart).
  Widget _priorityCell(BuildContext context, bool isUrgent, bool isLight) {
    final l10n = context.l10n;
    final ({Color color, String label, int bars}) data = isUrgent
        ? (color: AppColors.statusUrgent, label: l10n.priorityUrgent, bars: 3)
        : (
            color: isLight ? AppColors.lightText4 : AppColors.darkText4,
            label: l10n.priorityNormal,
            bars: 1,
          );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(width: 2),
          Container(
            width: 3,
            height: 10 + i * 2.0,
            decoration: BoxDecoration(
              color: i < data.bars
                  ? data.color
                  : data.color.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
        const SizedBox(width: 6),
        Text(
          data.label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: data.color,
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(BuildContext context, LabOrderFull item, bool isLight) {
    final l10n = context.l10n;
    final ({Color bg, Color text, String label}) data =
        switch (item.statusVariant) {
      LabOrderBadgeVariant.newOrder => (
          bg: isLight ? AppColors.statusInfoBg : AppColors.darkChipBlueBg,
          text: isLight ? AppColors.statusInfo : AppColors.darkChipBlueText,
          label: l10n.statusNew,
        ),
      LabOrderBadgeVariant.manufacturing => (
          bg: isLight ? AppColors.statusProgressBg : AppColors.darkChipVioletBg,
          text:
              isLight ? AppColors.statusProgress : AppColors.darkChipVioletText,
          label: l10n.statusManufacturing,
        ),
      LabOrderBadgeVariant.ready => (
          bg: isLight ? AppColors.statusSuccessBg : AppColors.darkChipGreenBg,
          text: isLight ? AppColors.statusSuccess : AppColors.darkChipGreenText,
          label: l10n.statusReady,
        ),
      LabOrderBadgeVariant.cancelled => (
          bg: isLight ? AppColors.borderNeutralLight : AppColors.darkBg2,
          text: isLight ? AppColors.categoryGrey : AppColors.darkText3,
          label: l10n.statusCancelled,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: data.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      // RTL: نص يمين، dot يسار.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: data.text,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: data.text,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
