// ════════════════════════════════════════════════════════════════════════════
// warehouse_orders_content.dart
//
// طلبات المواد الواردة للمستودع — **مربوطة بالباك** (index/fulfill/reject).
// الطلب متعدّد العناصر (مواد كتالوج + مواد جديدة مقترحة)؛ المستودع يلبّي كامل
// الطلب (خصم FIFO) أو يرفضه بسبب.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../../../shared/widgets/primitives/app_segmented_tabs.dart';
import '../../bloc/warehouse_requests_cubit.dart';
import '../../../domain/entities/warehouse_request.dart';
import 'warehouse_request_details_dialog.dart';

/// نصّ + لون حالة الطلب.
({String label, Color color}) requestStatusStyle(
    BuildContext context, WarehouseRequestStatus s) {
  final l10n = context.l10n;
  switch (s) {
    case WarehouseRequestStatus.newReq:
      return (label: l10n.whReqStatusNew, color: AppColors.statusInfo);
    case WarehouseRequestStatus.inProgress:
      return (label: l10n.whReqStatusInProgress, color: AppColors.dashOrange);
    case WarehouseRequestStatus.completed:
      return (label: l10n.whReqStatusCompleted, color: AppColors.dashGreen);
    case WarehouseRequestStatus.rejected:
      return (label: l10n.whReqStatusRejected, color: AppColors.alertRed);
    case WarehouseRequestStatus.unknown:
      return (label: '—', color: AppColors.categoryGrey);
  }
}

String requestFilterLabel(BuildContext context, RequestsFilter f) {
  final l10n = context.l10n;
  return switch (f) {
    RequestsFilter.all => l10n.ordersFilterAll,
    RequestsFilter.newReq => l10n.whReqStatusNew,
    RequestsFilter.inProgress => l10n.whReqStatusInProgress,
    RequestsFilter.completed => l10n.whReqStatusCompleted,
    RequestsFilter.rejected => l10n.whReqStatusRejected,
  };
}

class WarehouseOrdersContent extends StatelessWidget {
  const WarehouseOrdersContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return BlocConsumer<WarehouseRequestsCubit, WarehouseRequestsState>(
      listenWhen: (p, c) =>
          p.actionError != c.actionError && c.actionError != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(state.actionError!),
          backgroundColor: AppColors.alertRed,
        ));
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSegmentedTabs<RequestsFilter>(
              values: RequestsFilter.values,
              selected: state.filter,
              labelOf: (f) => requestFilterLabel(context, f),
              countOf: (f) => state.countOf(f),
              onChanged: (f) =>
                  context.read<WarehouseRequestsCubit>().setFilter(f),
            ),
            const SizedBox(height: 16),
            _body(context, state, isLight),
          ],
        );
      },
    );
  }

  Widget _body(
      BuildContext context, WarehouseRequestsState state, bool isLight) {
    if (state.status == RequestsStatus.loading && state.requests.isEmpty) {
      return const Padding(
          padding: EdgeInsets.all(48),
          child: Center(child: CircularProgressIndicator()));
    }
    if (state.status == RequestsStatus.error && state.requests.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(36),
        child: Center(
          child: Text(state.errorMessage ?? '—',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.alertRed)),
        ),
      );
    }
    final list = state.filtered;
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: AppEmptyState(
          icon: Icons.inbox_outlined,
          title: context.l10n.whOrdersEmptyFilter,
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, c) {
        final cross = c.maxWidth > 900 ? 3 : (c.maxWidth > 560 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            mainAxisExtent: 172,
          ),
          itemCount: list.length,
          itemBuilder: (context, i) =>
              _RequestCard(request: list[i], isLight: isLight),
        );
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.isLight});
  final WarehouseRequest request;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final st = requestStatusStyle(context, request.status);
    final txt1 = isLight ? AppColors.lightText1 : AppColors.darkText1;
    final txt3 = isLight ? AppColors.lightText3 : AppColors.darkText3;
    final date = request.createdAt;
    final dateStr = date == null
        ? '—'
        : '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return InkWell(
      onTap: () => WarehouseRequestDetailsDialog.show(context, request),
      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.spaceMD),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : AppColors.darkSurface,
          border: Border.all(
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(l10n.whReqNumber(request.id),
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w800, color: txt1)),
                ),
                _StatusChip(label: st.label, color: st.color),
              ],
            ),
            const SizedBox(height: 8),
            _line(Icons.person_outline_rounded,
                request.requesterName.isEmpty ? '—' : request.requesterName, txt3),
            const SizedBox(height: 4),
            _line(Icons.inventory_2_outlined,
                l10n.whReqItemsCount(request.itemsCount), txt3),
            const SizedBox(height: 4),
            _line(Icons.event_outlined, dateStr, txt3),
            const Spacer(),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(l10n.whReqViewDetails,
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(IconData icon, String text, Color color) => Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(color: color)),
          ),
        ],
      );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label,
          style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: color)),
    );
  }
}
