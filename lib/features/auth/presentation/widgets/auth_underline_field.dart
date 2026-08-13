// ════════════════════════════════════════════════════════════════════════════
// auth_underline_field.dart
//
// حقل نصي بخط سفلي + label عائم (Material floating label أصلي، لا تلوين
// خلفية). يستبدل EmailFormField / PasswordFormField / _InputField الخاص
// بـ login_page — واحد لكل حالات الاستخدام (بريد مع اقتراحات، كلمة سر مع
// إظهار/إخفاء، نص عادي).
//
// الأيقونة الأمامية وزر المسح/الإظهار يتموضعان تلقائياً حسب Directionality
// المحيطة (RTL/LTR) لأن InputDecoration.prefixIcon/suffixIcon و TextField's
// Row الداخلي مبنيان على Directionality من الأساس — لا حاجة لمنطق يدوي هنا.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'email_suggestion_engine.dart';

class AuthUnderlineField extends StatefulWidget {
  const AuthUnderlineField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.enabled = true,
    this.obscureText = false,
    this.showObscureToggle = false,
    this.suggestionDomains = const <String>[],
    this.keyboardType,
    this.autofillHints,
    this.dark = false,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final bool enabled;

  /// القيمة الابتدائية لإخفاء النص (كلمة السر). يُتحكَّم بها داخلياً بعدها
  /// عبر زر الإظهار/الإخفاء عندما [showObscureToggle] = true.
  final bool obscureText;

  /// true = يظهر زر عين للإظهار/الإخفاء بدل زر المسح (لحقول كلمة السر).
  final bool showObscureToggle;

  /// نطاقات اقتراحات البريد. فارغة = لا اقتراحات (الافتراضي).
  final List<String> suggestionDomains;

  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;

  /// true = نص/تسميات فاتحة على خلفية داكنة (موبايل).
  final bool dark;

  final TextInputAction? textInputAction;

  @override
  State<AuthUnderlineField> createState() => _AuthUnderlineFieldState();
}

class _AuthUnderlineFieldState extends State<AuthUnderlineField> {
  late final FocusNode _focusNode;
  late final EmailSuggestionEngine _engine;
  bool _obscure = true;
  List<String> _suggestions = const [];

  bool get _suggestionsEnabled => widget.suggestionDomains.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
    _engine = EmailSuggestionEngine(domains: widget.suggestionDomains);
    _focusNode = FocusNode()..addListener(_onFocusChange);
    if (_suggestionsEnabled) widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    if (_suggestionsEnabled) widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      if (!_focusNode.hasFocus) {
        _suggestions = const [];
      } else if (_suggestionsEnabled) {
        _suggestions = _engine.suggestionsFor(widget.controller.text);
      }
    });
  }

  void _onTextChanged() {
    if (!_focusNode.hasFocus) return;
    setState(
        () => _suggestions = _engine.suggestionsFor(widget.controller.text));
  }

  void _applySuggestion(String suggestion) {
    widget.controller.value = TextEditingValue(
      text: suggestion,
      selection: TextSelection.collapsed(offset: suggestion.length),
    );
    widget.onChanged?.call(suggestion);
    setState(() => _suggestions = const []);
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = widget.dark ? Colors.white : AppColors.authInputTextLight;
    final Color labelColor = widget.dark
        ? Colors.white.withValues(alpha: 0.70)
        : AppColors.authLabelLight;
    final Color lineColor = widget.dark
        ? Colors.white.withValues(alpha: 0.35)
        : AppColors.authDividerLight;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.controller,
      builder: (context, value, _) {
        final bool isFocused = _focusNode.hasFocus;
        final Color iconColor = isFocused
            ? AppColors.accent
            : (widget.dark
                ? Colors.white.withValues(alpha: 0.55)
                : AppColors.authInputIconLight);

        Widget? suffix;
        if (widget.showObscureToggle) {
          suffix = IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'إظهار/إخفاء كلمة المرور',
            icon: Icon(
              _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 18,
              color: iconColor,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          );
        } else if (value.text.isNotEmpty) {
          suffix = IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'مسح',
            icon: Icon(Icons.close_rounded, size: 18, color: iconColor),
            onPressed: () {
              widget.controller.clear();
              widget.onChanged?.call('');
              setState(() => _suggestions = const []);
            },
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              obscureText: _obscure,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              autofillHints: widget.autofillHints,
              autocorrect: false,
              enableSuggestions: false,
              textDirection: TextDirection.ltr,
              style: AppTextStyles.authFieldInput.copyWith(color: textColor),
              decoration: InputDecoration(
                labelText: widget.label,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                labelStyle: AppTextStyles.authFieldLabel.copyWith(color: labelColor),
                floatingLabelStyle: AppTextStyles.authFieldLabel.copyWith(
                  color: isFocused ? AppColors.accent : labelColor,
                ),
                errorText: widget.errorText,
                errorStyle: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontFamily: AppTextStyles.fontFamily,
                ),
                prefixIcon: Icon(widget.icon, size: 20, color: iconColor),
                suffixIcon: suffix,
                isDense: true,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: lineColor, width: 1.5),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.accent, width: 2),
                ),
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.error, width: 1.5),
                ),
                focusedErrorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.error, width: 2),
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: _suggestionsEnabled && _suggestions.isNotEmpty
                  ? _SuggestionsPanel(
                      suggestions: _suggestions,
                      dark: widget.dark,
                      onTap: _applySuggestion,
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        );
      },
    );
  }
}

class _SuggestionsPanel extends StatelessWidget {
  const _SuggestionsPanel({
    required this.suggestions,
    required this.dark,
    required this.onTap,
  });

  final List<String> suggestions;
  final bool dark;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        decoration: BoxDecoration(
          color: dark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: suggestions
              .take(5)
              .map((s) => _SuggestionRow(
                    text: s,
                    dark: dark,
                    onTap: () => onTap(s),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _SuggestionRow extends StatefulWidget {
  const _SuggestionRow({
    required this.text,
    required this.dark,
    required this.onTap,
  });

  final String text;
  final bool dark;
  final VoidCallback onTap;

  @override
  State<_SuggestionRow> createState() => _SuggestionRowState();
}

class _SuggestionRowState extends State<_SuggestionRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: _hovered
              ? AppColors.accent.withValues(alpha: 0.10)
              : Colors.transparent,
          child: Text(
            widget.text,
            textDirection: TextDirection.ltr,
            style: AppTextStyles.authFieldInput.copyWith(
              fontSize: 13,
              color: widget.dark ? Colors.white : AppColors.authInputTextLight,
            ),
          ),
        ),
      ),
    );
  }
}
