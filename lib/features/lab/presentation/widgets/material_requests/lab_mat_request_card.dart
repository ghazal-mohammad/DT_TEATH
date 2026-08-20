import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/primitives/app_badge.dart';
import 'lab_mat_request_data.dart';

/// بطاقة فاتورة واحدة في قائمة فواتير المخبر.
class LabMatRequestCard extends StatefulWidget {
  const LabMatRequestCard({super.key, required this.request, this.onDelete, this.onTap});
  final MatRequest request;

  /// عند تمريره يظهر زر حذف في رأس البطاقة (null = بلا حذف).
  final VoidCallback? onDelete;

  /// يُستدعى عند الدوس على البطاقة (لفتح تفاصيل الفاتورة).
  final VoidCallback? onTap;

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
    final l10n = context.l10n;
    final typeLabel = r.isFromCompany ? l10n.labReqTypeCompany : l10n.labReqTypeWarehouse;
    final typeIcon = r.isFromCompany ? AppIcons.supplier : AppIcons.materials;
    final firstMaterialName = r.isFromCompany
        ? (r.newItems.isNotEmpty ? r.newItems.first.materialName : '')
        : (r.items.isNotEmpty ? r.items.first.materialName : '');

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      // ClipRRect + شريط لوني منفصل بدل Border رباعي الألوان: Flutter يرمي
      // استثناء عند الرسم لو Border له borderRadius وألوان أضلاع مختلفة.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        child: InkWell(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
              border: Border.all(
                color: _hovered
                    ? (isLight ? AppColors.lightBorderHover : AppColors.darkBorderHover)
                    : (isLight ? AppColors.lightBorder : AppColors.darkBorder),
              ),
              boxShadow: _hovered
                  ? [BoxShadow(color: _accentColor.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4))]
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
                      // Row 1: رقم الفاتورة + أول مادة (+الباقي) + الحالة
                      Row(
                        children: [
                          Text(
                            l10n.labReqInvoiceNumber(r.id),
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
                              r.itemsCount > 1
                                  ? '$firstMaterialName +${r.itemsCount - 1}'
                                  : firstMaterialName,
                              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          AppBadge(text: _badgeText(context), variant: _badgeVariant),
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
                                    child: Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
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
                          _cell(context, icon: typeIcon, label: '', value: typeLabel),
                          const SizedBox(width: AppSizes.spaceXL),
                          _cell(context, icon: AppIcons.box, label: l10n.labReqItemsCount(r.itemsCount), value: ''),
                          const SizedBox(width: AppSizes.spaceXL),
                          _cell(
                            context,
                            icon: AppIcons.profile,
                            label: context.l10n.labReqRequestedBy,
                            value: r.requestedBy,
                            valueColor: AppColors.secondary,
                          ),
                          const SizedBox(width: AppSizes.spaceXL),
                          _cell(context, icon: AppIcons.calendar, label: context.l10n.ordersDate, value: r.date),
                          const Spacer(),
                        ],
                      ),
                      if (r.notes != null && r.notes!.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.spaceSM),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceMD, vertical: AppSizes.spaceXS),
                          decoration: BoxDecoration(
                            color: AppColors.statusInfo.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                            border: Border.all(color: AppColors.statusInfo.withValues(alpha: 0.18)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 12, color: AppColors.statusInfo),
                              const SizedBox(width: AppSizes.spaceXS),
                              Expanded(
                                child: Text(
                                  r.notes!,
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.statusInfo),
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
    final text = label.isEmpty ? value : (value.isEmpty ? label : '$label: $value');
    return Row(
      children: [
        Icon(icon, size: 11, color: isLight ? AppColors.lightText4 : AppColors.darkText4),
        const SizedBox(width: 3),
        Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? (isLight ? AppColors.lightText1 : AppColors.darkText1),
          ),
        ),
      ],
    );
  }
}
