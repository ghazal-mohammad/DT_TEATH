// ════════════════════════════════════════════════════════════════════════════
// lab_products_stats.dart
//
// بطاقة إحصاء كتالوج المخبر (إجمالي المنتجات) — مُستخرَجة من lab_products_page.dart
// ضمن تقسيم الصفحات العملاقة.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// صف إحصاء كتالوج المنتجات (بطاقة الإجمالي).
class LabProductsStatsRow extends StatelessWidget {
  const LabProductsStatsRow({super.key, required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _StatCard(
      accent: AppColors.statusProgress,
      icon: Icons.category_outlined,
      value: '$total',
      label: l10n.labProdTotal,
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.accent,
    required this.icon,
    required this.value,
    required this.label,
  });

  final Color accent;
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final radius = BorderRadius.circular(AppSizes.radiusLG);
    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.darkBg1,
        borderRadius: radius,
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            PositionedDirectional(
              end: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 4, color: accent),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 14, 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 20, color: accent),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                          color: isLight
                              ? AppColors.lightText1
                              : AppColors.darkText1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isLight
                              ? AppColors.lightText3
                              : AppColors.darkText3,
                          fontWeight: FontWeight.w600,
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
    );
  }
}
