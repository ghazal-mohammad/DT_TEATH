// ════════════════════════════════════════════════════════════════════════════
// warehouse_alert_box.dart
//
// صندوق تنبيه ملوّن بـ gradient، يحتوي على عنوان + قائمة عناصر قابلة للنقر.
//
// المرجع: DT_Teeth_Warehouse_v6_Enhanced.html — السطور 2166–2174 + 889–920
//
// 2 variants:
//   ab-r → red    (نفاد مخزون) — مع pulse animation
//   ab-o → orange (طلبيات جديدة)
//
// تصميم الصندوق:
//   ┌──────────────────────────────────┐ ← border ملوّن
//   │ ════ shimmer line أعلى ════════ │ ← ::before (animated)
//   │ 🚨  نفاد مخزون                   │ ← header (icon + title + sub)
//   │     8 مواد حرجة                  │
//   │                                  │
//   │ ● أكواب بلاستيكية         12     │ ← item (clickable)
//   │ ● حقن بنج                  5     │
//   │ ● ماسكات                    8     │
//   └──────────────────────────────────┘
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';

// ══════════════════════════════════════════════════════════════════════════
//                          DATA & ENUMS
// ══════════════════════════════════════════════════════════════════════════

/// نوع الصندوق — يحدد الألوان والـ animation.
enum WarehouseAlertBoxVariant {
  /// أحمر — للتنبيهات الحرجة (نفاد مخزون). يشغّل pulse animation.
  red,

  /// برتقالي — للتنبيهات المتوسطة (طلبيات جديدة).
  orange,
}

/// عنصر واحد داخل [WarehouseAlertBox].
class WarehouseAlertItemData {
  const WarehouseAlertItemData({
    required this.text,
    required this.value,
    this.onTap,
  });

  /// النص الرئيسي (مثل "أكواب بلاستيكية").
  final String text;

  /// القيمة على اليسار/الجانب (مثل "12" أو "جديد").
  final String value;

  /// callback عند الضغط على العنصر.
  final VoidCallback? onTap;
}

// ══════════════════════════════════════════════════════════════════════════
//                          ALERT BOX WIDGET
// ══════════════════════════════════════════════════════════════════════════

/// صندوق تنبيه ملوّن مع قائمة عناصر.
class WarehouseAlertBox extends StatefulWidget {
  const WarehouseAlertBox({
    super.key,
    required this.variant,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  /// نوع الصندوق (يحدد الألوان).
  final WarehouseAlertBoxVariant variant;

  /// الأيقونة في الـ header.
  final IconData icon;

  /// العنوان (مثل "نفاد مخزون").
  final String title;

  /// النص الفرعي (مثل "8 مواد حرجة").
  final String subtitle;

  /// قائمة العناصر داخل الصندوق.
  final List<WarehouseAlertItemData> items;

  @override
  State<WarehouseAlertBox> createState() => _WarehouseAlertBoxState();
}

class _WarehouseAlertBoxState extends State<WarehouseAlertBox>
    with TickerProviderStateMixin {
  late final AnimationController _shimmerController;
  AnimationController? _pulseController;

  @override
  void initState() {
    super.initState();
    // Shimmer animation للخط العلوي (يعمل لكل الـ variants).
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Pulse animation فقط للـ red variant.
    if (widget.variant == WarehouseAlertBoxVariant.red) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController?.dispose();
    super.dispose();
  }

  /// لون الـ variant الأساسي.
  Color get _accentColor {
    return widget.variant == WarehouseAlertBoxVariant.red
        ? AppColors.alertRed
        : AppColors.dashOrange;
  }

  /// لون نص العنوان (أفتح من الـ accent).
  Color get _titleColor {
    return widget.variant == WarehouseAlertBoxVariant.red
        ? AppColors.alertRedSoft // #FCA5A5
        : AppColors.dashOrangeSoft; // #FDBA74 — مطابق لـ HTML
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final accent = _accentColor;

    Widget content = Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        // gradient حسب الـ variant
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.07),
            accent.withValues(alpha: 0.03),
          ],
        ),
        border: Border.all(
          color: accent.withValues(alpha: 0.22),
          width: AppSizes.borderThin,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL), // r16
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        child: Stack(
          children: [
            // ── Shimmer line في الأعلى ─────────────────────────────────
            _buildShimmerLine(accent),

            // ── المحتوى ────────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(isLight),
                const SizedBox(height: 9),
                ...widget.items.asMap().entries.map((entry) {
                  final isLast = entry.key == widget.items.length - 1;
                  return _AlertItem(
                    data: entry.value,
                    accentColor: accent,
                    isLight: isLight,
                    isLast: isLast,
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );

    // إذا الـ variant red، نلفّه بـ FadeTransition للـ pulse.
    if (widget.variant == WarehouseAlertBoxVariant.red &&
        _pulseController != null) {
      content = FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.85).animate(_pulseController!),
        child: content,
      );
    }

    return content;
  }

  /// خط shimmer animated في الأعلى.
  Widget _buildShimmerLine(Color accent) {
    // ملاحظة RTL: full-width line — left:0 + right:0 متماثل، آمن للـ RTL.
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (_, __) {
          return Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1.0 + _shimmerController.value * 2, 0),
                end: Alignment(1.0 + _shimmerController.value * 2, 0),
                colors: [
                  Colors.transparent,
                  accent,
                  Colors.transparent,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// بناء header (icon + title + subtitle).
  Widget _buildHeader(bool isLight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          widget.icon,
          size: 20,
          color: _accentColor,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: _titleColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                widget.subtitle,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  color: _titleColor.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                          ALERT ITEM (داخلي)
// ══════════════════════════════════════════════════════════════════════════

/// عنصر واحد داخل [WarehouseAlertBox] — نقطة + نص + قيمة.
class _AlertItem extends StatefulWidget {
  const _AlertItem({
    required this.data,
    required this.accentColor,
    required this.isLight,
    required this.isLast,
  });

  final WarehouseAlertItemData data;
  final Color accentColor;
  final bool isLight;
  final bool isLast;

  @override
  State<_AlertItem> createState() => _AlertItemState();
}

class _AlertItemState extends State<_AlertItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.data.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.data.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          // hover: translate -3px (في RTL: + لليمين بصرياً)
          transform: Matrix4.identity()
            ..translate(_hovered ? -3.0 : 0.0, 0.0, 0.0),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          margin: EdgeInsets.only(bottom: widget.isLast ? 0 : 5),
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM), // r8
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // نقطة ملوّنة
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: widget.accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),

              // النص الرئيسي
              Expanded(
                child: Text(
                  widget.data.text,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: widget.isLight
                        ? AppColors.lightText1
                        : AppColors.darkText1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // القيمة
              Text(
                widget.data.value,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: widget.accentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
