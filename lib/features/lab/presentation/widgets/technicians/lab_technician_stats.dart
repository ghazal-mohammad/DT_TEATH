// ════════════════════════════════════════════════════════════════════════════
// lab_technician_stats.dart
//
// صف بطاقات إحصاء المخبريين (الإجمالي / يعمل الآن / جاهز للتوكيل) — مُستخرَج
// من lab_technicians_page.dart ضمن تقسيم الصفحات العملاقة.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// صف بطاقات إحصاء فريق المخبر الثلاث.
class LabTechnicianStatsRow extends StatelessWidget {
  const LabTechnicianStatsRow({
    super.key,
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
