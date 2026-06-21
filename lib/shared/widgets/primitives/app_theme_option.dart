// ════════════════════════════════════════════════════════════════════════════
// app_theme_option.dart
//
// بطاقة اختيار السمة (داكن/فاتح) الموحّدة — المصدر البصري: صفحة إعدادات
// المخبر (المعتمدة كمرجع لتوحيد النظامين):
//   - معاينة منقسمة اللون (60px) حسب الوضع
//   - دائرة ✓ على الزاوية عند التحديد
//   - حدود primary بسماكة 2 عند التحديد
//
// قاعدة التوحيد: صفحات الإعدادات في المخبر والمستودع تستخدم هذا الـ widget
// حصراً — ممنوع إعادة بناء بطاقة سمة محلياً.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';

/// بطاقة اختيار سمة واحدة (داكن أو فاتح).
class AppThemeOption extends StatelessWidget {
  const AppThemeOption({
    super.key,
    required this.label,
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  /// نص البطاقة (مثل "داكن" / "فاتح").
  final String label;

  /// الوضع الذي تمثّله البطاقة (يحدّد ألوان المعاينة).
  final ThemeMode mode;

  /// هل هذا هو الوضع المفعّل حالياً؟
  final bool selected;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(AppSizes.spaceSM),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: Border.all(
              color: selected
                  ? (isLight ? AppColors.primary : AppColors.brand)
                  : (isLight ? AppColors.lightBorder : AppColors.darkBorder),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              // Preview swatch
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    child: SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: _buildPreview(),
                    ),
                  ),
                  if (selected)
                    PositionedDirectional(
                      top: 6,
                      end: 6,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color:
                              isLight ? AppColors.primary : AppColors.brand,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color:
                      isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    switch (mode) {
      case ThemeMode.dark:
        // الوضع الغامق الفعلي: slate + لمسة إندِغو
        return Row(
          children: [
            Expanded(child: Container(color: AppColors.darkBg)),
            Expanded(child: Container(color: AppColors.brand)),
          ],
        );
      case ThemeMode.light:
        return Row(
          children: [
            Expanded(child: Container(color: const Color(0xFFE9ECFB))),
            Expanded(child: Container(color: const Color(0xFFF8F9FF))),
          ],
        );
      case ThemeMode.system:
        // "افتراضي النظام": نصف فاتح + نصف غامق ليدل أنه يتبع الجهاز.
        return Row(
          children: [
            Expanded(child: Container(color: const Color(0xFFE9ECFB))),
            Expanded(child: Container(color: AppColors.darkBg)),
          ],
        );
    }
  }
}
