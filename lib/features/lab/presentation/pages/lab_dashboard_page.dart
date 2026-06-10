// ════════════════════════════════════════════════════════════════════════════
// lab_dashboard_page.dart  — Phase 5.1 ✅
//
// صفحة لوحة التحكم الكاملة لنظام المخبر.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/current_user.dart';
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
      // العنوان "الصفحة الرئيسية" (مطابق للسايدبار وحسب الاتفاق).
      pageTitle: l10n.dashboard,
      pageSubtitle: null,
      searchPlaceholder: l10n.labDashboardSearchHint,
      showThemeToggle: false,
      userName: CurrentUser.instance.name ?? MockUserData.labUserName,
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
    final l10n = context.l10n;
    final cards = <Widget>[
      _DashboardStatCard(
        chipLabel: l10n.priorityUrgent,
        chipColor: const Color(0xFFEF4444),
        accentColor: const Color(0xFFEF4444),
        icon: Icons.local_fire_department_rounded,
        value: '2',
        label: l10n.labStatUrgentToday,
        trendIcon: Icons.arrow_downward_rounded,
        trendText: l10n.labStatNeedsFollowup,
        trendColor: const Color(0xFFEF4444),
      ),
      _DashboardStatCard(
        chipLabel: l10n.labChipThisMonth,
        chipColor: const Color(0xFF10B981),
        accentColor: const Color(0xFF10B981),
        icon: Icons.check_circle_rounded,
        value: '23',
        label: l10n.labStatReadyOrders,
        trendIcon: Icons.arrow_upward_rounded,
        trendText: l10n.labTrendFromLastMonth('+18%'),
        trendColor: const Color(0xFF10B981),
      ),
      _DashboardStatCard(
        chipLabel: l10n.labChipActive,
        chipColor: const Color(0xFF8B5CF6),
        accentColor: const Color(0xFF8B5CF6),
        icon: Icons.adjust_rounded,
        value: '7',
        label: l10n.labStatManufacturing,
        trendIcon: Icons.arrow_upward_rounded,
        trendText: l10n.labTrendFromYesterday('+1'),
        trendColor: const Color(0xFF8B5CF6),
      ),
      _DashboardStatCard(
        chipLabel: l10n.statusNew,
        chipColor: const Color(0xFF3B82F6),
        accentColor: const Color(0xFF3B82F6),
        icon: Icons.add_rounded,
        value: '4',
        label: l10n.labStatNewOrders,
        trendIcon: Icons.arrow_upward_rounded,
        trendText: l10n.labTrendFromYesterday('+2'),
        trendColor: const Color(0xFF3B82F6),
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
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
        decoration: BoxDecoration(
          // خلفية بيضاء من الداخل + حدود رمادية محايدة — مطابق لبطاقات المستودع
          // (اللون يظهر فقط عبر الشريط الجانبي وصندوق الأيقونة والـ chip).
          color: isLight ? AppColors.baseComponent : AppColors.darkBg1,
          borderRadius: radius,
          border: Border.all(
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
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
                child: Container(width: 4, color: widget.accentColor),
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
                        // icon (يسار البطاقة في RTL) — صندوق ملوّن خفيف (tint)
                        // مطابق لبطاقات المستودع.
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
                        color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isLight ? AppColors.lightText3 : AppColors.darkText3,
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
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFFFF7ED) : AppColors.darkChipOrangeBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          // أيقونة + عنوان (المجموعة اليمنى في RTL)
          final titleGroup = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.labOrdersDueToday,
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
                    context.l10n.labOrdersDueTodaySubtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isLight ? AppColors.lightText3 : AppColors.darkText3,
                    ),
                  ),
                ],
              ),
            ],
          );

          // عند العرض الواسع: العنوان يمين، والـ pills مدفوعة لأقصى اليسار
          // (WrapAlignment.end = اليسار في RTL).
          if (c.maxWidth > 640) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                titleGroup,
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: _buildOrderPills(isLight),
                  ),
                ),
              ],
            );
          }

          // عند العرض الضيّق: تدفّق طبيعي (Wrap) لتفادي أي overflow.
          return Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [titleGroup, ..._buildOrderPills(isLight)],
          );
        },
      ),
    );
  }

  List<Widget> _buildOrderPills(bool isLight) {
    // ترتيب التصميم المرجعي (RTL يمين→يسار):
    //   [16:00 جسر 3 وحدات — د. خالد] → [14:00 تلبيسة PFM — د. سارة]
    // الأقرب لـ deadline (14:00) في الأقصى يسار، والأبعد (16:00) أقرب للترويسة.
    const items = [
      _PillData(time: '16:00', body: 'جسر 3 وحدات — د. خالد'),
      _PillData(time: '14:00', body: 'تلبيسة PFM — د. سارة'),
    ];
    return items
        .map(
          (p) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isLight ? Colors.white : AppColors.darkBg1,
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
                    color: isLight ? AppColors.lightText1 : AppColors.darkText1,
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
                    color: isLight ? AppColors.lightText2 : AppColors.darkText2,
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
    final bool isLight = Theme.of(context).brightness == Brightness.light;

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
                Icon(
                  Icons.assignment_outlined,
                  size: 20,
                  color: isLight ? AppColors.primary : AppColors.darkText1,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.labTodayOrders,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isLight
                        ? const Color(0xFFF1DAFE)
                        : AppColors.darkChipVioletBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    context.l10n.labOrdersCount('${all.length}'),
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isLight
                          ? AppColors.primary
                          : AppColors.darkChipVioletText,
                    ),
                  ),
                ),
                const Spacer(),
                // tabs
                _Tab(
                  label: context.l10n.labOrdersFilterAll,
                  count: all.length,
                  isActive: _activeFilter == 'all',
                  isLight: isLight,
                  onTap: () => setState(() => _activeFilter = 'all'),
                ),
                const SizedBox(width: 6),
                _Tab(
                  label: context.l10n.labOrdersFilterNew,
                  count: counts['new']!,
                  isActive: _activeFilter == 'new',
                  isLight: isLight,
                  onTap: () => setState(() => _activeFilter = 'new'),
                ),
                const SizedBox(width: 6),
                _Tab(
                  label: context.l10n.labOrdersFilterManufacturing,
                  count: counts['manufacturing']!,
                  isActive: _activeFilter == 'manufacturing',
                  isLight: isLight,
                  onTap: () =>
                      setState(() => _activeFilter = 'manufacturing'),
                ),
                const SizedBox(width: 6),
                _Tab(
                  label: context.l10n.labOrdersFilterReady,
                  count: counts['ready']!,
                  isActive: _activeFilter == 'ready',
                  isLight: isLight,
                  onTap: () => setState(() => _activeFilter = 'ready'),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => context.go(RouteNames.labOrders),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      '${context.l10n.viewAll} ←',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isLight ? AppColors.primary : AppColors.brand,
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
            // موحّد مع المستودع: tableHeader (#BED8FA) بالفاتح.
            headerBackground:
                isLight ? AppColors.tableHeader : AppColors.darkBg2,
            columns: [
              AppDataColumn<LabOrderItem>(
                label: context.l10n.colOrderNumber,
                flex: 2,
                cellBuilder: (item) => Text(
                  item.orderId,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                  ),
                ),
              ),
              AppDataColumn<LabOrderItem>(
                label: context.l10n.colDoctor,
                flex: 2,
                cellBuilder: (item) => _doctorCell(item.doctorName, isLight),
              ),
              AppDataColumn<LabOrderItem>(
                label: context.l10n.colType,
                flex: 2,
                cellBuilder: (item) =>
                    Text(item.type, style: AppTextStyles.bodyMedium),
              ),
              AppDataColumn<LabOrderItem>(
                label: context.l10n.colMaterial,
                flex: 2,
                cellBuilder: (item) => Text(
                  item.material.isEmpty ? '—' : item.material,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              AppDataColumn<LabOrderItem>(
                label: context.l10n.colTooth,
                flex: 2,
                cellBuilder: (item) => Text(
                  item.tooth.isEmpty ? '—' : item.tooth,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              AppDataColumn<LabOrderItem>(
                label: context.l10n.colDate,
                flex: 2,
                cellBuilder: (item) =>
                    Text(item.dueDate, style: AppTextStyles.bodySmall),
              ),
              AppDataColumn<LabOrderItem>(
                label: context.l10n.colPriority,
                flex: 2,
                cellBuilder: (item) =>
                    _priorityCell(context, item.priority, isLight),
              ),
              AppDataColumn<LabOrderItem>(
                label: context.l10n.colStatus,
                flex: 2,
                cellBuilder: (item) => _statusBadge(context, item, isLight),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _doctorCell(String name, bool isLight) {
    // name مثل "د. سارة س" → نعرضو كامل، الـ avatar يستخدم آخر جزء (س)
    final parts =
        name.split(' ').where((p) => p.isNotEmpty).toList(growable: false);
    final String displayName = parts.join(' ');
    final String lastSegment = parts.isNotEmpty ? parts.last : name;
    final String initial =
        lastSegment.isNotEmpty ? lastSegment.characters.first : '';

    // التصميم المرجعي: الـ avatar يمين (نقطة بداية القراءة بالـ RTL)
    // ثم اسم الطبيب يسار → [avatar, SizedBox, Text].
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isLight ? const Color(0xFFE2EDFF) : AppColors.darkChipBlueBg,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isLight ? AppColors.primary : AppColors.darkChipBlueText,
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

  Widget _priorityCell(
      BuildContext context, LabOrderPriority priority, bool isLight) {
    final l10n = context.l10n;
    final ({Color color, String label, int bars}) data = switch (priority) {
      LabOrderPriority.urgent =>
        (color: const Color(0xFFEF4444), label: l10n.priorityUrgent, bars: 3),
      LabOrderPriority.medium =>
        (color: const Color(0xFF3B82F6), label: l10n.priorityMedium, bars: 2),
      LabOrderPriority.normal => (
          color: isLight ? AppColors.lightText4 : AppColors.darkText4,
          label: l10n.priorityNormal,
          bars: 1,
        ),
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

  Widget _statusBadge(BuildContext context, LabOrderItem item, bool isLight) {
    final l10n = context.l10n;
    final ({Color bg, Color text, String label}) data =
        switch (item.statusVariant) {
      LabOrderBadgeVariant.newOrder => (
          bg: isLight ? const Color(0xFFE2EDFF) : AppColors.darkChipBlueBg,
          text: isLight ? const Color(0xFF3B82F6) : AppColors.darkChipBlueText,
          label: l10n.statusNew,
        ),
      LabOrderBadgeVariant.manufacturing => (
          bg: isLight ? const Color(0xFFF1DAFE) : AppColors.darkChipVioletBg,
          text:
              isLight ? const Color(0xFF8B5CF6) : AppColors.darkChipVioletText,
          label: l10n.statusManufacturing,
        ),
      LabOrderBadgeVariant.ready => (
          bg: isLight ? const Color(0xFFD0FBD7) : AppColors.darkChipGreenBg,
          text: isLight ? const Color(0xFF10B981) : AppColors.darkChipGreenText,
          label: l10n.statusReady,
        ),
      LabOrderBadgeVariant.urgent => (
          bg: isLight ? const Color(0xFFFEE2E2) : AppColors.darkChipRedBg,
          text: isLight ? const Color(0xFFEF4444) : AppColors.darkChipRedText,
          label: l10n.priorityUrgent,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: data.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      // RTL: نص يمين، dot يسار.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: data.text,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: data.text,
              shape: BoxShape.circle,
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
    required this.isLight,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isActive;
  final bool isLight;
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
            color: isActive
                ? (isLight ? AppColors.primary : AppColors.brand)
                : Colors.transparent,
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
                  color: isActive
                      ? Colors.white
                      : (isLight ? AppColors.lightText2 : AppColors.darkText2),
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

// قسم الفريق محذوف بالكامل من التصميم الموحّد — تم نقل المعلومات
// إلى صفحة "إدارة المخبريين" المستقلة.

// ══════════════════════════════════════════════════════════════════════════
//  DASHBOARD GREETING — "مرحباً، د. رامي" + 3 mini stats
// ══════════════════════════════════════════════════════════════════════════

class _DashboardGreeting extends StatelessWidget {
  const _DashboardGreeting();

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        // الفاتح: تدرّج لافندر مطابق لـ hero المستودع (توحيد بصري بين النظامين).
        // الغامق: navy → بنفسجي (مطابق روح الـ hero بالموكب).
        gradient: isLight
            ? const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFFF3E9FB), Color(0xFFE7DBF5)],
              )
            : const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF20223A), // navy غامق
                  Color(0xFF2A2B4A),
                  Color(0xFF332B57), // لمسة بنفسجية
                ],
                stops: [0.0, 0.6, 1.0],
              ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
            color: isLight
                ? const Color(0xFFE0D2F0)
                : AppColors.darkBorder),
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
                // الترحيب يمين ويملأ المساحة المتبقّية، فتُدفع الإحصاءات
                // المصغّرة إلى أقصى اليسار (Expanded بدل Flexible حتى لا
                // تتكدّس بجانب الترحيب على اليمين).
                Expanded(child: greetingPart),
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
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final Color accent = isLight ? AppColors.primary : AppColors.darkText1;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: (isLight ? AppColors.primary : AppColors.brand)
                .withValues(alpha: isLight ? 0.08 : 0.20),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.medical_services_outlined,
              size: 18, color: isLight ? AppColors.primary : AppColors.brand),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.labGreeting(
                    CurrentUser.instance.name ?? MockUserData.labUserName),
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: accent,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              // ترتيب التصميم المرجعي (RTL يمين→يسار):
              // [● جميع الأنظمة] · [الاثنين، 18 مايو] · [آخر تحديث: منذ 3 دقيقة]
              // في Wrap RTL: أوّل child = يمين، فالـ status pill أوّلاً.
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: isLight
                          ? const Color(0xFFD0FBD7)
                          : AppColors.darkChipGreenBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isLight
                                ? const Color(0xFF10B981)
                                : AppColors.darkChipGreenText,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          context.l10n.systemAllNormal,
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isLight
                                ? const Color(0xFF10B981)
                                : AppColors.darkChipGreenText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '·',
                    style: TextStyle(
                        color: isLight
                            ? AppColors.lightText4
                            : AppColors.darkText4),
                  ),
                  Text(
                    'الاثنين، 18 مايو',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isLight ? AppColors.lightText3 : AppColors.darkText3,
                    ),
                  ),
                  Text(
                    '·',
                    style: TextStyle(
                        color: isLight
                            ? AppColors.lightText4
                            : AppColors.darkText4),
                  ),
                  Text(
                    'آخر تحديث: منذ 3 دقيقة',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isLight ? AppColors.lightText3 : AppColors.darkText3,
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
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    // ترتيب التصميم المرجعي (RTL يمين→يسار):
    //   [96% نسبة الإنجاز] → [5 قيد التنفيذ] → [12 طلب اليوم]
    // في Row RTL: أوّل child = يمين، فالـ نسبة الإنجاز أوّلاً.
    final l10n = context.l10n;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MiniStat(
          value: '96%',
          label: l10n.labHeroStatCompletionRate,
          icon: Icons.check_circle_outline_rounded,
          color: const Color(0xFF10B981),
        ),
        const SizedBox(width: 10),
        _MiniStat(
          value: '5',
          label: l10n.labHeroStatInProgress,
          icon: Icons.adjust_rounded,
          color: const Color(0xFF8B5CF6),
        ),
        const SizedBox(width: 10),
        _MiniStat(
          value: '12',
          label: l10n.labHeroStatTodayOrders,
          icon: Icons.assignment_outlined,
          // navy غير مرئي على الغامق → نستخدم brand بالغامق
          color: isLight ? const Color(0xFF1A1C4E) : AppColors.brand,
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
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFF8F9FC) : AppColors.darkBg2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
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
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                  height: 1.1,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isLight ? AppColors.lightText3 : AppColors.darkText3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
