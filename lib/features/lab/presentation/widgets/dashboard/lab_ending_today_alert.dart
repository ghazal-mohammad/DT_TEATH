// ════════════════════════════════════════════════════════════════════════════
// lab_ending_today_alert.dart
//
// صندوق تنبيه "طلبات تنتهي اليوم" في لوحة تحكم المخبر.
// مُستخرَج من lab_dashboard_page.dart ضمن تقسيم الصفحات العملاقة لودجات.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// تنبيه برتقالي يعرض الطلبات التي يحين تسليمها اليوم مع وقت كل منها.
class LabEndingTodayAlert extends StatelessWidget {
  const LabEndingTodayAlert({super.key});

  @override
  Widget build(BuildContext context) {
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
                        child: const Text(
                          '2',
                          textAlign: TextAlign.center,
                          style: TextStyle(
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

  List<Widget> _buildOrderPills(bool isLight) {
    // ترتيب التصميم المرجعي (RTL يمين→يسار):
    //   [16:00 جسر 3 وحدات — د. خالد] → [14:00 تلبيسة PFM — د. سارة]
    // الأقرب لـ deadline (14:00) في الأقصى يسار، والأبعد (16:00) أقرب للترويسة.
    const items = [
      _PillData(time: '16:00', body: 'جسر 3 وحدات — د. خالد'),
      _PillData(time: '14:00', body: 'تلبيسة PFM — د. سارة'),
    ];
    return items
        .map(
          (p) => Container(
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
                  p.time,
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
                  p.body,
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

class _PillData {
  const _PillData({required this.time, required this.body});
  final String time;
  final String body;
}
