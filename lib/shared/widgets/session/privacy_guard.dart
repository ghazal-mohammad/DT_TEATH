// ════════════════════════════════════════════════════════════════════════════
// privacy_guard.dart
//
// ستار خصوصية عبر كل المنصّات: يغطّي محتوى التطبيق بشاشة براند مُعتِمة كلما
// خرج التطبيق من المقدّمة (inactive / paused / hidden).
//
// 🎯 لماذا (أمن بيانات المرضى):
//   نظام التشغيل يلتقط "لقطة" لآخر إطار للتطبيق ليعرضها في مبدّل التطبيقات
//   (recents / Alt-Tab). بدون ستار، هذه اللقطة قد تكشف اسم مريض أو راتب موظف.
//   الستار يضمن أن اللقطة تُظهر اللوغو فقط.
//
// 🔒 يكمّل الحماية الأصيلة:
//   - Android: FLAG_SECURE (native) يمنع الالتقاط أصلاً + يُفرِغ الـ recents.
//   - iOS/سطح المكتب: لا مكافئ لـ FLAG_SECURE، فهذا الستار هو خط الدفاع للقطة.
//
// قاعدة معمارية: لا يمسّ أي شاشة — يغلّف الجذر مرّة واحدة في main.dart.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../core/l10n/build_context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../brand/app_logo.dart';

/// يغطّي [child] بستار خصوصية عندما لا يكون التطبيق في المقدّمة.
class PrivacyGuard extends StatefulWidget {
  const PrivacyGuard({super.key, required this.child});

  final Widget child;

  @override
  State<PrivacyGuard> createState() => _PrivacyGuardState();
}

class _PrivacyGuardState extends State<PrivacyGuard>
    with WidgetsBindingObserver {
  /// هل التطبيق حالياً خارج المقدّمة؟ (⇒ نعرض الستار).
  bool _obscured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // نُظهر الستار في كل حالة غير resumed — بما فيها inactive (بداية الانتقال
    // لمبدّل التطبيقات على iOS) حتى تكون اللقطة مُغطّاة دائماً.
    final shouldObscure = state != AppLifecycleState.resumed;
    if (shouldObscure != _obscured) {
      setState(() => _obscured = shouldObscure);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_obscured)
          // TickerMode يوقف أي أنيميشن تحت الستار أثناء الإخفاء.
          const _PrivacyCurtain(),
      ],
    );
  }
}

/// الستار نفسه — خلفية براند مُعتِمة + لوغو + قفل. مبنيّ ضمن Directionality/
/// Localizations (لأنه فوق MaterialApp.builder) فيصل لـ context.l10n بأمان.
class _PrivacyCurtain extends StatelessWidget {
  const _PrivacyCurtain();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: AppColors.modalDarkStart,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.modalDarkStart, AppColors.modalDarkEnd],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(
                  size: 96,
                  variant: AppLogoVariant.darkTheme,
                  showText: true,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: AppColors.dashCyan,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      context.l10n.privacyScreenHint,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dashCyan,
                      ),
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
}
