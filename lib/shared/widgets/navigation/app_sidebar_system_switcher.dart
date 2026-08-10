// ════════════════════════════════════════════════════════════════════════════
// app_sidebar_system_switcher.dart
//
// زر تبديل النظام في أسفل السايدبار — مطابق لـ CSS class `.sb-switch`.
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — الأسطر 565–587
//
// القواعد الأصلية:
//   .sb-switch {
//     margin:6px 10px 10px; padding:10px 12px;
//     background:rgba(255,255,255,0.03); border:1px solid var(--cyan-brd);
//     border-radius:var(--r12); display:flex; align-items:center; gap:8px;
//     cursor:pointer; transition:all 0.2s; position:relative; z-index:1;
//     overflow:hidden;
//   }
//   .sb-switch::before {
//     content:''; position:absolute; inset:0;
//     background:linear-gradient(90deg,transparent,rgba(158,251,236,0.04),transparent);
//     transform:translateX(-100%); transition:transform 0.5s;
//   }
//   .sb-switch:hover {
//     background:rgba(158,251,236,0.06);
//     border-color:var(--cyan-b);
//   }
//   .sb-switch:hover::before { transform:translateX(100%) }
//
//   .sw-av {
//     width:30px; height:30px; border-radius:50%;
//     background:linear-gradient(135deg,#1A1C4E,#ED8BFA);
//     display:flex; align-items:center; justify-content:center;
//     font-size:15px; font-weight:800; color:#fff;
//     box-shadow:0 0 10px rgba(158,251,236,0.2);
//   }
//   .sw-name { font-size:14px; font-weight:700; color:var(--t1) }
//   .sw-role { font-size:12px; color:var(--t3); margin-top:1px }
//   .sw-icon { margin-right:auto; color:var(--t3); font-size:16px }
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_sizes.dart';
import '../core/app_system_type.dart';

/// بطاقة معلومات المستخدم مع زر تبديل النظام.
///
/// تُعرض في أسفل السايدبار وتحتوي على:
/// - أفاتار بحرف واحد (أول حرف من الاسم)
/// - اسم المستخدم ودوره
/// - أيقونة سهم للتبديل
///
/// عند النقر، تُرسل إشارة إلى ViewModel/BLoC لتبديل النظام بين Lab و Warehouse.
///
/// مثال:
/// ```dart
/// AppSidebarSystemSwitcher(
///   currentSystem: AppSystemType.lab,
///   userName: 'شام',
///   userRole: l10n.roleLabManager,
///   onTap: () => cubit.switchSystem(),
/// )
/// ```
class AppSidebarSystemSwitcher extends StatefulWidget {
  const AppSidebarSystemSwitcher({
    super.key,
    required this.currentSystem,
    required this.userName,
    required this.userRole,
    required this.onTap,
    this.collapsed = false,
  });

  /// النظام الحالي — لتحديد لون الأفاتار والـ hover state.
  final AppSystemType currentSystem;

  /// اسم المستخدم (مثل "شام" أو "غزال").
  final String userName;

  /// الدور الوظيفي (مترجم عبر l10n — مثل `roleLabManager`).
  final String userRole;

  /// القيمة لما المستخدم يضغط على الكرت — للتبديل بين الأنظمة.
  /// null = المستخدم بدوره الحالي ما إله نظام تاني يبدّل عليه (لا يظهر سهم
  /// التبديل ولا يستجيب للنقر).
  final VoidCallback? onTap;

  /// وضع العرض المطوي — يعرض الأفاتار فقط.
  final bool collapsed;

  @override
  State<AppSidebarSystemSwitcher> createState() =>
      _AppSidebarSystemSwitcherState();
}

class _AppSidebarSystemSwitcherState extends State<AppSidebarSystemSwitcher> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    // idle: لمسة خفيفة. hover: لمسة براند (إندِغو).
    final Color bgColor = _isHovered
        ? AppColors.brand.withValues(alpha: 0.10)
        : (isLight
            ? AppColors.lightText1.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.04));

    final Color borderColor = _isHovered
        ? AppColors.brand
        : (isLight ? AppColors.lightBorder : AppColors.darkBorder);

    final Widget content = AnimatedContainer(
      duration: AppSizes.animationMedium, // 0.2s
      curve: Curves.easeOut,
      // من CSS: margin:6px 10px 10px
      margin: const EdgeInsetsDirectional.only(
        start: 10,
        end: 10,
        top: 6,
        bottom: 10,
      ),
      // من CSS: padding:10px 12px
      padding: widget.collapsed
          ? const EdgeInsets.all(AppSizes.spaceSM)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppSizes.radiusLG), // r12
      ),
      child: widget.collapsed
          ? _buildAvatar()
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAvatar(),
                const SizedBox(width: AppSizes.spaceSM), // gap:8px
                Expanded(child: _buildUserInfo(isLight)),
                if (widget.onTap != null) _buildSwitchIcon(isLight),
              ],
            ),
    );

    final bool canSwitch = widget.onTap != null;
    Widget result = MouseRegion(
      cursor: canSwitch ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: canSwitch ? (_) => setState(() => _isHovered = true) : null,
      onExit: canSwitch ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTap: widget.onTap,
        child: content,
      ),
    );

    if (widget.collapsed) {
      result = Tooltip(
        message: '${widget.userName} • ${widget.userRole}',
        child: result,
      );
    }

    return result;
  }

  /// بناء الأفاتار الدائري (.sw-av) — 30×30 مع gradient.
  Widget _buildAvatar() {
    // أول حرف من اسم المستخدم
    final String initial =
        widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?';

    return Container(
      width: AppSizes.sidebarAvatarSize, // 30×30
      height: AppSizes.sidebarAvatarSize,
      decoration: BoxDecoration(
        // من CSS: linear-gradient(135deg, #1A1C4E, #ED8BFA)
        // نستخدم لون النظام بدل الوردي الثابت لتوحيد الهوية
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            widget.currentSystem.primaryColor,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            // من CSS: box-shadow:0 0 10px rgba(158,251,236,0.2)
            color: AppColors.accent.withValues(alpha: 0.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 15, // font-size:15px
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }

  /// بناء معلومات المستخدم (اسم + دور).
  Widget _buildUserInfo(bool isLight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.userName,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14, // من CSS
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: isLight ? AppColors.lightText1 : AppColors.darkText1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 1), // margin-top:1px
        Text(
          widget.userRole,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12, // من CSS
            fontWeight: FontWeight.w500,
            height: 1.2,
            color: isLight ? AppColors.lightText3 : AppColors.darkText3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// بناء أيقونة السهم للتبديل (.sw-icon).
  Widget _buildSwitchIcon(bool isLight) {
    return Icon(
      AppIcons.switchSystem, // Iconsax.convert_card
      size: 16, // من CSS: font-size:16px
      color: isLight ? AppColors.lightText3 : AppColors.darkText3,
    );
  }
}
