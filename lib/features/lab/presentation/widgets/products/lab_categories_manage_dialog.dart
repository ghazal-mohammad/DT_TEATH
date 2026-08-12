// ════════════════════════════════════════════════════════════════════════════
// lab_categories_manage_dialog.dart
//
// مودال إدارة فئات أصناف المخبر (إضافة/تعديل/حذف) — موصول بالباك عبر
// LabProductsCubit (addItemCategory/updateItemCategory/deleteItemCategory).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/feedback/glass_toast.dart';
import '../../../domain/entities/lab_product.dart';
import '../../bloc/lab_products_cubit.dart';
import '../../bloc/lab_products_state.dart';

/// مودال إدارة فئات أصناف المخبر — يُمرَّر له نفس [LabProductsCubit] النشط
/// بالصفحة (bloc: صريح، لا context.watch) كي يعمل بأمان تحت showDialog.
class LabCategoriesManageDialog extends StatefulWidget {
  const LabCategoriesManageDialog({super.key, required this.cubit});

  final LabProductsCubit cubit;

  static Future<void> show(BuildContext context, LabProductsCubit cubit) {
    return showDialog<void>(
      context: context,
      builder: (_) => LabCategoriesManageDialog(cubit: cubit),
    );
  }

  @override
  State<LabCategoriesManageDialog> createState() =>
      _LabCategoriesManageDialogState();
}

class _LabCategoriesManageDialogState
    extends State<LabCategoriesManageDialog> {
  final TextEditingController _newName = TextEditingController();
  bool _adding = false;
  int? _editingId;
  final TextEditingController _editName = TextEditingController();

  @override
  void dispose() {
    _newName.dispose();
    _editName.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final name = _newName.text.trim();
    if (name.isEmpty) return;
    setState(() => _adding = true);
    final ok = await widget.cubit.addCategory(name);
    if (!mounted) return;
    setState(() => _adding = false);
    if (ok) {
      _newName.clear();
    } else {
      _showError();
    }
  }

  void _startEdit(LabProductCategory c) {
    setState(() {
      _editingId = c.id;
      _editName.text = c.name;
    });
  }

  Future<void> _confirmEdit(int id) async {
    final name = _editName.text.trim();
    if (name.isEmpty) return;
    final ok = await widget.cubit.renameCategory(id, name);
    if (!mounted) return;
    if (ok) {
      setState(() => _editingId = null);
    } else {
      _showError();
    }
  }

  Future<void> _delete(LabProductCategory c) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.labCategoryDeleteTitle),
        content: Text(l10n.labCategoryDeleteConfirm(c.name)),
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
    final ok = await widget.cubit.removeCategory(c.id);
    if (!mounted) return;
    if (!ok) _showError();
  }

  void _showError() {
    final msg = widget.cubit.state.errorMessage ?? context.l10n.error;
    GlassToast.show(context, message: msg);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 560),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
                child: Text(
                  l10n.labCategoriesManage,
                  style: AppTextStyles.headlineSmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newName,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: l10n.labCategoryNameHint,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusSM),
                          ),
                        ),
                        onSubmitted: (_) => _add(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _adding ? null : _add,
                      child: Text(l10n.labCategoryAdd),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              Flexible(
                child: BlocBuilder<LabProductsCubit, LabProductsState>(
                  bloc: widget.cubit,
                  builder: (context, state) {
                    if (state.categories.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.labCategoriesEmpty,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.lightText3),
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 10),
                      itemCount: state.categories.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, i) {
                        final c = state.categories[i];
                        final isEditing = _editingId == c.id;
                        return Row(
                          children: [
                            Expanded(
                              child: isEditing
                                  ? TextField(
                                      controller: _editName,
                                      autofocus: true,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              AppSizes.radiusSM),
                                        ),
                                      ),
                                      onSubmitted: (_) => _confirmEdit(c.id),
                                    )
                                  : Text(c.name,
                                      style: AppTextStyles.bodyMedium),
                            ),
                            if (isEditing)
                              IconButton(
                                icon: const Icon(Icons.check_rounded,
                                    size: 18, color: AppColors.statusSuccess),
                                onPressed: () => _confirmEdit(c.id),
                              )
                            else
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    size: 18),
                                onPressed: () => _startEdit(c),
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  size: 18, color: AppColors.statusUrgent),
                              onPressed: () => _delete(c),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.close),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
