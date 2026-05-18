// ════════════════════════════════════════════════════════════════════════════
// warehouse_materials_content.dart
//
// المحتوى الكامل لصفحة Materials — يجمع filter bar + grid + dialog launcher.
//
// 🎯 الهدف:
//   widget قائم بذاته يستهلك MaterialsCubit ويعرض الواجهة الكاملة.
//   جاهز للاستخدام داخل WarehouseMaterialsPage.
//
// 🔮 قابلية التوسيع:
//   - أضف filter جديد: case في MaterialFilter + يظهر تلقائياً في الـ bar
//   - أضف action جديد على card: تعديل في `_buildCardActions`
//   - أضف action جديد على page: ضيف زر في `_buildToolbar`
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../../../shared/widgets/layout/app_page_action_bar.dart';
import '../../../../../shared/widgets/loading/app_shimmer_card.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../../../shared/widgets/primitives/app_filter_chip_bar.dart';
import '../../../domain/entities/material_filter.dart';
import '../../../domain/entities/warehouse_material.dart';
import '../../bloc/materials_cubit.dart';
import '../../bloc/materials_state.dart';
import 'warehouse_material_card.dart';
import 'warehouse_material_form_dialog.dart';
import 'warehouse_material_grid.dart';

/// المحتوى الكامل لصفحة Materials.
///
/// يفترض وجود [MaterialsCubit] مزوّد في الشجرة (عبر BlocProvider).
class WarehouseMaterialsContent extends StatelessWidget {
  const WarehouseMaterialsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaterialsCubit, MaterialsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildToolbar(context, state),
            _buildBody(context, state),
          ],
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          TOOLBAR
  // ────────────────────────────────────────────────────────────────────────

  /// شريط الـ toolbar — filter chips + زر إضافة.
  Widget _buildToolbar(BuildContext context, MaterialsState state) {
    return AppPageActionBar(
      filter: AppFilterChipBar<MaterialFilter>(
        options: MaterialFilter.values,
        activeOption: state.activeFilter,
        labelBuilder: (f) => f.label(context),
        emojiBuilder: (f) => f.emoji,
        countBuilder: (f) => f == MaterialFilter.all
            ? state.materials.length
            : f.countIn(state.materials),
        onChanged: context.read<MaterialsCubit>().setFilter,
      ),
      actions: [
        AppButton(
          label: '+ ${context.l10n.whMaterialsAdd}',
          onPressed: () => _onAddTap(context),
          variant: AppButtonVariant.primary,
          size: AppButtonSize.small,
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          BODY (states)
  // ────────────────────────────────────────────────────────────────────────

  /// الـ body — يعرض loading / error / empty / grid حسب state.
  Widget _buildBody(BuildContext context, MaterialsState state) {
    // الـ loading الأولي
    if (state.isInitialLoading) {
      return _buildLoadingState();
    }

    // خطأ
    if (state.status == MaterialsStatus.error && state.materials.isEmpty) {
      return _buildErrorState(context, state.errorMessage ?? '');
    }

    // فاضي بعد فلترة
    if (state.isEmpty) {
      return _buildEmptyState(context, state);
    }

    // الشبكة
    return WarehouseMaterialGrid(
      materials: state.filteredMaterials,
      onCardTap: (m) => _onCardTap(context, m),
      actionsBuilder: (m) => _buildCardActions(context, m),
    );
  }

  /// shimmer loading.
  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        mainAxisSpacing: 11,
        crossAxisSpacing: 11,
        childAspectRatio: 0.95,
        children: List.generate(8, (_) => const AppShimmerCard()),
      ),
    );
  }

  /// رسالة خطأ مع زر retry.
  Widget _buildErrorState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: AppEmptyState(
        icon: Icons.error_outline,
        title: context.l10n.error,
        message: message,
        actionLabel: context.l10n.retry,
        onActionTap: () => context.read<MaterialsCubit>().load(),
      ),
    );
  }

  /// فاضي.
  Widget _buildEmptyState(BuildContext context, MaterialsState state) {
    final hasSearch = state.searchQuery.isNotEmpty;
    final hasFilter = state.activeFilter != MaterialFilter.all;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: AppEmptyState(
        icon: Icons.inventory_2_outlined,
        title: hasSearch || hasFilter
            ? context.l10n.actionClearFilters
            : context.l10n.whMaterialsTitle,
        message: hasSearch || hasFilter
            ? context.l10n.actionClearFilters
            : context.l10n.comingSoonSubtitle,
        actionLabel: hasFilter
            ? context.l10n.actionClearFilters
            : context.l10n.whMaterialsAdd,
        onActionTap: hasFilter
            ? context.read<MaterialsCubit>().clearFilters
            : () => _onAddTap(context),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          ACTIONS
  // ────────────────────────────────────────────────────────────────────────

  /// actions كل بطاقة — قابلة للتخصيص بسهولة.
  List<MaterialCardAction> _buildCardActions(
    BuildContext context,
    WarehouseMaterial m,
  ) {
    return [
      MaterialCardAction(
        label: context.l10n.edit,
        onTap: () => _onCardTap(context, m),
      ),
      MaterialCardAction(
        label: context.l10n.delete,
        onTap: () => _onDeleteTap(context, m),
      ),
    ];
  }

  /// فتح dialog إضافة مادة جديدة.
  Future<void> _onAddTap(BuildContext context) async {
    final cubit = context.read<MaterialsCubit>();
    final result = await WarehouseMaterialFormDialog.show(context);
    if (result != null) {
      await cubit.create(result);
    }
  }

  /// فتح dialog تعديل مادة.
  Future<void> _onCardTap(
    BuildContext context,
    WarehouseMaterial m,
  ) async {
    final cubit = context.read<MaterialsCubit>();
    final result = await WarehouseMaterialFormDialog.show(
      context,
      initialMaterial: m,
    );
    if (result != null) {
      await cubit.update(result);
    }
  }

  /// تأكيد الحذف ثم تنفيذ.
  Future<void> _onDeleteTap(
    BuildContext context,
    WarehouseMaterial m,
  ) async {
    final cubit = context.read<MaterialsCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.baseComponent
            : AppColors.modalDarkStart,
        title: Text(context.l10n.delete),
        content: Text(
          '${context.l10n.delete}: ${m.name}؟',
          style: const TextStyle(fontFamily: AppTextStyles.fontFamily),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              context.l10n.delete,
              style: const TextStyle(color: AppColors.alertRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await cubit.delete(m.id);
    }
  }
}
