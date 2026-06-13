// ════════════════════════════════════════════════════════════════════════════
// lab_dashboard_stat_cards.dart
//
// صف بطاقات الإحصاء في لوحة تحكم المخبر (عاجل/جاهز/قيد التصنيع/جديد).
// مُستخرَج من lab_dashboard_page.dart ضمن تقسيم الصفحات العملاقة لودجات.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// صف بطاقات الإحصاء الأربع في أعلى لوحة تحكم المخبر.
class LabDashboardStatCards extends StatelessWidget {
  const LabDashboardStatCards({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cards = <Widget>[
      _DashboardStatCard(
        chipLabel: l10n.priorityUrgent,
        chipColor: AppColors.statusUrgent,
        accentColor: AppColors.statusUrgent,
        icon: Icons.local_fire_department_rounded,
        value: '2',
        label: l10n.labStatUrgentToday,
        trendIcon: Icons.arrow_downward_rounded,
        trendText: l10n.labStatNeedsFollowup,
        trendColor: AppColors.statusUrgent,
      ),
      _DashboardStatCard(
        chipLabel: l10n.labChipThisMonth,
        chipColor: AppColors.statusSuccess,
        accentColor: AppColors.statusSuccess,
        icon: Icons.check_circle_rounded,
        value: '23',
        label: l10n.labStatReadyOrders,
        trendIcon: Icons.arrow_upward_rounded,
        trendText: l10n.labTrendFromLastMonth('+18%'),
        trendColor: AppColors.statusSuccess,
      ),
      _DashboardStatCard(
        chipLabel: l10n.labChipActive,
        chipColor: AppColors.statusProgress,
        accentColor: AppColors.statusProgress,
        icon: Icons.adjust_rounded,
        value: '7',
        label: l10n.labStatManufacturing,
        trendIcon: Icons.arrow_upward_rounded,
        trendText: l10n.labTrendFromYesterday('+1'),
        trendColor: AppColors.statusProgress,
      ),
      _DashboardStatCard(
        chipLabel: l10n.statusNew,
        chipColor: AppColors.statusInfo,
        accentColor: AppColors.statusInfo,
        icon: Icons.add_rounded,
        value: '4',
        label: l10n.labStatNewOrders,
        trendIcon: Icons.arrow_upward_rounded,
        trendText: l10n.labTrendFromYesterday('+2'),
        trendColor: AppColors.statusInfo,
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
