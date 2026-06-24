// ════════════════════════════════════════════════════════════════════════════
// app_alert_box.dart
//
// صندوق تنبيه موحّد — `.ab`, `.ab-r`, `.ab-o`, `.ab-head`, `.ab-item`
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — الأسطر 828–860
//
// القواعد الأصلية:
//   .ab { border-radius:var(--r16); padding:16px; margin-bottom:11px;
//         position:relative; overflow:hidden; }
//   .ab::before { content:''; position:absolute; top:0; left:0; right:0;
//                 height:1px; animation:shimmer 2s linear infinite;
//                 background-size:200% 100%; }
//
//   .ab-r (danger):
//     background:linear-gradient(135deg,rgba(239,68,68,0.07),rgba(239,68,68,0.03));
//     border:1px solid rgba(239,68,68,0.22);
//     animation:alertPulse 3s infinite;
//   .ab-r::before { background:linear-gradient(90deg,transparent,red,transparent); }
//
//   .ab-o (warning):
//     background:linear-gradient(135deg,rgba(249,115,22,0.07),rgba(249,115,22,0.03));
//     border:1px solid rgba(249,115,22,0.22);
//   .ab-o::before { background:linear-gradient(90deg,transparent,orange,transparent); }
//
//   .ab-head { display:flex; align-items:center; gap:7px; margin-bottom:9px }
//   .ab-ico  { font-size:20px }
//   .ab-title { font-size:14px; font-weight:700 }
//     .ab-r.ab-title → #fca5a5; .ab-o.ab-title → #fdba74
//   .ab-sub  { font-size:12px; margin-top:1px }
//
//   .ab-item { display:flex; gap:7px; padding:7px 9px; border-radius:var(--r8);
//              background:rgba(255,255,255,0.03); margin-bottom:5px;
//              cursor:pointer; transition:all 0.18s; }
//   .ab-item:hover { background:rgba(255,255,255,0.07); transform:translateX(-3px) }
//
//   .ab-dot { width:5px; height:5px; border-radius:50% }
//   .ab-txt { font-size:13.5px; color:var(--t1); flex:1; font-weight:600 }
//   .ab-val { font-size:13.5px; font-weight:700 }
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';

/// أنواع صندوق التنبيه.
enum AppAlertBoxVariant {
  /// خطر — لون أحمر + أنيميشن pulse مستمر.
  /// يُستخدم لـ: مواد منتهية الصلاحية، طلبات متأخرة، أخطاء نظام.
  danger,

  /// تحذير — لون برتقالي بدون pulse.
  /// يُستخدم لـ: مخزون منخفض، اقتراب تاريخ انتهاء، مهام معلّقة.
  warning,
}

/// عنصر واحد ضمن صندوق التنبيه.
class AppAlertBoxItem {
  const AppAlertBoxItem({
    required this.text,
    required this.value,
    this.onTap,
  });

  /// النص الأيسر (مثال: "قفازات مقاس L").
  final String text;

  /// القيمة الأيمن (مثال: "3 قطع" أو "2024-12-31").
  final String value;

  /// نقر للانتقال إلى التفاصيل — اختياري.
  final VoidCallback? onTap;
}

/// صندوق تنبيه يجمع مجموعة من العناصر تحت عنوان.
///
/// مثال:
/// ```dart
/// AppAlertBox(
///   variant: AppAlertBoxVariant.danger,
///   icon: Icons.warning,
///   title: 'مخزون حرج',
///   subtitle: '3 مواد بحاجة لإعادة طلب',
///   items: [
///     AppAlertBoxItem(text: 'قفازات طبية L', value: '5 قطع'),
///     AppAlertBoxItem(text: 'كمامات جراحية', value: '12 قطعة'),
///   ],
/// )
/// ```
class AppAlertBox extends StatefulWidget {
  const AppAlertBox({
    super.key,
    required this.variant,
    required this.icon,
    required this.title,
    required this.items,
    this.subtitle,
  });

  final AppAlertBoxVariant variant;
  final IconData icon;
  final String title;
  final String? subtitle;
  final List<AppAlertBoxItem> items;

  @override
  State<AppAlertBox> createState() => _AppAlertBoxState();
}

class _AppAlertBoxState extends State<AppAlertBox>
    with TickerProviderStateMixin {
  late final AnimationController _shimmerController;
  AnimationController? _pulseController;

  @override
  void initState() {
    super.initState();
    // shimmer 2s linear infinite — للشريط العلوي
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // alertPulse 3s infinite — فقط على النوع danger
    if (widget.variant == AppAlertBoxVariant.danger) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _AlertBoxColors colors = _resolveColors(widget.variant);

    // 1. الجسم الرئيسي
    Widget box = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight, // 135deg
          colors: colors.backgroundGradient,
        ),
        border: Border.all(color: colors.borderColor),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(colors),
          const SizedBox(height: 9),
          ...widget.items.map((item) => _AlertBoxItemTile(
                item: item,
                valueColor: colors.valueColor,
              )),
        ],
      ),
    );

    // 2. الشريط الـ shimmer العلوي (::before)
    box = Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          child: box,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _ShimmerBar(
            controller: _shimmerController,
            color: colors.shimmerColor,
          ),
        ),
      ],
    );

    // 3. أنيميشن pulse (box-shadow pulsing) لـ danger
    if (_pulseController != null) {
      box = AnimatedBuilder(
        animation: _pulseController!,
        builder: (context, child) {
          final double t = (_pulseController!.value * 2 - 1).abs();
          final double spread = (1 - t) * 6.0;
          final int alpha = ((1 - t) * 0.08 * 255).round();
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              boxShadow: [
                BoxShadow(
                  color: AppColors.statusUrgent.withAlpha(alpha),
                  spreadRadius: spread,
                  blurRadius: 0,
                ),
              ],
            ),
            child: child,
          );
        },
        child: box,
      );
    }

    // 4. margin-bottom:11px بين الصناديق
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: box,
    );
  }

  Widget _buildHeader(_AlertBoxColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // .ab-ico
        Icon(widget.icon, size: 20, color: colors.iconColor),
        const SizedBox(width: 7), // gap:7px
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.titleColor,
                  height: 1.2,
                ),
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 1),
                Text(
                  widget.subtitle!,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    color: colors.subtitleColor,
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  _AlertBoxColors _resolveColors(AppAlertBoxVariant variant) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    switch (variant) {
      case AppAlertBoxVariant.danger:
        return _AlertBoxColors(
          // rgba(239,68,68,0.07) → 0.03
          backgroundGradient: [
            const Color(0x12EF4444),
            const Color(0x08EF4444),
          ],
          borderColor: const Color(0x38EF4444), // 0.22
          shimmerColor: AppColors.statusUrgent,
          iconColor: AppColors.statusUrgent,
          titleColor: isLight
              ? const Color(0xFFDC2626)
              : const Color(0xFFFCA5A5),
          subtitleColor: isLight
              ? AppColors.statusUrgent
              : const Color(0x99FCA5A5), // rgba(252,165,165,0.6)
          valueColor: AppColors.statusUrgent,
        );
      case AppAlertBoxVariant.warning:
        return _AlertBoxColors(
          // rgba(249,115,22,0.07) → 0.03
          backgroundGradient: [
            const Color(0x12F97316),
            const Color(0x08F97316),
          ],
          borderColor: const Color(0x38F97316),
          shimmerColor: const Color(0xFFF97316),
          iconColor: const Color(0xFFF97316),
          titleColor: isLight
              ? const Color(0xFFEA580C)
              : const Color(0xFFFDBA74),
          subtitleColor: isLight
              ? const Color(0xFFF97316)
              : const Color(0x99FDBA74),
          valueColor: const Color(0xFFF97316),
        );
    }
  }
}

class _AlertBoxColors {
  const _AlertBoxColors({
    required this.backgroundGradient,
    required this.borderColor,
    required this.shimmerColor,
    required this.iconColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.valueColor,
  });

  final List<Color> backgroundGradient;
  final Color borderColor;
  final Color shimmerColor;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;
  final Color valueColor;
}

/// الشريط العلوي المتحرّك (::before) — shimmer effect.
class _ShimmerBar extends StatelessWidget {
  const _ShimmerBar({required this.controller, required this.color});

  final AnimationController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // background-position: 200% → -200% (linear)
        final double t = controller.value; // 0→1
        final double translate = -2.0 + t * 4.0; // -200% → 200%
        return SizedBox(
          height: 1,
          child: ClipRect(
            child: OverflowBox(
              maxWidth: double.infinity,
              alignment: Alignment.centerLeft,
              child: FractionalTranslation(
                translation: Offset(translate, 0),
                child: Container(
                  height: 1,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        color,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// عنصر فردي داخل صندوق التنبيه.
class _AlertBoxItemTile extends StatefulWidget {
  const _AlertBoxItemTile({required this.item, required this.valueColor});

  final AppAlertBoxItem item;
  final Color valueColor;

  @override
  State<_AlertBoxItemTile> createState() => _AlertBoxItemTileState();
}

class _AlertBoxItemTileState extends State<_AlertBoxItemTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return MouseRegion(
      cursor: widget.item.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.item.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 5),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          transform: _isHovered
              ? (Matrix4.identity()..translateByDouble(-3.0, 0.0, 0.0, 1.0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: _isHovered
                ? (isLight ? const Color(0x1A1A1C4E) : const Color(0x12FFFFFF))
                : (isLight ? const Color(0x0D1A1C4E) : const Color(0x08FFFFFF)),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Row(
            children: [
              // .ab-dot — نقطة 5x5
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: widget.valueColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  widget.item.text,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isLight
                        ? AppColors.lightText1
                        : AppColors.darkText1,
                    height: 1.2,
                  ),
                ),
              ),
              Text(
                widget.item.value,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isLight
                      ? const Color(0xFF5A6A9A)
                      : widget.valueColor,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
