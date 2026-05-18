// ════════════════════════════════════════════════════════════════════════════
// app_button.dart
//
// زر موحّد مطابق للـ CSS classes: .btn, .btn-p, .btn-s, .btn-d, .btn-sm
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — الأسطر 769–776
//
// القواعد الأصلية:
//   .btn    { padding:10px 20px; border-radius:var(--r8); font-size:14px;
//             font-weight:700; transition:all 0.2s; }
//   .btn-p  { background:linear-gradient(135deg,#1A1C4E,#13154e); color:#fff;
//             box-shadow:0 4px 14px rgba(26,28,78,0.25); }
//   .btn-p:hover { transform:translateY(-1px);
//             box-shadow:0 6px 20px rgba(26,28,78,0.35); }
//   .btn-s  { background:rgba(255,255,255,0.04); color:var(--t2);
//             border:1px solid var(--cyan-brd); }
//   .btn-d  { background:rgba(237,139,250,0.12); color:#9333ea;
//             border:1px solid rgba(237,139,250,0.3); }
//   .btn-sm { padding:5px 10px; font-size:13.5px; }
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';

/// أنواع الأزرار في النظام.
enum AppButtonVariant {
  /// زر أساسي — gradient داكن (`.btn-p`). للإجراءات الرئيسية: "حفظ"، "إرسال".
  primary,

  /// زر ثانوي — شفّاف بحدود (`.btn-s`). للإجراءات الجانبية: "إلغاء"، "تراجع".
  secondary,

  /// زر خطر — أرجواني شفّاف (`.btn-d`). للإجراءات الحذرة: "حذف"، "إلغاء طلب".
  danger,
}

/// أحجام الأزرار المتاحة.
enum AppButtonSize {
  /// الحجم العادي — padding:10px 20px، font-size:14px.
  regular,

  /// الحجم الصغير (`.btn-sm`) — padding:5px 10px، font-size:13.5px.
  small,
}

/// زر موحّد مطابق لنظام التصميم في HTML.
///
/// - يدعم الحالات: default, hover (عبر MouseRegion), pressed, disabled, loading
/// - يتعامل بشكل صحيح مع RTL (الأيقونة على اليمين في العربية)
/// - يحترم الـ theme الحالي
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.regular,
    this.icon,
    this.isLoading = false,
    this.expanded = false,
  });

  /// إنشاء زر أساسي اختصاراً.
  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.regular,
    this.icon,
    this.isLoading = false,
    this.expanded = false,
  }) : variant = AppButtonVariant.primary;

  /// إنشاء زر ثانوي اختصاراً.
  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.regular,
    this.icon,
    this.isLoading = false,
    this.expanded = false,
  }) : variant = AppButtonVariant.secondary;

  /// إنشاء زر خطر اختصاراً.
  const AppButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.regular,
    this.icon,
    this.isLoading = false,
    this.expanded = false,
  }) : variant = AppButtonVariant.danger;

  /// النص المعروض على الزر.
  final String label;

  /// دالّة النقر. `null` = الزر معطّل.
  final VoidCallback? onPressed;

  /// نوع الزر.
  final AppButtonVariant variant;

  /// الحجم.
  final AppButtonSize size;

  /// أيقونة اختياريّة تظهر قبل النص (في اليمين في RTL).
  final IconData? icon;

  /// إذا كانت true، يُعرض CircularProgressIndicator بدلاً من النص.
  final bool isLoading;

  /// يمتلك كل العرض المتاح. للاستخدام في الـ forms.
  final bool expanded;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null && !widget.isLoading;
    final EdgeInsets padding = widget.size == AppButtonSize.small
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
        : const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
    final double fontSize = widget.size == AppButtonSize.small ? 13.5 : 14;

    final Widget child = _buildContent(fontSize);

    // transform:translateY(-1px) عند hover للـ primary
    final double translateY =
        (_isHovered && isEnabled && widget.variant == AppButtonVariant.primary)
        ? -1.0
        : 0.0;

    final Widget button = AnimatedContainer(
      duration: const Duration(milliseconds: 200), // transition:all 0.2s
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, translateY, 0),
      padding: padding,
      decoration: _buildDecoration(context, isEnabled),
      child: child,
    );

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: isEnabled ? widget.onPressed : null,
        child: widget.expanded
            ? SizedBox(width: double.infinity, child: button)
            : button,
      ),
    );
  }

  Widget _buildContent(double fontSize) {
    if (widget.isLoading) {
      return SizedBox(
        height: fontSize + 4,
        width: fontSize + 4,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_resolveForegroundColor()),
        ),
      );
    }

    final Color fg = _resolveForegroundColor();
    final TextStyle textStyle = TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: fg,
      height: 1.2,
    );

    if (widget.icon == null) {
      return Center(
        child: Text(
          widget.label,
          style: textStyle,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Row(
      mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(widget.icon, size: fontSize + 2, color: fg),
        const SizedBox(width: 8),
        Text(widget.label, style: textStyle),
      ],
    );
  }

  BoxDecoration _buildDecoration(BuildContext context, bool isEnabled) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final BorderRadius radius = BorderRadius.circular(AppSizes.radiusSM); // r8
    final double opacity = isEnabled ? 1.0 : 0.5;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        // linear-gradient(135deg,#1A1C4E,#13154e)
        final double shadowBlur = (_isHovered && isEnabled) ? 20 : 14;
        final double shadowY = (_isHovered && isEnabled) ? 6 : 4;
        final double shadowOpacity = (_isHovered && isEnabled) ? 0.35 : 0.25;

        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight, // 135deg تقريباً
            colors: [
              const Color(0xFF1A1C4E).withValues(alpha: opacity),
              const Color(0xFF13154E).withValues(alpha: opacity),
            ],
          ),
          borderRadius: radius,
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: const Color(0xFF1A1C4E).withValues(
                      alpha: shadowOpacity,
                    ),
                    blurRadius: shadowBlur,
                    offset: Offset(0, shadowY),
                  ),
                ]
              : null,
        );

      case AppButtonVariant.secondary:
        // background:rgba(255,255,255,0.04); border:1px solid var(--cyan-brd)
        return BoxDecoration(
          color: isLight
              ? const Color(0x0A1A1C4E) // 0.04 on light
              : const Color(0x0AFFFFFF), // 0.04 on dark
          borderRadius: radius,
          border: Border.all(
            color: isLight
                ? AppColors.lightBorder
                : AppColors.darkBorder,
          ),
        );

      case AppButtonVariant.danger:
        // background:rgba(237,139,250,0.12); border:rgba(237,139,250,0.3)
        // 0x1F = 31 ≈ 0.12 * 255 (للـ alpha channel)
        // 0x4D = 77 ≈ 0.30 * 255
        return BoxDecoration(
          color: const Color(0x1FED8BFA).withValues(alpha: 0.12 * opacity),
          borderRadius: radius,
          border: Border.all(color: const Color(0x4DED8BFA)),
        );
    }
  }

  Color _resolveForegroundColor() {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return Colors.white;
      case AppButtonVariant.secondary:
        return isLight ? AppColors.lightText2 : AppColors.darkText2;
      case AppButtonVariant.danger:
        return const Color(0xFF9333EA);
    }
  }
}
