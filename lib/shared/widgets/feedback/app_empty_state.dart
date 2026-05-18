// ════════════════════════════════════════════════════════════════════════════
// app_empty_state.dart
//
// Widget للشاشات الفارغة — يُعرض عندما لا توجد بيانات لعرضها.
//
// يُستخدم في:
//   - الجداول الفارغة (لا توجد طلبات، لا توجد فواتير...)
//   - نتائج البحث الفارغة
//   - حالات الخطأ (تعذّر تحميل البيانات)
//
// المرجع البصري: لا يوجد mockup مخصص في HTML، لذلك نستخدم تصميماً متّسقاً
// مع باقي المشروع — أيقونة كبيرة مع نص عنوان ونص فرعي وزر اختياري.
//
// الأبعاد والألوان مستخرجة من نظام التصميم الموحّد (app_colors, app_sizes).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../primitives/app_button.dart';

/// أنواع الـ empty states المختلفة.
///
/// كل نوع يمثل لوناً ومؤشراً بصرياً مختلفاً.
enum AppEmptyStateVariant {
  /// محايد — لا توجد بيانات (خلفية رمادية، أيقونة باهتة).
  neutral,

  /// معلوماتي — لون سماوي (نتائج بحث فارغة، فلاتر...).
  info,

  /// تحذير — لون ذهبي (بيانات قيد الانتظار).
  warning,

  /// خطأ — لون وردي (تعذّر تحميل البيانات).
  error,
}

/// Widget لعرض شاشة فارغة أنيقة مع أيقونة وعنوان ورسالة وزر اختياري.
///
/// يُستخدم داخل الجداول، البطاقات، أو كامل الشاشة عند عدم وجود بيانات.
///
/// مثال:
/// ```dart
/// AppEmptyState(
///   icon: AppIcons.emptyBox,
///   title: AppStrings.emptyNoOrdersTitle,
///   message: AppStrings.emptyNoOrdersMessage,
///   actionLabel: AppStrings.add,
///   onActionTap: () => _showAddDialog(),
/// )
/// ```
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onActionTap,
    this.variant = AppEmptyStateVariant.neutral,
    this.compact = false,
  });

  /// أيقونة كبيرة تُعرض في الأعلى.
  final IconData icon;

  /// النص الرئيسي — يجب أن يكون قصيراً وواضحاً.
  /// مثال: "لا توجد طلبات"
  final String title;

  /// رسالة فرعية تشرح الحالة أو ترشد المستخدم للإجراء التالي.
  /// مثال: "ابدأ بإضافة أول طلب"
  final String? message;

  /// نص الزر الاختياري — يظهر فقط لو [onActionTap] موجود.
  final String? actionLabel;

  /// callback عند الضغط على الزر.
  final VoidCallback? onActionTap;

  /// نوع الـ empty state — يحدد لون الأيقونة والزر.
  final AppEmptyStateVariant variant;

  /// وضع مضغوط — أصغر حجماً (للاستخدام داخل بطاقات صغيرة).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final Color accentColor = _resolveAccentColor();

    final double iconSize = compact ? 48 : 72;
    final double iconBoxSize = compact ? 72 : 110;
    final EdgeInsets padding = compact
        ? const EdgeInsets.symmetric(
            vertical: AppSizes.space3XL,
            horizontal: AppSizes.spaceLG,
          )
        : const EdgeInsets.all(48);

    return Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── الأيقونة داخل دائرة ──────────────────────────────────────
          _buildIconBox(iconBoxSize, iconSize, accentColor, isLight),
          SizedBox(height: compact ? AppSizes.spaceLG : AppSizes.space2XL),

          // ── العنوان ─────────────────────────────────────────────────
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: compact ? 16 : 18,
              fontWeight: FontWeight.w800,
              height: 1.3,
              color: isLight ? AppColors.lightText1 : AppColors.darkText1,
            ),
          ),

          // ── الرسالة الفرعية ─────────────────────────────────────────
          if (message != null) ...[
            const SizedBox(height: AppSizes.spaceSM),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: compact ? 13 : 14,
                fontWeight: FontWeight.w500,
                height: 1.5,
                color: isLight ? AppColors.lightText3 : AppColors.darkText3,
              ),
            ),
          ],

          // ── زر الإجراء (اختياري) ────────────────────────────────────
          if (actionLabel != null && onActionTap != null) ...[
            SizedBox(height: compact ? AppSizes.spaceLG : AppSizes.space2XL),
            AppButton(
              label: actionLabel!,
              onPressed: onActionTap,
              variant: _resolveButtonVariant(),
              size: compact ? AppButtonSize.small : AppButtonSize.regular,
            ),
          ],
        ],
      ),
    );
  }

  /// بناء الأيقونة داخل دائرة شبه شفافة بلون الـ variant.
  Widget _buildIconBox(
    double boxSize,
    double iconSize,
    Color accentColor,
    bool isLight,
  ) {
    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accentColor.withValues(alpha: isLight ? 0.12 : 0.08),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
          width: AppSizes.borderThin,
        ),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: accentColor.withValues(alpha: 0.7),
      ),
    );
  }

  /// اللون الأساسي حسب الـ variant.
  Color _resolveAccentColor() {
    switch (variant) {
      case AppEmptyStateVariant.neutral:
        return AppColors.accent;
      case AppEmptyStateVariant.info:
        return AppColors.accent;
      case AppEmptyStateVariant.warning:
        return AppColors.warning;
      case AppEmptyStateVariant.error:
        return AppColors.error;
    }
  }

  /// نوع الزر المناسب للـ variant.
  AppButtonVariant _resolveButtonVariant() {
    switch (variant) {
      case AppEmptyStateVariant.neutral:
      case AppEmptyStateVariant.info:
        return AppButtonVariant.primary;
      case AppEmptyStateVariant.warning:
      case AppEmptyStateVariant.error:
        return AppButtonVariant.secondary;
    }
  }
}
