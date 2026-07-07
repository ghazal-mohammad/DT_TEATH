// ════════════════════════════════════════════════════════════════════════════
// app_error_view.dart
//
// واجهة خطأ لطيفة تحلّ محلّ مربّع الخطأ الافتراضي (الأحمر/الرمادي) في الإنتاج
// عبر ErrorWidget.builder. مستقلّة تمامًا: تُوفّر Directionality وألوانها بنفسها
// لأنها قد تُعرَض خارج MaterialApp/Localizations عند فشل بناء ودجت.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// بديل ودّي عند فشل بناء ودجت (تدهور رشيق بدل انهيار/شاشة حمراء).
class AppErrorView extends StatelessWidget {
  const AppErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: AppColors.bgGeneral,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 44,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'حدث خطأ غير متوقّع',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'يرجى تحديث الصفحة والمحاولة من جديد',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.guideSecondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
