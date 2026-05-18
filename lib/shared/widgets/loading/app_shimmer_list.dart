// ════════════════════════════════════════════════════════════════════════════
// app_shimmer_list.dart
//
// Skeleton placeholder لقائمة عناصر — يُعرض أثناء تحميل البيانات.
// مناسب لـ: قوائم الطلبات، قوائم المخبريين، قوائم المواد، قوائم الإشعارات.
//
// Design Principles:
//   - كل عنصر في القائمة له بنية ثابتة: avatar + title + subtitle + trailing
//   - عدد العناصر قابل للتخصيص (افتراضياً 5 لإعطاء انطباع امتلاء)
//   - يدعم كلا النمطين: scrollable (ListView) و non-scrollable (Column)
//   - إمكانية إضافة header skeleton (زر بحث/فلاتر)
//
// Extensibility:
//   - AppShimmerListLayout enum لـ 3 أنواع: avatar, icon, compact
//   - itemCount قابل للتعديل
//   - separator قابل للتخصيص
//
// Performance:
//   - الـ itemBuilder يُستخدم فقط لما scrollable=true (list virtualization)
//   - لما scrollable=false، نولّد كل العناصر مسبقاً (مقبول لأعداد صغيرة)
//
// Flutter Docs:
//   - https://docs.flutter.dev/ui/widgets/scrolling (ListView.separated)
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import 'app_shimmer.dart';

/// أنواع عناصر القائمة.
enum AppShimmerListLayout {
  /// عنصر مع avatar دائري (للمستخدمين/المخبريين).
  avatar,

  /// عنصر مع أيقونة مربعة (للمواد/الطلبات).
  icon,

  /// عنصر مضغوط — سطر واحد بدون subtitle.
  compact,
}

/// Skeleton placeholder لقائمة عناصر.
///
/// يولّد [itemCount] من العناصر الوهمية، كل واحد منها بيحاكي بنية عنصر فعلي
/// (avatar/icon + title + subtitle + trailing badge).
///
/// يدعم الوضع الـ scrollable (للقوائم الطويلة) و non-scrollable (للعرض داخل
/// كرت صغير).
///
/// مثال:
/// ```dart
/// // قائمة طلبات (5 عناصر)
/// AppShimmerList(
///   layout: AppShimmerListLayout.icon,
///   itemCount: 5,
/// )
///
/// // قائمة مخبريين داخل كرت
/// AppShimmerList(
///   layout: AppShimmerListLayout.avatar,
///   itemCount: 3,
///   scrollable: false,
/// )
/// ```
class AppShimmerList extends StatelessWidget {
  const AppShimmerList({
    super.key,
    this.layout = AppShimmerListLayout.icon,
    this.itemCount = 5,
    this.scrollable = true,
    this.showSearchHeader = false,
    this.itemHeight,
    this.spacing = AppSizes.spaceSM,
    this.padding,
    this.enabled = true,
  });

  /// نوع تخطيط العناصر.
  final AppShimmerListLayout layout;

  /// عدد العناصر الوهمية.
  final int itemCount;

  /// إذا true، يستخدم ListView.separated (قابلة للـ scroll).
  /// إذا false، يستخدم Column (ثابتة).
  final bool scrollable;

  /// إذا true، يعرض شريط بحث في الأعلى.
  final bool showSearchHeader;

  /// ارتفاع كل عنصر — لو null يُحسب حسب الـ layout.
  final double? itemHeight;

  /// المسافة بين العناصر.
  final double spacing;

  /// padding خارجي للقائمة.
  final EdgeInsets? padding;

  /// تفعيل/إيقاف الحركة.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      enabled: enabled,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showSearchHeader) ...[
              _buildSearchHeader(),
              SizedBox(height: spacing),
            ],
            if (scrollable)
              Expanded(child: _buildScrollableList())
            else
              _buildStaticList(),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────
  //                        LIST BUILDERS
  // ───────────────────────────────────────────────────────────────────

  /// بناء قائمة ثابتة (Column).
  Widget _buildStaticList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < itemCount; i++) ...[
          _buildItem(i),
          if (i < itemCount - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }

  /// بناء قائمة scrollable.
  Widget _buildScrollableList() {
    return ListView.separated(
      itemCount: itemCount,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) => _buildItem(index),
      separatorBuilder: (_, __) => SizedBox(height: spacing),
    );
  }

  /// header البحث (اختياري).
  Widget _buildSearchHeader() {
    return Row(
      children: const [
        Expanded(
          child: AppShimmerBox(
            width: double.infinity,
            height: 40,
            borderRadius: 50,
          ),
        ),
        SizedBox(width: AppSizes.spaceSM),
        AppShimmerBox(width: 40, height: 40, borderRadius: 10),
      ],
    );
  }

  /// بناء عنصر واحد حسب الـ layout.
  Widget _buildItem(int index) {
    final double height = itemHeight ?? _resolveHeight();

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceMD,
        vertical: AppSizes.spaceSM,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.darkBorder),
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: Row(
        children: [
          _buildLeading(),
          const SizedBox(width: AppSizes.spaceMD),
          Expanded(child: _buildContent()),
          const SizedBox(width: AppSizes.spaceSM),
          _buildTrailing(),
        ],
      ),
    );
  }

  /// الأيقونة/الصورة على اليمين (في RTL) أو اليسار (في LTR).
  Widget _buildLeading() {
    switch (layout) {
      case AppShimmerListLayout.avatar:
        return const AppShimmerBox(width: 40, height: 40, borderRadius: 20);
      case AppShimmerListLayout.icon:
        return const AppShimmerBox(width: 40, height: 40, borderRadius: 10);
      case AppShimmerListLayout.compact:
        return const AppShimmerBox(width: 28, height: 28, borderRadius: 8);
    }
  }

  /// محتوى العنصر (title + subtitle).
  Widget _buildContent() {
    if (layout == AppShimmerListLayout.compact) {
      // سطر واحد فقط
      return const Align(
        alignment: AlignmentDirectional.centerStart,
        child: AppShimmerBox(width: 160, height: 14),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        AppShimmerBox(width: 180, height: 14),
        SizedBox(height: 6),
        AppShimmerBox(width: 120, height: 11),
      ],
    );
  }

  /// العنصر الطرفي (badge أو chevron).
  Widget _buildTrailing() {
    return const AppShimmerBox(
      width: 50,
      height: 22,
      borderRadius: 11,
    );
  }

  /// الارتفاع الافتراضي حسب الـ layout.
  double _resolveHeight() {
    switch (layout) {
      case AppShimmerListLayout.avatar:
      case AppShimmerListLayout.icon:
        return 64;
      case AppShimmerListLayout.compact:
        return 48;
    }
  }
}
