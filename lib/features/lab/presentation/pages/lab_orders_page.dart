// ════════════════════════════════════════════════════════════════════════════
// lab_orders_page.dart  — Lab Orders (طلبات الأطباء)
//
// شبكة بطاقات طلبيات الأطباء بتصميم مطابق للصور المرجعية:
//   - شريط فلاتر علوي (الكل / عاجل / جديد / قيد التصنيع / جاهز) + عدّاد
//   - شبكة بطاقات مع شريط ملوّن على الحافة اليسرى
//   - مودالات: تفاصيل + معالجة
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/core/mock_user_data.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../data/mock/lab_dashboard_mock_data.dart';
import '../navigation/lab_sidebar_sections.dart';
import '../widgets/lab_order_details_dialog.dart';
import '../widgets/lab_order_models.dart';
import '../widgets/lab_order_process_dialog.dart';

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
      userName: MockUserData.labUserName,
      userRole: context.l10n.roleLabManager,
      notificationCount: 2,
      body: _LabOrdersBody(
        orders: _orders,
        filtered: _filtered,
        filter: _filter,
        onFilterChange: (v) => setState(() => _filter = v),
        onProcessSaved: (orderId, choice) {
          final idx = _orders.indexWhere((o) => o.id == orderId);
          if (idx == -1) return;
          setState(() {
            _orders[idx].statusVariant = choice == LabProcessChoice.delivered
                ? LabOrderBadgeVariant.ready
                : LabOrderBadgeVariant.newOrder;
          });
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
  final void Function(String orderId, LabProcessChoice choice) onProcessSaved;

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
          _FilterBar(
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
            const _EmptyOrders()
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
                        child: _OrderCard(
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

// ══════════════════════════════════════════════════════════════════════════
//  FILTER BAR — counter + 5 tabs
// ══════════════════════════════════════════════════════════════════════════

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.total,
    required this.shown,
    required this.urgentCount,
    required this.newCount,
    required this.mfgCount,
    required this.readyCount,
    required this.current,
    required this.onChange,
  });

  final int total;
  final int shown;
  final int urgentCount;
  final int newCount;
  final int mfgCount;
  final int readyCount;
  final String current;
  final ValueChanged<String> onChange;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Row(
      children: [
        Text(
          context.l10n.labOrdersCountOfTotal('$shown', '$total'),
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isLight ? AppColors.lightText3 : AppColors.darkText3,
          ),
        ),
        const Spacer(),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _Tab(
              label: context.l10n.labOrdersFilterAll,
              count: total,
              active: current == 'all',
              onTap: () => onChange('all'),
            ),
            _Tab(
              label: context.l10n.priorityUrgent,
              count: urgentCount,
              active: current == 'urgent',
              accent: const Color(0xFFEF4444),
              onTap: () => onChange('urgent'),
            ),
            _Tab(
              label: context.l10n.labOrdersFilterNew,
              count: newCount,
              active: current == 'new',
              onTap: () => onChange('new'),
            ),
            _Tab(
              label: context.l10n.labOrdersFilterManufacturing,
              count: mfgCount,
              active: current == 'manufacturing',
              onTap: () => onChange('manufacturing'),
            ),
            _Tab(
              label: context.l10n.labOrdersFilterReady,
              count: readyCount,
              active: current == 'ready',
              onTap: () => onChange('ready'),
            ),
          ],
        ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
    this.accent,
  });

  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final Color activeBg =
        accent ?? (isLight ? AppColors.primary : AppColors.brand);
    final Color idleText =
        accent ?? (isLight ? AppColors.lightText2 : AppColors.darkText2);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? activeBg
                : (isLight ? const Color(0xFFF6F7FB) : AppColors.darkBg2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : idleText,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$count',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: active
                      ? Colors.white
                      : (isLight ? AppColors.lightText3 : AppColors.darkText3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  ORDER CARD — مطابق للصورة
// ══════════════════════════════════════════════════════════════════════════

class _OrderCard extends StatefulWidget {
  const _OrderCard({
    required this.order,
    required this.onView,
    required this.onProcess,
  });

  final LabOrderFull order;
  final VoidCallback onView;
  final VoidCallback onProcess;

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final accent = labOrderAccentColor(
      statusVariant: o.statusVariant,
      isUrgent: o.isUrgent,
    );
    final initial =
        o.doctor.replaceAll('د. ', '').characters.firstOrNull ?? '';
    final radius = BorderRadius.circular(16);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : AppColors.darkBg1,
          borderRadius: radius,
          border: Border.all(
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hover ? 0.07 : 0.03),
              blurRadius: _hover ? 18 : 10,
              offset: Offset(0, _hover ? 8 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            children: [
              // الشريط الجانبي الملوّن (RTL = left visual)
              PositionedDirectional(
                end: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 5, color: accent),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(18, 14, 22, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Header: رقم (يمين) + نوع (يسار) ─────────────
                    // RTL: أوّل child = يمين، فالـ ID يمين والنوع يسار.
                    Row(
                      children: [
                        Text(
                          o.id,
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color:
                                isLight ? AppColors.primary : AppColors.darkText1,
                          ),
                        ),
                        const Spacer(),
                        _TypePill(label: o.type),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // ── الطبيب (avatar+اسم يمين) + شارة عاجل (يسار) ─
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isLight
                                ? const Color(0xFFE2EDFF)
                                : AppColors.darkChipBlueBg,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            initial,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isLight
                                  ? AppColors.primary
                                  : AppColors.darkChipBlueText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          o.doctor,
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color:
                                isLight ? AppColors.lightText1 : AppColors.darkText1,
                          ),
                        ),
                        const Spacer(),
                        if (o.isUrgent) const _UrgentPill(),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // ── صندوق المعلومات (المادة/السن/الموعد) ────────
                    _InfoBox(material: o.material, tooth: o.tooth, date: o.date),
                    const SizedBox(height: 14),
                    // ── Footer: حالة (يمين) + عرض/معالجة (يسار) ─────
                    // RTL convention: status badge يمين، الزر الأساسي (معالجة) يسار.
                    Row(
                      children: [
                        _StatusBadge(variant: o.statusVariant),
                        const Spacer(),
                        _ViewButton(onTap: widget.onView),
                        const SizedBox(width: 6),
                        _ProcessButton(onTap: widget.onProcess),
                      ],
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

// ── pieces ─────────────────────────────────────────────────────────────

class _TypePill extends StatelessWidget {
  const _TypePill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFF1F3F8) : AppColors.darkBg2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isLight ? AppColors.lightText2 : AppColors.darkText2,
        ),
      ),
    );
  }
}

class _UrgentPill extends StatelessWidget {
  const _UrgentPill();

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFFEE2E2) : AppColors.darkChipRedBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 13,
            color: isLight ? const Color(0xFFEF4444) : AppColors.darkChipRedText,
          ),
          const SizedBox(width: 4),
          Text(
            context.l10n.priorityUrgent,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color:
                  isLight ? const Color(0xFFEF4444) : AppColors.darkChipRedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.material,
    required this.tooth,
    required this.date,
  });

  final String material;
  final String tooth;
  final String date;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFF8F9FC) : AppColors.darkBg2,
        borderRadius: BorderRadius.circular(12),
      ),
      // RTL: أوّل child = يمين. الترتيب المطلوب (يمين→يسار):
      //   [المادة] | [السن] | [الموعد]
      child: Row(
        children: [
          Expanded(child: _cell(context.l10n.colMaterial, material, isLight)),
          _divider(isLight),
          Expanded(child: _cell(context.l10n.colTooth, tooth, isLight)),
          _divider(isLight),
          Expanded(child: _cell(context.l10n.colDate, date, isLight)),
        ],
      ),
    );
  }

  Widget _divider(bool isLight) => Container(
        width: 1,
        height: 28,
        color: isLight ? const Color(0xFFE5E7EE) : AppColors.darkBorder,
      );

  Widget _cell(String label, String value, bool isLight) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isLight ? AppColors.lightText3 : AppColors.darkText3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isLight ? AppColors.lightText1 : AppColors.darkText1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.variant});
  final LabOrderBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final c = LabStatusColors.of(variant);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      // RTL: نص يمين، dot يسار → [Text, SizedBox, dot].
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            labStatusLabel(context, variant),
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: c.fg,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: c.fg, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

class _ProcessButton extends StatelessWidget {
  const _ProcessButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isLight ? AppColors.primary : AppColors.brand,
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 5),
              Text(
                context.l10n.labOrderProcess,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewButton extends StatelessWidget {
  const _ViewButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : AppColors.darkBg1,
            border: Border.all(
                color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Text(
            context.l10n.actionView,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isLight ? AppColors.lightText1 : AppColors.darkText1,
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  EMPTY STATE
// ══════════════════════════════════════════════════════════════════════════

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 48,
            color: Color(0xFFB0B6C3),
          ),
          const SizedBox(height: AppSizes.spaceMD),
          Text(
            context.l10n.labNoOrdersInCategory,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isLight ? AppColors.lightText3 : AppColors.darkText3,
            ),
          ),
        ],
      ),
    );
  }
}
