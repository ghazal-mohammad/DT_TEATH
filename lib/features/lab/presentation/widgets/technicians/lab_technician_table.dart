// ════════════════════════════════════════════════════════════════════════════
// lab_technician_table.dart
//
// جدول فريق المخبر (المخبري / الدوام / المهمة الحالية / الحالة / إجراء التوكيل)
// — مُستخرَج من lab_technicians_page.dart ضمن تقسيم الصفحات العملاقة.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'lab_technician_view_data.dart';

/// جدول فريق المخبر مع صفوف المخبريين وإجراءات التوكيل/الإيقاف.
class LabTechnicianTeamTable extends StatelessWidget {
  const LabTechnicianTeamTable({
    super.key,
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
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row: عنوان (يمين بـ RTL) + زر إضافة (يسار بـ RTL)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSizes.spaceLG,
              AppSizes.spaceLG,
              AppSizes.spaceLG,
              12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.groups_outlined,
                  size: 20,
                  color: isLight ? AppColors.primary : AppColors.darkText1,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.labTeamSectionTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: isLight
                          ? AppColors.lightText1
                          : AppColors.darkText1,
                    ),
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
            child: _headerCell(context.l10n.labTeamColumnName, isLight),
          ),
          Expanded(
            flex: 2,
            child: _headerCell(context.l10n.labTeamColumnShift, isLight),
          ),
          Expanded(
            flex: 3,
            child: _headerCell(context.l10n.labTeamColumnCurrentTask, isLight),
          ),
          Expanded(
            flex: 2,
            child: _headerCell(context.l10n.labTeamColumnStatus, isLight),
          ),
          Expanded(
            flex: 2,
            child: _headerCell(context.l10n.labTeamColumnAction, isLight),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String text, bool isLight) => Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
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
                  color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
                ),
              ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _NameCell(tech: tech)),
          Expanded(
            flex: 2,
            child: Text(
              tech.shift,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _PauseToggle(
                  isPaused:
                      tech.status == TechnicianStatus.onBreak ||
                      tech.status == TechnicianStatus.available,
                  onTap: onTogglePause,
                ),
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
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tech.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isLight ? AppColors.lightText3 : AppColors.darkText3,
                ),
              ),
            ],
          ),
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
          color: isLight ? AppColors.surfaceTintCool : AppColors.darkBg2,
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
            Flexible(
              child: Text(
                tech.currentTask,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isLight ? AppColors.lightText2 : AppColors.darkText2,
                ),
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
        bg = isLight ? AppColors.chipAmberBgLight : AppColors.darkChipOrangeBg;
        fg = isLight
            ? AppColors.chipAmberTextLight
            : AppColors.darkChipOrangeText;
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
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
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
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
            ),
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
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_rounded,
                size: 14,
                color: isLight ? AppColors.lightText2 : AppColors.darkText2,
              ),
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
