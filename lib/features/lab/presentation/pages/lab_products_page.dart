// ════════════════════════════════════════════════════════════════════════════
// lab_products_page.dart  — إدارة منتجات المخبر (Lab Products Catalog)
//
// متطلب رئيس المخبر — "عرض وتعديل المنتجات التي يصنعها المخبر".
//   ملاحظة: لا توجد "حالة" للمنتج (قرار الفريق 2026-06-12) — الكتالوج ثابت.
//
// المعمارية (يطابق نظام المستودع): UI → LabProductsCubit → LabProductsRepository.
//   - الكيان في domain/entities/lab_product.dart
//   - العقد في domain/repositories/lab_products_repository.dart
//   - التنفيذ الحقيقي في data/repositories/remote_lab_products_repository.dart
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
import '../../../../shared/widgets/primitives/app_button.dart';
import '../../domain/entities/lab_product.dart';
import '../../domain/repositories/lab_products_repository.dart';
import '../bloc/lab_products_cubit.dart';
import '../bloc/lab_products_state.dart';
import '../navigation/lab_sidebar_sections.dart';
import '../widgets/products/lab_categories_manage_dialog.dart';
import '../widgets/products/lab_product_form_dialog.dart';
import '../widgets/products/lab_products_stats.dart';
import '../widgets/products/lab_products_table.dart';

/// صفحة منتجات المخبر — تُنشئ [LabProductsCubit] محلياً وتزوّده للـ subtree.
/// الـ repository يأتي من الـ DI (RemoteLabProductsRepository → الباك).
class LabProductsPage extends StatelessWidget {
  const LabProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          LabProductsCubit(repository: sl<LabProductsRepository>())..load(),
      child: Builder(
        builder: (context) {
          final l10n = context.l10n;
          return AppShellLayout(
            system: AppSystemType.lab,
            currentRoute: RouteNames.labProducts,
            sections: LabSidebarSections.build(context),
            pageTitle: l10n.labProducts,
            pageSubtitle: l10n.labTopbarSubtitle,
            searchPlaceholder: l10n.labProductsSearchHint,
            onSearchChanged: (v) =>
                context.read<LabProductsCubit>().setSearchQuery(v),
            userRole: currentUserRoleLabel(context, fallback: l10n.roleLabManager),
            body: BlocBuilder<LabProductsCubit, LabProductsState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.spaceLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LabProductsStatsRow(total: state.products.length),
                      const SizedBox(height: AppSizes.spaceLG),
                      AppPageActionBar(
                        filter: const SizedBox.shrink(),
                        actions: [
                          AppButton.secondary(
                            label: l10n.labCategoriesManage,
                            onPressed: () => LabCategoriesManageDialog.show(
                                context, context.read<LabProductsCubit>()),
                            size: AppButtonSize.small,
                          ),
                          const SizedBox(width: 8),
                          AppButton.primary(
                            label: '+ ${l10n.labProdAdd}',
                            onPressed: () => _onAdd(context),
                            size: AppButtonSize.small,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spaceMD),
                      LabProductsTable(
                        products: state.filtered,
                        onEdit: (p) => _onEdit(context, p),
                        onDelete: (p) => _onDelete(context, p),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _onAdd(BuildContext context) async {
    final cubit = context.read<LabProductsCubit>();
    final l10n = context.l10n;
    final result = await LabProductFormDialog.show(
      context,
      null,
      categories: cubit.state.categories,
    );
    if (result == null) return;
    final ok = await cubit.create(LabProduct(
      id: '',
      name: result.name,
      type: result.type,
      material: result.material,
      price: result.price,
      productionDays: result.productionDays,
      categoryId: result.categoryId,
    ));
    if (!ok && context.mounted) {
      GlassToast.show(context, message: cubit.state.errorMessage ?? l10n.error);
    }
  }

  Future<void> _onEdit(BuildContext context, LabProduct product) async {
    final cubit = context.read<LabProductsCubit>();
    final l10n = context.l10n;
    final result = await LabProductFormDialog.show(
      context,
      product,
      categories: cubit.state.categories,
    );
    if (result == null) return;
    final ok = await cubit.update(product.copyWith(
      name: result.name,
      type: result.type,
      material: result.material,
      price: result.price,
      productionDays: result.productionDays,
      categoryId: result.categoryId,
      clearCategory: result.categoryId == null,
    ));
    if (!ok && context.mounted) {
      GlassToast.show(context, message: cubit.state.errorMessage ?? l10n.error);
    }
  }

  Future<void> _onDelete(BuildContext context, LabProduct product) async {
    final cubit = context.read<LabProductsCubit>();
    final l10n = context.l10n;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.labProdDeleteTitle),
        content: Text(l10n.labProdDeleteConfirm(product.name)),
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
    if (confirmed != true) return;
    final ok = await cubit.delete(product.id);
    if (!ok && context.mounted) {
      GlassToast.show(context, message: cubit.state.errorMessage ?? l10n.error);
    }
  }
}
