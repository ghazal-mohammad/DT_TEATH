// ════════════════════════════════════════════════════════════════════════════
// app_topbar_action.dart
//
// زر أيقونة في التوب بار — مطابق لـ CSS class `.tb-ib`.
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — الأسطر 627–638
//
// القواعد الأصلية:
//   .tb-ib {
//     width:36px; height:36px; border-radius:10px;
//     background:rgba(158,251,236,0.06); border:1px solid var(--cyan-brd);
//     display:flex; align-items:center; justify-content:center;
//     font-size:15.5px; cursor:pointer; color:var(--t2);
//     transition:all 0.2s; position:relative;
//   }
//   .tb-ib:hover {
//     background:rgba(158,251,236,0.14);
//     border-color:var(--cyan-b);
//     transform:scale(1.06);
//   }
//   .tb-dot {
//     position:absolute; top:5px; right:5px;
//     width:7px; height:7px; border-radius:50%;
//     background:var(--red); border:1.5px solid #1A1C4E;
//     box-shadow:0 0 7px rgba(239,68,68,0.7);
//     animation:glowPulse 2s infinite;
//   }
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';

/// زر أيقونة في التوب بار مع badge اختياري للإشعارات.
///
/// يستخدم لأزرار: البحث، الإشعارات، الثيم، البروفايل، تسجيل الخروج.
/// يحتوي على hover effect يكبّر الأيقونة بـ scale 1.06.
/// يمكن إظهار نقطة حمراء نابضة كمؤشر إشعارات جديدة.
///
/// مثال:
/// ```dart
/// AppTopbarAction(
///   icon: AppIcons.bell,
///   onPressed: () => context.go(RouteNames.labNotifications),
///   hasDot: unreadCount > 0,
///   tooltip: l10n.notifications,
/// )
/// ```
class AppTopbarAction extends StatefulWidget {
  const AppTopbarAction({
    super.key,
    required this.icon,
    required this.onPressed,
    this.hasDot = false,
    this.tooltip,
  });

  /// الأيقونة المعروضة.
  final IconData icon;

  /// callback عند الضغط.
  final VoidCallback? onPressed;

  /// إذا true، تظهر نقطة حمراء نابضة (للإشعارات الجديدة).
  final bool hasDot;

  /// نص تلميح للـ accessibility — مطلوب لأزرار الأيقونات بلا نص.
  final String? tooltip;

  @override
  State<AppTopbarAction> createState() => _AppTopbarActionState();
}

class _AppTopbarActionState extends State<AppTopbarAction>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late final AnimationController _dotPulseController;

  @override
  void initState() {
    super.initState();
    // glow pulse animation: 2s infinite
    _dotPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _dotPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final bool isEnabled = widget.onPressed != null;

    // ── تحديد الألوان ─────────────────────────────────────────────────
    // لون اللمسة التفاعلية: كحلي بالفاتح، إندِغو (brand) بالغامق — صفر تركواز.
    final Color hot = isLight ? AppColors.primary : AppColors.brand;
    final Color bgColor = _isHovered
        ? hot.withValues(alpha: 0.14)
        : hot.withValues(alpha: isLight ? 0.12 : 0.06);

    final Color borderColor = _isHovered
        ? hot
        : (isLight ? AppColors.lightBorder : AppColors.darkBorder);

    final Color iconColor = _isHovered
        ? (isLight ? AppColors.primary : hot)
        : (isLight ? AppColors.lightText2 : AppColors.darkText2);

    Widget button = AnimatedContainer(
      duration: AppSizes.animationMedium,
      curve: Curves.easeOut,
      width: AppSizes.topbarActionSize, // 36×36
      height: AppSizes.topbarActionSize,
      transform: _isHovered && isEnabled
          ? (Matrix4.identity()..scale(1.06)) // من CSS: transform:scale(1.06)
          : Matrix4.identity(),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD), // r10
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              widget.icon,
              size: 15.5, // font-size:15.5px من CSS
              color: iconColor,
            ),
          ),
          // ── نقطة الإشعار النابضة (.tb-dot) ──────────────────────────
          if (widget.hasDot) _buildPulsingDot(),
        ],
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
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

  /// بناء النقطة النابضة (.tb-dot).
  /// من CSS: top:5px, right:5px, 7×7, red circle with glow pulse
  Widget _buildPulsingDot() {
    const Color dotColor = AppColors.alertRed; // --red

    return PositionedDirectional(
      top: 5, // من CSS
      end: 5, // في CSS: right:5px — في RTL = end
      child: AnimatedBuilder(
        animation: _dotPulseController,
        builder: (context, child) {
          // glow pulse: opacity من 1 إلى 0.6 والعودة
          final double pulseIntensity =
              0.4 + (_dotPulseController.value * 0.6);
          return Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              border: Border.all(
                // من CSS: border:1.5px solid #1A1C4E
                color: AppColors.primary,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  // من CSS: box-shadow:0 0 7px rgba(239,68,68,0.7)
                  color: dotColor.withValues(alpha: 0.7 * pulseIntensity),
                  blurRadius: 7,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
