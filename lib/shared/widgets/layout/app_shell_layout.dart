// ════════════════════════════════════════════════════════════════════════════
// app_shell_layout.dart
//
// Layout رئيسي يجمع AppSidebar + AppTopbar + content area لكل صفحات النظام.
// هذا الـ widget هو الـ "shell" الموحّد لكل صفحات Lab و Warehouse — يضمن
// تطابق pixel-perfect مع HTML mockup ويزيل تكرار كود السايدبار/التوب بار
// في كل صفحة.
//
// المرجع: DT_Teeth_Warehouse_v6_Enhanced.html — السطور 2092–2125
//   <div style="display:flex">
//     <aside class="sb">...</aside>     ← AppSidebar
//     <div class="main">
//       <div class="tb">...</div>        ← AppTopbar
//       <div class="ct">                 ← content area
//         {body}
//       </div>
//     </div>
//   </div>
//
// مميزات التصميم:
//   1. مصدر حقيقة واحد للـ layout — أي تعديل ينعكس على كل الصفحات.
//   2. الـ Sidebar تتحوّل لـ Drawer تلقائياً تحت 900px.
//   3. الـ ScrollView داخلي للـ content (الـ Sidebar/Topbar ثابتين).
//   4. RTL-first: كل الاتجاهات تستخدم Directional في widgets الفرعية.
//   5. يدعم تمرير قائمة sections من الخارج — أي feature يمدد القائمة بدون
//      الحاجة لتعديل AppSidebar نفسه.
//
// قواعد الاستخدام (Phase 4.1):
//   AppShellLayout(
//     system: AppSystemType.warehouse,
//     currentRoute: RouteNames.warehouseDashboard,
//     pageTitle: context.l10n.whDashboardTitle,
//     pageSubtitle: context.l10n.warehouseTopbarSubtitle,
//     sections: WarehouseSidebarSections.build(context),
//     userName: 'أحمد محمود',
//     userRole: context.l10n.roleWarehouseManager,
//     body: WarehouseDashboardContent(),
//   )
//
// ملاحظات معمارية مهمة:
//   - استخدمنا [Builder] حول كل subtree يحتاج Scaffold.of(context)
//     (مثل openDrawer)، لأن السياق الذي يبني Scaffold لا يعرف بالـ Scaffold
//     نفسه (هذا قيد Flutter معروف).
//   - context.watch<ThemeCubit> داخل build() مرة واحدة فقط — نمرّر القيمة
//     للـ submethods لتجنّب multiple subscriptions.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/current_user.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../core/mock_user_data.dart';
import '../../../core/theme/app_sizes.dart';
import '../../bloc/mock_system_cubit.dart';
import '../../bloc/theme_cubit.dart';
import '../core/app_system_type.dart';
import '../navigation/app_sidebar.dart';
import '../navigation/app_topbar.dart';

// ══════════════════════════════════════════════════════════════════════════
//                          BREAKPOINTS
// ══════════════════════════════════════════════════════════════════════════

/// نقطة كسر تحت 900px → الـ Sidebar تتحوّل لـ Drawer.
const double kShellMobileBreakpoint = 900.0;

/// نقطة كسر تحت 1200px → الـ Sidebar collapsed (أيقونات فقط).
const double kShellCollapsedBreakpoint = 1200.0;

// ══════════════════════════════════════════════════════════════════════════
//                          MAIN SHELL WIDGET
// ══════════════════════════════════════════════════════════════════════════

/// الـ Shell layout الموحّد لصفحات نظام DT.Teeth.
///
/// يبني التركيبة المعيارية:
/// ```
///   ┌─────────────────────────────────────────────┐
///   │   Topbar  (search, theme, notifications)    │
///   ├──────┬──────────────────────────────────────┤
///   │      │                                      │
///   │  S   │             Body (scrollable)        │
///   │  i   │                                      │
///   │  d   │                                      │
///   │  e   │                                      │
///   │  b   │                                      │
///   │  a   │                                      │
///   │  r   │                                      │
///   └──────┴──────────────────────────────────────┘
/// ```
///
/// **ملاحظة RTL**: في عربي الـ sidebar تظهر على اليمين والـ body على اليسار،
/// تلقائياً بدون أي تدخّل لأن الـ Row في Flutter يحترم Directionality.
class AppShellLayout extends StatelessWidget {
  const AppShellLayout({
    super.key,
    required this.system,
    required this.currentRoute,
    required this.sections,
    required this.pageTitle,
    this.userName,
    required this.userRole,
    required this.body,
    this.pageSubtitle,
    this.notificationCount = 0,
    this.onSearchChanged,
    this.searchPlaceholder,
    this.contentPadding,
    this.showThemeToggle = true,
    this.showTopbarActions = true,
    this.showSearch = true,
  });

  /// النظام الحالي — يحدد ألوان الـ active state وشارة السايدبار.
  final AppSystemType system;

  /// المسار الحالي (من GoRouter) — لتحديد العنصر النشط في السايدبار.
  final String currentRoute;

  /// أقسام السايدبار (تأتي من factory مخصّصة لكل نظام).
  final List<SidebarSectionData> sections;

  /// عنوان الصفحة المعروض في التوب بار.
  final String pageTitle;

  /// عنوان فرعي اختياري في التوب بار.
  final String? pageSubtitle;

  /// اسم المستخدم — يظهر في switcher السايدبار وتولتيب البروفايل.
  ///
  /// اختياري: لو null (الحالة الافتراضية للصفحات) يحلّه الـ shell من
  /// [CurrentUser] الحقيقي، ثم fallback تطويري حسب النظام. هكذا يبقى مصدر
  /// اسم المستخدم في مكان واحد بدل تمريره يدوياً من كل صفحة.
  final String? userName;

  /// الاسم المعروض فعلياً: المُمرَّر صراحةً، وإلا المستخدم الحقيقي، وإلا
  /// fallback تطويري حسب النظام (يُحذف مع [MockUserData] عند نضوج الـ Auth).
  String get _resolvedUserName =>
      userName ?? CurrentUser.instance.name ?? _devFallbackName;

  String get _devFallbackName => switch (system) {
        AppSystemType.lab => MockUserData.labUserName,
        AppSystemType.warehouse => MockUserData.defaultUserName,
      };

  /// الدور الوظيفي — يظهر تحت الاسم في switcher.
  final String userRole;

  /// محتوى الصفحة الفعلي.
  final Widget body;

  /// عدد الإشعارات غير المقروءة (>0 → نقطة حمراء على جرس التوب بار).
  final int notificationCount;

  /// callback عند تغيير نص البحث.
  final ValueChanged<String>? onSearchChanged;

  /// نص placeholder لحقل البحث (اختياري — افتراضه context.l10n.search).
  final String? searchPlaceholder;

  /// إظهار حقل البحث في التوب بار (يُخفى مثلاً في صفحة الملف الشخصي).
  final bool showSearch;

  /// padding داخلي للمحتوى. الافتراضي = 22px (مطابق لـ .ct في HTML).
  final EdgeInsetsGeometry? contentPadding;

  /// إظهار زر تبديل الثيم (Light/Dark) في التوب بار. الافتراضي true.
  /// نمرّر false من الصفحات اللي تصميمها المرجعي ما فيه زر التبديل.
  final bool showThemeToggle;

  /// إظهار أزرار الإجراءات (ثيم/إشعارات/بروفايل) بجانب حقل البحث في التوب بار.
  /// نمرّر false في صفحة الملف الشخصي ليبقى حقل البحث وحده بلا أيقونات.
  final bool showTopbarActions;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool isMobile = width < kShellMobileBreakpoint;
    final bool isCollapsed = width < kShellCollapsedBreakpoint && !isMobile;
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight ? AppColors.lightBg : AppColors.darkBg,

      // ── على الموبايل: السايدبار = Drawer ينفتح من اليمين (RTL) ─────────
      drawer: isMobile
          ? Drawer(
              backgroundColor: Colors.transparent,
              elevation: 0,
              // Builder لإعطاء سياق يعرف بالـ Drawer (لاستخدام Navigator.pop).
              child: Builder(
                builder: (drawerContext) => _buildSidebar(
                  drawerContext,
                  collapsed: false,
                  insideDrawer: true,
                ),
              ),
            )
          : null,

      body: SafeArea(
        // Builder لإعطاء سياق يعرف بـ Scaffold (لاستخدام openDrawer).
        child: Builder(
          builder: (scaffoldContext) => Row(
            children: [
              // ── Sidebar (إذا desktop/tablet) ───────────────────────────
              if (!isMobile)
                _buildSidebar(
                  scaffoldContext,
                  collapsed: isCollapsed,
                  insideDrawer: false,
                ),

              // ── Main content area ───────────────────────────────────────
              // استخدام LayoutBuilder + Stack + Positioned بدلاً من Column + Expanded
              // لضمان constraints محددة بدقة لكلٍ من التوب بار والـ body.
              // Column + Expanded يفشل في Flutter Web عند loose height constraints.
              Expanded(
                child: LayoutBuilder(
                  builder: (layoutCtx, constraints) {
                    const double topbarH = AppSizes.topbarHeight;
                    final double bodyH = constraints.maxHeight - topbarH;
                    return Stack(
                      children: [
                        // ── Body (أسفل التوب بار) ─────────────────────────
                        Positioned(
                          top: topbarH,
                          left: 0,
                          right: 0,
                          height: bodyH > 0 ? bodyH : 0,
                          child: body,
                        ),
                        // ── Topbar (ثابت في الأعلى) ───────────────────────
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: topbarH,
                          child: _buildTopbar(
                            scaffoldContext,
                            isMobile: isMobile,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //                           SUB-BUILDERS
  // ────────────────────────────────────────────────────────────────────────

  /// بناء AppSidebar مع الـ sections المعطاة والـ navigation handler.
  ///
  /// [insideDrawer] صحيح إذا الـ widget داخل Drawer — في هذه الحالة نُغلق
  /// الـ Drawer بعد كل تنقّل.
  Widget _buildSidebar(
    BuildContext context, {
    required bool collapsed,
    required bool insideDrawer,
  }) {
    return AppSidebar(
      system: system,
      currentRoute: currentRoute,
      sections: sections,
      userName: _resolvedUserName,
      userRole: userRole,
      collapsed: collapsed,
      onItemTap: (route) {
        // إغلاق الـ Drawer (إذا كنا داخله) قبل التنقّل لتجربة أنعم.
        // نستخدم Scaffold.of لأنه الـ idiomatic API لإغلاق Drawer في Flutter.
        if (insideDrawer) {
          Scaffold.of(context).closeDrawer();
        }

        // تجنّب التنقّل لنفس المسار الحالي (يمنع rebuild غير ضروري).
        if (route == currentRoute) return;

        context.go(route);
      },
      onSystemSwitch: () {
        if (insideDrawer) Scaffold.of(context).closeDrawer();
        _handleSystemSwitch(context);
      },
    );
  }

  /// بناء AppTopbar مع كل الـ callbacks المربوطة بالـ Cubits.
  ///
  Widget _buildTopbar(
    BuildContext context, {
    required bool isMobile,
  }) {
    // معاملات مشتركة — نُعرّفها مرة واحدة لتجنّب التكرار.
    void onMenuTap() => Scaffold.of(context).openDrawer();
    void onNotificationTap() => _handleNotificationTap(context);
    void onProfileTap() => _handleProfileTap(context);

    // البحث وزرّا الإشعارات/البروفايل فقط. الثيم واللغة في صفحة الإعدادات حصراً.
    // نمرّر الـ placeholder كما هو (قد يكون null)؛ AppTopbar يحلّ الافتراضي
    // عبر context.l10n.search عند العرض.
    return AppTopbar(
      title: pageTitle,
      subtitle: pageSubtitle,
      showSearch: showSearch && !isMobile,
      onSearchChanged: onSearchChanged,
      searchPlaceholder: searchPlaceholder,
      notificationCount: notificationCount,
      onMenuTap: isMobile ? onMenuTap : null,
      showMenuButton: isMobile,
      onNotificationTap: showTopbarActions ? onNotificationTap : null,
      onProfileTap: showTopbarActions ? onProfileTap : null,
    );
  }

  /// التوجّه لصفحة الإشعارات الصحيحة حسب النظام.
  void _handleNotificationTap(BuildContext context) {
    final notifRoute = system == AppSystemType.warehouse
        ? RouteNames.warehouseNotifications
        : RouteNames.labNotifications;
    if (currentRoute != notifRoute) {
      context.go(notifRoute);
    }
  }

  /// التوجّه لصفحة الإعدادات الصحيحة حسب النظام.
  void _handleProfileTap(BuildContext context) {
    final settingsRoute = system == AppSystemType.warehouse
        ? RouteNames.warehouseSettings
        : RouteNames.labSettings;
    if (currentRoute != settingsRoute) {
      context.go(settingsRoute);
    }
  }

  /// معالج التبديل بين الأنظمة من السايدبار.
  ///
  /// يبدّل النظام في [MockSystemCubit] ثم يوجّه إلى Dashboard النظام الجديد.
  void _handleSystemSwitch(BuildContext context) {
    final cubit = context.read<MockSystemCubit>();
    cubit.toggle();

    // التوجّه لـ Dashboard النظام الجديد
    final newRoute = cubit.isLab
        ? RouteNames.labDashboard
        : RouteNames.warehouseDashboard;
    context.go(newRoute);
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          DEFAULTS
  // ────────────────────────────────────────────────────────────────────────
}

// ══════════════════════════════════════════════════════════════════════════
//                          SHELL METRICS
// ══════════════════════════════════════════════════════════════════════════

/// أبعاد افتراضية للـ shell — قد تُستخدم في اختبارات أو layout calculations.
class AppShellMetrics {
  AppShellMetrics._();

  /// الحد الأدنى لعرض الـ content area (لا يقل عن هذا حتى لو السايدبار مفتوحة).
  static const double minContentWidth = 600.0;

  /// عرض السايدبار الافتراضي.
  static double get sidebarWidth => AppSizes.sidebarWidth;

  /// عرض السايدبار المطوية.
  static double get sidebarCollapsedWidth => AppSizes.sidebarCollapsed;

  /// ارتفاع التوب بار.
  static double get topbarHeight => AppSizes.topbarHeight;
}
