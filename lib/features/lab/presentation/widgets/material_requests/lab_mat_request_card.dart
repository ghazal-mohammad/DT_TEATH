// ════════════════════════════════════════════════════════════════════════════
// lab_mat_request_card.dart
//
// بطاقة طلب مادة من المستودع (معرف + مادة + حالة + تفاصيل + سبب/ملاحظة)
// — مُستخرَجة من lab_material_requests_page.dart ضمن تقسيم الصفحات.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/primitives/app_badge.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import 'lab_mat_request_data.dart';

/// بطاقة طلب مادة واحدة في قائمة طلبات المخبر من المستودع.
class LabMatRequestCard extends StatefulWidget {
  const LabMatRequestCard({super.key, required this.request});
  final MatRequest request;

  @override
  State<LabMatRequestCard> createState() => _LabMatRequestCardState();
}

class _LabMatRequestCardState extends State<LabMatRequestCard> {
  bool _hovered = false;

  Color get _accentColor {
    switch (widget.request.status) {
      case MatRequestStatus.newRequest:
        return AppColors.accent;
      case MatRequestStatus.delivered:
        return AppColors.success;
      case MatRequestStatus.unavailable:
        return AppColors.error;
    }
  }

  AppBadgeVariant get _badgeVariant {
    switch (widget.request.status) {
      case MatRequestStatus.newRequest:
        return AppBadgeVariant.cyan;
      case MatRequestStatus.delivered:
        return AppBadgeVariant.green;
      case MatRequestStatus.unavailable:
        return AppBadgeVariant.redAnimated;
    }
  }

  String _badgeText(BuildContext context) {
    switch (widget.request.status) {
      case MatRequestStatus.newRequest:
        return context.l10n.statusNew;
      case MatRequestStatus.delivered:
        return context.l10n.statusDelivered;
      case MatRequestStatus.unavailable:
        return context.l10n.labReqStatusUnavailable;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          // الشريط الملوّن على الحافة اليسرى البصرية (مطابق لباقي بطاقات النظام).
          border: Border(
            left: BorderSide(color: _accentColor, width: 3),
            top: BorderSide(
              color: _hovered
                  ? (isLight ? AppColors.lightBorderHover : AppColors.darkBorderHover)
                  : (isLight ? AppColors.lightBorder : AppColors.darkBorder),
            ),
            bottom: BorderSide(
              color: _hovered
                  ? (isLight ? AppColors.lightBorderHover : AppColors.darkBorderHover)
                  : (isLight ? AppColors.lightBorder : AppColors.darkBorder),
            ),
            right: BorderSide(
              color: _hovered
                  ? (isLight ? AppColors.lightBorderHover : AppColors.darkBorderHover)
                  : (isLight ? AppColors.lightBorder : AppColors.darkBorder),
            ),
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
        child: Padding(
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
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AppBadge(text: _badgeText(context), variant: _badgeVariant),
                ],
              ),
              const SizedBox(height: AppSizes.spaceMD),
              const Divider(height: 1, color: AppColors.darkBorder),
              const SizedBox(height: AppSizes.spaceMD),
              // Row 2: التفاصيل
              Row(
                children: [
                  _cell(context, icon: AppIcons.box, label: context.l10n.colQuantity, value: '${r.quantity} ${r.unit}'),
                  const SizedBox(width: AppSizes.spaceXL),
                  _cell(context, icon: AppIcons.profile, label: context.l10n.labReqRequestedBy, value: r.requestedBy, valueColor: AppColors.secondary),
                  const SizedBox(width: AppSizes.spaceXL),
                  _cell(context, icon: AppIcons.calendar, label: context.l10n.ordersDate, value: r.date),
                  if (r.company != null && r.company!.isNotEmpty) ...[
                    const SizedBox(width: AppSizes.spaceXL),
                    _cell(context, icon: AppIcons.box, label: context.l10n.labReqFieldCompany, value: r.company!),
                  ],
                  if (r.labOrderId != null) ...[
                    const SizedBox(width: AppSizes.spaceXL),
                    _cell(context, icon: AppIcons.labOrders, label: context.l10n.labReqLabOrder, value: r.labOrderId!, valueColor: AppColors.accent),
                  ],
                  const Spacer(),
                  if (r.status == MatRequestStatus.newRequest)
                    AppButton.secondary(
                      label: context.l10n.labActionTrack,
                      icon: AppIcons.eye,
                      onPressed: () {},
                      size: AppButtonSize.small,
                    ),
                ],
              ),
              // سبب الطلب (للمواد الجديدة) — صندوق معلوماتي محايد.
              if (r.reason != null && r.reason!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.spaceSM),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spaceMD,
                    vertical: AppSizes.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.statusInfo.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    border: Border.all(
                        color: AppColors.statusInfo.withValues(alpha: 0.18)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 12, color: AppColors.statusInfo),
                      const SizedBox(width: AppSizes.spaceXS),
                      Expanded(
                        child: Text(
                          '${context.l10n.labReqFieldReason}: ${r.reason!}',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.statusInfo),
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
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(AppIcons.warning, size: 12, color: AppColors.error),
                      const SizedBox(width: AppSizes.spaceXS),
                      Text(
                        r.note!,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              ],
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
            Icon(icon, size: 11, color: isLight ? AppColors.lightText4 : AppColors.darkText4),
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
            color: valueColor ?? (isLight ? AppColors.lightText1 : AppColors.darkText1),
          ),
        ),
      ],
    );
  }
}
