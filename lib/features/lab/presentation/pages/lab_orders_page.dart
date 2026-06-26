// ════════════════════════════════════════════════════════════════════════════
// lab_orders_page.dart  — Lab Orders (طلبات الأطباء)
//
// شبكة بطاقات طلبيات الأطباء (فلاتر + بطاقات + مودالات تفاصيل/معالجة).
//
// المعمارية (يطابق نظام المستودع): UI → LabOrdersCubit → LabOrdersRepository.
//   - الكيان في domain/entities/lab_order.dart
//   - العقد في domain/repositories/lab_orders_repository.dart
//   - تنفيذ mock في data/repositories/mock_lab_orders_repository.dart
//   - عند ربط الباك: نستبدل Mock بـ Remote دون لمس الـ UI.
//
// شريط الفلاتر والبطاقة والحالة الفارغة في widgets/orders/.
// ملاحظة: استهلاك المخزون عند المعالجة يبقى side-effect هنا (LabInventoryStore).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../../../shared/widgets/loading/app_shimmer_card.dart';
import '../../data/lab_inventory_store.dart';
import '../../domain/entities/lab_order.dart';
import '../../domain/repositories/lab_orders_repository.dart';
import '../../domain/repositories/lab_repository.dart';
import '../bloc/lab_orders_cubit.dart';
import '../bloc/lab_orders_state.dart';
import '../navigation/lab_sidebar_sections.dart';
import '../widgets/lab_order_details_dialog.dart';
import '../widgets/lab_order_process_dialog.dart';
import '../widgets/orders/lab_order_card.dart';
import '../widgets/orders/lab_orders_empty_state.dart';
import '../widgets/orders/lab_orders_filter_bar.dart';

/// صفحة طلبات الأطباء — تُنشئ [LabOrdersCubit] محلياً وتزوّده للـ subtree.
class LabOrdersPage extends StatelessWidget {
  const LabOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          LabOrdersCubit(repository: sl<LabOrdersRepository>())..load(),
      child: BlocBuilder<LabOrdersCubit, LabOrdersState>(
        builder: (context, state) {
          return AppShellLayout(
            system: AppSystemType.lab,
            currentRoute: RouteNames.labOrders,
            sections: LabSidebarSections.buildWithBadges(
              context,
              newOrdersCount: state.newCount,
              unreadNotifsCount: 2,
            ),
            pageTitle: context.l10n.doctorOrders,
            pageSubtitle: null,
            searchPlaceholder: context.l10n.labOrdersSearchHint,
            userRole: context.l10n.roleLabManager,
            notificationCount: 2,
            body: _OrdersBody(state: state),
          );
        },
      ),
    );
  }
}

class _OrdersBody extends StatelessWidget {
  const _OrdersBody({required this.state});

  final LabOrdersState state;

  @override
  Widget build(BuildContext context) {
    // أثناء التحميل الأولي نعرض هيكلاً عظمياً بدل وميض "لا توجد طلبات".
    if (state.status == LabOrdersStatus.loading && state.orders.isEmpty) {
      return const _OrdersLoading();
    }
    if (state.status == LabOrdersStatus.error && state.orders.isEmpty) {
      return _OrdersError(
        message: state.errorMessage ?? context.l10n.error,
        onRetry: () => context.read<LabOrdersCubit>().load(),
      );
    }
    final filtered = state.filtered;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Filter bar ─────────────────────────────────────────────
          LabOrdersFilterBar(
            total: state.total,
            shown: filtered.length,
            urgentCount: state.urgentCount,
            newCount: state.newCount,
            mfgCount: state.mfgCount,
            readyCount: state.readyCount,
            current: state.filter,
            onChange: (v) => context.read<LabOrdersCubit>().setFilter(v),
          ),
          const SizedBox(height: AppSizes.spaceLG),
          // ── Grid ───────────────────────────────────────────────────
          if (filtered.isEmpty)
            const LabOrdersEmptyState()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final int cols = width > 1200
                    ? 3
                    : width > 760
                        ? 2
                        : 1;
                const double spacing = 16;
                final double cardW = (width - spacing * (cols - 1)) / cols;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final o in filtered)
                      SizedBox(
                        width: cardW,
                        child: LabOrderCard(
                          order: o,
                          onView: () => LabOrderDetailsDialog.show(context, o),
                          onProcess: () => _process(context, o),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _process(BuildContext context, LabOrderFull order) async {
    final cubit = context.read<LabOrdersCubit>();
    // نجلب الفنّيين الحقيقيين لقائمة التعيين، وإلا يفشل التعيين بـ"الفنّي غير موجود".
    final names = await _technicianNames();
    if (!context.mounted) return;
    final choice = await LabOrderProcessDialog.show(
      context,
      order,
      technicianNames: names,
    );
    if (choice == null) return;
    // تحديث الطلب عبر الـ Cubit/Repository.
    await cubit.processOrder(
      id: order.id,
      status: choice.status,
      cost: choice.cost,
      technician: choice.technician,
    );
    // إنجاز الطلب → إنقاص المواد المستهلكة من مخزون المخبر (UC75) — side-effect.
    if (choice.consumption.isNotEmpty) {
      LabInventoryStore.instance.applyConsumption(choice.consumption);
    }
  }

  /// أسماء الفنّيين الحقيقيين من الباك (قائمة فارغة عند الفشل — المودال يعمل بلا تعيين).
  Future<List<String>> _technicianNames() async {
    try {
      final techs = await sl<LabRepository>().getTechnicians();
      return techs.map((t) => t.name).toList();
    } catch (_) {
      return const [];
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  LOADING / ERROR
// ══════════════════════════════════════════════════════════════════════════

class _OrdersLoading extends StatelessWidget {
  const _OrdersLoading();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: LayoutBuilder(
        builder: (context, c) {
          final width = c.maxWidth;
          final int cols = width > 1200 ? 3 : (width > 760 ? 2 : 1);
          const double spacing = 16;
          final double cardW = (width - spacing * (cols - 1)) / cols;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (int i = 0; i < 6; i++)
                SizedBox(width: cardW, child: const AppShimmerCard()),
            ],
          );
        },
      ),
    );
  }
}

class _OrdersError extends StatelessWidget {
  const _OrdersError({required this.message, required this.onRetry});

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
