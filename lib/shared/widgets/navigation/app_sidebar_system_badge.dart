// ════════════════════════════════════════════════════════════════════════════
// app_sidebar_system_badge.dart
//
// شارة النظام في السايدبار — مطابقة لـ CSS class `.sys-badge`.
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — الأسطر 510–522
//
// القواعد الأصلية:
//   .sys-badge {
//     margin:8px 12px; padding:6px 10px; border-radius:var(--r8);
//     display:flex; align-items:center; gap:6px;
//     font-size:14px; font-weight:700; position:relative; z-index:1;
//   }
//   .sys-badge.wh {
//     background:rgba(249,115,22,0.08);
//     border:1px solid rgba(249,115,22,0.2);
//     color:var(--orange);
//   }
//   .sys-badge.lab {
//     background:rgba(237,139,250,0.08);
//     border:1px solid rgba(237,139,250,0.2);
//     color:var(--violet);
//   }
//   .badge-blink {
//     width:6px; height:6px; border-radius:50%;
//     flex-shrink:0; animation:blink 1.5s ease-in-out infinite;
//   }
//
// الأنيميشن blink:
//   @keyframes blink { 0%,100%{opacity:1} 50%{opacity:0.4} }
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/theme/app_sizes.dart';
import '../core/app_system_type.dart';

/// شارة نظام مع نقطة نابضة — تُعرض أعلى السايدبار بعد اللوجو.
///
/// تبيّن للمستخدم: "أنت الآن في نظام المخبر" أو "نظام المستودع".
/// النقطة الصغيرة تنبض بلون النظام (blink animation مدّتها 1.5s).
///
/// مثال:
/// ```dart
/// AppSidebarSystemBadge(system: AppSystemType.lab)
/// ```
class AppSidebarSystemBadge extends StatefulWidget {
  const AppSidebarSystemBadge({
    super.key,
    required this.system,
  });

  /// نظام التطبيق الحالي — يحدد الألوان والنص.
  final AppSystemType system;

  @override
  State<AppSidebarSystemBadge> createState() => _AppSidebarSystemBadgeState();
}

class _AppSidebarSystemBadgeState extends State<AppSidebarSystemBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    // blink animation: 1.5s ease-in-out infinite
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // من CSS: margin:8px 12px
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      // من CSS: padding:6px 10px
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: widget.system.badgeBgColor,
        border: Border.all(
          color: widget.system.badgeBorderColor,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusSM), // r8
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── النقطة النابضة ───────────────────────────────────────────
          AnimatedBuilder(
            animation: _blinkController,
            builder: (context, child) {
              // blink: من opacity 1 إلى 0.4 والعودة
              final double opacity = 1.0 - (_blinkController.value * 0.6);
              return Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: widget.system.primaryColor.withValues(alpha: opacity),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.system.primaryColor
                          .withValues(alpha: opacity * 0.7),
                      blurRadius: 6,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 6), // gap:6px
          // ── نص الشارة ────────────────────────────────────────────────
          Flexible(
            child: Text(
              widget.system.shortLabel(context),
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14, // من CSS
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: widget.system.badgeTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
