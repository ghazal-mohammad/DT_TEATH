// ════════════════════════════════════════════════════════════════════════════
// lab_material_requests_page.dart  — طلبات المواد من المستودع (منظور المخبر)
//
// المخبر يرسل طلبات للمستودع عند نقص المواد.
//   - 4 filter chips (الكل / جديد / تم التسليم / غير متوفر)
//   - قائمة طلبات + زر "طلب مادة جديدة" → فورم
//
// المعمارية: UI → LabMaterialRequestsCubit → LabMaterialRequestsRepository.
//   - الكيان في domain/entities/lab_material_request.dart
//   - العقد + تنفيذ mock في domain/data — يُستبدل بـ Remote عند ربط الباك.
//
// المرجع: DT_Teeth_Technical_Decision_Guide_v5.md — القرار 30 (Reference Integrity)
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/feedback/glass_toast.dart';
import '../../../../shared/widgets/core/mock_user_data.dart';
import '../../../../shared/widgets/layout/app_page_action_bar.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../../../shared/widgets/primitives/app_button.dart';
import '../../../../shared/widgets/primitives/app_filter_chip.dart';
import '../../domain/entities/lab_material_request.dart';
import '../../domain/repositories/lab_material_requests_repository.dart';
import '../bloc/lab_material_requests_cubit.dart';
import '../bloc/lab_material_requests_state.dart';
import '../navigation/lab_sidebar_sections.dart';
import '../widgets/material_requests/lab_mat_request_card.dart';
import '../widgets/material_requests/lab_mat_request_dialog.dart';
import '../widgets/material_requests/lab_mat_requests_empty.dart';

/// صفحة طلبات المواد — تُنشئ [LabMaterialRequestsCubit] وتزوّده للـ subtree.
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
            userRole: context.l10n.roleLabManager,
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
    final requests = state.filtered;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Filter Bar + Action ────────────────────────────────────
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
                onPressed: () => _onNewRequest(context),
                size: AppButtonSize.small,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceLG),

          // ── Requests List ──────────────────────────────────────────
          if (requests.isEmpty)
            const LabMatRequestsEmpty()
          else
            for (final req in requests) ...[
              LabMatRequestCard(
                request: req,
                onDelete: () => _onDelete(context, req),
              ),
              const SizedBox(height: AppSizes.spaceMD),
            ],
        ],
      ),
    );
  }

  /// فتح فورم "طلب مادة جديدة" وإرساله عبر الـ Cubit.
  Future<void> _onNewRequest(BuildContext context) async {
    final cubit = context.read<LabMaterialRequestsCubit>();
    final successText = context.l10n.labReqSentSuccess;
    final r = await LabMaterialRequestDialog.show(
      context,
      catalog: cubit.state.catalog,
    );
    if (r == null) return;
    await cubit.addRequest(
      material: r.material,
      quantity: r.quantity,
      unit: r.unit,
      requestedBy: MockUserData.labUserName,
      materialId: r.materialId,
      company: r.company,
      reason: r.reason,
    );
    if (context.mounted) {
      GlassToast.show(
        context,
        message: successText,
        icon: Icons.check_circle_rounded,
      );
    }
  }

  /// تأكيد ثم حذف طلب مواد عبر الـ Cubit.
  Future<void> _onDelete(BuildContext context, MatRequest req) async {
    final cubit = context.read<LabMaterialRequestsCubit>();
    final l10n = context.l10n;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.labReqDeleteTitle),
        content: Text(l10n.labReqDeleteConfirm(req.material)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) cubit.delete(req.id);
  }
}
