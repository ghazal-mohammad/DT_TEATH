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
import '../../../../core/theme/app_sizes.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../data/lab_inventory_store.dart';
import '../../domain/entities/lab_order.dart';
import '../../domain/repositories/lab_orders_repository.dart';
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
    final choice = await LabOrderProcessDialog.show(context, order);
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
}
