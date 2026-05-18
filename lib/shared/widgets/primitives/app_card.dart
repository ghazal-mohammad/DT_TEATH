// ════════════════════════════════════════════════════════════════════════════
// app_card.dart
//
// بطاقة glass morphism موحّدة — `.card` + header `.ch`
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — الأسطر 656–681
//
// القواعد الأصلية:
//   .card { background:var(--surface); border:1px solid var(--cyan-brd);
//           border-radius:var(--r16); backdrop-filter:blur(20px);
//           box-shadow:var(--s1); transition:all 0.25s; overflow:hidden; }
//   .card::before { content:''; position:absolute; top:0; left:0; right:0;
//             height:1px; background:linear-gradient(90deg,transparent,
//             rgba(158,251,236,0.4),transparent); opacity:0; }
//   .card:hover { border-color:rgba(158,251,236,0.35);
//             box-shadow:var(--s2),0 0 0 1px rgba(158,251,236,0.08); }
//   .card:hover::before { opacity:1 }
//
//   .ch { padding:16px 20px; border-bottom:1px solid var(--cyan-brd);
//         display:flex; align-items:center; gap:8px;
//         background:rgba(158,251,236,0.03); }
//   .ch-t { font-size:15px; font-weight:700; color:var(--t1) }
//   .ch-b { font-size:12px; font-weight:700; color:var(--cyan-b);
//           background:rgba(158,251,236,0.12); padding:2px 8px;
//           border-radius:20px }
//   .ch-a { margin-right:auto; font-size:14px; font-weight:700;
//           color:var(--cyan-b); cursor:pointer; }
//
// ملاحظة تقنية: Flutter لا يدعم backdrop-filter بنفس طريقة CSS. نستخدم
// BackdropFilter حين يكون العنصر فوق محتوى، ونكتفي بـ surface color
// شفّاف قليلاً عندما لا يكون ذلك مطلوباً بصرياً.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';

/// بطاقة glass morphism — الحاوية الأساسية لكل محتوى في الشاشة.
///
/// تُستخدم لتجميع: الجداول، النماذج، الإحصاءات، الأقسام...
/// تدعم header اختياري (`.ch`) مع عنوان وشارة وزر action.
///
/// مثال:
/// ```dart
/// AppCard(
///   header: AppCardHeader(
///     title: 'طلبات المخبر',
///     badge: '12',
///     actionLabel: 'عرض الكل',
///     onActionTap: () { ... },
///   ),
///   child: MyDataTable(...),
/// )
/// ```
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.header,
    this.padding = const EdgeInsets.all(AppSizes.spaceLG),
    this.enableBackdropBlur = true,
    this.onTap,
  });

  /// المحتوى الرئيسي للبطاقة (تحت الـ header إن وُجد).
  final Widget child;

  /// رأس البطاقة اختياري — يظهر أعلى الـ child بفاصل.
  final AppCardHeader? header;

  /// الـ padding حول `child` (الـ header له padding ثابت خاص به).
  final EdgeInsets padding;

  /// تفعيل backdrop-filter (blur 20px). يُعطَّل في الأداء الحرج.
  final bool enableBackdropBlur;

  /// إذا تم تمريرها، تصبح البطاقة قابلة للنقر.
  final VoidCallback? onTap;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    final Color borderColor = _isHovered
        ? const Color(0x599EFBEC) // rgba(158,251,236,0.35)
        : (isLight ? AppColors.lightBorder : AppColors.darkBorder);

    final Color surfaceColor = isLight
        ? AppColors.lightSurface
        : AppColors.darkSurface;

    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 250), // transition 0.25s
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL), // r16
        boxShadow: [
          BoxShadow(
            color: _isHovered
                ? AppColors.shadowMedium // s2
                : AppColors.shadowLight, // s1
            blurRadius: _isHovered ? 28 : 20,
            offset: const Offset(0, 4),
          ),
          if (_isHovered)
            const BoxShadow(
              color: const Color(0x149EFBEC), // 0.08 glow
              blurRadius: 0,
              spreadRadius: 1,
            ),
        ],
      ),
      clipBehavior: Clip.antiAlias, // overflow:hidden
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.header != null) widget.header!,
          Padding(padding: widget.padding, child: widget.child),
        ],
      ),
    );

    // تطبيق backdrop-filter:blur(20px) — يعمل فقط فوق محتوى (stack).
    if (widget.enableBackdropBlur) {
      card = ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: card,
        ),
      );
    }

    card = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: card,
    );

    if (widget.onTap != null) {
      card = GestureDetector(onTap: widget.onTap, child: card);
    }

    return card;
  }
}

/// رأس البطاقة — `.ch` في HTML.
///
/// يحتوي على:
/// - عنوان (`.ch-t`)
/// - شارة عدد اختيارية (`.ch-b`)
/// - زر نص على اليسار اختياري (`.ch-a`) — مفيد لـ "عرض الكل"
///
/// [accentColor]: لون الشارة والـ badge. الافتراضي = [AppColors.accent] (سماوي).
/// يُستخدم مع Warehouse أو Lab بتمرير لونهما الخاص — بدل [WarehouseDashboardCard].
class AppCardHeader extends StatelessWidget {
  const AppCardHeader({
    super.key,
    required this.title,
    this.badge,
    this.actionLabel,
    this.onActionTap,
    this.leadingIcon,
    this.accentColor, // null → AppColors.accent
  });

  final String title;
  final String? badge;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final IconData? leadingIcon;

  /// لون مخصص للـ badge والـ action text.
  /// - Lab pages    → AppColors.labSystem
  /// - Warehouse    → AppColors.warehouseSystem
  /// - null         → AppColors.accent (افتراضي)
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    // accentColor: يُستخدم لتلوين الـ badge — null → AppColors.accent
    final Color effective = accentColor ?? AppColors.accent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        // خلفية الـ header: لون accent بنسبة شفافية 3%
        color: effective.withValues(alpha: 0.03),
        border: Border(
          bottom: BorderSide(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            Icon(
              leadingIcon,
              size: 18,
              color: isLight ? AppColors.lightText1 : AppColors.darkText1,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isLight ? AppColors.lightText1 : AppColors.darkText1,
              height: 1.2,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: effective.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge!,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isLight ? AppColors.primary : effective,
                  height: 1.2,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (actionLabel != null && onActionTap != null)
            _CardHeaderAction(
              label: actionLabel!,
              onTap: onActionTap!,
              accentColor: effective,
            ),
        ],
      ),
    );
  }
}

/// زر النص في رأس البطاقة (مثال: "عرض الكل").
class _CardHeaderAction extends StatefulWidget {
  const _CardHeaderAction({
    required this.label,
    required this.onTap,
    required this.accentColor,
  });
  final String label;
  final VoidCallback onTap;
  final Color accentColor;

  @override
  State<_CardHeaderAction> createState() => _CardHeaderActionState();
}

class _CardHeaderActionState extends State<_CardHeaderAction> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _isHovered ? 0.7 : 1.0,
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isLight ? AppColors.primary : widget.accentColor,
            ),
          ),
        ),
      ),
    );
  }
}
