// ════════════════════════════════════════════════════════════════════════════
// lab_dashboard_page.dart  — Phase 5.1 ✅
//
// صفحة لوحة التحكم الكاملة لنظام المخبر.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/core/mock_user_data.dart';
import '../../../../shared/widgets/data/app_data_table.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../data/mock/lab_dashboard_mock_data.dart';
import '../navigation/lab_sidebar_sections.dart';

// ══════════════════════════════════════════════════════════════════════════

class LabDashboardPage extends StatelessWidget {
  const LabDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppShellLayout(
      system: AppSystemType.lab,
      currentRoute: RouteNames.labDashboard,
      sections: LabSidebarSections.buildWithBadges(
        context,
        newOrdersCount: LabDashboardMockData.newOrdersCount,
        unreadNotifsCount: 2,
      ),
      pageTitle: l10n.labDashboardTitle,
      pageSubtitle: null,
      searchPlaceholder: 'فلترة طلبات هذه الصفحة... (رقم، طبيب، مادة)',
      showThemeToggle: false,
      userName: MockUserData.labUserName,
      userRole: l10n.roleLabManager,
      notificationCount: 2,
      body: const _LabDashboardBody(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  BODY
// ══════════════════════════════════════════════════════════════════════════

class _LabDashboardBody extends StatelessWidget {
  const _LabDashboardBody();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, outerConstraints) {
        return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: outerConstraints.maxWidth,
          maxWidth: outerConstraints.maxWidth,
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. Greeting bar ─────────────────────────────────────────
          const _DashboardGreeting(),
          const SizedBox(height: AppSizes.spaceLG),

          // ── 2. Stat Cards ────────────────────────────────────────────
          const _StatCardsRow(),
          const SizedBox(height: AppSizes.spaceLG),

          // ── 3. Ending Today Alert ────────────────────────────────────
          const _EndingTodayAlert(),
          const SizedBox(height: AppSizes.spaceLG),

          // ── 4. Orders Table ──────────────────────────────────────────
          const _OrdersTableSection(),
        ],
      ),
      ),
    );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  STAT CARDS ROW
// ══════════════════════════════════════════════════════════════════════════

class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow();

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      const _DashboardStatCard(
        chipLabel: 'عاجل',
        chipColor: Color(0xFFEF4444),
        accentColor: Color(0xFFEF4444),
        icon: Icons.local_fire_department_rounded,
        value: '2',
        label: 'تنتهي اليوم',
        trendIcon: Icons.arrow_downward_rounded,
        trendText: 'يحتاج متابعة',
        trendColor: Color(0xFFEF4444),
      ),
      const _DashboardStatCard(
        chipLabel: 'هذا الشهر',
        chipColor: Color(0xFF10B981),
        accentColor: Color(0xFF10B981),
        icon: Icons.check_circle_rounded,
        value: '23',
        label: 'طلبات جاهزة',
        trendIcon: Icons.arrow_upward_rounded,
        trendText: '+18% من الشهر الماضي',
        trendColor: Color(0xFF10B981),
      ),
      const _DashboardStatCard(
        chipLabel: 'نشط',
        chipColor: Color(0xFF8B5CF6),
        accentColor: Color(0xFF8B5CF6),
        icon: Icons.adjust_rounded,
        value: '7',
        label: 'قيد التصنيع',
        trendIcon: Icons.arrow_upward_rounded,
        trendText: '+1 من أمس',
        trendColor: Color(0xFF8B5CF6),
      ),
      const _DashboardStatCard(
        chipLabel: 'جديد',
        chipColor: Color(0xFF3B82F6),
        accentColor: Color(0xFF3B82F6),
        icon: Icons.add_rounded,
        value: '4',
        label: 'طلبات جديدة',
        trendIcon: Icons.arrow_upward_rounded,
        trendText: '+2 من أمس',
        trendColor: Color(0xFF3B82F6),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        if (isWide) {
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
            Row(children: [
              Expanded(child: cards[0]),
              const SizedBox(width: AppSizes.spaceMD),
              Expanded(child: cards[1]),
            ]),
            const SizedBox(height: AppSizes.spaceMD),
            Row(children: [
              Expanded(child: cards[2]),
              const SizedBox(width: AppSizes.spaceMD),
              Expanded(child: cards[3]),
            ]),
          ],
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  DASHBOARD STAT CARD — مطابق تماماً لتصميم الصورة
// ══════════════════════════════════════════════════════════════════════════

class _DashboardStatCard extends StatefulWidget {
  const _DashboardStatCard({
    required this.chipLabel,
    required this.chipColor,
    required this.accentColor,
    required this.icon,
    required this.value,
    required this.label,
    required this.trendIcon,
    required this.trendText,
    required this.trendColor,
  });

  final String chipLabel;
  final Color chipColor;
  final Color accentColor;
  final IconData icon;
  final String value;
  final String label;
  final IconData trendIcon;
  final String trendText;
  final Color trendColor;

  @override
  State<_DashboardStatCard> createState() => _DashboardStatCardState();
}

class _DashboardStatCardState extends State<_DashboardStatCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSizes.radiusLG);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hover ? 0.07 : 0.03),
              blurRadius: _hover ? 18 : 12,
              offset: Offset(0, _hover ? 8 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            children: [
              // الشريط الجانبي الملوّن — مدمج مع الحافة اليسرى البصرية
              // (في RTL: end = اليسار البصري)
              PositionedDirectional(
                end: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 5, color: widget.accentColor),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(18, 14, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // chip (يمين البطاقة في RTL)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: widget.chipColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.chipLabel,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: widget.chipColor,
                            ),
                          ),
                        ),
                        // icon (يسار البطاقة في RTL)
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: widget.accentColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            widget.icon,
                            size: 18,
                            color: widget.accentColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.value,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                        color: AppColors.lightText1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.lightText3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.trendIcon, size: 12, color: widget.trendColor),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            widget.trendText,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: widget.trendColor,
                            ),
                            overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  ENDING TODAY ALERT
// ══════════════════════════════════════════════════════════════════════════

class _EndingTodayAlert extends StatelessWidget {
  const _EndingTodayAlert();

  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          // أيقونة دائرية
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              size: 20,
              color: accent,
            ),
          ),
          // العنوان + الرسالة
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ينتهي اليوم',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '2',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'يجب إنهاء هذه الطلبات قبل المساء',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.lightText3,
                ),
              ),
            ],
          ),
          // pills للطلبيات
          ..._buildOrderPills(),
        ],
      ),
    );
  }

  List<Widget> _buildOrderPills() {
    const items = [
      _PillData(time: '14:00', body: 'تلبيسة PFM — د. سارة'),
      _PillData(time: '16:00', body: 'جسر 3 وحدات — د. خالد'),
    ];
    return items
        .map(
          (p) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  p.time,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.lightText1,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '•',
                  style: TextStyle(color: Color(0xFFF59E0B)),
                ),
                const SizedBox(width: 6),
                Text(
                  p.body,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.lightText2,
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}

class _PillData {
  const _PillData({required this.time, required this.body});
  final String time;
  final String body;
}

// ══════════════════════════════════════════════════════════════════════════
//  ORDERS TABLE SECTION
// ══════════════════════════════════════════════════════════════════════════

class _OrdersTableSection extends StatefulWidget {
  const _OrdersTableSection();

  @override
  State<_OrdersTableSection> createState() => _OrdersTableSectionState();
}

class _OrdersTableSectionState extends State<_OrdersTableSection> {
  String _activeFilter = 'all';

  List<LabOrderItem> get _filtered {
    final all = LabDashboardMockData.todayOrders;
    switch (_activeFilter) {
      case 'new':
        return all
            .where((o) => o.statusVariant == LabOrderBadgeVariant.newOrder)
            .toList();
      case 'manufacturing':
        return all
            .where(
              (o) => o.statusVariant == LabOrderBadgeVariant.manufacturing,
            )
            .toList();
      case 'ready':
        return all
            .where((o) => o.statusVariant == LabOrderBadgeVariant.ready)
            .toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = LabDashboardMockData.todayOrders;
    final counts = {
      'new': all
          .where((o) => o.statusVariant == LabOrderBadgeVariant.newOrder)
          .length,
      'manufacturing': all
          .where((o) => o.statusVariant == LabOrderBadgeVariant.manufacturing)
          .length,
      'ready': all
          .where((o) => o.statusVariant == LabOrderBadgeVariant.ready)
          .length,
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spaceLG,
              AppSizes.spaceLG,
              AppSizes.spaceLG,
              AppSizes.spaceMD,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.assignment_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'طلبات اليوم',
                  style: AppTextStyles.headlineSmall,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1DAFE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${all.length} طلب',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                // tabs
                _Tab(
                  label: 'الكل',
                  count: all.length,
                  isActive: _activeFilter == 'all',
                  onTap: () => setState(() => _activeFilter = 'all'),
                ),
                const SizedBox(width: 6),
                _Tab(
                  label: 'جديد',
                  count: counts['new']!,
                  isActive: _activeFilter == 'new',
                  onTap: () => setState(() => _activeFilter = 'new'),
                ),
                const SizedBox(width: 6),
                _Tab(
                  label: 'قيد التصنيع',
                  count: counts['manufacturing']!,
                  isActive: _activeFilter == 'manufacturing',
                  onTap: () =>
                      setState(() => _activeFilter = 'manufacturing'),
                ),
                const SizedBox(width: 6),
                _Tab(
                  label: 'جاهز',
                  count: counts['ready']!,
                  isActive: _activeFilter == 'ready',
                  onTap: () => setState(() => _activeFilter = 'ready'),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => context.go(RouteNames.labOrders),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      '← عرض الكل',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table
          AppDataTable<LabOrderItem>(
            data: _filtered,
            headerBackground: const Color(0xFFE2EDFF),
            columns: [
              AppDataColumn<LabOrderItem>(
                label: 'رقم الطلب',
                flex: 2,
                cellBuilder: (item) => Text(
                  item.orderId,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.lightText1,
                  ),
                ),
              ),
              AppDataColumn<LabOrderItem>(
                label: 'الطبيب',
                flex: 2,
                cellBuilder: (item) => _doctorCell(item.doctorName),
              ),
              AppDataColumn<LabOrderItem>(
                label: 'النوع',
                flex: 2,
                cellBuilder: (item) =>
                    Text(item.type, style: AppTextStyles.bodyMedium),
              ),
              AppDataColumn<LabOrderItem>(
                label: 'المادة',
                flex: 2,
                cellBuilder: (item) => Text(
                  item.material.isEmpty ? '—' : item.material,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              AppDataColumn<LabOrderItem>(
                label: 'السن',
                flex: 2,
                cellBuilder: (item) => Text(
                  item.tooth.isEmpty ? '—' : item.tooth,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              AppDataColumn<LabOrderItem>(
                label: 'الموعد',
                flex: 2,
                cellBuilder: (item) =>
                    Text(item.dueDate, style: AppTextStyles.bodySmall),
              ),
              AppDataColumn<LabOrderItem>(
                label: 'الأولوية',
                flex: 2,
                cellBuilder: (item) => _priorityCell(item.priority),
              ),
              AppDataColumn<LabOrderItem>(
                label: 'الحالة',
                flex: 2,
                cellBuilder: _statusBadge,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _doctorCell(String name) {
    // name مثل "د. سارة س" → نعرضو كامل، الـ avatar يستخدم آخر جزء (س)
    final parts =
        name.split(' ').where((p) => p.isNotEmpty).toList(growable: false);
    final String displayName = parts.join(' ');
    final String lastSegment = parts.isNotEmpty ? parts.last : name;
    final String initial =
        lastSegment.isNotEmpty ? lastSegment.characters.first : '';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFFE2EDFF),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            displayName,
            style: AppTextStyles.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _priorityCell(LabOrderPriority priority) {
    final ({Color color, String label, int bars}) data = switch (priority) {
      LabOrderPriority.urgent =>
        (color: const Color(0xFFEF4444), label: 'عاجل', bars: 3),
      LabOrderPriority.medium =>
        (color: const Color(0xFF3B82F6), label: 'متوسطة', bars: 2),
      LabOrderPriority.normal =>
        (color: AppColors.lightText4, label: 'عادية', bars: 1),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(width: 2),
          Container(
            width: 3,
            height: 10 + i * 2.0,
            decoration: BoxDecoration(
              color: i < data.bars
                  ? data.color
                  : data.color.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
        const SizedBox(width: 6),
        Text(
          data.label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: data.color,
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(LabOrderItem item) {
    final ({Color bg, Color text, String label}) data =
        switch (item.statusVariant) {
      LabOrderBadgeVariant.newOrder => (
          bg: const Color(0xFFE2EDFF),
          text: const Color(0xFF3B82F6),
          label: 'جديد',
        ),
      LabOrderBadgeVariant.manufacturing => (
          bg: const Color(0xFFF1DAFE),
          text: const Color(0xFF8B5CF6),
          label: 'قيد التصنيع',
        ),
      LabOrderBadgeVariant.ready => (
          bg: const Color(0xFFD0FBD7),
          text: const Color(0xFF10B981),
          label: 'جاهز',
        ),
      LabOrderBadgeVariant.urgent => (
          bg: const Color(0xFFFEE2E2),
          text: const Color(0xFFEF4444),
          label: 'عاجل',
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: data.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: data.text,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            data.label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: data.text,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  TAB CHIP
// ══════════════════════════════════════════════════════════════════════════

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
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
                  color: isActive ? Colors.white : AppColors.lightText2,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$count',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isActive
                      ? Colors.white
                      : AppColors.lightText3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// قسم الفريق محذوف بالكامل من التصميم الموحّد — تم نقل المعلومات
// إلى صفحة "إدارة المخبريين" المستقلة.

// ══════════════════════════════════════════════════════════════════════════
//  DASHBOARD GREETING — "مرحباً، د. رامي" + 3 mini stats
// ══════════════════════════════════════════════════════════════════════════

class _DashboardGreeting extends StatelessWidget {
  const _DashboardGreeting();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth > 760;
          final greetingPart = _GreetingText();
          final statsPart = _MiniStatsRow();
          if (wide) {
            return Row(
              children: [
                // RTL start (right visual)
                Flexible(child: greetingPart),
                const SizedBox(width: 24),
                statsPart,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              greetingPart,
              const SizedBox(height: 14),
              statsPart,
            ],
          );
        },
      ),
    );
  }
}

class _GreetingText extends StatelessWidget {
  const _GreetingText();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.medical_services_outlined,
              size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'مرحباً، رامي',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'الاثنين، 18 مايو',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightText3,
                    ),
                  ),
                  Text(
                    '·',
                    style: TextStyle(color: AppColors.lightText4),
                  ),
                  Text(
                    'آخر تحديث: منذ 3 دقيقة',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightText3,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0FBD7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'جميع الأنظمة تعمل بشكل طبيعي',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniStatsRow extends StatelessWidget {
  const _MiniStatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _MiniStat(
          value: '12',
          label: 'طلب اليوم',
          icon: Icons.assignment_outlined,
          color: Color(0xFF1A1C4E),
        ),
        SizedBox(width: 10),
        _MiniStat(
          value: '5',
          label: 'قيد التنفيذ',
          icon: Icons.adjust_rounded,
          color: Color(0xFF8B5CF6),
        ),
        SizedBox(width: 10),
        _MiniStat(
          value: '96%',
          label: 'نسبة الإنجاز',
          icon: Icons.check_circle_outline_rounded,
          color: Color(0xFF10B981),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.lightText1,
                  height: 1.1,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightText3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
