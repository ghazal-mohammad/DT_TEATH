// ════════════════════════════════════════════════════════════════════════════
// lab_technician_performance.dart
//
// قسم أداء/تقييم الفنّيين (الشهر الحالي) — من showTechniciansPerformance.
// لكل فنّي: دوام اليوم + مُسنَد/قيد التنفيذ/مكتمل + معدّل إنجاز (شريط + %).
// التقييم = المكتمل ÷ المُسنَد، مُلوَّن (أخضر/ذهبي/أحمر). يحترم الثيمين.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/technician_performance.dart';

/// قسم يعرض تقرير أداء الفنّيين (لا يظهر إن كانت القائمة فارغة).
class LabTechnicianPerformanceSection extends StatelessWidget {
  const LabTechnicianPerformanceSection({super.key, required this.items});

  final List<TechnicianPerformance> items;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final l10n = context.l10n;
    final Color accent = isLight ? AppColors.primary : AppColors.brand;
    final Color border = isLight ? AppColors.lightBorder : AppColors.darkBorder;

    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.darkBg1,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.insights_rounded, size: 20, color: accent),
              const SizedBox(width: 8),
              Text(
                l10n.techPerfTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  fontSize: 16,
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
              const Spacer(),
              Text(
                l10n.techPerfThisMonth,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isLight ? AppColors.lightText3 : AppColors.darkText3,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceMD),
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 1, color: border),
            _PerfRow(p: items[i], isLight: isLight),
          ],
        ],
      ),
    );
  }
}

class _PerfRow extends StatelessWidget {
  const _PerfRow({required this.p, required this.isLight});

  final TechnicianPerformance p;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final double rate = p.completionRate;
    final Color rateColor = rate >= 0.7
        ? AppColors.statusSuccess
        : rate >= 0.4
            ? AppColors.statusWarn
            : AppColors.statusUrgent;
    final String shift = (p.shiftStart.isNotEmpty && p.shiftEnd.isNotEmpty)
        ? '${p.shiftStart} — ${p.shiftEnd}'
        : '—';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name.isEmpty ? '—' : p.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isLight
                            ? AppColors.lightText1
                            : AppColors.darkText1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 12,
                            color: isLight
                                ? AppColors.lightText4
                                : AppColors.darkText4),
                        const SizedBox(width: 4),
                        Text(
                          shift,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isLight
                                ? AppColors.lightText3
                                : AppColors.darkText3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _stat(l10n.techPerfAssigned, '${p.totalAssigned}',
                  AppColors.statusInfo),
              _stat(l10n.techPerfInProgress, '${p.totalInProgress}',
                  AppColors.statusProgress),
              _stat(l10n.techPerfCompleted, '${p.totalCompleted}',
                  AppColors.statusSuccess),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: rate,
                    minHeight: 8,
                    backgroundColor:
                        isLight ? AppColors.lightBorder : AppColors.darkBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(rateColor),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(rate * 100).round()}%',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: rateColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) => Padding(
        padding: const EdgeInsetsDirectional.only(start: 16),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.headlineSmall.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 10,
                color: isLight ? AppColors.lightText4 : AppColors.darkText4,
              ),
            ),
          ],
        ),
      );
}
