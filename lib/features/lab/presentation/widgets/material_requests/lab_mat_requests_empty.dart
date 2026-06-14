// ════════════════════════════════════════════════════════════════════════════
// lab_mat_requests_empty.dart
//
// الحالة الفارغة لقائمة طلبات المواد — مُستخرَجة من lab_material_requests_page.dart
// ضمن تقسيم الصفحات.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// رسالة "لا طلبات في هذه الفئة" لقائمة طلبات المواد.
class LabMatRequestsEmpty extends StatelessWidget {
  const LabMatRequestsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(
            AppIcons.emptyInbox,
            size: 48,
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.lightText4
                : AppColors.darkText4,
          ),
          const SizedBox(height: AppSizes.spaceMD),
          Text(context.l10n.labReqEmptyCategory, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
