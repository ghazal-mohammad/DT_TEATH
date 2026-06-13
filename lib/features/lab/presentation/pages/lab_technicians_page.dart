// ════════════════════════════════════════════════════════════════════════════
// lab_technicians_page.dart  — إدارة المخبريين
//
// شاشة إدارة المخبريين — مطابقة للصور المرجعية:
//   - 3 stat cards (الإجمالي / يعمل الآن / جاهز للتوكيل)
//   - جدول فريق المخبر مع: المخبري (avatar+اسم+دور) / أوقات الدوام /
//     المسؤولية الحالية / الحالة (نشط/متاح/استراحة) / إجراء (توكيل + pause/play)
//   - مودال "توكيل طلبية"
//   ملاحظة: لا يوجد "إضافة مخبري" هنا — إضافة الموظفين من صلاحيات الأدمن فقط.
//
// النماذج في widgets/technicians/lab_technician_view_data.dart، وبطاقات الإحصاء
// والجدول في widgets/technicians/ (تقسيم الصفحات العملاقة).
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
import '../widgets/technicians/lab_technician_stats.dart';
import '../widgets/technicians/lab_technician_table.dart';
import '../widgets/technicians/lab_technician_view_data.dart';

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
                Expanded(
                    child: AppShimmerCard(
                        layout: AppShimmerCardLayout.statCard)),
                SizedBox(width: AppSizes.spaceMD),
                Expanded(
                    child: AppShimmerCard(
                        layout: AppShimmerCardLayout.statCard)),
                SizedBox(width: AppSizes.spaceMD),
                Expanded(
                    child: AppShimmerCard(
                        layout: AppShimmerCardLayout.statCard)),
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
          LabTechnicianStatsRow(
            total: _totalCount,
            active: _activeCount,
            available: _availableCount,
          ),
          const SizedBox(height: AppSizes.spaceLG),
          LabTechnicianTeamTable(
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
