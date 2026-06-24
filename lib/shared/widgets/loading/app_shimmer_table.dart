// ════════════════════════════════════════════════════════════════════════════
// app_shimmer_table.dart
//
// Skeleton placeholder للجداول — يُعرض أثناء تحميل بيانات الجداول.
// مناسب لـ: جداول المواد، الطلبات، الفواتير، تقارير الإنتاج.
//
// Design Principles:
//   - مطابق لبنية AppDataTable الفعلية (header + rows + pagination)
//   - عدد الأعمدة والصفوف قابل للتخصيص
//   - عرض الأعمدة يمكن تحديده بـ flex لتنوع التخطيطات
//   - يدعم عرض badge/chip في عمود محدد (للحالات)
//
// Extensibility:
//   - AppShimmerTableColumn class يصف كل عمود (width + type)
//   - AppShimmerColumnType enum: text, badge, number, avatar
//   - preset configurations جاهزة (orders, materials, invoices)
//
// Flutter Docs:
//   - https://docs.flutter.dev/ui/layout (Row + Expanded + Flexible)
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import 'app_shimmer.dart';

/// نوع محتوى العمود — يحدد شكل الـ shimmer.
enum AppShimmerColumnType {
  /// نص عادي — مستطيل بعرض الخلية.
  text,

  /// badge/chip صغير (مثل "نشط"، "معلّق").
  badge,

  /// رقم قصير (3-4 خانات).
  number,

  /// avatar دائري صغير + نص.
  avatar,

  /// أيقونة مربعة (action button).
  iconAction,
}

/// وصف عمود واحد في الـ shimmer table.
///
/// يُستخدم لتخصيص شكل كل عمود بشكل مستقل.
class AppShimmerTableColumn {
  const AppShimmerTableColumn({
    this.flex = 1,
    this.type = AppShimmerColumnType.text,
  });

  /// نسبة العرض (Flexible.flex).
  final int flex;

  /// نوع محتوى العمود.
  final AppShimmerColumnType type;

  /// Preset — عمود نصي قياسي.
  static const AppShimmerTableColumn text = AppShimmerTableColumn();

  /// Preset — عمود حالة/badge.
  static const AppShimmerTableColumn badge = AppShimmerTableColumn(
    flex: 1,
    type: AppShimmerColumnType.badge,
  );

  /// Preset — عمود رقمي.
  static const AppShimmerTableColumn number = AppShimmerTableColumn(
    flex: 1,
    type: AppShimmerColumnType.number,
  );

  /// Preset — عمود actions.
  static const AppShimmerTableColumn actions = AppShimmerTableColumn(
    flex: 1,
    type: AppShimmerColumnType.iconAction,
  );

  /// Preset — عمود أوسع (للعنوان الرئيسي).
  static const AppShimmerTableColumn wide = AppShimmerTableColumn(flex: 2);
}

/// Skeleton placeholder لجدول بيانات.
///
/// يحاكي بنية [AppDataTable] الحقيقية:
/// - Header مع أسماء الأعمدة (shimmer boxes أقصر)
/// - صفوف بيانات (shimmer boxes بعرض كامل)
/// - footer اختياري (pagination)
///
/// ## أمثلة استخدام
///
/// ### جدول طلبات (preset)
/// ```dart
/// const AppShimmerTable.orders(rowCount: 8)
/// ```
///
/// ### جدول مخصّص
/// ```dart
/// AppShimmerTable(
///   columns: [
///     AppShimmerTableColumn.wide,    // اسم المادة
///     AppShimmerTableColumn.number,  // الكمية
///     AppShimmerTableColumn.badge,   // الحالة
///     AppShimmerTableColumn.actions, // إجراءات
///   ],
///   rowCount: 10,
///   showPagination: true,
/// )
/// ```
class AppShimmerTable extends StatelessWidget {
  const AppShimmerTable({
    super.key,
    required this.columns,
    this.rowCount = 6,
    this.showHeader = true,
    this.showPagination = false,
    this.rowHeight = 52,
    this.headerHeight = 44,
    this.enabled = true,
  });

  /// preset لجدول طلبات (4 أعمدة: رقم، عنوان، حالة، إجراءات).
  const AppShimmerTable.orders({
    super.key,
    this.rowCount = 6,
    this.showPagination = true,
    this.enabled = true,
  })  : columns = const [
          AppShimmerTableColumn.number,
          AppShimmerTableColumn.wide,
          AppShimmerTableColumn.badge,
          AppShimmerTableColumn.actions,
        ],
        showHeader = true,
        rowHeight = 52,
        headerHeight = 44;

  /// preset لجدول مواد (5 أعمدة).
  const AppShimmerTable.materials({
    super.key,
    this.rowCount = 6,
    this.showPagination = true,
    this.enabled = true,
  })  : columns = const [
          AppShimmerTableColumn.wide,
          AppShimmerTableColumn.number,
          AppShimmerTableColumn.number,
          AppShimmerTableColumn.badge,
          AppShimmerTableColumn.actions,
        ],
        showHeader = true,
        rowHeight = 52,
        headerHeight = 44;

  /// preset لجدول فواتير.
  const AppShimmerTable.invoices({
    super.key,
    this.rowCount = 6,
    this.showPagination = true,
    this.enabled = true,
  })  : columns = const [
          AppShimmerTableColumn.number,
          AppShimmerTableColumn.wide,
          AppShimmerTableColumn.number,
          AppShimmerTableColumn.badge,
        ],
        showHeader = true,
        rowHeight = 52,
        headerHeight = 44;

  /// وصف الأعمدة.
  final List<AppShimmerTableColumn> columns;

  /// عدد صفوف البيانات الوهمية.
  final int rowCount;

  /// عرض صف الـ header؟
  final bool showHeader;

  /// عرض footer الـ pagination؟
  final bool showPagination;

  /// ارتفاع صف البيانات.
  final double rowHeight;

  /// ارتفاع صف الـ header.
  final double headerHeight;

  /// تفعيل/إيقاف الحركة.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          width: AppSizes.borderThin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: AppShimmer(
        enabled: enabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showHeader) _buildHeaderRow(isLight),
            ..._buildDataRows(isLight),
            if (showPagination) _buildPaginationRow(isLight),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────
  //                        ROW BUILDERS
  // ───────────────────────────────────────────────────────────────────

  /// صف الـ header — نصوص أقصر وأكثف من صفوف البيانات.
  Widget _buildHeaderRow(bool isLight) {
    return Container(
      height: headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceMD),
      decoration: BoxDecoration(
        color: isLight
            ? AppColors.lightBg2
            : AppColors.darkGlass,
        border: Border(
          bottom: BorderSide(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < columns.length; i++) ...[
            Expanded(
              flex: columns[i].flex,
              child: const AppShimmerBox(width: 70, height: 12),
            ),
            if (i < columns.length - 1)
              const SizedBox(width: AppSizes.spaceSM),
          ],
        ],
      ),
    );
  }

  /// بناء صفوف البيانات.
  List<Widget> _buildDataRows(bool isLight) {
    return List.generate(rowCount, (index) {
      final bool isLast = index == rowCount - 1;
      return Container(
        height: rowHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceMD),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color:
                        isLight ? AppColors.lightBorder : AppColors.darkBorder,
                    width: 0.5,
                  ),
                ),
        ),
        child: Row(
          children: [
            for (int i = 0; i < columns.length; i++) ...[
              Expanded(
                flex: columns[i].flex,
                child: _buildCellContent(columns[i].type),
              ),
              if (i < columns.length - 1)
                const SizedBox(width: AppSizes.spaceSM),
            ],
          ],
        ),
      );
    });
  }

  /// محتوى خلية حسب نوعها.
  Widget _buildCellContent(AppShimmerColumnType type) {
    switch (type) {
      case AppShimmerColumnType.text:
        return const AppShimmerBox(width: 120, height: 12);
      case AppShimmerColumnType.badge:
        return const Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppShimmerBox(width: 60, height: 22, borderRadius: 11),
        );
      case AppShimmerColumnType.number:
        return const AppShimmerBox(width: 50, height: 12);
      case AppShimmerColumnType.avatar:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppShimmerBox(width: 28, height: 28, borderRadius: 14),
            SizedBox(width: AppSizes.spaceSM),
            AppShimmerBox(width: 90, height: 12),
          ],
        );
      case AppShimmerColumnType.iconAction:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppShimmerBox(width: 28, height: 28, borderRadius: 8),
            SizedBox(width: 6),
            AppShimmerBox(width: 28, height: 28, borderRadius: 8),
          ],
        );
    }
  }

  /// footer pagination.
  Widget _buildPaginationRow(bool isLight) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceMD),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightBg2 : AppColors.darkGlass,
        border: Border(
          top: BorderSide(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          ),
        ),
      ),
      child: const Row(
        children: [
          AppShimmerBox(width: 100, height: 12),
          Spacer(),
          AppShimmerBox(width: 28, height: 28, borderRadius: 8),
          SizedBox(width: 6),
          AppShimmerBox(width: 28, height: 28, borderRadius: 8),
          SizedBox(width: 6),
          AppShimmerBox(width: 28, height: 28, borderRadius: 8),
          SizedBox(width: 6),
          AppShimmerBox(width: 28, height: 28, borderRadius: 8),
        ],
      ),
    );
  }
}
