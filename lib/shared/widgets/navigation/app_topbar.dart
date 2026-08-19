// ════════════════════════════════════════════════════════════════════════════
// app_topbar.dart
//
// التوب بار الرئيسي — مطابق لـ CSS class `.tb`.
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — الأسطر 604–638
//
// القواعد الأصلية:
//   .tb {
//     height:64px; background:rgba(26,28,78,0.90);
//     backdrop-filter:blur(20px);
//     border-bottom:1px solid var(--cyan-brd);
//     padding:0 22px; display:flex; align-items:center; gap:11px;
//     position:sticky; top:0; z-index:50; flex-shrink:0;
//   }
//   .tb::after {
//     content:''; position:absolute; bottom:0; left:0; right:0; height:1px;
//     background:linear-gradient(90deg, transparent, var(--cyan-b), transparent);
//     opacity:0.3;
//   }
//   .tb-title { font-size:16px; font-weight:800; color:var(--t1) }
//   .tb-sub { font-size:12px; color:var(--t3); margin-top:2px }
//   .tb-r { margin-right:auto; display:flex; align-items:center; gap:7px }
//
// ملاحظة التخطيط:
//   - العنوان داخل Expanded يملأ المساحة ويُحاذى للبداية (يمين في RTL)، فيُدفع
//     البحث إلى الطرف الآخر (يسار) — يطابق `.tb-r { margin-right:auto }`.
//   - المحتوى موسَّط عمودياً عبر Stack(alignment: center).
// ════════════════════════════════════════════════════════════════════════════

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/l10n/build_context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_sizes.dart';
import '../command_palette/command_palette.dart';
import 'app_topbar_action.dart';
import 'app_topbar_search.dart';

/// التوب بار الرئيسي للتطبيق.
///
/// يحتوي على:
/// 1. زر قائمة (للموبايل فقط) — يفتح السايدبار كـ Drawer
/// 2. عنوان الصفحة + عنوان فرعي اختياري
/// 3. حقل بحث (إذا مُفعّل)
/// 4. أزرار إجراءات: جرس الإشعارات، مركز الأوامر (Ctrl+K)
///
/// يدعم backdrop blur لإعطاء تأثير زجاجي فوق المحتوى.
/// يدعم Light/Dark mode تلقائياً.
///
/// مثال:
/// ```dart
/// AppTopbar(
///   title: 'لوحة التحكم',
///   subtitle: 'مرحباً بك في نظام المخبر',
///   showSearch: true,
///   onSearchChanged: (q) => bloc.search(q),
///   onNotificationTap: () => context.go(RouteNames.labNotifications),
///   notificationCount: 3,
/// )
/// ```
class AppTopbar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopbar({
    super.key,
    required this.title,
    this.subtitle,
    this.showSearch = true,
    this.onSearchChanged,
    this.searchPlaceholder,
    this.onNotificationTap,
    this.notificationCount = 0,
    this.onMenuTap,
    this.showMenuButton = false,
  });

  /// عنوان الصفحة الرئيسي — يعرض بخط كبير.
  final String title;

  /// عنوان فرعي اختياري — يعرض بخط أصغر تحت العنوان.
  final String? subtitle;

  /// هل يُعرض حقل البحث؟
  final bool showSearch;

  /// callback لما النص في حقل البحث يتغيّر.
  final ValueChanged<String>? onSearchChanged;

  /// نص الـ placeholder لحقل البحث (null → يُحلّ عبر context.l10n.search).
  final String? searchPlaceholder;

  /// callback لفتح صفحة الإشعارات.
  final VoidCallback? onNotificationTap;

  /// عدد الإشعارات غير المقروءة — لو > 0 تظهر نقطة حمراء.
  final int notificationCount;

  /// callback لفتح السايدبار (في الموبايل).
  final VoidCallback? onMenuTap;

  /// هل يُعرض زر القائمة (للموبايل)؟
  final bool showMenuButton;

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.topbarHeight);

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    // من CSS: background:rgba(26,28,78,0.90)
    final Color bgColor = isLight
        ? AppColors.lightSurface.withValues(alpha: 0.92)
        : AppColors.primary.withValues(alpha: 0.90);

    final Color borderColor =
        isLight ? AppColors.lightBorder : AppColors.darkBorder;

    return ClipRect(
      child: BackdropFilter(
        // من CSS: backdrop-filter:blur(20px)
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: AppSizes.topbarHeight, // 64px
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.topbarPadding, // 22px
          ),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              bottom: BorderSide(color: borderColor),
            ),
          ),
          child: Stack(
            // توسيط المحتوى عمودياً داخل ارتفاع التوب بار (64px) بدل التصاقه
            // بالأعلى (الافتراضي topStart) — يبقى خط التوهّج السفلي Positioned.
            alignment: Alignment.center,
            children: [
              // ── المحتوى الرئيسي ────────────────────────────────────────
              Row(
                children: [
                  // ── زر القائمة (للموبايل فقط) ─────────────────────────
                  if (showMenuButton && onMenuTap != null) ...[
                    AppTopbarAction(
                      icon: AppIcons.menu,
                      onPressed: onMenuTap,
                      tooltip: context.l10n.menu,
                    ),
                    const SizedBox(width: AppSizes.topbarGap), // gap:11px
                  ],

                  // ── العنوان + العنوان الفرعي ─────────────────────────
                  // Expanded (لا Flexible+Spacer): العنوان يملأ المساحة ويُحاذى
                  // للبداية (يمين في RTL)، فيُدفع البحث لأقصى الجهة الأخرى
                  // (يسار) بدل أن يطفو في الوسط.
                  Expanded(child: _buildTitle(isLight)),

                  // ── الأدوات (بحث + جرس إشعارات + مركز أوامر) ──────────
                  _buildActions(context),
                ],
              ),

              // ── Pseudo-element ::after (خط glow في الأسفل) ──────────
              // من CSS: bottom:0, left:0, right:0, h:1px
              // background:linear-gradient(90deg, transparent, cyan-b, transparent)
              // opacity:0.3
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        (isLight ? AppColors.primary : AppColors.brand)
                            .withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء العنوان + العنوان الفرعي.
  Widget _buildTitle(bool isLight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 16, // من CSS: font-size:16px
            fontWeight: FontWeight.w800,
            height: 1.2,
            color: isLight ? AppColors.lightText1 : AppColors.darkText1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2), // margin-top:2px
          Text(
            subtitle!,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12, // من CSS: font-size:12px
              fontWeight: FontWeight.w500,
              height: 1.2,
              color: isLight ? AppColors.lightText3 : AppColors.darkText3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  /// بناء مجموعة الإجراءات (Search + Actions).
  Widget _buildActions(BuildContext context) {
    // البحث + جرس الإشعارات. أزرار الثيم/اللغة ليست هنا (مكانها صفحة
    // الإعدادات حصراً)، والبروفايل صار تبويباً داخل الإعدادات فلا زر له هنا.
    final bool wide = MediaQuery.of(context).size.width > 900;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // نُظهر حقل البحث فقط عند توفّر معالج فعلي (onSearchChanged) — كي لا يظهر
        // "صندوق بحث ميّت" في صفحات العرض (اللوحة/الإعدادات/الإشعارات) التي لا
        // تفلتر شيئاً. الصفحات ذات القوائم تربط المعالج فيظهر ويعمل.
        if (showSearch && onSearchChanged != null && wide) ...[
          AppTopbarSearch(
            onChanged: onSearchChanged,
            placeholder: searchPlaceholder,
          ),
          const SizedBox(width: AppSizes.spaceSM),
        ],
        // جرس الإشعارات — يظهر فقط لو الصفحة مررت معالجاً فعلياً (نفس منطق
        // إخفاء البحث)، والنقطة الحمراء تعكس notificationCount > 0.
        if (onNotificationTap != null) ...[
          AppTopbarAction(
            icon: AppIcons.notifications,
            onPressed: onNotificationTap,
            hasDot: notificationCount > 0,
            tooltip: context.l10n.notifications,
          ),
          const SizedBox(width: AppSizes.spaceSM),
        ],
        // زرّ مركز الأوامر (بحث عالمي Ctrl+K) — دائم، بديلٌ للفأرة عن الاختصار.
        const _CommandButton(),
      ],
    );
  }
}

/// زرّ يفتح مركز الأوامر (البحث العالمي) — يحترم الثيمين.
class _CommandButton extends StatelessWidget {
  const _CommandButton();

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final bool wide = MediaQuery.of(context).size.width > 900;
    final Color fg = isLight ? AppColors.lightText2 : AppColors.darkText2;
    return Tooltip(
      message: context.l10n.commandPaletteOpen,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => CommandPalette.show(context),
          child: Container(
            height: AppSizes.topbarSearchHeight,
            padding: EdgeInsets.symmetric(horizontal: wide ? 12 : 9),
            decoration: BoxDecoration(
              color: isLight ? AppColors.lightBg1 : AppColors.darkBg2,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                  color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(AppIcons.search, size: AppSizes.iconSM, color: fg),
                if (wide) ...[
                  const SizedBox(width: 6),
                  Text('Ctrl K',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: fg, fontWeight: FontWeight.w700)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
