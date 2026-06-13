// ════════════════════════════════════════════════════════════════════════════
// lab_orders_page.dart  — Lab Orders (طلبات الأطباء)
//
// شبكة بطاقات طلبيات الأطباء بتصميم مطابق للصور المرجعية:
//   - شريط فلاتر علوي (الكل / عاجل / جديد / قيد التصنيع / جاهز) + عدّاد
//   - شبكة بطاقات مع شريط ملوّن على الحافة اليسرى
//   - مودالات: تفاصيل + معالجة
//
// شريط الفلاتر والبطاقة والحالة الفارغة في widgets/orders/ (تقسيم الصفحات).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../data/lab_inventory_store.dart';
import '../../data/mock/lab_dashboard_mock_data.dart';
import '../navigation/lab_sidebar_sections.dart';
import '../widgets/lab_order_details_dialog.dart';
import '../widgets/lab_order_models.dart';
import '../widgets/lab_order_process_dialog.dart';
import '../widgets/orders/lab_order_card.dart';
import '../widgets/orders/lab_orders_empty_state.dart';
import '../widgets/orders/lab_orders_filter_bar.dart';

// ══════════════════════════════════════════════════════════════════════════
//  MOCK DATA — مطابق للصورة (6 طلبيات)
// ══════════════════════════════════════════════════════════════════════════

List<LabOrderFull> _seedOrders() => [
      LabOrderFull(
        id: 'LAB-045',
        doctor: 'د. سارة',
        type: 'تلبيسة',
        material: 'PFM',
        tooth: '#14',
        date: '27-03-2026',
        statusVariant: LabOrderBadgeVariant.newOrder,
        isUrgent: true,
        notes: 'سن مكسور — يلزم استعجال',
      ),
      LabOrderFull(
        id: 'LAB-044',
        doctor: 'د. خالد',
        type: 'جسر',
        material: 'Zirconia',
        tooth: '#14-12',
        date: '28-03-2026',
        statusVariant: LabOrderBadgeVariant.manufacturing,
      ),
      LabOrderFull(
        id: 'LAB-043',
        doctor: 'د. أحمد',
        type: 'تلبيسة',
        material: 'Metal',
        tooth: '#36',
        date: '30-03-2026',
        statusVariant: LabOrderBadgeVariant.ready,
      ),
      LabOrderFull(
        id: 'LAB-042',
        doctor: 'د. سارة',
        type: 'وجه',
        material: 'E-max',
        tooth: '#21',
        date: '27-03-2026',
        statusVariant: LabOrderBadgeVariant.manufacturing,
        isUrgent: true,
        notes: 'وجه أمامي — لون A2',
      ),
      LabOrderFull(
        id: 'LAB-041',
        doctor: 'د. ليلى',
        type: 'طقم',
        material: 'Acrylic',
        tooth: '#كامل',
        date: '02-04-2026',
        statusVariant: LabOrderBadgeVariant.newOrder,
      ),
      LabOrderFull(
        id: 'LAB-040',
        doctor: 'د. خالد',
        type: 'تلبيسة',
        material: 'Zirconia',
        tooth: '#26',
        date: '29-03-2026',
        statusVariant: LabOrderBadgeVariant.manufacturing,
      ),
    ];

// ══════════════════════════════════════════════════════════════════════════
//  PAGE
// ══════════════════════════════════════════════════════════════════════════

class LabOrdersPage extends StatefulWidget {
  const LabOrdersPage({super.key});

  @override
  State<LabOrdersPage> createState() => _LabOrdersPageState();
}

class _LabOrdersPageState extends State<LabOrdersPage> {
  late List<LabOrderFull> _orders;
  String _filter = 'all'; // all | urgent | new | manufacturing | ready

  @override
  void initState() {
    super.initState();
    _orders = _seedOrders();
  }

  List<LabOrderFull> get _filtered {
    switch (_filter) {
      case 'urgent':
        return _orders.where((o) => o.isUrgent).toList();
      case 'new':
        return _orders
            .where((o) => o.statusVariant == LabOrderBadgeVariant.newOrder)
            .toList();
      case 'manufacturing':
        return _orders
            .where((o) =>
                o.statusVariant == LabOrderBadgeVariant.manufacturing)
            .toList();
      case 'ready':
        return _orders
            .where((o) => o.statusVariant == LabOrderBadgeVariant.ready)
            .toList();
      default:
        return _orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShellLayout(
      system: AppSystemType.lab,
      currentRoute: RouteNames.labOrders,
      sections: LabSidebarSections.buildWithBadges(
        context,
        newOrdersCount: _orders
            .where((o) => o.statusVariant == LabOrderBadgeVariant.newOrder)
            .length,
        unreadNotifsCount: 2,
      ),
      pageTitle: context.l10n.doctorOrders,
      pageSubtitle: null,
      searchPlaceholder: context.l10n.labOrdersSearchHint,
      userRole: context.l10n.roleLabManager,
      notificationCount: 2,
      body: _LabOrdersBody(
        orders: _orders,
        filtered: _filtered,
        filter: _filter,
        onFilterChange: (v) => setState(() => _filter = v),
        onProcessSaved: (orderId, result) {
          final idx = _orders.indexWhere((o) => o.id == orderId);
          if (idx == -1) return;
          setState(() {
            final order = _orders[idx];
            order.statusVariant = result.status;
            if (result.cost != null) order.cost = result.cost;
            order.assignedTechnician = result.technician;
          });
          // إنجاز الطلب → إنقاص المواد المستهلكة من مخزون المخبر (UC75).
          if (result.consumption.isNotEmpty) {
            LabInventoryStore.instance.applyConsumption(result.consumption);
          }
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  BODY
// ══════════════════════════════════════════════════════════════════════════

class _LabOrdersBody extends StatelessWidget {
  const _LabOrdersBody({
    required this.orders,
    required this.filtered,
    required this.filter,
    required this.onFilterChange,
    required this.onProcessSaved,
  });

  final List<LabOrderFull> orders;
  final List<LabOrderFull> filtered;
  final String filter;
  final ValueChanged<String> onFilterChange;
  final void Function(String orderId, LabProcessResult result) onProcessSaved;

  int _count(bool Function(LabOrderFull) test) =>
      orders.where(test).length;

  @override
  Widget build(BuildContext context) {
    final urgentCount = _count((o) => o.isUrgent);
    final newCount =
        _count((o) => o.statusVariant == LabOrderBadgeVariant.newOrder);
    final mfgCount = _count(
        (o) => o.statusVariant == LabOrderBadgeVariant.manufacturing);
    final readyCount =
        _count((o) => o.statusVariant == LabOrderBadgeVariant.ready);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Filter bar ─────────────────────────────────────────────
          LabOrdersFilterBar(
            total: orders.length,
            shown: filtered.length,
            urgentCount: urgentCount,
            newCount: newCount,
            mfgCount: mfgCount,
            readyCount: readyCount,
            current: filter,
            onChange: onFilterChange,
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
                final double cardW =
                    (width - spacing * (cols - 1)) / cols;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final o in filtered)
                      SizedBox(
                        width: cardW,
                        child: LabOrderCard(
                          order: o,
                          onView: () =>
                              LabOrderDetailsDialog.show(context, o),
                          onProcess: () async {
                            final choice = await LabOrderProcessDialog.show(
                              context,
                              o,
                            );
                            if (choice != null) onProcessSaved(o.id, choice);
                          },
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
}
