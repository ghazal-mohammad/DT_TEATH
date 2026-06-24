// ════════════════════════════════════════════════════════════════════════════
// app_shimmer_card.dart
//
// Skeleton placeholder لبطاقات AppCard و AppStatCard.
// يُعرض أثناء تحميل البيانات بدلاً من الـ spinner التقليدي.
//
// Design Principle:
//   - البنية مطابقة لـ AppCard / AppStatCard الحقيقية (padding, radius, borders)
//   - العناصر الداخلية (عنوان، قيمة، trend…) تُمثّل بـ AppShimmerBox بأبعاد مماثلة
//   - يدعم 3 presets: basic, statCard, dashboard
//
// Reference files:
//   - lib/shared/widgets/primitives/app_card.dart
//   - lib/shared/widgets/primitives/app_stat_card.dart
//
// Extensibility:
//   - Enum AppShimmerCardLayout يمنح 3 تخطيطات جاهزة
//   - height و padding قابلة للتعديل
//   - يمكن تغليفه يدوياً بـ AppShimmer للحصول على الحركة
//
// Flutter Docs:
//   - https://docs.flutter.dev/cookbook/effects/shimmer-loading
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import 'app_shimmer.dart';

/// أنواع التخطيطات المتاحة لـ [AppShimmerCard].
enum AppShimmerCardLayout {
  /// تخطيط عام — عنوان + سطرين نص + شريط سفلي.
  /// مناسب لكروت المحتوى العادية.
  basic,

  /// تخطيط StatCard — قيمة كبيرة + label + trend indicator.
  /// يحاكي بنية AppStatCard بدقة.
  statCard,

  /// تخطيط Dashboard hero — عنوان كبير + subtitle + زرّين.
  dashboard,
}

/// Skeleton placeholder لبطاقة — يُعرض أثناء التحميل.
///
/// Widget بيحاكي بنية [AppCard] الفعلية بحيث لما تيجي البيانات، الانتقال
/// من الـ skeleton إلى المحتوى الفعلي يكون سلس بدون "قفزة" بصرية.
///
/// يغلّف نفسه تلقائياً بـ [AppShimmer] لتفعيل حركة الموجة.
///
/// مثال:
/// ```dart
/// // StatCard skeleton
/// AppShimmerCard(layout: AppShimmerCardLayout.statCard)
///
/// // Custom height
/// AppShimmerCard(
///   layout: AppShimmerCardLayout.basic,
///   height: 160,
/// )
/// ```
class AppShimmerCard extends StatelessWidget {
  const AppShimmerCard({
    super.key,
    this.layout = AppShimmerCardLayout.basic,
    this.height,
    this.padding,
    this.enabled = true,
  });

  /// نوع التخطيط.
  final AppShimmerCardLayout layout;

  /// ارتفاع الكرت — لو `null`، يُحسب حسب [layout].
  final double? height;

  /// padding داخلي — افتراضياً 16 (مطابق لـ AppCard).
  final EdgeInsets? padding;

  /// تفعيل/إيقاف الحركة (يُمرّر للـ [AppShimmer] الداخلي).
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    // ── أبعاد الكرت حسب الـ layout ───────────────────────────────────
    final double cardHeight = height ?? _resolveHeight();
    final EdgeInsets cardPadding = padding ?? const EdgeInsets.all(16);

    // ── الإطار الخارجي — مطابق لـ AppCard ────────────────────────────
    return Container(
      height: cardHeight,
      padding: cardPadding,
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          width: AppSizes.borderThin,
        ),
      ),
      child: AppShimmer(
        enabled: enabled,
        child: _buildLayout(),
      ),
    );
  }

  /// اختيار التخطيط المناسب.
  Widget _buildLayout() {
    switch (layout) {
      case AppShimmerCardLayout.basic:
        return _buildBasicLayout();
      case AppShimmerCardLayout.statCard:
        return _buildStatCardLayout();
      case AppShimmerCardLayout.dashboard:
        return _buildDashboardLayout();
    }
  }

  /// الارتفاع الافتراضي حسب التخطيط.
  double _resolveHeight() {
    switch (layout) {
      case AppShimmerCardLayout.basic:
        return 140;
      case AppShimmerCardLayout.statCard:
        // 124 لا 120: محتوى التخطيط يملأ الارتفاع تماماً، فنترك 4px لاستيعاب
        // الـ border (~1px لكل جهة) وتفادي تجاوز سفلي 2px.
        return 124;
      case AppShimmerCardLayout.dashboard:
        return 180;
    }
  }

  // ───────────────────────────────────────────────────────────────────
  //                        LAYOUT BUILDERS
  // ───────────────────────────────────────────────────────────────────

  /// تخطيط عام: عنوان + سطرين + شريط سفلي.
  Widget _buildBasicLayout() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان
        AppShimmerBox(width: 140, height: 16),
        SizedBox(height: AppSizes.spaceMD),
        // سطر نص أول
        AppShimmerBox(width: double.infinity, height: 12),
        SizedBox(height: AppSizes.spaceSM),
        // سطر نص ثاني (أقصر)
        AppShimmerBox(width: 200, height: 12),
        Spacer(),
        // شريط سفلي (مثل progress أو meta)
        Row(
          children: [
            AppShimmerBox(width: 80, height: 10),
            Spacer(),
            AppShimmerBox(width: 60, height: 10),
          ],
        ),
      ],
    );
  }

  /// تخطيط StatCard: أيقونة + قيمة + label + trend.
  Widget _buildStatCardLayout() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // أيقونة دائرية + label
        Row(
          children: [
            AppShimmerBox(width: 36, height: 36, borderRadius: 10),
            SizedBox(width: AppSizes.spaceSM),
            AppShimmerBox(width: 100, height: 12),
          ],
        ),
        Spacer(),
        // القيمة الكبيرة
        AppShimmerBox(width: 120, height: 28, borderRadius: 6),
        SizedBox(height: AppSizes.spaceSM),
        // Trend indicator
        Row(
          children: [
            AppShimmerBox(width: 16, height: 16, borderRadius: 4),
            SizedBox(width: 6),
            AppShimmerBox(width: 70, height: 11),
          ],
        ),
      ],
    );
  }

  /// تخطيط Dashboard: عنوان كبير + subtitle + زرّين.
  Widget _buildDashboardLayout() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان كبير
        AppShimmerBox(width: 220, height: 22, borderRadius: 6),
        SizedBox(height: AppSizes.spaceSM),
        // Subtitle
        AppShimmerBox(width: 300, height: 14),
        SizedBox(height: AppSizes.spaceXS),
        AppShimmerBox(width: 260, height: 14),
        Spacer(),
        // زرّين
        Row(
          children: [
            AppShimmerBox(width: 120, height: 36, borderRadius: 10),
            SizedBox(width: AppSizes.spaceSM),
            AppShimmerBox(width: 100, height: 36, borderRadius: 10),
          ],
        ),
      ],
    );
  }
}
