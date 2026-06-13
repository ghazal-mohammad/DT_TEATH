// ════════════════════════════════════════════════════════════════════════════
// lab_technicians_page.dart  — إدارة المخبريين
//
// شاشة إدارة المخبريين — مطابقة للصور المرجعية:
//   - 3 stat cards (الإجمالي / يعمل الآن / جاهز للتوكيل)
//   - جدول فريق المخبر مع: المخبري (avatar+اسم+دور) / أوقات الدوام /
//     المسؤولية الحالية / الحالة (نشط/متاح/استراحة) / إجراء (توكيل + pause/play)
//   - مودال "توكيل طلبية"
//   ملاحظة: لا يوجد "إضافة مخبري" هنا — إضافة الموظفين من صلاحيات الأدمن فقط.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/network/failure.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../../../shared/widgets/loading/app_shimmer_card.dart';
import '../../../../shared/widgets/loading/app_shimmer_table.dart';
import '../../data/mock/lab_dashboard_mock_data.dart';
import '../../data/models/lab_technician.dart';
import '../../domain/repositories/lab_repository.dart';
import '../navigation/lab_sidebar_sections.dart';
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

// ══════════════════════════════════════════════════════════════════════════
//  PAGE
// ══════════════════════════════════════════════════════════════════════════

class LabTechniciansPage extends StatefulWidget {
  const LabTechniciansPage({super.key});

  @override
  State<LabTechniciansPage> createState() => _LabTechniciansPageState();
}

class _LabTechniciansPageState extends State<LabTechniciansPage> {
  final LabRepository _labRepo = sl<LabRepository>();

  // الفنيون يُجلبون من الباك (GET /api/labManager/showAllTechnicians).
  List<TechnicianItem> _technicians = [];
  bool _loadingTechs = true;
  String? _techsError;

  late List<LabOrderFull> _orders;

  @override
  void initState() {
    super.initState();
    _loadTechnicians();
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

  /// جلب الفنيين من الباك ومابّتهم لنموذج العرض.
  /// الحقول غير المتوفّرة بالباك (الدوام/المهمة/الحالة) تبقى قيمها افتراضية
  /// وتُدار محلياً (التوكيل/الإيقاف) لأن الباك ما بيدعمها.
  Future<void> _loadTechnicians() async {
    setState(() {
      _loadingTechs = true;
      _techsError = null;
    });
    try {
      final techs = await _labRepo.getTechnicians();
      if (!mounted) return;
      setState(() {
        _technicians = techs.map(_mapToItem).toList();
        _loadingTechs = false;
      });
    } on Failure catch (f) {
      if (!mounted) return;
      setState(() {
        _techsError = f.message;
        _loadingTechs = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _techsError = context.l10n.error;
        _loadingTechs = false;
      });
    }
  }

  TechnicianItem _mapToItem(LabTechnician t) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    return TechnicianItem(
      name: t.name,
      role: isAr ? 'فني' : 'Technician',
      shift: '—', // غير متوفّر بالباك
      currentTask: context.l10n.labTechPendingAssign,
      taskCount: 0,
      status: TechnicianStatus.available,
      initials: _computeInitials(t.name),
    );
  }

  int get _totalCount => _technicians.length;
  int get _activeCount =>
      _technicians.where((t) => t.status == TechnicianStatus.active).length;
  int get _availableCount =>
      _technicians.where((t) => t.status == TechnicianStatus.available).length;

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
      // تسجيل المنفّذ على الطلبية نفسها (UC70/UC71) + نقلها لقيد التصنيع.
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        _orders[idx].assignedTechnician = tech.name;
        if (_orders[idx].statusVariant == LabOrderBadgeVariant.newOrder) {
          _orders[idx].statusVariant = LabOrderBadgeVariant.manufacturing;
        }
      }
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
      searchPlaceholder: context.l10n.techSearchHint,
      showThemeToggle: false,
      userRole: context.l10n.roleLabManager,
      notificationCount: 2,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loadingTechs) {
      // Skeleton فوري بدل spinner يحجب الصفحة — الصفحة تبيّن بنيتها
      // فوراً حتى لو تأخّر الباك (أول طلب Laravel بيكون بطيء).
      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: const [
                Expanded(child: AppShimmerCard(height: 96)),
                SizedBox(width: AppSizes.spaceMD),
                Expanded(child: AppShimmerCard(height: 96)),
                SizedBox(width: AppSizes.spaceMD),
                Expanded(child: AppShimmerCard(height: 96)),
              ],
            ),
            const SizedBox(height: AppSizes.spaceLG),
            const AppShimmerTable(
              columns: [
                AppShimmerTableColumn.wide,
                AppShimmerTableColumn.text,
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
    if (_techsError != null) {
      return _TechsError(message: _techsError!, onRetry: _loadTechnicians);
    }
    return SingleChildScrollView(
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
            onAssign: _onAssign,
            onTogglePause: _onTogglePause,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  ERROR STATE — فشل جلب الفنيين من الباك
// ══════════════════════════════════════════════════════════════════════════

class _TechsError extends StatelessWidget {
  const _TechsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
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
            chipLabel: context.l10n.labTeamTotalChip,
            chipColor: AppColors.statusInfo,
            accentColor: AppColors.statusInfo,
            icon: Icons.people_alt_rounded,
            value: '$total',
            label: context.l10n.labTeamTotal,
          ),
          _TechStatCard(
            chipLabel: context.l10n.labTeamActiveChip,
            chipColor: AppColors.statusProgress,
            accentColor: AppColors.statusProgress,
            icon: Icons.adjust_rounded,
            value: '$active',
            label: context.l10n.techStatActiveLabel,
          ),
          _TechStatCard(
            chipLabel: context.l10n.labTeamReadyChip,
            chipColor: AppColors.statusSuccess,
            accentColor: AppColors.statusSuccess,
            icon: Icons.check_circle_rounded,
            value: '$available',
            label: context.l10n.labTeamAvailable,
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
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
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
    required this.onAssign,
    required this.onTogglePause,
  });

  final List<TechnicianItem> technicians;
  final void Function(TechnicianItem) onAssign;
  final void Function(TechnicianItem) onTogglePause;

  @override
  Widget build(BuildContext context) {
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
          // Header row: عنوان (يمين بـ RTL) + زر إضافة (يسار بـ RTL)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
                AppSizes.spaceLG, AppSizes.spaceLG, AppSizes.spaceLG, 12),
            child: Row(
              children: [
                // المجموعة الأولى → start side (RIGHT in RTL) — مطابق للمحاكاة
                Icon(Icons.groups_outlined,
                    size: 20,
                    color: isLight ? AppColors.primary : AppColors.darkText1),
                const SizedBox(width: 8),
                Text(
                  context.l10n.labTeamSectionTitle,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isLight
                        ? AppColors.statusProgressBg
                        : AppColors.darkChipVioletBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${technicians.length}',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isLight
                          ? AppColors.primary
                          : AppColors.darkChipVioletText,
                    ),
                  ),
                ),
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
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      color: isLight ? AppColors.statusInfoBg : AppColors.darkBg2,
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: _headerCell(context.l10n.labTeamColumnName, isLight)),
          Expanded(
              flex: 2,
              child: _headerCell(context.l10n.labTeamColumnShift, isLight)),
          Expanded(
              flex: 3,
              child:
                  _headerCell(context.l10n.labTeamColumnCurrentTask, isLight)),
          Expanded(
              flex: 2,
              child: _headerCell(context.l10n.labTeamColumnStatus, isLight)),
          Expanded(
              flex: 2,
              child: _headerCell(context.l10n.labTeamColumnAction, isLight)),
        ],
      ),
    );
  }

  Widget _headerCell(String text, bool isLight) => Text(
        text,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: isLight ? AppColors.lightText2 : AppColors.darkText2,
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
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                    color:
                        isLight ? AppColors.lightBorder : AppColors.darkBorder)),
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
                color: isLight ? AppColors.lightText1 : AppColors.darkText1,
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
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar أولاً → يظهر على اليمين بـ RTL (يطابق المحاكاة)
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isLight ? AppColors.primary : AppColors.brand,
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
                color: isLight ? AppColors.lightText1 : AppColors.darkText1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tech.role,
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
    );
  }
}

class _TaskPill extends StatelessWidget {
  const _TaskPill({required this.tech});
  final TechnicianItem tech;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isLight ? const Color(0xFFF1F3F8) : AppColors.darkBg2,
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
                  color: isLight ? AppColors.primary : AppColors.brand,
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
                color: isLight ? AppColors.lightText2 : AppColors.darkText2,
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
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    late final Color bg;
    late final Color fg;
    late final String label;
    switch (status) {
      case TechnicianStatus.active:
        bg = isLight ? AppColors.statusProgressBg : AppColors.darkChipVioletBg;
        fg = isLight ? AppColors.statusProgress : AppColors.darkChipVioletText;
        label = context.l10n.labTeamActive;
        break;
      case TechnicianStatus.available:
        bg = isLight ? AppColors.statusSuccessBg : AppColors.darkChipGreenBg;
        fg = isLight ? AppColors.statusSuccess : AppColors.darkChipGreenText;
        label = context.l10n.labTeamAvailable;
        break;
      case TechnicianStatus.onBreak:
        bg = isLight ? const Color(0xFFFEF3C7) : AppColors.darkChipOrangeBg;
        fg = isLight ? const Color(0xFFD97706) : AppColors.darkChipOrangeText;
        label = context.l10n.techStatusBreak;
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
        // RTL: نص يمين، dot يسار.
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
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
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isLight ? Colors.white : AppColors.darkBg1,
            border: Border.all(
                color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Icon(
            isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            size: 16,
            color: isLight ? AppColors.lightText2 : AppColors.darkText2,
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
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : AppColors.darkBg1,
            border: Border.all(
                color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded,
                  size: 14,
                  color: isLight ? AppColors.lightText2 : AppColors.darkText2),
              const SizedBox(width: 4),
              Text(
                context.l10n.labTeamAssign,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

