// ════════════════════════════════════════════════════════════════════════════
// app_sidebar_section.dart
//
// عنوان قسم في السايدبار — مطابق لـ CSS class `.sec-lbl`.
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — الأسطر 526–530
//
// القواعد الأصلية:
//   .sec-lbl{
//     font-size:11.5px; font-weight:700; color:var(--t4);
//     letter-spacing:1.8px; text-transform:uppercase;
//     padding:0 7px; margin:10px 0 3px;
//   }
//
// يُستخدم لتصنيف عناصر السايدبار إلى مجموعات مثل:
//   - "الرئيسية" / "MAIN"
//   - "المخزون" / "INVENTORY"
//   - "المالية" / "FINANCE"
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';

/// عنوان قسم في السايدبار.
///
/// يظهر فوق مجموعة من [AppSidebarItem] لتصنيفها منطقياً.
/// النص يُعرض بخط صغير مع letter-spacing واسع، وبلون خافت (t4).
///
/// في وضع `collapsed`، يُخفى العنوان تلقائياً (يظهر خط فاصل بدلاً منه).
///
/// مثال:
/// ```dart
/// AppSidebarSection(title: 'الرئيسية')
/// ```
class AppSidebarSection extends StatelessWidget {
  const AppSidebarSection({
    super.key,
    required this.title,
    this.collapsed = false,
  });

  /// نص العنوان (مترجم عبر l10n). يُعرض بأحرف uppercase في اللاتيني.
  final String title;

  /// إذا true، يُخفى النص ويُعرض خط فاصل بدلاً منه (للـ mobile).
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    // قسم بدون عنوان → نضع فقط فاصل علوي خفيف للفصل البصري
    if (title.isEmpty) {
      return const SizedBox(height: 6);
    }

    // في الوضع المطوي (collapsed)، نعرض divider بدل النص
    if (collapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceSM,
          vertical: AppSizes.spaceSM,
        ),
        child: Container(
          height: AppSizes.borderThin,
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      );
    }

    return Padding(
      // مسافة أكبر فوق كل قسم لتمييزه بصرياً
      padding: const EdgeInsets.fromLTRB(7, 14, 7, 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: isLight
                  ? AppColors.lightBorder
                  : AppColors.darkBorder.withValues(alpha: 0.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              title,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.2,
                letterSpacing: 1.5,
                color: isLight ? AppColors.lightText4 : AppColors.darkText4,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: isLight
                  ? AppColors.lightBorder
                  : AppColors.darkBorder.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
