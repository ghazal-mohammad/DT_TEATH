// ════════════════════════════════════════════════════════════════════════════
// app_icon_button.dart
//
// زر أيقونة موحّد مطابق للـ CSS class `.ib` وtypes المختلفة
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — الأسطر 778–789
//
// القواعد الأصلية:
//   .ib { width:32px; height:32px; border-radius:8px;
//         border:1px solid var(--cyan-brd); background:rgba(255,255,255,0.03);
//         transition:all 0.2s cubic-bezier(0.34,1.4,0.64,1); }
//   .ib:hover { transform:scale(1.12); background:rgba(158,251,236,0.12);
//               border-color:var(--cyan-b); }
//   .ib.p { background:linear-gradient(135deg,#1A1C4E,#13154e); color:#fff; }
//   .ib.w { background:rgba(237,251,158,0.18); color:#1A1C4E; }
//   .ib.d { background:rgba(237,139,250,0.15); color:#9333ea; }
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// أنواع زر الأيقونة المربّع.
enum AppIconButtonVariant {
  /// الشكل الافتراضي — شفّاف بحدود سماويّة (`.ib`).
  neutral,

  /// Primary — gradient داكن (`.ib.p`).
  primary,

  /// Warning — ذهبي مع خلفية فاتحة (`.ib.w`).
  warning,

  /// Danger — وردي مع نص أرجواني (`.ib.d`).
  danger,
}

/// زر أيقونة مربّع (32x32) موحّد.
///
/// يُستخدم في:
/// - الـ topbar (جرس الإشعارات، الإعدادات)
/// - أعمدة الإجراءات في الجداول (تعديل، حذف، عرض التفاصيل)
/// - القوائم المنبثقة
///
/// مثال:
/// ```dart
/// AppIconButton(
///   icon: Icons.edit,
///   onPressed: () => editItem(item),
///   variant: AppIconButtonVariant.primary,
///   tooltip: 'تعديل',
/// )
/// ```
class AppIconButton extends StatefulWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.variant = AppIconButtonVariant.neutral,
    this.tooltip,
    this.size = 32,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final AppIconButtonVariant variant;

  /// تلميح للـ accessibility (مطلوب لكل زر أيقونة بلا نص).
  final String? tooltip;

  /// حجم الزر (العرض = الارتفاع). الافتراضي 32px.
  final double size;

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;

    Widget button = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: const Cubic(0.34, 1.4, 0.64, 1), // cubic-bezier exact
      width: widget.size,
      height: widget.size,
      transform: _isHovered && isEnabled
          ? (Matrix4.identity()..scale(1.12)) // scale(1.12) مطابق
          : Matrix4.identity(),
      transformAlignment: Alignment.center,
      decoration: _buildDecoration(context),
      child: Icon(
        widget.icon,
        size: 14, // font-size:14px في HTML الأصلي
        color: _resolveIconColor(context),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return MouseRegion(
      cursor: isEnabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(onTap: widget.onPressed, child: button),
    );
  }

  BoxDecoration _buildDecoration(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    switch (widget.variant) {
      case AppIconButtonVariant.neutral:
        return BoxDecoration(
          color: _isHovered
              ? const Color(0x1F9EFBEC) // rgba(158,251,236,0.12)
              : (isLight
                    ? const Color(0x081A1C4E) // 0.03 light
                    : const Color(0x08FFFFFF)), // 0.03 dark
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isHovered
                ? AppColors.accent
                : (isLight ? AppColors.lightBorder : AppColors.darkBorder),
          ),
        );

      case AppIconButtonVariant.primary:
        return BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1C4E), Color(0xFF13154E)],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A1C4E).withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        );

      case AppIconButtonVariant.warning:
        return BoxDecoration(
          color: const Color(0x2EEDFB9E), // rgba(237,251,158,0.18)
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0x4D9EFBEC)),
        );

      case AppIconButtonVariant.danger:
        return BoxDecoration(
          color: const Color(0x26ED8BFA), // rgba(237,139,250,0.15)
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0x4DED8BFA)),
        );
    }
  }

  Color _resolveIconColor(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    switch (widget.variant) {
      case AppIconButtonVariant.neutral:
        return isLight ? AppColors.lightText2 : AppColors.darkText2;
      case AppIconButtonVariant.primary:
        return Colors.white;
      case AppIconButtonVariant.warning:
        return const Color(0xFF1A1C4E);
      case AppIconButtonVariant.danger:
        return const Color(0xFF9333EA);
    }
  }
}
