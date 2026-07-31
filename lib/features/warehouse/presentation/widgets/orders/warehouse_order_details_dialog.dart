// ════════════════════════════════════════════════════════════════════════════
// warehouse_order_details_dialog.dart
//
// Dialog تفاصيل طلبية التوريد — مطابق للـ mockup:
//   • رأس: عنوان + وصف + زر إغلاق
//   • بانر الحالة + تاريخ الطلب
//   • قسمين: بيانات الطلب | بيانات الجهة الطالبة
//   • Timeline تقدم التوريد (3 خطوات: استلام → جزئي → تم)
//   • ملاحظات (إن وجدت)
//   • زر إغلاق سفلي
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../data/mock/warehouse_pages_mock_data.dart';

part 'warehouse_order_details_parts.dart';

class WarehouseOrderDetailsDialog extends StatelessWidget {
  const WarehouseOrderDetailsDialog({
    super.key,
    required this.order,
    required this.urgent,
  });

  final WarehouseOrderItem order;
  final bool urgent;

  static Future<void> show(
    BuildContext context, {
    required WarehouseOrderItem order,
    required bool urgent,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => WarehouseOrderDetailsDialog(order: order, urgent: urgent),
    );
  }

  String _statusLabel(AppLocalizations l10n) => switch (order.status) {
        WarehouseOrderStatus.newOrder => l10n.ordersStatusNew,
        WarehouseOrderStatus.fulfilled => l10n.ordersStatusFulfilled,
        WarehouseOrderStatus.missing => l10n.ordersStatusPartial,
      };

  Color get _statusColor => switch (order.status) {
        WarehouseOrderStatus.newOrder => AppColors.statusInfo,
        WarehouseOrderStatus.fulfilled => AppColors.statusSuccess,
        WarehouseOrderStatus.missing => AppColors.statusProgress,
      };

  String get _requestNumber {
    final n = order.orderNumber.replaceAll(RegExp(r'\D'), '');
    return 'REQ-1${n.padLeft(3, '0')}';
  }

  /// المسؤول الافتراضي (في غياب backend) — موحّد للـ mock.
  String get _responsible => 'رامي الصالح';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // فرض RTL صراحةً — بعض parent widgets للديالوغ قد تُرجع LTR كافتراضي
    // مما يقلب صفوف داخلية معينة (مثل الـ timeline والـ info rows).
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 760),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 50,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              const Divider(height: 1, color: AppColors.lightBorder),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStatusBanner(l10n),
                      const SizedBox(height: 18),
                      _SectionTitle(l10n.orderDetailsInfoSection),
                      const SizedBox(height: 10),
                      _buildInfoCards(l10n),
                      const SizedBox(height: 18),
                      _SectionTitle(l10n.orderDetailsProgressSection),
                      const SizedBox(height: 14),
                      _buildTimeline(l10n),
                      if (order.notes != null && order.notes!.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        _SectionTitle(l10n.orderDetailsNotes),
                        const SizedBox(height: 8),
                        _buildNotes(),
                      ],
                    ],
                  ),
                ),
              ),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.orderDetailsTitle(_requestNumber),
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.lightText1,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  context.l10n.orderDetailsSubtitle,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightText3,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(99),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.lightBorder.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close,
                  size: 16, color: AppColors.lightText3),
            ),
          ),
        ],
      ),
    );
  }

  // ── Status Banner (الحالة + تاريخ الطلب) ─────────────────────────────
  Widget _buildStatusBanner(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceTintIndigo3,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.orderDetailsStatusLabel,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightText3,
                  ),
                ),
                const SizedBox(height: 6),
                // RTL: النص يمين، الـ dot يسار → [Text, SizedBox, dot].
                Row(
                  children: [
                    Text(
                      _statusLabel(l10n),
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _statusColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration:
                          BoxDecoration(color: _statusColor, shape: BoxShape.circle),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.orderDetailsOrderDate,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightText3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                order.date,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightText1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Info Cards (بيانات الطلب | بيانات الجهة) ─────────────────────────
  Widget _buildInfoCards(AppLocalizations l10n) {
    return LayoutBuilder(builder: (context, c) {
      final isNarrow = c.maxWidth < 560;
      final requestInfo = _InfoCard(
        title: l10n.orderDetailsRequestData,
        rows: [
          _InfoRow(label: l10n.orderDetailsMaterial, value: order.materialName),
          _InfoRow(label: l10n.ordersQuantity, value: '${order.quantity} ${order.unit}'),
          _InfoRow(
            label: l10n.orderDetailsPriority,
            value: urgent ? l10n.ordersUrgent : l10n.orderDetailsNormal,
            urgent: urgent,
            showUrgentBadge: true,
          ),
        ],
      );
      final requesterInfo = _InfoCard(
        title: l10n.orderDetailsRequesterData,
        rows: [
          _InfoRow(label: l10n.orderDetailsParty, value: order.requester),
          _InfoRow(label: l10n.orderDetailsResponsible, value: _responsible),
          _InfoRow(label: l10n.orderDetailsRequestNumber, value: _requestNumber),
        ],
      );
      if (isNarrow) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [requestInfo, const SizedBox(height: 10), requesterInfo],
        );
      }
      // RTL: أوّل child=يمين. المطلوب: بيانات الطلب يمين، الجهة يسار.
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: requestInfo),
          const SizedBox(width: 12),
          Expanded(child: requesterInfo),
        ],
      );
    });
  }

  // ── Timeline ─────────────────────────────────────────────────────────
  Widget _buildTimeline(AppLocalizations l10n) {
    // 3 محطات (من اليمين لليسار): استلام → جزئي → تم
    final List<_TimelineStep> steps = [
      _TimelineStep(
        label: l10n.orderTimelineReceived,
        date: order.date,
        state: _TimelineState.done,
      ),
      _TimelineStep(
        label: l10n.orderTimelinePartial,
        date: order.status == WarehouseOrderStatus.missing ||
                order.status == WarehouseOrderStatus.fulfilled
            ? order.date
            : null,
        state: order.status == WarehouseOrderStatus.missing
            ? _TimelineState.current
            : (order.status == WarehouseOrderStatus.fulfilled
                ? _TimelineState.done
                : _TimelineState.pending),
      ),
      _TimelineStep(
        label: l10n.ordersStatusFulfilled,
        date: order.status == WarehouseOrderStatus.fulfilled ? order.date : null,
        state: order.status == WarehouseOrderStatus.fulfilled
            ? _TimelineState.done
            : _TimelineState.pending,
      ),
    ];
    return _Timeline(steps: steps);
  }

  // ── Notes ────────────────────────────────────────────────────────────
  Widget _buildNotes() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceTintCool2,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Text(
        order.notes!,
        style: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.lightText1,
          height: 1.5,
        ),
      ),
    );
  }

  // ── Footer ───────────────────────────────────────────────────────────
  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.lightBorder)),
      ),
      // RTL: للزر على اليسار → centerEnd (لأن end في RTL = يسار).
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.lightText1,
            side: const BorderSide(color: AppColors.lightBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          ),
          child: Text(
            context.l10n.close,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                                PIECES
// ══════════════════════════════════════════════════════════════════════════

