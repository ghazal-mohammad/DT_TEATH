// ════════════════════════════════════════════════════════════════════════════
// lab_ending_today_alert.dart
//
// صندوق تنبيه "طلبات تنتهي اليوم" في لوحة تحكم المخبر.
// مُستخرَج من lab_dashboard_page.dart ضمن تقسيم الصفحات العملاقة لودجات.
//
// يعرض الطلبات الحقيقية المُمرَّرة له (LabDashboardState.ordersDueToday) —
// لا بيانات وهمية. لا يوجد حقل وقت حقيقي بالباك لهذه الطلبات (date تاريخ
// فقط)، لذا لا نعرض وقتاً مُختلَقاً.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/lab_order.dart';

/// صندوق تنبيه يعرض الطلبات الحقيقية التي يحين تسليمها اليوم.
class LabEndingTodayAlert extends StatelessWidget {
  const LabEndingTodayAlert({super.key, required this.ordersDueToday});

  /// الطلبات الحقيقية المستحقّة اليوم (من LabDashboardState.ordersDueToday).
  final List<LabOrderFull> ordersDueToday;

  @override
  Widget build(BuildContext context) {
    if (ordersDueToday.isEmpty) {
      return _buildEmpty(context);
    }

    const Color accent = AppColors.chipOrangeAccentLight;
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: isLight ? AppColors.chipOrangeBgLight : AppColors.darkChipOrangeBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          // أيقونة + عنوان (المجموعة اليمنى في RTL)
          final titleGroup = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  size: 20,
                  color: accent,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.labOrdersDueToday,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.statusUrgent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${ordersDueToday.length}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.labOrdersDueTodaySubtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isLight ? AppColors.lightText3 : AppColors.darkText3,
                    ),
                  ),
                ],
              ),
            ],
          );

          // عند العرض الواسع: العنوان يمين، والـ pills مدفوعة لأقصى اليسار
          // (WrapAlignment.end = اليسار في RTL).
          if (c.maxWidth > 640) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                titleGroup,
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: _buildOrderPills(isLight),
                  ),
                ),
              ],
            );
          }

          // عند العرض الضيّق: تدفّق طبيعي (Wrap) لتفادي أي overflow.
          return Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [titleGroup, ..._buildOrderPills(isLight)],
          );
        },
      ),
    );
  }

  /// حالة عدم وجود أي طلب مستحق اليوم — رسالة واضحة بدل صندوق برتقالي مضلِّل
  /// أو فراغ صامت.
  Widget _buildEmpty(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isLight ? AppColors.baseComponent : AppColors.darkBg1,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 20,
            color: AppColors.statusSuccess,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.labOrdersDueTodayEmpty,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: isLight ? AppColors.lightText2 : AppColors.darkText2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// pills العرض السريع لكل طلب حقيقي مستحق اليوم — النوع + الطبيب
  /// (لا وقت: date بالباك تاريخ فقط، بلا ساعة).
  List<Widget> _buildOrderPills(bool isLight) {
    return ordersDueToday
        .map(
          (order) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isLight ? Colors.white : AppColors.darkBg1,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.chipOrangeAccentLight.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  order.type,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '•',
                  style: TextStyle(color: AppColors.chipOrangeAccentLight),
                ),
                const SizedBox(width: 6),
                Text(
                  order.doctor,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isLight ? AppColors.lightText2 : AppColors.darkText2,
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}
