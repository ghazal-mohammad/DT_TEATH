// ════════════════════════════════════════════════════════════════════════════
// lab_orders_empty_state.dart
//
// الحالة الفارغة لشبكة طلبات الأطباء (لا طلبات ضمن الفئة المختارة)
// — مُستخرَجة من lab_orders_page.dart ضمن تقسيم الصفحات.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// رسالة "لا طلبات في هذه الفئة" تُعرض حين تكون الشبكة فارغة.
class LabOrdersEmptyState extends StatelessWidget {
  const LabOrdersEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 48,
            color: AppColors.iconMutedLight,
          ),
          const SizedBox(height: AppSizes.spaceMD),
          Text(
            context.l10n.labNoOrdersInCategory,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isLight ? AppColors.lightText3 : AppColors.darkText3,
            ),
          ),
        ],
      ),
    );
  }
}
