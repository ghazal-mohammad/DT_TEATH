// ════════════════════════════════════════════════════════════════════════════
// password_form_field.dart
//
// حقل إدخال كلمة المرور مع زر إظهار/إخفاء.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';

class PasswordFormField extends StatefulWidget {
  const PasswordFormField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.label,
    this.hint = '••••••••',
    this.errorText,
    this.enabled = true,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final String label;
  final String hint;
  final String? errorText;
  final bool enabled;

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  late final FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final bool hasError = widget.errorText != null;

    final Color borderColor = hasError
        ? AppColors.error
        : _isFocused
            ? AppColors.primary
            : (isLight ? AppColors.lightBorder : AppColors.darkBorder);

    final Color bgColor = isLight
        ? AppColors.lightSurface
        : AppColors.darkSurface.withValues(alpha: 0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isLight ? AppColors.lightText2 : AppColors.darkText2,
              height: 1.2,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            border: Border.all(
              color: borderColor,
              width: _isFocused || hasError ? 2 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 16, end: 12),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 20,
                  color: _isFocused
                      ? AppColors.primary
                      : (isLight
                          ? AppColors.lightText3
                          : AppColors.darkText3),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  obscureText: _obscureText,
                  // أمان الأجهزة المشتركة: منع حفظ/اقتراح المتصفّح للاعتمادات.
                  autofillHints: const <String>[],
                  enableSuggestions: false,
                  autocorrect: false,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isLight
                        ? AppColors.lightText1
                        : AppColors.darkText1,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 15,
                      color: isLight
                          ? AppColors.lightText4
                          : AppColors.darkText4,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    isDense: true,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _obscureText = !_obscureText),
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 16, start: 8),
                  child: Icon(
                    _obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: isLight
                        ? AppColors.lightText3
                        : AppColors.darkText3,
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: hasError
              ? Padding(
                  padding: const EdgeInsetsDirectional.only(start: 4, top: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 14,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.errorText!,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
          ),
      ],
    );
  }
}
