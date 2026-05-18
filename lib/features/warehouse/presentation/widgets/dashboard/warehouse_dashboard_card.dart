// ════════════════════════════════════════════════════════════════════════════
// warehouse_dashboard_card.dart
//
// Card wrapper مع header اختياري — يُستخدم لتغليف الجداول والـ widgets.
//
// المرجع: DT_Teeth_Warehouse_v6_Enhanced.html — السطور 717–741 (.card + .ch)
//
// تركيبة Card الأصلية:
//   .card  — surface + border + shadow + radius:16
//   .ch    — header: padding 16/20 + border-bottom + bg cyan شفّاف
//   .ch-t  — العنوان الرئيسي (15px, weight 700)
//   .ch-b  — badge ملوّن صغير (caption)
//   .ch-a  — زر action على اليسار (margin-right:auto في LTR، start في RTL)
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';

/// Card wrapper مع header قابل للتخصيص (عنوان + caption + action).
///
/// مثال:
/// ```dart
/// WarehouseDashboardCard(
///   header: WarehouseCardHeader(
///     title: '⭐ المواد الأكثر طلباً',
///     caption: 'هذا الشهر',
///     actionLabel: 'التقرير الكامل ←',
///     onActionTap: () => context.go(...),
///   ),
///   child: AppDataTable(...),
/// )
/// ```
class WarehouseDashboardCard extends StatelessWidget {
  const WarehouseDashboardCard({
    super.key,
    this.header,
    required this.child,
    this.padding,
    this.margin,
  });

  /// Header اختياري (عنوان + caption + action).
  final WarehouseCardHeader? header;

  /// محتوى الـ card.
  final Widget child;

  /// padding داخلي للمحتوى (افتراضياً 0 — مناسب للجداول).
  final EdgeInsetsGeometry? padding;

  /// margin خارجي.
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    // ملاحظة معمارية: نفصل الـ shadow عن الـ clip لتجنّب تحذير Flutter
    // (Container لا يدعم الجمع بين shadow و clipBehavior في نفس الـ decoration).
    // الـ shadow في Container الخارجي، الـ clip في ClipRRect الداخلي.
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusXL), // r16
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.04 : 0.22),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        child: Container(
          decoration: BoxDecoration(
            color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
            border: Border.all(
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
              width: AppSizes.borderThin,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (header != null) header!,
              if (padding != null)
                Padding(padding: padding!, child: child)
              else
                child,
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                          CARD HEADER
// ══════════════════════════════════════════════════════════════════════════

/// header الكارد — يحتوي عنوان + caption (badge) + action button.
class WarehouseCardHeader extends StatefulWidget {
  const WarehouseCardHeader({
    super.key,
    required this.title,
    this.caption,
    this.actionLabel,
    this.onActionTap,
  });

  /// العنوان الرئيسي (15px, weight 700).
  final String title;

  /// caption صغير ملوّن (يظهر على شكل badge بجانب العنوان).
  final String? caption;

  /// نص الـ action button (يظهر على الجانب الآخر).
  final String? actionLabel;

  /// callback عند الضغط على الـ action.
  final VoidCallback? onActionTap;

  @override
  State<WarehouseCardHeader> createState() => _WarehouseCardHeaderState();
}

class _WarehouseCardHeaderState extends State<WarehouseCardHeader> {
  bool _actionHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.dashCyan.withValues(alpha: 0.025),
        border: Border(
          bottom: BorderSide(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
            width: AppSizes.borderThin,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── العنوان ─────────────────────────────────────────────────
          Flexible(
            child: Text(
              widget.title,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: isLight ? AppColors.lightText1 : AppColors.darkText1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // ── Caption (إذا موجود) ───────────────────────────────────
          if (widget.caption != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.dashCyan.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: Text(
                widget.caption!,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: AppColors.dashCyan,
                ),
              ),
            ),
          ],

          // ── Spacer + Action button (إذا موجود) ─────────────────────
          if (widget.actionLabel != null && widget.onActionTap != null) ...[
            const Spacer(),
            MouseRegion(
              onEnter: (_) => setState(() => _actionHovered = true),
              onExit: (_) => setState(() => _actionHovered = false),
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: widget.onActionTap,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _actionHovered ? 0.7 : 1.0,
                  child: Text(
                    widget.actionLabel!,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: AppSizes.fontMD,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: AppColors.dashCyan,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
