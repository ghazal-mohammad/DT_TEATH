
import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/primitives/app_badge.dart';
import 'lab_mat_request_data.dart';

/// بطاقة طلب مادة واحدة في قائمة طلبات المخبر من المستودع.
class LabMatRequestCard extends StatefulWidget {
  const LabMatRequestCard({super.key, required this.request, this.onDelete});
  final MatRequest request;

  /// عند تمريره يظهر زر حذف في رأس البطاقة (null = بلا حذف).
  final VoidCallback? onDelete;

  @override
  State<LabMatRequestCard> createState() => _LabMatRequestCardState();
}

class _LabMatRequestCardState extends State<LabMatRequestCard> {
  bool _hovered = false;

  Color get _accentColor {
    switch (widget.request.status) {
      case MatRequestStatus.newRequest:
        return AppColors.accent;
      case MatRequestStatus.inProgress:
        return AppColors.statusProgress;
      case MatRequestStatus.delivered:
        return AppColors.success;
      case MatRequestStatus.unavailable:
        return AppColors.error;
      case MatRequestStatus.cancelled:
        return AppColors.categoryGrey;
    }
  }

  AppBadgeVariant get _badgeVariant {
    switch (widget.request.status) {
      case MatRequestStatus.newRequest:
        return AppBadgeVariant.cyan;
      case MatRequestStatus.inProgress:
        return AppBadgeVariant.violet;
      case MatRequestStatus.delivered:
        return AppBadgeVariant.green;
      case MatRequestStatus.unavailable:
        return AppBadgeVariant.redAnimated;
      case MatRequestStatus.cancelled:
        return AppBadgeVariant.gold;
    }
  }

  String _badgeText(BuildContext context) {
    switch (widget.request.status) {
      case MatRequestStatus.newRequest:
        return context.l10n.statusNew;
      case MatRequestStatus.inProgress:
        return context.l10n.labReqStatusInProgress;
      case MatRequestStatus.delivered:
        return context.l10n.statusDelivered;
      case MatRequestStatus.unavailable:
        return context.l10n.labReqStatusUnavailable;
      case MatRequestStatus.cancelled:
        return context.l10n.statusCancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      // ClipRRect + شريط لوني منفصل بدل Border رباعي الألوان: Flutter يرمي
      // استثناء عند الرسم لو Border له borderRadius وألوان أضلاع مختلفة
      // ("A borderRadius can only be given on borders with uniform colors")
      // — كانت البطاقة تفشل بالرسم بصمت بكل تحميل (تظهر فاضية فعلياً).
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
            border: Border.all(
              color: _hovered
                  ? (isLight
                        ? AppColors.lightBorderHover
                        : AppColors.darkBorderHover)
                  : (isLight ? AppColors.lightBorder : AppColors.darkBorder),
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                child: Container(width: 3, color: _accentColor),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.spaceLG),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: معرف الطلب + المادة + الحالة
                    Row(
                      children: [
                        Text(
                          r.id,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: AppSizes.spaceSM),
                        Expanded(
                          child: Text(
                            r.material,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AppBadge(
                          text: _badgeText(context),
                          variant: _badgeVariant,
                        ),
                        if (widget.onDelete != null) ...[
                          const SizedBox(width: AppSizes.spaceSM),
                          Tooltip(
                            message: context.l10n.delete,
                            child: Semantics(
                              button: true,
                              label: context.l10n.delete,
                              child: InkResponse(
                                onTap: widget.onDelete,
                                radius: 18,
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSizes.spaceMD),
                    const Divider(height: 1, color: AppColors.darkBorder),
                    const SizedBox(height: AppSizes.spaceMD),
                    // Row 2: التفاصيل
                    Row(
                      children: [
                        _cell(
                          context,
                          icon: AppIcons.box,
                          label: context.l10n.colQuantity,
                          value: '${r.quantity} ${r.unit}',
                        ),
                        const SizedBox(width: AppSizes.spaceXL),
                        _cell(
                          context,
                          icon: AppIcons.profile,
                          label: context.l10n.labReqRequestedBy,
                          value: r.requestedBy,
                          valueColor: AppColors.secondary,
                        ),
                        const SizedBox(width: AppSizes.spaceXL),
                        _cell(
                          context,
                          icon: AppIcons.calendar,
                          label: context.l10n.ordersDate,
                          value: r.date,
                        ),
                        if (r.company != null && r.company!.isNotEmpty) ...[
                          const SizedBox(width: AppSizes.spaceXL),
                          _cell(
                            context,
                            icon: AppIcons.box,
                            label: context.l10n.labReqFieldCompany,
                            value: r.company!,
                          ),
                        ],
                        if (r.labOrderId != null) ...[
                          const SizedBox(width: AppSizes.spaceXL),
                          _cell(
                            context,
                            icon: AppIcons.labOrders,
                            label: context.l10n.labReqLabOrder,
                            value: r.labOrderId!,
                            valueColor: AppColors.accent,
                          ),
                        ],
                        const Spacer(),
                      ],
                    ),
                    if (r.reason != null && r.reason!.isNotEmpty) ...[
                      const SizedBox(height: AppSizes.spaceSM),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.spaceMD,
                          vertical: AppSizes.spaceXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.statusInfo.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSM,
                          ),
                          border: Border.all(
                            color: AppColors.statusInfo.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 12,
                              color: AppColors.statusInfo,
                            ),
                            const SizedBox(width: AppSizes.spaceXS),
                            Expanded(
                              child: Text(
                                '${context.l10n.labReqFieldReason}: ${r.reason!}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.statusInfo,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Note if unavailable
                    if (r.note != null) ...[
                      const SizedBox(height: AppSizes.spaceSM),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.spaceMD,
                          vertical: AppSizes.spaceXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSM,
                          ),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              AppIcons.warning,
                              size: 12,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: AppSizes.spaceXS),
                            Text(
                              r.note!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cell(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 11,
              color: isLight ? AppColors.lightText4 : AppColors.darkText4,
            ),
            const SizedBox(width: 3),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isLight ? AppColors.lightText4 : AppColors.darkText4,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color:
                valueColor ??
                (isLight ? AppColors.lightText1 : AppColors.darkText1),
          ),
        ),
      ],
    );
  }
}
