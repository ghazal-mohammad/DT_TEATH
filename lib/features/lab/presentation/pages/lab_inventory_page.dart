// ════════════════════════════════════════════════════════════════════════════
// lab_inventory_page.dart  — مخزون المخبر (Lab Internal Inventory)
//
// المعمارية (يطابق بقية شاشات المخبر): UI → LabStockCubit → LabStockRepository.
//   - الكيان    : domain/entities/lab_stock.dart
//   - العقد     : domain/repositories/lab_stock_repository.dart
//   - Remote    : data/repositories/remote_lab_stock_repository.dart
//                 (GET showLabStock · POST addToStock/subtractFromStock)
//
// مطابقة الباك: مخزون المخبر بلا فئات/حدّ أدنى/سعر — لذلك الفلترة بالحالة
// (الكل/منخفض/نافد) لا بالفئة، والأعمدة: المادة/الكمية/الحالة/استهلاك.
// "تسجيل استهلاك" = subtractFromStock (UC75) ويُحدِّث القائمة من الباك.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/data/app_data_table.dart';
import '../../../../shared/widgets/feedback/glass_toast.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../../../shared/widgets/loading/app_shimmer_card.dart';
import '../../../../shared/widgets/loading/app_shimmer_table.dart';
import '../../../../shared/widgets/primitives/app_badge.dart';
import '../../../../shared/widgets/primitives/app_button.dart';
import '../../../../shared/widgets/primitives/app_filter_chip.dart';
import '../../domain/entities/lab_stock.dart';
import '../../domain/repositories/lab_stock_repository.dart';
import '../bloc/lab_stock_cubit.dart';
import '../bloc/lab_stock_state.dart';
import '../navigation/lab_sidebar_sections.dart';

// ══════════════════════════════════════════════════════════════════════════
//  PAGE — تُنشئ LabStockCubit محلياً وتزوّده للـ subtree.
// ══════════════════════════════════════════════════════════════════════════

class LabInventoryPage extends StatelessWidget {
  const LabInventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LabStockCubit(repository: sl<LabStockRepository>())..load(),
      child: Builder(
        builder: (context) {
          final l10n = context.l10n;
          return AppShellLayout(
            system: AppSystemType.lab,
            currentRoute: RouteNames.labInventory,
            sections: LabSidebarSections.build(context),
            pageTitle: l10n.labInventory,
            pageSubtitle: l10n.labTopbarSubtitle,
            searchPlaceholder: l10n.labInvSearchHint,
            onSearchChanged: (v) =>
                context.read<LabStockCubit>().setSearchQuery(v),
            userRole: l10n.roleLabManager,
            body: BlocBuilder<LabStockCubit, LabStockState>(
              builder: (context, state) => _buildBody(context, state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, LabStockState state) {
    if (state.isInitialLoading) return const _InventoryLoading();
    if (state.status == LabStockStatusPhase.error) {
      return _InventoryError(
        message: state.errorMessage ?? context.l10n.error,
        onRetry: () => context.read<LabStockCubit>().load(),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatsRow(total: state.total, low: state.lowCount, out: state.outCount),
          const SizedBox(height: AppSizes.spaceLG),
          _InventoryCard(
            filter: state.filter,
            onFilterChanged: (f) =>
                context.read<LabStockCubit>().setFilter(f),
            items: state.filtered,
            onConsume: (s) => _onConsume(context, s),
          ),
        ],
      ),
    );
  }

  Future<void> _onConsume(BuildContext context, LabStock stock) async {
    final cubit = context.read<LabStockCubit>();
    final amount = await _ConsumeDialog.show(context, stock);
    if (amount == null) return;
    final error = await cubit.subtractQuantity(stock.id, amount);
    if (error != null && context.mounted) {
      GlassToast.show(context, message: error);
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  LOADING / ERROR
// ══════════════════════════════════════════════════════════════════════════

class _InventoryLoading extends StatelessWidget {
  const _InventoryLoading();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                  child: AppShimmerCard(layout: AppShimmerCardLayout.statCard)),
              SizedBox(width: AppSizes.spaceMD),
              Expanded(
                  child: AppShimmerCard(layout: AppShimmerCardLayout.statCard)),
              SizedBox(width: AppSizes.spaceMD),
              Expanded(
                  child: AppShimmerCard(layout: AppShimmerCardLayout.statCard)),
            ],
          ),
          SizedBox(height: AppSizes.spaceLG),
          AppShimmerTable(
            columns: [
              AppShimmerTableColumn.wide,
              AppShimmerTableColumn.text,
              AppShimmerTableColumn.badge,
              AppShimmerTableColumn.actions,
            ],
            rowCount: 6,
          ),
        ],
      ),
    );
  }
}

class _InventoryError extends StatelessWidget {
  const _InventoryError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded,
              size: 42,
              color: isLight ? AppColors.lightText3 : AppColors.darkText3),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isLight ? AppColors.lightText2 : AppColors.darkText2,
            ),
          ),
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

// ══════════════════════════════════════════════════════════════════════════
//  STAT CARDS ROW
// ══════════════════════════════════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.total, required this.low, required this.out});

  final int total;
  final int low;
  final int out;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cards = [
      _StatCard(
        accent: AppColors.statusInfo,
        icon: Icons.inventory_2_outlined,
        value: '$total',
        label: l10n.labInvTotal,
      ),
      _StatCard(
        accent: AppColors.chipOrangeAccentLight,
        icon: Icons.trending_down_rounded,
        value: '$low',
        label: l10n.labInvLow,
      ),
      _StatCard(
        accent: AppColors.statusUrgent,
        icon: Icons.error_outline_rounded,
        value: '$out',
        label: l10n.labInvOut,
      ),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth > 800) {
          return Row(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSizes.spaceMD),
                Expanded(child: cards[i]),
              ],
            ],
          );
        }
        return Column(
          children: [
            for (final card in cards) ...[
              card,
              const SizedBox(height: AppSizes.spaceMD),
            ],
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.accent,
    required this.icon,
    required this.value,
    required this.label,
  });

  final Color accent;
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final radius = BorderRadius.circular(AppSizes.radiusLG);
    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.darkBg1,
        borderRadius: radius,
        border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            PositionedDirectional(
              end: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 4, color: accent),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 14, 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 20, color: accent),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                          color:
                              isLight ? AppColors.lightText1 : AppColors.darkText1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isLight
                              ? AppColors.lightText3
                              : AppColors.darkText3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  INVENTORY CARD (status filter chips + table)
// ══════════════════════════════════════════════════════════════════════════

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({
    required this.filter,
    required this.onFilterChanged,
    required this.items,
    required this.onConsume,
  });

  final LabStockFilter filter;
  final ValueChanged<LabStockFilter> onFilterChanged;
  final List<LabStock> items;
  final void Function(LabStock) onConsume;

  static const _filterOrder = [
    LabStockFilter.all,
    LabStockFilter.low,
    LabStockFilter.out,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.darkBg1,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spaceLG,
              AppSizes.spaceLG,
              AppSizes.spaceLG,
              AppSizes.spaceMD,
            ),
            child: Row(
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 20,
                    color: isLight ? AppColors.primary : AppColors.darkText1),
                const SizedBox(width: 8),
                Text(
                  l10n.labInventory,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: AppFilterChipRow(
                    options: [
                      l10n.labOrdersFilterAll,
                      l10n.labInvLow,
                      l10n.labInvOut,
                    ],
                    selectedIndex: _filterOrder.indexOf(filter),
                    onChanged: (i) => onFilterChanged(_filterOrder[i]),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spaceLG,
              0,
              AppSizes.spaceLG,
              AppSizes.spaceLG,
            ),
            child: AppDataTable<LabStock>(
              data: items,
              headerBackground:
                  isLight ? AppColors.tableHeader : AppColors.darkBg2,
              emptyMessage: l10n.labInvEmpty,
              emptyIcon: Icons.inventory_2_outlined,
              columns: [
                AppDataColumn<LabStock>(
                  label: l10n.colMaterial,
                  flex: 3,
                  cellBuilder: (s) => Text(
                    s.material,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color:
                          isLight ? AppColors.lightText1 : AppColors.darkText1,
                    ),
                  ),
                ),
                AppDataColumn<LabStock>(
                  label: l10n.whColStock,
                  flex: 2,
                  cellBuilder: (s) => Text(
                    '${_fmtQty(s.quantity)} ${s.unit}',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color:
                          isLight ? AppColors.lightText1 : AppColors.darkText1,
                    ),
                  ),
                ),
                AppDataColumn<LabStock>(
                  label: l10n.colStatus,
                  flex: 2,
                  cellBuilder: (s) => Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _statusBadge(context, s.status),
                  ),
                ),
                AppDataColumn<LabStock>(
                  label: '',
                  flex: 2,
                  cellBuilder: (s) => Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: AppButton.secondary(
                      label: l10n.labInvConsume,
                      icon: Icons.remove_circle_outline_rounded,
                      onPressed: s.quantity <= 0 ? null : () => onConsume(s),
                      size: AppButtonSize.small,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(BuildContext context, LabStockStatus s) {
    final l10n = context.l10n;
    switch (s) {
      case LabStockStatus.available:
        return AppBadge(
            text: l10n.whStatusAvailable, variant: AppBadgeVariant.green);
      case LabStockStatus.low:
        return AppBadge(text: l10n.whStatusLow, variant: AppBadgeVariant.gold);
      case LabStockStatus.out:
        return AppBadge(
            text: l10n.whStatusOut, variant: AppBadgeVariant.redAnimated);
    }
  }

  /// كمية بلا كسر زائد: 6.0 → "6"، 6.5 → "6.5".
  static String _fmtQty(double q) =>
      q == q.roundToDouble() ? q.toInt().toString() : q.toString();
}

// ══════════════════════════════════════════════════════════════════════════
//  CONSUME DIALOG — تسجيل استهلاك (subtractFromStock)
// ══════════════════════════════════════════════════════════════════════════

class _ConsumeDialog extends StatefulWidget {
  const _ConsumeDialog({required this.stock});
  final LabStock stock;

  static Future<double?> show(BuildContext context, LabStock stock) {
    return showDialog<double>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => _ConsumeDialog(stock: stock),
    );
  }

  @override
  State<_ConsumeDialog> createState() => _ConsumeDialogState();
}

class _ConsumeDialogState extends State<_ConsumeDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = context.l10n;
    final value = int.tryParse(_controller.text.trim());
    if (value == null || value <= 0) {
      setState(() => _error = l10n.labInvConsumeInvalid);
      return;
    }
    if (value > widget.stock.quantity) {
      setState(() => _error = l10n.labInvConsumeExceeds);
      return;
    }
    Navigator.of(context).pop(value.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final s = widget.stock;
    return Dialog(
      backgroundColor: isLight ? Colors.white : AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.labInvConsumeTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${s.material} — ${l10n.labInvCurrentQty}: '
                '${_InventoryCard._fmtQty(s.quantity)} ${s.unit}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isLight ? AppColors.lightText3 : AppColors.darkText3,
                ),
              ),
              const SizedBox(height: AppSizes.spaceLG),
              Text(
                l10n.labInvConsumeAmount,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofocus: true,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: l10n.labInvConsumeHint,
                  errorText: _error,
                  suffixText: s.unit,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceLG),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton.secondary(
                    label: l10n.cancel,
                    onPressed: () => Navigator.of(context).pop(),
                    size: AppButtonSize.small,
                  ),
                  const SizedBox(width: 10),
                  AppButton.primary(
                    label: l10n.save,
                    onPressed: _submit,
                    size: AppButtonSize.small,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
