// ════════════════════════════════════════════════════════════════════════════
// warehouse_stock_log_page.dart
//
// سجل حركة المخزون (showStockLogs) بفلتر مادة اختياري — يعتمد على قائمة المواد
// من showAllStock (نفس النظرة العامة) لبناء خيارات الفلتر مع شارة "منخفض"
// الحقيقية المحسوبة بالباك. صفحة تُفتح بـ Navigator.push من صفحة المواد، بلا
// عنصر سايدبار خاص بها.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../../shared/widgets/forms/app_form_select.dart';
import '../../domain/entities/stock_overview.dart';
import '../../domain/repositories/warehouse_stock_repository.dart';
import '../bloc/stock_overview_cubit.dart';

class WarehouseStockLogPage extends StatelessWidget {
  const WarehouseStockLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          StockOverviewCubit(sl<WarehouseStockRepository>())..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.whStockLogTitle)),
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return BlocBuilder<StockOverviewCubit, StockOverviewState>(
      builder: (context, state) {
        if (state.status == StockOverviewStatus.loading ||
            state.status == StockOverviewStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == StockOverviewStatus.error) {
          return Center(
            child: AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: context.l10n.error,
              message: state.errorMessage ?? '',
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(AppSizes.spaceLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FilterRow(overview: state.overview, isLight: isLight),
              const SizedBox(height: AppSizes.spaceMD),
              Expanded(
                child: state.logs.isEmpty
                    ? AppEmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: context.l10n.whStockLogEmpty,
                        message: '',
                      )
                    : ListView.separated(
                        itemCount: state.logs.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, i) =>
                            _LogRow(log: state.logs[i], isLight: isLight),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.overview, required this.isLight});

  final List<StockOverviewItem> overview;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<StockOverviewCubit>();
    final current = context.watch<StockOverviewCubit>().state.logsFilterMaterialId;
    return SizedBox(
      width: 320,
      child: AppFormSelect<String?>(
        label: l10n.whStockLogFilterLabel,
        value: current,
        options: [
          AppSelectOption<String?>(value: null, label: l10n.whFilterAll),
          for (final item in overview)
            AppSelectOption<String?>(
              value: item.materialId,
              label: item.isLow ? '${item.name} · ${l10n.whStockLogLowBadge}' : item.name,
            ),
        ],
        onChanged: cubit.setLogsFilter,
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.log, required this.isLight});

  final StockLogEntry log;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isIn = log.type == StockLogType.stockIn;
    final typeColor = isIn ? AppColors.statusSuccess : AppColors.statusUrgent;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLight ? AppColors.baseComponent : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Icon(
            isIn ? Icons.south_west_rounded : Icons.north_east_rounded,
            size: 18,
            color: typeColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.materialName ?? '—',
                    style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isLight
                            ? AppColors.lightText1
                            : AppColors.darkText1)),
                if (log.reason != null || log.notes != null)
                  Text(
                    [
                      if (log.reason != null) _reasonLabel(l10n, log.reason!),
                      if (log.notes != null) log.notes!,
                    ].join(' · '),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.lightText3, fontSize: 11.5),
                  ),
              ],
            ),
          ),
          Text(
            '${isIn ? '+' : '-'}${log.quantity}',
            style: AppTextStyles.bodySmall
                .copyWith(fontWeight: FontWeight.w800, color: typeColor),
          ),
          if (log.doneBy != null) ...[
            const SizedBox(width: 10),
            Text(log.doneBy!,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.lightText3, fontSize: 11.5)),
          ],
        ],
      ),
    );
  }

  String _reasonLabel(AppLocalizations l10n, String apiReason) {
    switch (apiReason) {
      case 'purchase':
        return l10n.whStockReasonPurchase;
      case 'fulfillment':
        return l10n.whStockReasonFulfillment;
      case 'expired':
        return l10n.whStockReasonExpired;
      case 'adjustment':
        return l10n.whStockReasonAdjustment;
      case 'return':
        return l10n.whStockReasonReturn;
      default:
        return apiReason;
    }
  }
}
