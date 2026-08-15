// ════════════════════════════════════════════════════════════════════════════
// warehouse_request_details_dialog.dart
//
// تفاصيل طلب مواد وارد + إجراءات المستودع: تلبية (خصم FIFO) أو رفض بسبب.
// يستقبل نفس WarehouseRequestsCubit عبر BlocProvider.value ليعكس التغيير على
// القائمة بعد الإجراء.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../bloc/warehouse_requests_cubit.dart';
import '../../../domain/entities/warehouse_request.dart';
import 'warehouse_orders_content.dart' show requestStatusStyle;

class WarehouseRequestDetailsDialog extends StatelessWidget {
  const WarehouseRequestDetailsDialog({super.key, required this.request});

  final WarehouseRequest request;

  static Future<void> show(BuildContext context, WarehouseRequest request) {
    final cubit = context.read<WarehouseRequestsCubit>();
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: WarehouseRequestDetailsDialog(request: request),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final st = requestStatusStyle(context, request.status);
    return Dialog(
      backgroundColor: isLight ? Colors.white : AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(l10n.whReqDetailsTitle,
                        style: AppTextStyles.headlineSmall.copyWith(
                            color: isLight
                                ? AppColors.lightText1
                                : AppColors.darkText1)),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: st.color.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(100)),
                    child: Text(st.label,
                        style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: st.color)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                  '${l10n.whReqNumber(request.id)} · ${l10n.whReqRequester}: '
                  '${request.requesterName.isEmpty ? "—" : request.requesterName}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.lightText3)),
              const SizedBox(height: AppSizes.spaceMD),
              Flexible(child: _body(context, isLight)),
              const SizedBox(height: AppSizes.spaceMD),
              _actions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, bool isLight) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (request.items.isNotEmpty) ...[
            _sectionLabel(context, l10n.whReqExistingMaterials),
            ...request.items.map((it) => _itemRow(
                context, it.materialName, it.quantityRequested, null, isLight)),
          ],
          if (request.newItems.isNotEmpty) ...[
            const SizedBox(height: 10),
            _sectionLabel(context, l10n.whReqNewMaterials),
            ...request.newItems.map((it) => _itemRow(context, it.materialName,
                it.quantity, it.unit, isLight, company: it.companyName)),
          ],
          if (request.notes != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceTintCool2,
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              ),
              child: Text(request.notes!,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.lightText2)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 2),
        child: Text(text,
            style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w800, color: AppColors.info)),
      );

  Widget _itemRow(BuildContext context, String name, int qty, String? unit,
      bool isLight,
      {String? company}) {
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.isEmpty ? '—' : name,
                    style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isLight
                            ? AppColors.lightText1
                            : AppColors.darkText1)),
                if (company != null)
                  Text(company,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.lightText3, fontSize: 11)),
              ],
            ),
          ),
          Text('${l10n.whReqQtyRequested}: $qty${unit != null ? " $unit" : ""}',
              style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w800, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<WarehouseRequestsCubit, WarehouseRequestsState>(
      builder: (context, state) {
        final busy = state.busyId == request.id;
        // Wrap لا Row: طلب "جديد" يعرض حتى 4 أزرار معاً (إلغاء/بدء
        // المعالجة/رفض/تلبية) — Row ثابت كان يفيض بعرض الديالوج الضيّق.
        return Wrap(
          alignment: WrapAlignment.end,
          spacing: 8,
          runSpacing: 8,
          children: [
            AppButton.secondary(
              label: l10n.cancel,
              onPressed: () => Navigator.of(context).pop(),
              size: AppButtonSize.small,
            ),
            if (request.status.canMarkPending)
              AppButton.secondary(
                label: l10n.whReqMarkPending,
                onPressed: busy ? null : () => _markPending(context),
                size: AppButtonSize.small,
                icon: Icons.hourglass_top_rounded,
              ),
            if (request.status.canReject)
              AppButton.danger(
                label: l10n.whReqReject,
                onPressed: busy ? null : () => _reject(context),
                size: AppButtonSize.small,
              ),
            if (request.status.canFulfill)
              AppButton.primary(
                label: l10n.whReqFulfill,
                onPressed: busy ? null : () => _fulfill(context),
                size: AppButtonSize.small,
                icon: Icons.check_rounded,
              ),
          ],
        );
      },
    );
  }

  Future<void> _fulfill(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<WarehouseRequestsCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.whReqFulfill),
        content: Text(l10n.whReqFulfillConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel)),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.whReqFulfill)),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await cubit.fulfill(request.id);
    if (ok && context.mounted) Navigator.of(context).pop();
  }

  Future<void> _markPending(BuildContext context) async {
    final cubit = context.read<WarehouseRequestsCubit>();
    final ok = await cubit.markPending(request.id);
    if (ok && context.mounted) Navigator.of(context).pop();
  }

  Future<void> _reject(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<WarehouseRequestsCubit>();
    final ctrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.whReqRejectTitle),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l10n.whReqRejectReason,
            hintText: l10n.whReqRejectReasonHint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.alertRed),
            onPressed: () {
              final t = ctrl.text.trim();
              if (t.isNotEmpty) Navigator.of(ctx).pop(t);
            },
            child: Text(l10n.whReqReject),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (reason == null || reason.isEmpty) return;
    final ok = await cubit.reject(request.id, reason: reason);
    if (ok && context.mounted) Navigator.of(context).pop();
  }
}
