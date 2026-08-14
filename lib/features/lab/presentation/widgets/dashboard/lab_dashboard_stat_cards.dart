// ════════════════════════════════════════════════════════════════════════════
// lab_dashboard_stat_cards.dart
//
// صف بطاقات الإحصاء في لوحة تحكم المخبر (اليوم/جاهز/قيد التصنيع/جديد).
// مُستخرَج من lab_dashboard_page.dart ضمن تقسيم الصفحات العملاقة لودجات.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// صف بطاقات الإحصاء الأربع في أعلى لوحة تحكم المخبر.
///
/// القيم محسوبة بالكامل من الطلبات الحقيقية (LabDashboardCubit). لا يوجد صف
/// اتجاه (trend) — الباك لا يوفّر بيانات تاريخية لحساب نِسَب حقيقية، وعرض
/// أرقام مُختلَقة كـ"+18% من الشهر الماضي" كان يضلّل المستخدم.
class LabDashboardStatCards extends StatelessWidget {
  const LabDashboardStatCards({
    super.key,
    required this.dueToday,
    required this.ready,
    required this.manufacturing,
    required this.newOrders,
  });

  /// طلبات تنتهي اليوم.
  final int dueToday;

  /// طلبات جاهزة للتسليم.
  final int ready;

  /// طلبات قيد التصنيع.
  final int manufacturing;

  /// طلبات جديدة.
  final int newOrders;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cards = <Widget>[
      _DashboardStatCard(
        // "عاجل" كانت تصف قيمة dueToday بشكل خاطئ (مفهوم إلحاح غير موجود
        // فعلياً بهذا العدّاد) — استُبدلت بتسمية صادقة: طلبات اليوم.
        chipLabel: l10n.labTodayOrders,
        chipColor: AppColors.statusUrgent,
        accentColor: AppColors.statusUrgent,
        icon: Icons.local_fire_department_rounded,
        value: '$dueToday',
        label: l10n.labStatUrgentToday,
      ),
      _DashboardStatCard(
        chipLabel: l10n.labChipThisMonth,
        chipColor: AppColors.statusSuccess,
        accentColor: AppColors.statusSuccess,
        icon: Icons.check_circle_rounded,
        value: '$ready',
        label: l10n.labStatReadyOrders,
      ),
      _DashboardStatCard(
        chipLabel: l10n.labChipActive,
        chipColor: AppColors.statusProgress,
        accentColor: AppColors.statusProgress,
        icon: Icons.adjust_rounded,
        value: '$manufacturing',
        label: l10n.labStatManufacturing,
      ),
      _DashboardStatCard(
        chipLabel: l10n.statusNew,
        chipColor: AppColors.statusInfo,
        accentColor: AppColors.statusInfo,
        icon: Icons.add_rounded,
        value: '$newOrders',
        label: l10n.labStatNewOrders,
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
  });

  final String chipLabel;
  final Color chipColor;
  final Color accentColor;
  final IconData icon;
  final String value;
  final String label;

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
