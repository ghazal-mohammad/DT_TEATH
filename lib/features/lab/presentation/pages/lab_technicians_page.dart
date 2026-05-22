// ════════════════════════════════════════════════════════════════════════════
// lab_technicians_page.dart  — إدارة المخبريين
//
// شاشة إدارة المخبريين — مطابقة للصور المرجعية:
//   - 3 stat cards (الإجمالي / يعمل الآن / جاهز للتوكيل)
//   - جدول فريق المخبر مع: المخبري (avatar+اسم+دور) / أوقات الدوام /
//     المسؤولية الحالية / الحالة (نشط/متاح/استراحة) / إجراء (توكيل + pause/play)
//   - مودال "إضافة مخبري جديد"
//   - مودال "توكيل طلبية"
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
import '../widgets/add_technician_dialog.dart';
import '../widgets/assign_order_dialog.dart';
import '../widgets/lab_order_models.dart';

// ══════════════════════════════════════════════════════════════════════════
//  MODEL + MOCK DATA
// ══════════════════════════════════════════════════════════════════════════

enum TechnicianStatus { active, available, onBreak }

class TechnicianItem {
  TechnicianItem({
    required this.name,
    required this.role,
    required this.shift,
    required this.currentTask,
    required this.taskCount,
    required this.status,
    required this.initials,
  });

  String name;
  String role;
  String shift;
  String currentTask;
  int taskCount;
  TechnicianStatus status;
  String initials;
}

List<TechnicianItem> _seedTechnicians() => [
      TechnicianItem(
        name: 'محمد علي',
        role: 'فني تلبيسات',
        shift: '08:00 - 16:00',
        currentTask: 'طلبات التلبيسات',
        taskCount: 4,
        status: TechnicianStatus.active,
        initials: 'مع',
      ),
      TechnicianItem(
        name: 'سامر حسن',
        role: 'فني جسور',
        shift: '09:00 - 17:00',
        currentTask: 'طلبات الجسور',
        taskCount: 3,
        status: TechnicianStatus.active,
        initials: 'سح',
      ),
      TechnicianItem(
        name: 'ليلى كريم',
        role: 'فنية أكريل',
        shift: '10:00 - 18:00',
        currentTask: 'الأعمال الأكريلية',
        taskCount: 0,
        status: TechnicianStatus.available,
        initials: 'لك',
      ),
      TechnicianItem(
        name: 'يوسف ناصر',
        role: 'فني زيركون',
        shift: '08:00 - 16:00',
        currentTask: 'طلبات Zirconia',
        taskCount: 2,
        status: TechnicianStatus.onBreak,
        initials: 'ين',
      ),
    ];

// ══════════════════════════════════════════════════════════════════════════
//  PAGE
// ══════════════════════════════════════════════════════════════════════════

class LabTechniciansPage extends StatefulWidget {
  const LabTechniciansPage({super.key});

  @override
  State<LabTechniciansPage> createState() => _LabTechniciansPageState();
}

class _LabTechniciansPageState extends State<LabTechniciansPage> {
  late List<TechnicianItem> _technicians;
  late List<LabOrderFull> _orders;

  @override
  void initState() {
    super.initState();
    _technicians = _seedTechnicians();
    _orders = [
      LabOrderFull(
        id: 'LAB-045',
        doctor: 'د. سارة',
        type: 'تلبيسة',
        material: 'PFM',
        tooth: '#14',
        date: '27-03-2026',
        statusVariant: LabOrderBadgeVariant.newOrder,
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
        id: 'LAB-042',
        doctor: 'د. سارة',
        type: 'وجه',
        material: 'E-max',
        tooth: '#21',
        date: '27-03-2026',
        statusVariant: LabOrderBadgeVariant.manufacturing,
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
  }

  int get _totalCount => _technicians.length;
  int get _activeCount =>
      _technicians.where((t) => t.status == TechnicianStatus.active).length;
  int get _availableCount =>
      _technicians.where((t) => t.status == TechnicianStatus.available).length;

  Future<void> _onAdd() async {
    final r = await AddTechnicianDialog.show(context);
    if (r == null || r.name.isEmpty) return;
    setState(() {
      _technicians.add(TechnicianItem(
        name: r.name,
        role: r.role,
        shift: '${r.shiftStart} - ${r.shiftEnd}',
        currentTask: 'بانتظار التوكيل',
        taskCount: 0,
        status: TechnicianStatus.available,
        initials: _computeInitials(r.name),
      ));
    });
  }

  String _computeInitials(String name) {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.firstOrNull ?? '?';
    return '${parts[0].characters.firstOrNull ?? ''}${parts[1].characters.firstOrNull ?? ''}';
  }

  Future<void> _onAssign(TechnicianItem tech) async {
    final orderId = await AssignOrderDialog.show(
      context,
      technicianName: tech.name,
      orders: _orders,
    );
    if (orderId == null) return;
    setState(() {
      tech.taskCount += 1;
      tech.status = TechnicianStatus.active;
    });
  }

  void _onTogglePause(TechnicianItem tech) {
    setState(() {
      if (tech.status == TechnicianStatus.onBreak ||
          tech.status == TechnicianStatus.available) {
        tech.status = TechnicianStatus.active;
      } else {
        tech.status = TechnicianStatus.onBreak;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShellLayout(
      system: AppSystemType.lab,
      currentRoute: RouteNames.labTechnicians,
      sections: LabSidebarSections.buildWithBadges(
        context,
        newOrdersCount: 4,
        unreadNotifsCount: 2,
      ),
      pageTitle: context.l10n.labManageTechnicians,
      pageSubtitle: null,
      searchPlaceholder: 'بحث عن مخبري... (اسم، دور، مهمة)',
      showThemeToggle: false,
      userName: MockUserData.labUserName,
      userRole: context.l10n.roleLabManager,
      notificationCount: 2,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StatsRow(
              total: _totalCount,
              active: _activeCount,
              available: _availableCount,
            ),
            const SizedBox(height: AppSizes.spaceLG),
            _TeamTable(
              technicians: _technicians,
              onAdd: _onAdd,
              onAssign: _onAssign,
              onTogglePause: _onTogglePause,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  STAT CARDS ROW
// ══════════════════════════════════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.total,
    required this.active,
    required this.available,
  });

  final int total;
  final int active;
  final int available;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth > 800;
        final cards = [
          _TechStatCard(
            chipLabel: 'الإجمالي',
            chipColor: const Color(0xFF3B82F6),
            accentColor: const Color(0xFF3B82F6),
            icon: Icons.people_alt_rounded,
            value: '$total',
            label: 'إجمالي المخبريين',
          ),
          _TechStatCard(
            chipLabel: 'يعمل الآن',
            chipColor: const Color(0xFF8B5CF6),
            accentColor: const Color(0xFF8B5CF6),
            icon: Icons.adjust_rounded,
            value: '$active',
            label: 'مخبريون نشطون',
          ),
          _TechStatCard(
            chipLabel: 'جاهز للتوكيل',
            chipColor: const Color(0xFF10B981),
            accentColor: const Color(0xFF10B981),
            icon: Icons.check_circle_rounded,
            value: '$available',
            label: 'متاحون',
          ),
        ];
        if (wide) {
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
            for (final c in cards) ...[
              c,
              const SizedBox(height: AppSizes.spaceMD),
            ],
          ],
        );
      },
    );
  }
}

class _TechStatCard extends StatefulWidget {
  const _TechStatCard({
    required this.chipLabel,
    required this.chipColor,
    required this.accentColor,
    required this.icon,
    required this.value,
    required this.label,
  });

  final String chipLabel;
  final Color chipColor;
  final Color accentColor;
  final IconData icon;
  final String value;
  final String label;

  @override
  State<_TechStatCard> createState() => _TechStatCardState();
}

class _TechStatCardState extends State<_TechStatCard> {
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
              PositionedDirectional(
                end: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 5, color: widget.accentColor),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
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
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: widget.accentColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(widget.icon,
                              size: 18, color: widget.accentColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
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
//  TEAM TABLE
// ══════════════════════════════════════════════════════════════════════════

class _TeamTable extends StatelessWidget {
  const _TeamTable({
    required this.technicians,
    required this.onAdd,
    required this.onAssign,
    required this.onTogglePause,
  });

  final List<TechnicianItem> technicians;
  final VoidCallback onAdd;
  final void Function(TechnicianItem) onAssign;
  final void Function(TechnicianItem) onTogglePause;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row: عنوان (يمين بـ RTL) + زر إضافة (يسار بـ RTL)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
                AppSizes.spaceLG, AppSizes.spaceLG, AppSizes.spaceLG, 12),
            child: Row(
              children: [
                // المجموعة الأولى → start side (RIGHT in RTL) — مطابق للمحاكاة
                const Icon(Icons.groups_outlined,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'فريق المخبر',
                  style: AppTextStyles.headlineSmall,
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1DAFE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${technicians.length}',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                // الزر آخر → end side (LEFT in RTL)
                _AddBtn(onTap: onAdd),
              ],
            ),
          ),
          _TableHeader(),
          for (int i = 0; i < technicians.length; i++)
            _TableRow(
              tech: technicians[i],
              isLast: i == technicians.length - 1,
              onAssign: () => onAssign(technicians[i]),
              onTogglePause: () => onTogglePause(technicians[i]),
            ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      color: const Color(0xFFE2EDFF),
      child: Row(
        children: [
          Expanded(flex: 3, child: _headerCell('المخبري')),
          Expanded(flex: 2, child: _headerCell('أوقات الدوام')),
          Expanded(flex: 3, child: _headerCell('المسؤولية الحالية')),
          Expanded(flex: 2, child: _headerCell('الحالة')),
          Expanded(flex: 2, child: _headerCell('إجراء')),
        ],
      ),
    );
  }

  Widget _headerCell(String text) => Text(
        text,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.lightText2,
          letterSpacing: 0.4,
        ),
      );
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.tech,
    required this.isLast,
    required this.onAssign,
    required this.onTogglePause,
  });

  final TechnicianItem tech;
  final bool isLast;
  final VoidCallback onAssign;
  final VoidCallback onTogglePause;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: AppColors.lightBorder)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Expanded(flex: 3, child: _NameCell(tech: tech)),
          Expanded(
            flex: 2,
            child: Text(
              tech.shift,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.lightText1,
              ),
            ),
          ),
          Expanded(flex: 3, child: _TaskPill(tech: tech)),
          Expanded(flex: 2, child: _StatusPill(status: tech.status)),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PauseToggle(
                  isPaused: tech.status == TechnicianStatus.onBreak ||
                      tech.status == TechnicianStatus.available,
                  onTap: onTogglePause,
                ),
                const SizedBox(width: 6),
                _AssignBtn(onTap: onAssign),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NameCell extends StatelessWidget {
  const _NameCell({required this.tech});
  final TechnicianItem tech;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar أولاً → يظهر على اليمين بـ RTL (يطابق المحاكاة)
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            tech.initials,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // الاسم والدور — يظهروا على يسار الـ avatar بـ RTL
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tech.name,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.lightText1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tech.role,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.lightText3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TaskPill extends StatelessWidget {
  const _TaskPill({required this.tech});
  final TechnicianItem tech;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tech.taskCount > 0) ...[
              Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${tech.taskCount}',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              tech.currentTask,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.lightText2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final TechnicianStatus status;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final String label;
    switch (status) {
      case TechnicianStatus.active:
        bg = const Color(0xFFF1DAFE);
        fg = const Color(0xFF8B5CF6);
        label = 'نشط';
        break;
      case TechnicianStatus.available:
        bg = const Color(0xFFD0FBD7);
        fg = const Color(0xFF10B981);
        label = 'متاح';
        break;
      case TechnicianStatus.onBreak:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        label = 'استراحة';
        break;
    }
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PauseToggle extends StatelessWidget {
  const _PauseToggle({required this.isPaused, required this.onTap});
  final bool isPaused;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.lightBorder),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Icon(
            isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            size: 16,
            color: AppColors.lightText2,
          ),
        ),
      ),
    );
  }
}

class _AssignBtn extends StatelessWidget {
  const _AssignBtn({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.lightBorder),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 14, color: AppColors.lightText2),
              const SizedBox(width: 4),
              Text(
                'توكيل طلبية',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightText1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddBtn extends StatelessWidget {
  const _AddBtn({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              const Text(
                'إضافة مخبري',
                style: TextStyle(
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
