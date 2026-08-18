// ════════════════════════════════════════════════════════════════════════════
// app_sidebar.dart
//
// السايدبار الرئيسي لنظام DT.Teeth — مطابق لـ CSS class `.sb`.
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — الأسطر 472–507
//
// القواعد الأصلية:
//   .sb {
//     width:232px; flex-shrink:0; height:100vh;
//     position:sticky; top:0;
//     background:linear-gradient(180deg, #1A1C4E, #0f1035);
//     display:flex; flex-direction:column;
//     border-left:1px solid var(--cyan-brd);  /* في LTR = اليسار */
//     overflow:hidden; z-index:100; position:relative;
//   }
//
//   .sb::before {
//     content:''; position:absolute;
//     top:-80px; right:-60px; width:200px; height:200px; border-radius:50%;
//     background:radial-gradient(circle, rgba(158,251,236,0.08), transparent 70%);
//     pointer-events:none; animation:glowPulse 5s ease-in-out infinite;
//   }
//   .sb::after {
//     content:''; position:absolute;
//     bottom:-60px; left:-40px; width:160px; height:160px; border-radius:50%;
//     background:radial-gradient(circle, rgba(237,139,250,0.05), transparent 70%);
//     pointer-events:none;
//   }
//
//   .sb-top {
//     padding:16px 14px; border-bottom:1px solid var(--cyan-brd);
//     display:flex; align-items:center; gap:10px;
//   }
//   .sb-logo-icon {
//     width:38px; height:38px; border-radius:10px;
//     background:linear-gradient(135deg, #1A1C4E, #9EFBEC);
//     ...
//   }
//
//   .sys-sep {
//     text-align:center; padding:5px 8px; font-size:12px;
//     font-weight:700; letter-spacing:1px; color:var(--t4);
//     text-transform:uppercase;
//   }
//   .sys-sep::before, .sys-sep::after {
//     content:''; position:absolute; top:50%;
//     width:calc(50% - 36px); height:1px; background:var(--cyan-brd);
//   }
//
// ملاحظات RTL:
//   - في الـ HTML الأصلي، border-left يفصل السايدبار عن المحتوى.
//   - في Flutter RTL، السايدبار يكون على اليمين، فالحد الفاصل يكون على اليسار
//     وهذا بالضبط ما يعنيه `border-left` في CSS. نحن نطبّق نفس السلوك.
//   - الـ glow ::before (top-right في CSS) = in RTL = top-start = top-right بصرياً.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../core/l10n/build_context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../brand/app_logo.dart';
import '../core/app_system_type.dart';
import 'app_sidebar_item.dart';
import 'app_sidebar_section.dart';
import 'app_sidebar_system_badge.dart';
import 'app_sidebar_system_switcher.dart';

// ══════════════════════════════════════════════════════════════════════════
//                          DATA CLASSES
// ══════════════════════════════════════════════════════════════════════════

/// بيانات عنصر سايدبار واحد — بدون بناء الـ Widget.
///
/// يُستخدم عند تمرير قائمة عناصر إلى [AppSidebar] بدل بنائها يدوياً.
class SidebarItemData {
  const SidebarItemData({
    required this.icon,
    required this.label,
    required this.route,
    this.badge,
  });

  final IconData icon;
  final String label;
  final String route;
  final String? badge;
}

/// قسم في السايدبار — يجمع عدة عناصر تحت عنوان.
class SidebarSectionData {
  const SidebarSectionData({
    required this.title,
    required this.items,
  });

  /// عنوان القسم (مترجم عبر l10n).
  final String title;

  /// قائمة العناصر ضمن القسم.
  final List<SidebarItemData> items;
}

// ══════════════════════════════════════════════════════════════════════════
//                          MAIN SIDEBAR WIDGET
// ══════════════════════════════════════════════════════════════════════════

/// السايدبار الرئيسي لنظام DT.Teeth.
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.system,
    required this.currentRoute,
    required this.sections,
    required this.userName,
    required this.userRole,
    required this.onItemTap,
    required this.onSystemSwitch,
    required this.onLogout,
    this.collapsed = false,
    // اسم وإصدار التطبيق ثابتان (علامة تجارية + رقم نسخة) — ليسا نصّ واجهة قابل
    // للترجمة، لذا يبقيان literals وليس عبر l10n.
    this.appVersion = 'v1.0 · Flutter Web',
    this.appName = 'DT.Teeth',
    this.showVersion = false,
    this.showSystemBadge = false,
    this.showSystemSeparator = false,
  });

  final AppSystemType system;
  final String currentRoute;
  final List<SidebarSectionData> sections;
  final String userName;
  final String userRole;
  final ValueChanged<String> onItemTap;

  /// null = بلا زر تبديل نظام (دور المستخدم مقصور على نظام واحد — الأدمن فقط
  /// يملك أكثر من نظام يبدّل بينه).
  final VoidCallback? onSystemSwitch;

  /// القيمة لما المستخدم يضغط على "تسجيل الخروج" — عنصر ثابت بأسفل السايدبار
  /// (خارج منطقة السكرول)، بنفس تنسيق باقي عناصر التنقّل (AppSidebarItem)
  /// لكن isActive دائماً false ولا يغيّر currentRoute.
  final VoidCallback onLogout;
  final bool collapsed;
  final String appVersion;
  final String appName;

  /// إظهار نص الإصدار تحت اسم التطبيق — مخفي افتراضياً بالتصميم الموحّد.
  final bool showVersion;

  /// إظهار شارة النظام (نظام المخبر/المستودع) — مخفية افتراضياً بالتصميم الموحّد.
  final bool showSystemBadge;

  /// إظهار الفاصل العلوي لقسم تبديل الأنظمة — مخفي افتراضياً.
  final bool showSystemSeparator;

  @override
  Widget build(BuildContext context) {
    // الفاتح: خلفية بيضاء (التصميم الموحّد). الغامق: سطح slate مطابق للثيم.
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final double width = collapsed
        ? AppSizes.sidebarCollapsed
        : AppSizes.sidebarWidth;

    return AnimatedContainer(
      duration: AppSizes.animationMedium,
      curve: Curves.easeOut,
      width: width,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.darkBg1,
        border: BorderDirectional(
          start: BorderSide(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
            width: AppSizes.borderThin,
          ),
        ),
      ),
      child: ClipRect(
        child: Stack(
          children: [
            if (!isLight)
              PositionedDirectional(
                top: -80,
                end: -60,
                child: IgnorePointer(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.brand.withValues(alpha: 0.10),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.7],
                      ),
                    ),
                  ),
                ),
              ),
            if (!isLight)
              PositionedDirectional(
                bottom: -60,
                start: -40,
                child: IgnorePointer(
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.labSystem.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.7],
                      ),
                    ),
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTop(context, isLight),
                if (!collapsed && showSystemBadge)
                  AppSidebarSystemBadge(system: system),
                Expanded(child: _buildNavScroll(context)),
                if (!collapsed && showSystemSeparator)
                  _buildSystemSeparator(context, isLight),
                _buildLogoutItem(context),
                AppSidebarSystemSwitcher(
                  currentSystem: system,
                  userName: userName,
                  userRole: userRole,
                  onTap: onSystemSwitch,
                  collapsed: collapsed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTop(BuildContext context, bool isLight) {
    return Container(
      // padding عمودي أكبر لإعطاء اللوغو مساحة كافية
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sidebarHorizontalPadding,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          ),
        ),
      ),
      child: collapsed
          ? Center(child: _buildCollapsedLogo())
          : _buildExpandedLogo(context, isLight),
    );
  }

  /// اللوغو في الوضع الكامل — دائرة navy كبيرة في المنتصف + اسم تحتها.
  /// مطابق لديزاين سايدبار الطبيب: دائرة بيضاء/داكنة كبيرة مع أيقونة السن.
  Widget _buildExpandedLogo(BuildContext context, bool isLight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── الدائرة الكحلية + اللوغو الكامل (أيقونة + DT_Teeth) بداخلها ─
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, Color(0xFF0F1035)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.30),
              width: 1.5,
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Center(
              child: AppLogo(
                size: 68,
                variant: AppLogoVariant.darkTheme,
                showText: true,
                semanticLabel: 'DT.Teeth',
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // اسم النظام كـ subtitle رمادي تحت اللوغو
        Text(
          system.shortLabel(context),
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.2,
            color: isLight ? AppColors.lightText4 : AppColors.darkText4,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (showVersion) ...[
          const SizedBox(height: 2),
          Text(
            appVersion,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.1,
              color: isLight ? AppColors.lightText4 : AppColors.darkText4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  /// اللوغو في الوضع المطوي — دائرة صغيرة فقط بدون نص.
  Widget _buildCollapsedLogo() {
    return Container(
      width: AppSizes.sidebarLogoSize,
      height: AppSizes.sidebarLogoSize,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.accent],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(6),
        child: Center(
          child: AppLogo(
            size: 22,
            variant: AppLogoVariant.darkTheme,
            showText: false,
            semanticLabel: 'DT.Teeth',
          ),
        ),
      ),
    );
  }

  Widget _buildNavScroll(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final section in sections) ..._buildSection(context, section),
        ],
      ),
    );
  }

  List<Widget> _buildSection(BuildContext context, SidebarSectionData section) {
    return [
      AppSidebarSection(title: section.title, collapsed: collapsed),
      ...section.items.map(
        (item) => AppSidebarItem(
          icon: item.icon,
          label: item.label,
          badge: item.badge,
          isActive: currentRoute == item.route,
          system: system,
          collapsed: collapsed,
          onTap: () => onItemTap(item.route),
        ),
      ),
    ];
  }

  Widget _buildSystemSeparator(BuildContext context, bool isLight) {
    final Color lineColor = isLight
        ? AppColors.lightBorder
        : AppColors.darkBorder;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: lineColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              context.l10n.sectionSystem,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.2,
                letterSpacing: 1,
                color: isLight ? AppColors.lightText4 : AppColors.darkText4,
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: lineColor)),
        ],
      ),
    );
  }

  /// عنصر "تسجيل الخروج" — ثابت بأسفل السايدبار، خارج منطقة السكرول، بنفس
  /// widget وتنسيق عناصر التنقّل العادية (AppSidebarItem). isActive دائماً
  /// false لأنه ليس صفحة تنقّل، وonTap يستدعي performLogout مباشرة (وليس
  /// context.go متل باقي العناصر).
  Widget _buildLogoutItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: AppSidebarItem(
        icon: AppIcons.logout,
        label: context.l10n.logout,
        system: system,
        collapsed: collapsed,
        onTap: onLogout,
      ),
    );
  }
}
