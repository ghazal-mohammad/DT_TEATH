// ════════════════════════════════════════════════════════════════════════════
// lab_orders_page.dart  — Phase 5.2 ✅
//
// صفحة طلبات الأطباء — مطابقة للصورة المرجعية.
//
// الهيكل:
//   - AppPageActionBar: filter chips (الكل/جديد/قيد التصنيع/جاهز) + زر إضافة
//   - قائمة بطاقات (LabOrderCard) — كل بطاقة تعرض طلبية واحدة
//     محتوى البطاقة: الطبيب + الطلبية + التاريخ + المادة + النوع + الحالة
//
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — pg-lo
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/core/mock_user_data.dart';
import '../../../../shared/widgets/layout/app_page_action_bar.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../../../shared/widgets/primitives/app_badge.dart';
import '../../../../shared/widgets/primitives/app_button.dart';
import '../../../../shared/widgets/primitives/app_filter_chip.dart';
import '../../data/mock/lab_dashboard_mock_data.dart';
import '../navigation/lab_sidebar_sections.dart';

// ══════════════════════════════════════════════════════════════════════════
//  MOCK DATA — طلبيات كاملة لصفحة الطلبات
// ══════════════════════════════════════════════════════════════════════════

class _LabOrderFull {
  const _LabOrderFull({
    required this.id,
    required this.doctor,
    required this.patient,
    required this.type,
    required this.material,
    required this.date,
    required this.statusKey,
    required this.statusVariant,
    this.isUrgent = false,
    this.techName,
  });

  final String id;
  final String doctor;
  final String patient;
  final String type;
  final String material;
  final String date;
  final String statusKey;
  final LabOrderBadgeVariant statusVariant;
  final bool isUrgent;
  final String? techName;
}

const _kOrders = [
  _LabOrderFull(
    id: 'LAB-145',
    doctor: 'د. تجربة',
    patient: 'البشيرة',
    type: 'تلبيسة',
    material: 'PFM',
    date: '2026-03-27',
    statusKey: 'new',
    statusVariant: LabOrderBadgeVariant.newOrder,
  ),
  _LabOrderFull(
    id: 'LAB-143',
    doctor: 'د. أحمد',
    patient: 'م. ر.',
    type: 'جسر',
    material: 'Zircona',
    date: '2026-04-28',
    statusKey: 'manufacturing',
    statusVariant: LabOrderBadgeVariant.manufacturing,
    techName: 'فني 1',
  ),
  _LabOrderFull(
    id: 'LAB-143',
    doctor: 'د. أحمد',
    patient: 'ك. س.',
    type: 'تلبيسة',
    material: 'Metal',
    date: '2026-04-30',
    statusKey: 'new',
    statusVariant: LabOrderBadgeVariant.newOrder,
    isUrgent: true,
    techName: 'فني 3',
  ),
  _LabOrderFull(
    id: 'LAB-182',
    doctor: 'د. خالد',
    patient: 'م. ر.',
    type: 'تلبيسة',
    material: 'PFM',
    date: '2026-05-01',
    statusKey: 'new',
    statusVariant: LabOrderBadgeVariant.newOrder,
    isUrgent: true,
  ),
  _LabOrderFull(
    id: 'LAB-129',
    doctor: 'د. رنا',
    patient: 'أ. س.',
    type: 'طقم',
    material: 'Acrylic',
    date: '2026-05-02',
    statusKey: 'ready',
    statusVariant: LabOrderBadgeVariant.ready,
    techName: 'فني 2',
  ),
  _LabOrderFull(
    id: 'LAB-168',
    doctor: 'د. سارة',
    patient: 'ل. م.',
    type: 'جسر',
    material: 'Zirconia',
    date: '2026-05-03',
    statusKey: 'manufacturing',
    statusVariant: LabOrderBadgeVariant.manufacturing,
    techName: 'فني 1',
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
  int _filterIndex = 0; // 0=الكل 1=جديد 2=قيد التصنيع 3=جاهز

  List<_LabOrderFull> get _filtered {
    switch (_filterIndex) {
      case 1:
        return _kOrders
            .where((o) => o.statusVariant == LabOrderBadgeVariant.newOrder)
            .toList();
      case 2:
        return _kOrders
            .where(
                (o) => o.statusVariant == LabOrderBadgeVariant.manufacturing)
            .toList();
      case 3:
        return _kOrders
            .where((o) => o.statusVariant == LabOrderBadgeVariant.ready)
            .toList();
      default:
        return _kOrders;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppShellLayout(
      system: AppSystemType.lab,
      currentRoute: RouteNames.labOrders,
      sections: LabSidebarSections.buildWithBadges(
        context,
        newOrdersCount: 4,
        unreadNotifsCount: 2,
      ),
      pageTitle: l10n.doctorOrders,
      pageSubtitle: l10n.labTopbarSubtitle,
      userName: MockUserData.labUserName,
      userRole: l10n.roleLabManager,
      body: _LabOrdersBody(
        filterIndex: _filterIndex,
        onFilterChanged: (i) => setState(() => _filterIndex = i),
        orders: _filtered,
        l10n: l10n,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  BODY
// ══════════════════════════════════════════════════════════════════════════

class _LabOrdersBody extends StatelessWidget {
  const _LabOrdersBody({
    required this.filterIndex,
    required this.onFilterChanged,
    required this.orders,
    required this.l10n,
  });

  final int filterIndex;
  final ValueChanged<int> onFilterChanged;
  final List<_LabOrderFull> orders;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Filter Bar ───────────────────────────────────────────────
          AppPageActionBar(
            filter: AppFilterChipRow(
              options: [
                l10n.labOrdersFilterAll,
                l10n.labOrdersFilterNew,
                l10n.labOrdersFilterManufacturing,
                l10n.labOrdersFilterReady,
              ],
              selectedIndex: filterIndex,
              onChanged: onFilterChanged,
            ),
            actions: [
              AppButton.primary(
                label: '+ طلب جديد',
                onPressed: () {},
                size: AppButtonSize.small,
              ),
            ],
          ),

          // ── Cards List ───────────────────────────────────────────────
          if (orders.isEmpty)
            const _EmptyOrders()
          else
            for (final order in orders) ...[
              _LabOrderCard(order: order, l10n: l10n),
              const SizedBox(height: AppSizes.spaceMD),
            ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  ORDER CARD — مطابق للصورة
// ══════════════════════════════════════════════════════════════════════════

class _LabOrderCard extends StatefulWidget {
  const _LabOrderCard({required this.order, required this.l10n});
  final _LabOrderFull order;
  final AppLocalizations l10n;

  @override
  State<_LabOrderCard> createState() => _LabOrderCardState();
}

class _LabOrderCardState extends State<_LabOrderCard> {
  bool _hovered = false;

  // Map variant → badge
  static const _variantMap = {
    LabOrderBadgeVariant.newOrder: AppBadgeVariant.cyan,
    LabOrderBadgeVariant.manufacturing: AppBadgeVariant.gold,
    LabOrderBadgeVariant.ready: AppBadgeVariant.green,
    LabOrderBadgeVariant.urgent: AppBadgeVariant.redAnimated,
  };
  static const _textMap = {
    LabOrderBadgeVariant.newOrder: 'جديد',
    LabOrderBadgeVariant.manufacturing: 'قيد التصنيع',
    LabOrderBadgeVariant.ready: 'جاهز',
    LabOrderBadgeVariant.urgent: 'عاجل',
  };

  // Map variant → left accent color
  static const _accentMap = {
    LabOrderBadgeVariant.newOrder: AppColors.accent,
    LabOrderBadgeVariant.manufacturing: AppColors.warning,
    LabOrderBadgeVariant.ready: AppColors.success,
    LabOrderBadgeVariant.urgent: AppColors.error,
  };

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final badgeVariant = o.isUrgent
        ? AppBadgeVariant.redAnimated
        : (_variantMap[o.statusVariant] ?? AppBadgeVariant.cyan);
    final badgeText = o.isUrgent
        ? 'عاجل'
        : (_textMap[o.statusVariant] ?? '');
    final accentColor = o.isUrgent
        ? AppColors.error
        : (_accentMap[o.statusVariant] ?? AppColors.accent);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          border: Border(
            // حد ملون على الجانب الأيمن (RTL) حسب الحالة
            right: BorderSide(color: accentColor, width: 3),
            top: BorderSide(
              color: _hovered
                  ? (isLight ? AppColors.lightBorderHover : AppColors.darkBorderHover)
                  : (isLight ? AppColors.lightBorder : AppColors.darkBorder),
            ),
            bottom: BorderSide(
              color: _hovered
                  ? (isLight ? AppColors.lightBorderHover : AppColors.darkBorderHover)
                  : (isLight ? AppColors.lightBorder : AppColors.darkBorder),
            ),
            left: BorderSide(
              color: _hovered
                  ? (isLight ? AppColors.lightBorderHover : AppColors.darkBorderHover)
                  : (isLight ? AppColors.lightBorder : AppColors.darkBorder),
            ),
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row 1: الطبيب + الحالة + الطلبية ────────────────────
              Row(
                children: [
                  // Doctor chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusFull),
                      border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(AppIcons.profile,
                            size: 12,
                            color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Text(
                          o.doctor,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceSM),
                  // Status badge
                  AppBadge(text: badgeText, variant: badgeVariant),
                  const Spacer(),
                  // Order ID
                  Text(
                    o.id,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.spaceMD),
              const Divider(
                  height: 1, color: AppColors.darkBorder),
              const SizedBox(height: AppSizes.spaceMD),

              // ── Row 2: التفاصيل ──────────────────────────────────────
              Row(
                children: [
                  _infoCell(
                    context,
                    icon: AppIcons.calendar,
                    label: 'التاريخ',
                    value: o.date,
                  ),
                  const SizedBox(width: AppSizes.spaceXL),
                  _infoCell(
                    context,
                    icon: AppIcons.tooth,
                    label: 'النوع',
                    value: o.type,
                  ),
                  const SizedBox(width: AppSizes.spaceXL),
                  _infoCell(
                    context,
                    icon: AppIcons.box,
                    label: 'المادة',
                    value: o.material,
                  ),
                  if (o.techName != null) ...[
                    const SizedBox(width: AppSizes.spaceXL),
                    _infoCell(
                      context,
                      icon: AppIcons.technicians,
                      label: 'الفني',
                      value: o.techName!,
                      valueColor: AppColors.secondary,
                    ),
                  ],
                  const Spacer(),
                  // Actions
                  if (o.techName == null)
                    AppButton.secondary(
                      label: widget.l10n.labTeamAssign,
                      icon: AppIcons.technicians,
                      onPressed: () {},
                      size: AppButtonSize.small,
                    )
                  else
                    AppButton.secondary(
                      label: 'تفاصيل',
                      icon: AppIcons.eye,
                      onPressed: () {},
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

  Widget _infoCell(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon,
                size: 11,
                color: isLight
                    ? AppColors.lightText4
                    : AppColors.darkText4),
            const SizedBox(width: 3),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isLight ? AppColors.lightText4 : AppColors.darkText4,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ??
                (isLight ? AppColors.lightText1 : AppColors.darkText1),
          ),
        ),
      ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(AppIcons.emptyInbox,
              size: 48, color: AppColors.darkText4),
          const SizedBox(height: AppSizes.spaceMD),
          Text('لا توجد طلبيات في هذه الفئة',
              style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
