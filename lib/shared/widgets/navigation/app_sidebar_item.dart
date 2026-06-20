// ════════════════════════════════════════════════════════════════════════════
// app_sidebar_item.dart
//
// عنصر تنقل واحد في السايدبار — مطابق لـ CSS class `.ni`.
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — الأسطر 531–562
//
// القواعد الأصلية:
//   .ni {
//     display:flex; align-items:center; gap:7px;
//     padding:7px 9px; border-radius:var(--r10);
//     color:var(--t3); font-size:15px; font-weight:600;
//     cursor:pointer; transition:all 0.2s;
//     margin-bottom:1px; position:relative; overflow:hidden;
//   }
//   .ni::after {
//     content:''; position:absolute; right:0; top:20%; bottom:20%;
//     width:2px; border-radius:1px;
//     background:var(--cyan-b); transform:scaleY(0); transition:transform 0.2s;
//   }
//   .ni:hover { color:var(--t1); background:rgba(158,251,236,0.08) }
//   .ni.on {
//     color:var(--cyan-b);
//     background:linear-gradient(90deg, rgba(158,251,236,0.15), rgba(158,251,236,0.03));
//   }
//   .ni.on::after { transform:scaleY(1) }
//
//   .ni-ico {
//     width:32px; height:32px; border-radius:8px;
//     display:flex; align-items:center; justify-content:center;
//     font-size:15.5px; flex-shrink:0; transition:all 0.2s;
//   }
//   .ni.on .ni-ico { background:rgba(158,251,236,0.16) }
//   .ni:not(.on) .ni-ico { background:rgba(255,255,255,0.04) }
//
//   .ni-bdg {
//     margin-right:auto; padding:1px 6px; border-radius:20px;
//     font-size:12px; font-weight:700;
//     background:rgba(239,68,68,0.15); color:#fca5a5;
//     border:1px solid rgba(239,68,68,0.3);
//     box-shadow:0 0 8px rgba(239,68,68,0.15);
//     animation:badgeBounce 0.3s cubic-bezier(0.34,1.56,0.64,1);
//   }
//
// ملاحظة RTL: في CSS `::after` يكون على `right:0` (يعني اليمين).
// لكن بما إننا في RTL، اليمين البصري في Flutter يصير start. نستخدم
// PositionedDirectional بحيث الشريط يظهر على الجانب اليمين من العنصر
// بشكل صحيح بغض النظر عن اتجاه النص.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../core/app_system_type.dart';

/// عنصر تنقل واحد في السايدبار.
///
/// يعرض أيقونة + نص + badge اختياري (مثل عدد الطلبات الجديدة).
/// يدعم 3 حالات بصرية: idle, hover, active — كل واحدة بلون مختلف.
/// اللون في الـ active state يتغيّر حسب [system] (Lab=وردي، Warehouse=سماوي).
///
/// في الـ collapsed mode (عرض ضيق)، يُعرض الأيقونة فقط مع tooltip.
///
/// مثال:
/// ```dart
/// AppSidebarItem(
///   icon: AppIcons.dashboard,
///   label: l10n.dashboard,
///   isActive: true,
///   system: AppSystemType.lab,
///   onTap: () => context.go(RouteNames.labDashboard),
/// )
/// ```
class AppSidebarItem extends StatefulWidget {
  const AppSidebarItem({
    super.key,
    required this.icon,
    required this.label,
    this.badge,
    this.isActive = false,
    this.system = AppSystemType.lab,
    this.onTap,
    this.collapsed = false,
  });

  /// أيقونة العنصر (من AppIcons).
  final IconData icon;

  /// نص العنصر (مترجم عبر l10n).
  final String label;

  /// شارة عدد اختيارية — تعرض رقماً (مثل عدد الإشعارات الجديدة).
  /// لو قيمتها null، ما تظهر.
  final String? badge;

  /// هل العنصر الحالي نشط (الصفحة الحالية)؟
  /// لما يكون نشط، يغيّر اللون والخلفية ويظهر شريط accent على اليمين.
  final bool isActive;

  /// نظام التطبيق — يحدد لون الـ active state.
  final AppSystemType system;

  /// القيمة لما المستخدم يضغط على العنصر.
  final VoidCallback? onTap;

  /// وضع العرض المطوي (للـ tablet/mobile).
  /// لما true، يُعرض الأيقونة فقط بدون نص، مع tooltip على hover.
  final bool collapsed;

  @override
  State<AppSidebarItem> createState() => _AppSidebarItemState();
}

class _AppSidebarItemState extends State<AppSidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // theme-aware: النشط مملوء بـ colorScheme.primary (كحلي بالفاتح، إندِغو بالغامق)
    // مع نص onPrimary. الفاتح يبقى مطابقاً تماماً للتصميم المرجعي.
    final ColorScheme cs = Theme.of(context).colorScheme;

    // ── تحديد الألوان حسب الحالة ────────────────────────────────────────
    final Color textColor = widget.isActive
        ? cs.onPrimary
        : _isHovered
            ? cs.primary
            : cs.onSurface;

    // خلفية العنصر — النشط مملوء بـ primary (مطابق للتصميم المرجعي)
    final Decoration decoration = widget.isActive
        ? BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          )
        : _isHovered
            ? BoxDecoration(
                color: cs.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              )
            : const BoxDecoration();

    // خلفية الأيقونة شفافة — نعتمد على لون النص نفسو للأيقونة
    final Color iconBgColor = Colors.transparent;

    // ── محتوى العنصر ─────────────────────────────────────────────────────
    Widget content = AnimatedContainer(
      duration: AppSizes.animationMedium,
      curve: Curves.easeOut,
      // مسافة أكبر بين العناصر (مثل الصورة — مسافة واضحة بين كل تبويب)
      margin: const EdgeInsets.only(bottom: 4),
      padding: EdgeInsets.symmetric(
        horizontal:
            widget.collapsed ? AppSizes.spaceXS : AppSizes.sidebarItemPaddingH,
        // padding عمودي أكبر لتتناسب مع ديزاين الطبيب
        vertical: widget.collapsed
            ? AppSizes.sidebarItemPaddingV
            : AppSizes.sidebarItemPaddingV + 3,
      ),
      decoration: decoration,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── أيقونة ─────────────────────────────────────────────────────
          // في ديزاين الطبيب: الأيقونة مباشرة بدون صندوق — نحقق ذلك
          // بجعل خلفية الصندوق شفافة تماماً في الحالة غير النشطة
          _buildIconBox(iconBgColor, textColor),

          // ── نص العنصر ─────────────────────────────────────────────────
          if (!widget.collapsed) ...[
            const SizedBox(width: 10), // مسافة أكبر بين الأيقونة والنص
            Expanded(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 15,
                  fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w600,
                  height: 1.2,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          // ── Badge ──────────────────────────────────────────────────────
          if (widget.badge != null && !widget.collapsed) ...[
            const SizedBox(width: AppSizes.spaceXS),
            _buildBadge(),
          ],
        ],
      ),
    );

    // الشريط الجانبي الـ accent محذوف — الخلفية الكحلية المملوءة كافية.

    // ── تغليف بـ MouseRegion و GestureDetector ────────────────────────
    Widget result = MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(onTap: widget.onTap, child: content),
    );

    // ── Tooltip في الوضع المطوي ───────────────────────────────────────
    if (widget.collapsed) {
      result = Tooltip(
        message: widget.label,
        child: result,
      );
    }

    return result;
  }

  /// بناء صندوق الأيقونة — في الحالة العادية بدون خلفية واضحة (مثل ديزاين الطبيب).
  Widget _buildIconBox(Color bgColor, Color iconColor) {
    // في الحالة العادية (غير نشط وغير hover): الأيقونة مباشرة بدون صندوق
    final Color effectiveBg = (widget.isActive || _isHovered)
        ? bgColor
        : Colors.transparent;

    return AnimatedContainer(
      duration: AppSizes.animationMedium,
      curve: Curves.easeOut,
      width: AppSizes.sidebarIconBoxSize,
      height: AppSizes.sidebarIconBoxSize,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
      ),
      child: Icon(
        widget.icon,
        // أيقونة أكبر قليلاً (مثل الصورة — أيقونات واضحة)
        size: 18,
        color: iconColor,
      ),
    );
  }

  /// بناء الـ badge — دائرة حمراء صغيرة برقم أبيض (مطابق للتصميم).
  Widget _buildBadge() {
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.isActive ? Colors.white : AppColors.alertRed,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        widget.badge!,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          height: 1.1,
          color: widget.isActive ? AppColors.primary : Colors.white,
        ),
      ),
    );
  }
}
