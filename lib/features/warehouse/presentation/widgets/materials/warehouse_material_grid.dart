// ════════════════════════════════════════════════════════════════════════════
// warehouse_material_grid.dart
//
// شبكة متجاوبة من material cards.
//
// 🎯 الهدف:
//   widget يأخذ List<WarehouseMaterial> ويعرضهم في grid responsive.
//   يدير الـ empty state و loading state بشكل موحّد.
//
// 🔮 قابلية التوسيع:
//   - عدد الأعمدة يتكيّف تلقائياً مع العرض
//   - الـ actionsBuilder يمرّر MaterialCardAction list من الخارج
//   - يدعم empty state widget مخصّص
//
// المرجع: HTML line 965 — `.mat-grid{grid-template-columns:repeat(4,1fr);gap:11px}`
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/warehouse_material.dart';
import 'warehouse_material_card.dart';

/// شبكة من material cards.
class WarehouseMaterialGrid extends StatelessWidget {
  const WarehouseMaterialGrid({
    super.key,
    required this.materials,
    this.onCardTap,
    this.actionsBuilder,
    this.emptyStateBuilder,
    this.spacing = 11.0,
    this.maxColumns = 4,
    this.minCardWidth = 220.0,
    this.cardAspectRatio = 0.95,
  });

  /// قائمة المواد المعروضة (يفترض أنها مفلترة مسبقاً).
  final List<WarehouseMaterial> materials;

  /// callback عند الضغط على بطاقة (لفتح Modal تفاصيل/تعديل).
  final ValueChanged<WarehouseMaterial>? onCardTap;

  /// builder ينتج actions لكل بطاقة (مثل [تعديل، حذف]).
  /// إذا null، البطاقة بدون actions.
  final List<MaterialCardAction> Function(WarehouseMaterial m)? actionsBuilder;

  /// widget يظهر عند فراغ القائمة (إذا null، رسالة افتراضية).
  final Widget? Function(BuildContext context)? emptyStateBuilder;

  /// المسافة بين البطاقات.
  final double spacing;

  /// أقصى عدد أعمدة (الافتراضي 4).
  final int maxColumns;

  /// أقل عرض للبطاقة قبل أن نقلّل الأعمدة.
  final double minCardWidth;

  /// نسبة العرض للارتفاع للبطاقة.
  final double cardAspectRatio;

  @override
  Widget build(BuildContext context) {
    if (materials.isEmpty) {
      return emptyStateBuilder?.call(context) ?? _defaultEmptyState(context);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // حساب عدد الأعمدة الأمثل
        final w = constraints.maxWidth;
        var columns = (w / minCardWidth).floor();
        if (columns < 1) columns = 1;
        if (columns > maxColumns) columns = maxColumns;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: cardAspectRatio,
          ),
          itemCount: materials.length,
          itemBuilder: (context, index) {
            final m = materials[index];
            return WarehouseMaterialCard(
              material: m,
              onTap: onCardTap == null ? null : () => onCardTap!(m),
              actions: actionsBuilder?.call(m) ?? const [],
            );
          },
        );
      },
    );
  }

  /// Empty state افتراضي.
  Widget _defaultEmptyState(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Text(
          '—',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 32,
            color: (isLight ? AppColors.lightText4 : AppColors.darkText4)
                .withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
