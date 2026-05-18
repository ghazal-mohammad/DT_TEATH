// ════════════════════════════════════════════════════════════════════════════
// lab_technicians_page.dart  — Phase 5.3 ✅
//
// شاشة إدارة المخبريين — مطابقة 100% لـ HTML المرجعي (pg-lt).
//
// الهيكل:
//   - جدول المخبريين: الاسم + أوقات الدوام + المسؤولية الحالية + الحالة + إجراء
//   - 3 stat cards أسفل الجدول: إجمالي / نشط / متاح
//
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — pg-lt
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/core/mock_user_data.dart';
import '../../../../shared/widgets/data/app_data_table.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../../../shared/widgets/primitives/app_badge.dart';
import '../../../../shared/widgets/primitives/app_button.dart';
import '../navigation/lab_sidebar_sections.dart';

// ══════════════════════════════════════════════════════════════════════════
//  MOCK DATA
// ══════════════════════════════════════════════════════════════════════════

class _TechnicianItem {
  const _TechnicianItem({
    required this.name,
    required this.shift,
    required this.currentTask,
    required this.isBusy,
  });

  final String name;
  final String shift;
  final String currentTask;
  final bool isBusy;
}

const _kTechnicians = [
  _TechnicianItem(
    name: 'هشام علي',
    shift: '08:00 - 16:00',
    currentTask: 'طلبات التلبيسات · 3 active',
    isBusy: true,
  ),
  _TechnicianItem(
    name: 'سامر شماع',
    shift: '11:00 - 19:00',
    currentTask: 'طلبات الجسور · 2 active',
    isBusy: true,
  ),
  _TechnicianItem(
    name: 'أيار كريم',
    shift: '18:00 - 22:00',
    currentTask: 'الأعمال الاختيارية التلبيسية',
    isBusy: false,
  ),
];

// ══════════════════════════════════════════════════════════════════════════
//  PAGE
// ══════════════════════════════════════════════════════════════════════════

/// صفحة إدارة المخبريين — نظام المخبر.
class LabTechniciansPage extends StatelessWidget {
  const LabTechniciansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppShellLayout(
      system: AppSystemType.lab,
      currentRoute: RouteNames.labTechnicians,
      sections: LabSidebarSections.build(context),
      pageTitle: l10n.labManageTechnicians,
      pageSubtitle: l10n.labTopbarSubtitle,
      userName: MockUserData.labUserName,
      userRole: l10n.roleLabManager,
      body: const _LabTechniciansBody(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  BODY
// ══════════════════════════════════════════════════════════════════════════

class _LabTechniciansBody extends StatelessWidget {
  const _LabTechniciansBody();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final totalCount = _kTechnicians.length;
    final activeCount = _kTechnicians.where((t) => t.isBusy).length;
    final availableCount = _kTechnicians.where((t) => !t.isBusy).length;

    return LayoutBuilder(
      builder: (context, outerConstraints) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── جدول المخبريين ───────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              border: Border.all(
                color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
              ),
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
                      const Text('👥 ', style: TextStyle(fontSize: 16)),
                      Text(
                        l10n.labTeamTitle,
                        style: AppTextStyles.headlineSmall,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Table
                AppDataTable<_TechnicianItem>(
                  data: _kTechnicians,
                  columns: [
                    AppDataColumn<_TechnicianItem>(
                      label: l10n.labTeamColumnName,
                      flex: 3,
                      cellBuilder: (t) => Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.dashViolet,
                                  AppColors.secondary,
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                t.name.substring(0, 1),
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t.name,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppDataColumn<_TechnicianItem>(
                      label: l10n.labTeamColumnShift,
                      flex: 2,
                      cellBuilder: (t) =>
                          Text(t.shift, style: AppTextStyles.bodySmall),
                    ),
                    AppDataColumn<_TechnicianItem>(
                      label: l10n.labTeamColumnCurrentTask,
                      flex: 4,
                      cellBuilder: (t) => Text(
                        t.currentTask,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    AppDataColumn<_TechnicianItem>(
                      label: l10n.labTeamColumnStatus,
                      flex: 2,
                      cellBuilder: (t) => AppBadge(
                        text: t.isBusy
                            ? l10n.labTeamBusy
                            : l10n.labTeamFree,
                        variant: t.isBusy
                            ? AppBadgeVariant.violet
                            : AppBadgeVariant.green,
                      ),
                    ),
                    AppDataColumn<_TechnicianItem>(
                      label: l10n.labTeamColumnAction,
                      flex: 2,
                      cellBuilder: (t) => t.isBusy
                          ? Text('—', style: AppTextStyles.bodySmall)
                          : AppButton.secondary(
                              label: l10n.labTeamAssign,
                              onPressed: () {},
                              size: AppButtonSize.small,
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.spaceMD),

          // ── 3 Stat Cards ─────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatMiniCard(
                  value: '$totalCount',
                  label: l10n.labTeamTotal,
                  valueColor: isLight
                      ? AppColors.lightText1
                      : AppColors.darkText1,
                ),
              ),
              const SizedBox(width: AppSizes.spaceMD),
              Expanded(
                child: _StatMiniCard(
                  value: '$activeCount',
                  label: l10n.labTeamActive,
                  valueColor: const Color(0xFF86EFAC), // #86efac
                ),
              ),
              const SizedBox(width: AppSizes.spaceMD),
              Expanded(
                child: _StatMiniCard(
                  value: '$availableCount',
                  label: l10n.labTeamAvailable,
                  valueColor: AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  STAT MINI CARD
// ══════════════════════════════════════════════════════════════════════════

class _StatMiniCard extends StatelessWidget {
  const _StatMiniCard({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.spaceMD,
        horizontal: AppSizes.spaceLG,
      ),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isLight ? AppColors.lightText4 : AppColors.darkText3,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
