// ════════════════════════════════════════════════════════════════════════════
// app_progress_bar.dart
//
// شريط تقدّم موحّد — `.pb`, `.pbf`
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — الأسطر 824–826
//
// القواعد الأصلية:
//   .pb  { height:4px; border-radius:2px;
//          background:rgba(255,255,255,0.06); overflow:hidden }
//   .pbf { height:100%; border-radius:2px;
//          transition:width 0.8s cubic-bezier(0.4,0,0.2,1) }
//
// يُستخدم في:
//   - عرض مستوى المخزون (0–100%)
//   - التقدم في طلبات المخبر (قيد التنفيذ)
//   - أشرطة الإحصاءات السريعة
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

/// أنواع لون الـ progress bar وفق الحالة.
enum AppProgressBarVariant {
  /// أخضر — تقدّم صحي (مخزون كافٍ، طلب يسير...).
  success,

  /// سماوي — افتراضي/محايد.
  info,

  /// ذهبي — تحذير معتدل (مخزون منخفض، اقتراب).
  warning,

  /// وردي/أحمر — حرج (مخزون حرج، طلب متأخر).
  critical,

  /// gradient سماوي→أزرق — للإحصاءات الرئيسية.
  gradient,
}

/// شريط تقدّم موحّد — ارتفاع ثابت 4px مع انتقال ناعم.
///
/// مثال:
/// ```dart
/// AppProgressBar(
///   value: 0.75, // 75%
///   variant: AppProgressBarVariant.warning,
/// )
/// ```
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.variant = AppProgressBarVariant.info,
    this.height = 4,
    this.showPercentage = false,
    this.label,
  }) : assert(value >= 0 && value <= 1, 'value must be between 0 and 1');

  /// القيمة من 0.0 إلى 1.0.
  final double value;

  final AppProgressBarVariant variant;

  /// الارتفاع (الافتراضي 4px مطابق لـ HTML).
  final double height;

  /// إظهار النسبة المئوية على اليمين — useful في الشاشات التفصيلية.
  final bool showPercentage;

  /// عنوان اختياري فوق الشريط (مثل "مستوى المخزون").
  final String? label;

  @override
  Widget build(BuildContext context) {
    final Widget bar = SizedBox(
      height: height,
      child: Stack(
        children: [
          // .pb — الخلفية
          Container(
            decoration: BoxDecoration(
              color: const Color(0x0FFFFFFF), // rgba(255,255,255,0.06)
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // .pbf — الجزء المملوء
          FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: const Cubic(0.4, 0, 0.2, 1),
              decoration: BoxDecoration(
                gradient: _buildGradient(),
                color: _buildSolidColor(),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );

    if (label == null && !showPercentage) return bar;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null || showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                if (label != null)
                  Expanded(
                    child: Text(
                      label!,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFF3A5AB8)
                            : const Color(0xFF9EFBEC),
                      ),
                    ),
                  ),
                if (showPercentage)
                  Text(
                    '${(value * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _buildSolidColor() ?? const Color(0xFF9EFBEC),
                    ),
                  ),
              ],
            ),
          ),
        bar,
      ],
    );
  }

  Gradient? _buildGradient() {
    if (variant == AppProgressBarVariant.gradient) {
      return const LinearGradient(
        colors: [Color(0xFF9EFBEC), Color(0xFF3A5AB8)],
      );
    }
    return null;
  }

  Color? _buildSolidColor() {
    switch (variant) {
      case AppProgressBarVariant.success:
        return const Color(0xFF0DBD7F);
      case AppProgressBarVariant.info:
        return const Color(0xFF9EFBEC);
      case AppProgressBarVariant.warning:
        return const Color(0xFFF97316);
      case AppProgressBarVariant.critical:
        return const Color(0xFFEF4444);
      case AppProgressBarVariant.gradient:
        return null; // يستخدم gradient
    }
  }
}
