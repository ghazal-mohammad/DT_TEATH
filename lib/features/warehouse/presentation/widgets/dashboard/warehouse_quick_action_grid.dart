// ════════════════════════════════════════════════════════════════════════════
// warehouse_quick_action_grid.dart
//
// شبكة 2×2 من أزرار الإجراءات السريعة في Dashboard.
//
// المرجع: DT_Teeth_Warehouse_v6_Enhanced.html — السطور 2175–2183 + 923–942
//
// 4 variants ملوّنة:
//   qc  → cyan   (مادة)
//   qg2 → green  (فاتورة)
//   qv  → violet (تقارير)
//   qo  → orange (طلبيات)
//
// تصميم الزر:
//   ┌────────────────┐
//   │     [📦]       │ ← icon (22px)
//   │     مادة        │ ← label (12.5px, weight 700, ملوّن)
//   └────────────────┘
//   عند hover: translateY(-3) + scale(1.03) + shadow أقوى
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_sizes.dart';

// ══════════════════════════════════════════════════════════════════════════
//                          DATA & ENUMS
// ══════════════════════════════════════════════════════════════════════════

/// نوع زر الإجراء السريع — يحدد الألوان.
enum WarehouseQuickActionVariant {
  cyan,
  green,
  violet,
  orange,
}

/// بيانات زر إجراء سريع واحد.
class WarehouseQuickActionData {
  const WarehouseQuickActionData({
    required this.variant,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final WarehouseQuickActionVariant variant;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

// ══════════════════════════════════════════════════════════════════════════
//                          GRID WIDGET
// ══════════════════════════════════════════════════════════════════════════

/// شبكة 2×2 من أزرار الإجراءات السريعة.
class WarehouseQuickActionGrid extends StatelessWidget {
  const WarehouseQuickActionGrid({
    super.key,
    required this.actions,
  });

  /// قائمة الإجراءات (يفضّل تكون 4 عناصر بالضبط لشبكة 2×2 متناسقة).
  final List<WarehouseQuickActionData> actions;

  /// factory builder بإجراءات افتراضية (مادة/فاتورة/تقارير/طلبيات).
  factory WarehouseQuickActionGrid.standard({
    Key? key,
    required BuildContext context,
    required VoidCallback onAddMaterial,
    required VoidCallback onAddInvoice,
    required VoidCallback onReports,
    required VoidCallback onOrders,
  }) {
    return WarehouseQuickActionGrid(
      key: key,
      actions: [
        WarehouseQuickActionData(
          variant: WarehouseQuickActionVariant.cyan,
          icon: AppIcons.add,
          label: context.l10n.whQuickActionAddMaterial,
          onTap: onAddMaterial,
        ),
        WarehouseQuickActionData(
          variant: WarehouseQuickActionVariant.green,
          icon: AppIcons.invoices,
          label: context.l10n.whQuickActionAddInvoice,
          onTap: onAddInvoice,
        ),
        WarehouseQuickActionData(
          variant: WarehouseQuickActionVariant.violet,
          icon: AppIcons.reports,
          label: context.l10n.whQuickActionReports,
          onTap: onReports,
        ),
        WarehouseQuickActionData(
          variant: WarehouseQuickActionVariant.orange,
          icon: AppIcons.orders,
          label: context.l10n.whQuickActionOrders,
          onTap: onOrders,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          width: AppSizes.borderThin,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── العنوان ─────────────────────────────────────────────────
          Text(
            context.l10n.whQuickActions,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: AppSizes.fontLG,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: isLight ? AppColors.lightText1 : AppColors.darkText1,
            ),
          ),
          const SizedBox(height: 12),

          // ── الشبكة 2×2 ───────────────────────────────────────────────
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1.4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: actions
                .map((a) => _QuickActionButton(data: a))
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                          ZR (داخلي)
// ══════════════════════════════════════════════════════════════════════════

class _QuickActionButton extends StatefulWidget {
  const _QuickActionButton({required this.data});

  final WarehouseQuickActionData data;

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _hovered = false;

  /// لون الـ variant.
  Color get _color {
    switch (widget.data.variant) {
      case WarehouseQuickActionVariant.cyan:
        return AppColors.dashCyan;
      case WarehouseQuickActionVariant.green:
        return AppColors.dashGreen;
      case WarehouseQuickActionVariant.violet:
        return AppColors.dashViolet;
      case WarehouseQuickActionVariant.orange:
        return AppColors.dashOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.data.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translateByDouble(0.0, _hovered ? -3.0 : 0.0, 0.0, 1.0)
            ..scaleByDouble(_hovered ? 1.03 : 1.0, _hovered ? 1.03 : 1.0,
                _hovered ? 1.03 : 1.0, 1.0),
          transformAlignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.07),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: AppSizes.borderThin,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusLG), // r12
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: _hovered ? 0.20 : 0.10),
                blurRadius: _hovered ? 24 : 14,
                offset: Offset(0, _hovered ? 8 : 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.data.icon,
                size: 22,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                widget.data.label,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
