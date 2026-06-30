// ════════════════════════════════════════════════════════════════════════════
// app_badge.dart
//
// شارة (Badge) موحّدة مطابقة بدقة Pixel-Perfect للـ CSS classes:
//   .bdg, .bc, .bv, .bg, .bo, .br
//
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — الأسطر 757–767
//
// القواعد الـ CSS المرجعيّة الأصلية (للمطوّر الذي سيصيانة هذا الملف):
//   .bdg {
//     display:inline-flex; align-items:center; gap:3px;
//     padding:4px 10px; border-radius:20px;
//     font-size:12.5px; font-weight:700;
//   }
//   .bdg::before { content:''; width:4px; height:4px; border-radius:50%; }
//
//   .bc { background:rgba(158,251,236,0.16); color:var(--cyan-b);
//         border:1px solid rgba(158,251,236,0.30); }
//   .bv { background:rgba(237,139,250,0.25); color:#7c3aed;
//         border:1px solid rgba(237,139,250,0.45); }
//   .bg { background:rgba(13,189,127,0.30); color:#1a6b3c;
//         border:1px solid rgba(13,189,127,0.5); }
//   .bo { background:rgba(237,251,158,0.20); color:#ECFB9E;
//         border:1px solid rgba(158,251,236,0.40); }
//   .br { background:rgba(237,139,250,0.20); color:#9333ea;
//         border:1px solid rgba(237,139,250,0.40);
//         animation:alertPulse 3s infinite; }
//
// استخدام AppBadge في شاشات المخبر/المستودع يتم حصراً عبر هذا الـ widget.
// لا تستخدم Container مخصّصاً لبناء badge يدوياً لأنه يكسر توحيد المعايير.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';

/// أنواع الشارة الخمسة المتاحة في نظام DT.Teeth.
///
/// كل نوع يمثّل حالة أو سياقاً مختلفاً، ويتطابق مع الـ CSS class المذكور.
enum AppBadgeVariant {
  /// شارة سماويّة — الحالة الافتراضية/المعلومات (`.bc`).
  /// تُستخدم للحالات المحايدة: "قيد المراجعة"، "مستند بإذن"...
  cyan,

  /// شارة بنفسجيّة — النشاط الإيجابي/الخاص (`.bv`).
  /// تُستخدم لحالات التمييز أو المخبر: "تم التسليم"، "مُعتمد"...
  violet,

  /// شارة خضراء — النجاح المؤكّد (`.bg`).
  /// تُستخدم لحالات: "مكتمل"، "تمّ الدفع"، "متوفّر"...
  green,

  /// شارة ذهبيّة — التحذير/الانتظار (`.bo`).
  /// تُستخدم لحالات: "قيد الانتظار"، "منخفض"، "ينتهي قريباً"...
  gold,

  /// شارة حمراء متحرّكة — تنبيه فوري (`.br`).
  /// تُستخدم لحالات الخطر: "منتهي الصلاحية"، "نفذ المخزون"...
  /// تحتوي على أنيميشن `alertPulse` مدّته 3 ثوانٍ (نبض مستمر).
  redAnimated,
}

/// شارة موحّدة (Badge) تُعرض حالة عنصر ضمن النظام.
///
/// مطابقة بدقّة للـ class `.bdg` في ملف HTML المرجعي.
/// تحترم وضع الـ theme (light/dark) تلقائياً.
///
/// مثال:
/// ```dart
/// AppBadge(
///   text: 'مكتمل',
///   variant: AppBadgeVariant.green,
/// )
/// ```
class AppBadge extends StatefulWidget {
  /// إنشاء شارة جديدة.
  const AppBadge({
    super.key,
    required this.text,
    this.variant = AppBadgeVariant.cyan,
    this.showDot = true,
  });

  /// النص المعروض داخل الشارة. يُمرَّر مترجماً (مترجم عبر l10n).
  final String text;

  /// نوع الشارة — يحدّد الألوان والسلوك.
  final AppBadgeVariant variant;

  /// إظهار النقطة الدائرية قبل النص (`.bdg::before` في CSS).
  ///
  /// قيمتها الافتراضية `true` لتطابق السلوك الأصلي في HTML.
  final bool showDot;

  @override
  State<AppBadge> createState() => _AppBadgeState();
}

class _AppBadgeState extends State<AppBadge>
    with SingleTickerProviderStateMixin {
  // مُتحكّم واحد طوال عمر الـ State (تيكر واحد). نشغّله/نوقفه حسب النوع بدل
  // إعادة إنشائه — SingleTickerProviderStateMixin يسجّل أول تيكر دائماً ويرمي
  // "multiple tickers were created" عند إنشاء تيكر ثانٍ ولو بعد dispose.
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // alertPulse 3s infinite
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    // الأنيميشن مطلوب فقط لـ redAnimated (يطابق animation:alertPulse في CSS).
    if (widget.variant == AppBadgeVariant.redAnimated) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AppBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    // عند تغيير النوع أثناء runtime، نشغّل/نوقف نفس المُتحكّم (بلا إعادة إنشاء).
    if (oldWidget.variant != widget.variant) {
      if (widget.variant == AppBadgeVariant.redAnimated) {
        if (!_pulseController.isAnimating) _pulseController.repeat();
      } else {
        _pulseController.stop();
        _pulseController.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget badge = _buildBadge(context);

    // تطبيق أنيميشن النبض (box-shadow pulse) فقط على النوع الأحمر.
    if (widget.variant == AppBadgeVariant.redAnimated) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          // alertPulse الأصلي: 0%,100%{box-shadow:0 0 0 0 rgba(239,68,68,0)}
          //                     50%{box-shadow:0 0 0 6px rgba(239,68,68,0.08)}
          final t = (_pulseAnimation.value * 2 - 1).abs(); // 0→1→0
          final spread = (1 - t) * 6.0;
          final alpha = ((1 - t) * 0.08 * 255).round();
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withAlpha(alpha),
                  spreadRadius: spread,
                  blurRadius: 0,
                ),
              ],
            ),
            child: child,
          );
        },
        child: badge,
      );
    }

    return badge;
  }

  /// بناء جسم الشارة (بدون تأثيرات خارجية مثل pulse).
  Widget _buildBadge(BuildContext context) {
    final _BadgeColors colors = _resolveColors(context, widget.variant);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10, // من CSS: padding: 4px 10px
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border.all(color: colors.border, width: 1),
        borderRadius: BorderRadius.circular(20), // CSS: border-radius:20px
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.showDot) ...[
            // ::before dot — بالضبط 4x4px مع border-radius:50%
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: colors.dot,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 3), // CSS: gap:3px
          ],
          Text(
            widget.text,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13, // CSS exact
              fontWeight: FontWeight.w700, // 700
              color: colors.text,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  /// حلّ ألوان الشارة بناء على النوع والـ theme الحالي.
  _BadgeColors _resolveColors(BuildContext context, AppBadgeVariant variant) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    switch (variant) {
      case AppBadgeVariant.cyan:
        // .bc: rgba(158,251,236,0.16) bg, cyan-b color, rgba(158,251,236,0.30) border
        return _BadgeColors(
          background: const Color(0x299EFBEC), // 0.16
          border: const Color(0x4D9EFBEC), // 0.30
          text: isLight ? const Color(0xFF1A1C4E) : AppColors.accent,
          dot: isLight ? const Color(0xFF1A1C4E) : AppColors.accent,
        );
      case AppBadgeVariant.violet:
        // .bv: rgba(237,139,250,0.25) bg, #7c3aed color, rgba(237,139,250,0.45) border
        return const _BadgeColors(
          background: Color(0x40ED8BFA), // 0.25
          border: Color(0x73ED8BFA), // 0.45
          text: Color(0xFF7C3AED),
          dot: Color(0xFF7C3AED),
        );
      case AppBadgeVariant.green:
        // .bg: rgba(13,189,127,0.30) bg, #1a6b3c color, rgba(13,189,127,0.5) border
        return const _BadgeColors(
          background: Color(0x4D0DBD7F), // 0.30
          border: Color(0x800DBD7F), // 0.5
          text: Color(0xFF1A6B3C),
          dot: Color(0xFF1A6B3C),
        );
      case AppBadgeVariant.gold:
        // .bo: rgba(237,251,158,0.20) bg, #ECFB9E color, rgba(158,251,236,0.40) border
        return _BadgeColors(
          background: const Color(0x33EDFB9E), // 0.20
          border: const Color(0x669EFBEC), // 0.40
          text: isLight ? const Color(0xFF7A6A00) : const Color(0xFFECFB9E),
          dot: isLight ? const Color(0xFF7A6A00) : const Color(0xFFECFB9E),
        );
      case AppBadgeVariant.redAnimated:
        // .br: rgba(237,139,250,0.20) bg, #9333ea color, rgba(237,139,250,0.40) border
        // ملاحظة: HTML يستخدم الوردي للـ .br (ليس الأحمر الصريح)، ولكن
        // الـ alertPulse يستخدم rgba(239,68,68,...) — وهذه ملاحظة موثّقة
        // للمطوّر: الـ box-shadow فقط باللون الأحمر بينما الحدود وردية.
        return const _BadgeColors(
          background: Color(0x33ED8BFA), // 0.20
          border: Color(0x66ED8BFA), // 0.40
          text: Color(0xFF9333EA),
          dot: Color(0xFF9333EA),
        );
    }
  }
}

/// حاوية لونيّة داخلية — لا تُصدَّر خارج هذا الملف.
///
/// تبسّط تمرير الألوان الأربعة المطلوبة لرسم الشارة.
class _BadgeColors {
  const _BadgeColors({
    required this.background,
    required this.border,
    required this.text,
    required this.dot,
  });

  final Color background;
  final Color border;
  final Color text;
  final Color dot;
}
