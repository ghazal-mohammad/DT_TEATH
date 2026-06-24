// ════════════════════════════════════════════════════════════════════════════
// warehouse_stat_card.dart
//
// بطاقة إحصائية ملوّنة في Dashboard المستودع.
// 4 variants حسب نوع الإحصائية:
//   cc (cyan)  — المخزون الحالي
//   cr (red)   — مواد قاربت النفاد
//   co (orange)— طلبات واردة
//   cg (green) — مواد منتهية الصلاحية (لكنها استثنائياً orange/red في HTML)
//
// المرجع: DT_Teeth_Warehouse_v6_Enhanced.html — السطور 2141–2146 + 745–799
//
// تصميم البطاقة:
//   ┌─────────────────────────────────┐
//   │ ╔════ خط gradient أعلى ═══════╗ │ ← ::before (2px)
//   │  [📦]              +4         │ ← icon + chip
//   │                               │
//   │   247                         │ ← value (34px, gradient text)
//   │   المخزون الحالي              │ ← label
//   └─────────────────────────────────┘
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';

// ══════════════════════════════════════════════════════════════════════════
//                          ENUMS & DATA
// ══════════════════════════════════════════════════════════════════════════

/// نوع بطاقة الإحصائية — يحدد الألوان والـ gradient.
enum WarehouseStatCardVariant {
  /// سماوي — للمعلومات العامة (مخزون، إجمالي).
  cyan,

  /// أحمر — للتنبيهات الحرجة (نفاد).
  red,

  /// برتقالي — للتنبيهات المتوسطة (طلبات جديدة).
  orange,

  /// أخضر — للحالات الإيجابية.
  green,

  /// بنفسجي — لمواد منتهية الصلاحية (variant خاصة).
  violet,
}

/// نوع الـ chip في أعلى البطاقة (دلالة التغيّر).
enum WarehouseStatChipType {
  /// أخضر — زيادة إيجابية (مثل +4).
  up,

  /// أحمر — تنبيه (نقص أو تحذير).
  down,

  /// برتقالي — تحذير (warning).
  warn,

  /// سماوي — معلومة عادية (ok).
  ok,
}

// ══════════════════════════════════════════════════════════════════════════
//                          STAT CARD WIDGET
// ══════════════════════════════════════════════════════════════════════════

/// بطاقة إحصائية بـ 4 variants ملوّنة، تظهر أيقونة + chip + قيمة + label.
///
/// مثال:
/// ```dart
/// WarehouseStatCard(
///   variant: WarehouseStatCardVariant.cyan,
///   icon: Icons.inventory,
///   value: 247,
///   label: context.l10n.whStatCurrentInventory,
///   chipText: '+4',
///   chipType: WarehouseStatChipType.up,
///   onTap: () => context.go(RouteNames.warehouseMaterials),
/// )
/// ```
class WarehouseStatCard extends StatefulWidget {
  const WarehouseStatCard({
    super.key,
    required this.variant,
    required this.icon,
    required this.value,
    required this.label,
    required this.chipText,
    required this.chipType,
    this.onTap,
  });

  /// لون البطاقة (cc/cr/co/cg/cv).
  final WarehouseStatCardVariant variant;

  /// الأيقونة في الزاوية اليمنى العليا.
  final IconData icon;

  /// القيمة الكبيرة (الرقم).
  final int value;

  /// النص تحت القيمة.
  final String label;

  /// نص الـ chip (مثل "+4" أو "تنبيه").
  final String chipText;

  /// نوع الـ chip (يحدد لونه).
  final WarehouseStatChipType chipType;

  /// callback عند الضغط على البطاقة.
  final VoidCallback? onTap;

  @override
  State<WarehouseStatCard> createState() => _WarehouseStatCardState();
}

class _WarehouseStatCardState extends State<WarehouseStatCard> {
  bool _hovered = false;

  /// الألوان الأساسية للـ variant (start, end للـ gradient).
  ({Color start, Color end}) get _colors {
    switch (widget.variant) {
      case WarehouseStatCardVariant.cyan:
        return (start: AppColors.dashCyan, end: AppColors.info);
      case WarehouseStatCardVariant.green:
        return (start: AppColors.dashGreen, end: AppColors.success);
      case WarehouseStatCardVariant.orange:
        return (start: AppColors.dashOrange, end: AppColors.dashAmber);
      case WarehouseStatCardVariant.red:
        return (start: AppColors.alertRed, end: AppColors.dashPink);
      case WarehouseStatCardVariant.violet:
        return (start: AppColors.dashViolet, end: AppColors.dashPink);
    }
  }

  /// لون الـ chip حسب نوعه.
  ({Color bg, Color fg}) get _chipColors {
    switch (widget.chipType) {
      case WarehouseStatChipType.up:
        return (
          bg: AppColors.dashGreen.withValues(alpha: 0.12),
          fg: AppColors.dashGreen,
        );
      case WarehouseStatChipType.down:
        return (
          bg: AppColors.alertRed.withValues(alpha: 0.10),
          fg: AppColors.alertRed,
        );
      case WarehouseStatChipType.warn:
        return (
          bg: AppColors.dashOrange.withValues(alpha: 0.10),
          fg: AppColors.dashOrange,
        );
      case WarehouseStatChipType.ok:
        return (
          bg: AppColors.dashCyan.withValues(alpha: 0.10),
          fg: AppColors.dashCyan,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final colors = _colors;
    final chipColors = _chipColors;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translateByDouble(0.0, _hovered ? -5.0 : 0.0, 0.0, 1.0)
            ..scaleByDouble(_hovered ? 1.02 : 1.0, _hovered ? 1.02 : 1.0,
                _hovered ? 1.02 : 1.0, 1.0),
          transformAlignment: Alignment.center,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            // من CSS: linear-gradient(145deg, rgba(15,30,66,0.8), rgba(10,20,44,0.7))
            gradient: isLight
                ? null
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.statCardDarkStart,
                      AppColors.statCardDarkEnd,
                    ],
                  ),
            color: isLight ? AppColors.lightSurface : null,
            border: Border.all(
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
              width: AppSizes.borderThin,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusXL), // r16
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: colors.start.withValues(alpha: 0.20),
                      blurRadius: 40,
                      offset: const Offset(0, 12),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            child: Stack(
              children: [
                // ── Pseudo-element ::before — خط gradient أعلى ────────
                // ملاحظة RTL: نستخدم Positioned (مش PositionedDirectional)
                // لأن الـ left:0 + right:0 يجعل الخط full-width — متماثل
                // في الاتجاهين، وما في فرق بين RTL/LTR.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.start, colors.end],
                      ),
                    ),
                  ),
                ),

                // ── المحتوى ────────────────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // الصف العلوي (icon + chip)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildIcon(colors.start),
                        _buildChip(chipColors.bg, chipColors.fg),
                      ],
                    ),
                    const SizedBox(height: 9),

                    // القيمة (gradient text)
                    _buildValue(colors),
                    const SizedBox(height: 2),

                    // الـ label
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                        color: isLight
                            ? AppColors.lightText3
                            : AppColors.darkText3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// الأيقونة في صندوق ملوّن 40×40.
  Widget _buildIcon(Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: Icon(
        widget.icon,
        size: 17,
        color: color,
      ),
    );
  }

  /// الـ chip بلون حسب نوعه.
  Widget _buildChip(Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        widget.chipText,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: fg,
        ),
      ),
    );
  }

  /// القيمة الكبيرة بـ gradient text.
  Widget _buildValue(({Color start, Color end}) colors) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [colors.start, colors.end],
      ).createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(
        widget.value.toString(),
        style: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 34,
          fontWeight: FontWeight.w900,
          height: 1.0,
          color: Colors.white, // سيتم تطبيق الـ gradient فوقه
        ),
      ),
    );
  }
}
