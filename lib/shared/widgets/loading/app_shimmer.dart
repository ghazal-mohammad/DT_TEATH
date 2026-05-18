// ════════════════════════════════════════════════════════════════════════════
// app_shimmer.dart
//
// Widget أساسي لعرض تأثير shimmer (skeleton loader).
// يُستخدم كبديل عن Spinner التقليدي أثناء تحميل البيانات.
//
// المرجع البصري: CSS animation `shimmer` في HTML الأصلي:
//   @keyframes shimmer {
//     0% { background-position:-200% 0 }
//     100% { background-position:200% 0 }
//   }
//
// الفكرة: نغلّف الـ child بـ ShaderMask مع LinearGradient متحرّك
// يعطي انطباع "موجة ضوء" تمرّ فوق المحتوى.
//
// الفرق عن _ShimmerBar في app_alert_box.dart: هذا عام (يغلّف أي widget)
// بينما تلك مخصّصة لشريط خطّي رفيع.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Widget يضيف تأثير shimmer على أي child.
///
/// يعمل بتطبيق ShaderMask مع gradient متحرك من اليمين إلى اليسار.
/// اللون الأساسي باهت، والـ highlight أفتح لإعطاء تأثير اللمعان.
///
/// يُستخدم كمغلّف (wrapper) حول shapes بسيطة (Container, ClipRRect...) لعمل
/// placeholder جميل للمحتوى اللي لسّه جاي.
///
/// مثال:
/// ```dart
/// AppShimmer(
///   child: Container(
///     width: 200,
///     height: 16,
///     decoration: BoxDecoration(
///       color: Colors.white,
///       borderRadius: BorderRadius.circular(8),
///     ),
///   ),
/// )
/// ```
class AppShimmer extends StatefulWidget {
  const AppShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.enabled = true,
  });

  /// الـ widget الذي سيُطبَّق عليه تأثير shimmer.
  final Widget child;

  /// مدة دورة الـ animation الكاملة.
  final Duration duration;

  /// إذا false، يُعرض الـ child كما هو بدون تأثير.
  /// مفيد لتشغيل/إيقاف الـ shimmer ديناميكياً.
  final bool enabled;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AppShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final bool isLight = Theme.of(context).brightness == Brightness.light;

    // الألوان حسب الثيم
    final Color baseColor = isLight
        ? AppColors.lightBg2
        : AppColors.darkSurface;

    final Color highlightColor = isLight
        ? AppColors.lightSurface
        : AppColors.darkGlass;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // الـ gradient يتحرك من -1 إلى 2 (خارج الـ bounds من كل جهة)
        // ليبدأ من خارج الشاشة ويخرج بالكامل عبر الـ child
        final double t = _controller.value;
        final double start = -1.0 + t * 3.0; // -1 → 2

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                baseColor,
                highlightColor,
                baseColor,
                baseColor,
              ],
              stops: [
                0.0,
                (start - 0.3).clamp(0.0, 1.0),
                start.clamp(0.0, 1.0),
                (start + 0.3).clamp(0.0, 1.0),
                1.0,
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Helper widget لإنشاء box بلون الـ shimmer base.
///
/// يُستخدم داخل [AppShimmer] كـ placeholder لعنصر مثل نص أو صورة.
///
/// مثال:
/// ```dart
/// AppShimmer(
///   child: Column(
///     children: [
///       AppShimmerBox(width: 200, height: 16),
///       SizedBox(height: 8),
///       AppShimmerBox(width: 150, height: 12),
///     ],
///   ),
/// )
/// ```
class AppShimmerBox extends StatelessWidget {
  const AppShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  /// عرض المربع.
  final double width;

  /// ارتفاع المربع.
  final double height;

  /// نصف قطر زوايا المربع.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightBg2 : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
