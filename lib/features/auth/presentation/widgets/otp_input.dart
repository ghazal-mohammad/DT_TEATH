// ════════════════════════════════════════════════════════════════════════════
// otp_input.dart
//
// Widget يعرض 6 خانات منفصلة لإدخال كود OTP.
//
// الميزات:
//   - 6 boxes منفصلة (كل box = خانة واحدة)
//   - auto-focus next box عند الكتابة
//   - auto-focus previous عند الـ backspace
//   - paste support: لو المستخدم لصق 6 أرقام، تتوزع تلقائياً
//   - animation عند الكتابة (border يلمع cyan)
//   - error state (border أحمر + shake)
//   - filled state (background fade)
//   - responsive: يتكيّف مع أي عرض بدون overflow
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';

/// حقل إدخال OTP بـ 6 خانات.
class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.onCompleted,
    required this.onChanged,
    this.length = 6,
    this.hasError = false,
    this.enabled = true,
  });

  /// callback عند اكتمال إدخال كل الخانات.
  final ValueChanged<String> onCompleted;

  /// callback عند تغيير أي خانة (للـ live state).
  final ValueChanged<String> onChanged;

  /// عدد الخانات (افتراضياً 6).
  final int length;

  /// هل هناك خطأ؟ (يتسبّب بـ shake + red border).
  final bool hasError;

  /// هل الحقل مفعّل؟
  final bool enabled;

  @override
  State<OtpInput> createState() => OtpInputState();
}

class OtpInputState extends State<OtpInput>
    with SingleTickerProviderStateMixin {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());

    // listener على كل FocusNode → setState عشان الـ border يتحدّث
    for (final node in _focusNodes) {
      node.addListener(() {
        if (mounted) setState(() {});
      });
    }

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(_shakeController);

    // auto focus على الأولى
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.enabled) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void didUpdateWidget(covariant OtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // shake عند ظهور خطأ
    if (widget.hasError && !oldWidget.hasError) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  /// مسح كل الخانات (يُستدعى من parent عند الـ resend).
  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    if (mounted && widget.enabled) {
      _focusNodes[0].requestFocus();
    }
    widget.onChanged('');
  }

  String get _currentValue =>
      _controllers.map((c) => c.text).join();

  void _onCharChanged(int index, String value) {
    // لو المستخدم لصق نص طويل (paste)
    if (value.length > 1) {
      _handlePaste(value);
      return;
    }

    // كتابة عادية
    if (value.isNotEmpty) {
      // الانتقال للخانة التالية
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // الخانة الأخيرة → unfocus
        _focusNodes[index].unfocus();
      }
    }

    final String fullValue = _currentValue;
    widget.onChanged(fullValue);

    // اكتمل الإدخال؟
    if (fullValue.length == widget.length) {
      widget.onCompleted(fullValue);
    }
  }

  void _handlePaste(String pastedText) {
    final String digits = pastedText.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return;

    final String trimmed =
        digits.substring(0, digits.length.clamp(0, widget.length));

    for (int i = 0; i < widget.length; i++) {
      _controllers[i].text = i < trimmed.length ? trimmed[i] : '';
    }

    final int nextIndex = trimmed.length.clamp(0, widget.length - 1);
    _focusNodes[nextIndex].requestFocus();

    widget.onChanged(_currentValue);
    if (_currentValue.length == widget.length) {
      widget.onCompleted(_currentValue);
    }
  }

  KeyEventResult _onKeyEvent(int index, FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      widget.onChanged(_currentValue);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // ── حساب أبعاد الخانة بشكل متجاوب ─────────────────────────
          // كل خانة تأخذ padding أفقي 4px من كل جانب = 8px إجمالي
          const double hPad = 4.0;
          // إذا كان maxWidth غير محدود (infinity)، نستخدم 340px افتراضي
          // (حجم النموذج في صفحة verify_code_page.dart = maxWidth 340)
          final double availableWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : 340.0;
          // نطرح (hPad * 2 * length) مساحة الـ padding الكلية
          final double boxWidth = ((availableWidth - (hPad * 2 * widget.length)) /
                  widget.length)
              .clamp(36.0, 54.0);
          final double boxHeight = (boxWidth * 1.15).clamp(42.0, 62.0);
          // حجم الخط يتكيّف مع حجم الصندوق
          final double fontSize = (boxWidth * 0.5).clamp(18.0, 28.0);

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // ⚠️ مهم: نفرض LTR لأن الأرقام لاتينية
            textDirection: TextDirection.ltr,
            children: List.generate(widget.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: hPad),
                child: _buildSingleBox(index, boxWidth, boxHeight, fontSize),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildSingleBox(
      int index, double boxWidth, double boxHeight, double fontSize) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final bool isFilled = _controllers[index].text.isNotEmpty;
    final bool isFocused = _focusNodes[index].hasFocus;

    final Color borderColor = widget.hasError
        ? AppColors.error
        : isFocused
            ? AppColors.primary
            : isFilled
                ? AppColors.primary.withValues(alpha: 0.5)
                : (isLight ? AppColors.lightBorder : AppColors.darkBorder);

    final Color bgColor = isFilled
        ? AppColors.primary.withValues(alpha: 0.08)
        : (isLight
            ? AppColors.lightSurface
            : AppColors.darkSurface.withValues(alpha: 0.6));

    // ─────────────────────────────────────────────────────────────────
    //  ⚠️ Bug fix: focusNode لازم يكون على TextField مباشرة.
    //  الـ outer Focus يلتقط backspace events فقط، والـ TextField
    //  بياخد الـ focusNode الفعلي.
    // ─────────────────────────────────────────────────────────────────
    return Focus(
      onKeyEvent: (node, event) => _onKeyEvent(index, node, event),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: boxWidth,
        height: boxHeight,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: borderColor,
            width: isFocused || widget.hasError ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          boxShadow: isFocused
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          enabled: widget.enabled,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) => _onCharChanged(index, value),
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: isLight ? AppColors.lightText1 : AppColors.darkText1,
            height: 1.2,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
