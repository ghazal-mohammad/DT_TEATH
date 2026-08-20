// ════════════════════════════════════════════════════════════════════════════
// lab_material_requests_page.dart  — فواتير طلب المواد (منظور المخبر)
//
// المخبر يرسل فواتير للمستودع: إما من مواد كتالوج المستودع (items[])، أو من
// شركة خارجية لمواد جديدة (new_items[]) — كل فاتورة نوع واحد بس.
//   - 4 filter chips (الكل / جديد / تم التسليم / غير متوفر)
//   - قائمة فواتير + زر "طلب فاتورة جديدة" → خطوة اختيار النوع → فورم مناسب
//
// المعمارية: UI → LabMaterialRequestsCubit → LabMaterialRequestsRepository.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/employee_role_label.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/feedback/glass_toast.dart';
import '../../../../shared/widgets/layout/app_page_action_bar.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../../../shared/widgets/loading/app_shimmer_card.dart';
import '../../../../shared/widgets/primitives/app_button.dart';
import '../../../../shared/widgets/primitives/app_filter_chip.dart';
import '../../domain/entities/lab_material_request.dart';
import '../../domain/repositories/lab_material_requests_repository.dart';
import '../bloc/lab_material_requests_cubit.dart';
import '../bloc/lab_material_requests_state.dart';
import '../navigation/lab_sidebar_sections.dart';
import '../widgets/material_requests/lab_invoice_details_dialog.dart';
import '../widgets/material_requests/lab_invoice_from_company_dialog.dart';
import '../widgets/material_requests/lab_invoice_from_warehouse_dialog.dart';
import '../widgets/material_requests/lab_invoice_printer.dart';
import '../widgets/material_requests/lab_invoice_type_chooser_dialog.dart';
import '../widgets/material_requests/lab_mat_request_card.dart';
import '../widgets/material_requests/lab_mat_requests_empty.dart';

/// صفحة الفواتير — تُنشئ [LabMaterialRequestsCubit] وتزوّده للـ subtree.
class LabMaterialRequestsPage extends StatelessWidget {
  const LabMaterialRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LabMaterialRequestsCubit(
        repository: sl<LabMaterialRequestsRepository>(),
      )..load(),
      child: BlocBuilder<LabMaterialRequestsCubit, LabMaterialRequestsState>(
        builder: (context, state) {
          return AppShellLayout(
            system: AppSystemType.lab,
            currentRoute: RouteNames.labMaterialRequests,
            sections: LabSidebarSections.build(context),
            pageTitle: context.l10n.materialRequests,
            pageSubtitle: context.l10n.labTopbarSubtitle,
            userRole: currentUserRoleLabel(context, fallback: context.l10n.roleLabManager),
            searchPlaceholder: context.l10n.labReqSearchHint,
            onSearchChanged: (q) =>
                context.read<LabMaterialRequestsCubit>().setSearchQuery(q),
            body: _MaterialRequestsBody(state: state),
          );
        },
      ),
    );
  }
}

class _MaterialRequestsBody extends StatelessWidget {
  const _MaterialRequestsBody({required this.state});

  final LabMaterialRequestsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (state.status == LabMatRequestsStatus.loading && state.requests.isEmpty) {
      return const SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.spaceLG),
        child: Column(
          children: [
            AppShimmerCard(layout: AppShimmerCardLayout.basic),
            SizedBox(height: AppSizes.spaceMD),
            AppShimmerCard(layout: AppShimmerCardLayout.basic),
            SizedBox(height: AppSizes.spaceMD),
            AppShimmerCard(layout: AppShimmerCardLayout.basic),
          ],
        ),
      );
    }

    if (state.status == LabMatRequestsStatus.error && state.requests.isEmpty) {
      return _MatRequestsError(
        message: state.errorMessage ?? l10n.error,
        onRetry: () => context.read<LabMaterialRequestsCubit>().load(),
      );
    }

    final requests = state.filtered;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageActionBar(
            filter: AppFilterChipRow(
              options: [
                l10n.labOrdersFilterAll,
                l10n.statusNew,
                l10n.statusDelivered,
                l10n.labReqStatusUnavailable,
              ],
              selectedIndex: state.filterIndex,
              onChanged: (i) =>
                  context.read<LabMaterialRequestsCubit>().setFilter(i),
            ),
            actions: [
              AppButton.primary(
                label: '+ ${l10n.labReqNewRequest}',
                onPressed: () => _onNewInvoice(context),
                size: AppButtonSize.small,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceLG),
          if (requests.isEmpty)
            const LabMatRequestsEmpty()
          else
            for (final req in requests) ...[
              LabMatRequestCard(
                request: req,
                onTap: () => LabInvoiceDetailsDialog.show(
                  context,
                  req,
                  onPrint: () => LabInvoicePrinter.print(req),
                ),
                // الحذف مسموح فقط للفواتير "الجديدة" — الباك يرفض حذف أي فاتورة
                // بدأ تنفيذها (422)، فلا نعرض زر حذف يفشل دايماً.
                onDelete: req.status == MatRequestStatus.newRequest
                    ? () => _onDelete(context, req)
                    : null,
              ),
              const SizedBox(height: AppSizes.spaceMD),
            ],
        ],
      ),
    );
  }

  /// خطوة اختيار نوع الفاتورة ثم الفورم المناسب، وإرسالها عبر الـ Cubit.
  Future<void> _onNewInvoice(BuildContext context) async {
    final cubit = context.read<LabMaterialRequestsCubit>();
    final l10n = context.l10n;

    final type = await LabInvoiceTypeChooserDialog.show(context);
    if (type == null || !context.mounted) return;

    bool ok;
    if (type == LabInvoiceType.warehouse) {
      final r = await LabInvoiceFromWarehouseDialog.show(
        context,
        catalog: cubit.state.catalog,
        catalogError: cubit.state.catalogError,
        onRetryCatalog: cubit.loadCatalog,
      );
      if (r == null || !context.mounted) return;
      ok = await cubit.addRequestFromWarehouse(items: r.items, notes: r.notes);
    } else {
      final r = await LabInvoiceFromCompanyDialog.show(context);
      if (r == null || !context.mounted) return;
      ok = await cubit.addRequestFromCompany(
        companyName: r.companyName,
        items: r.items,
        notes: r.notes,
      );
    }

    if (!context.mounted) return;
    if (ok) {
      GlassToast.show(context, message: l10n.labReqSentSuccess, icon: Icons.check_circle_rounded);
    } else {
      GlassToast.show(context, message: cubit.state.errorMessage ?? l10n.error);
    }
  }

  /// تأكيد ثم حذف فاتورة عبر الـ Cubit.
  Future<void> _onDelete(BuildContext context, MatRequest req) async {
    final cubit = context.read<LabMaterialRequestsCubit>();
    final l10n = context.l10n;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.labReqDeleteTitle),
        content: Text(l10n.labReqDeleteConfirm(req.id)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await cubit.delete(req.id);
    if (!ok && context.mounted) {
      GlassToast.show(context, message: cubit.state.errorMessage ?? l10n.error);
    }
  }
}

class _MatRequestsError extends StatelessWidget {
  const _MatRequestsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 42),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
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
