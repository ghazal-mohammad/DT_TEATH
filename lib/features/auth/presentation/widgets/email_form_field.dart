// ════════════════════════════════════════════════════════════════════════════
// email_form_field.dart
//
// حقل إدخال إيميل متقدّم — مع:
//   - اقتراحات domains تلقائية (gmail.com, dtteeth.com, ...) عند كتابة @
//   - دعم Enter key للـ submit
//   - validation real-time
//   - animations سلسة عند الـ focus
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';

/// قائمة الـ domains الشائعة للاقتراحات.
const List<String> _commonDomains = [
  'gmail.com',
  'yahoo.com',
  'hotmail.com',
  'outlook.com',
  'dtteeth.com',
  'icloud.com',
];

/// حقل إدخال إيميل مع اقتراحات وanimations.
class EmailFormField extends StatefulWidget {
  const EmailFormField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    this.label,
    this.hint,
    this.errorText,
    this.enabled = true,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  /// يُستدعى عند Enter — حتى لو الإيميل ناقص.
  /// الـ parent بيقرّر إذا يقبل أو يرفض.
  final ValueChanged<String> onSubmitted;

  final String? label;
  final String? hint;
  final String? errorText;
  final bool enabled;

  @override
  State<EmailFormField> createState() => _EmailFormFieldState();
}

class _EmailFormFieldState extends State<EmailFormField> {
  late final FocusNode _focusNode;
  bool _isFocused = false;

  /// قائمة الاقتراحات المعروضة حالياً.
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
      // إخفاء الاقتراحات عند فقدان الـ focus
      if (!_isFocused) {
        _showSuggestions = false;
      } else {
        // عند الـ focus، نعيد حساب الاقتراحات
        _updateSuggestions(widget.controller.text);
      }
    });
  }

  void _onTextChanged() {
    _updateSuggestions(widget.controller.text);
  }

  /// يحدّث قائمة الاقتراحات بناءً على النص الحالي.
  void _updateSuggestions(String text) {
    if (!_isFocused) return;

    // 3 حالات للاقتراحات:
    // 1. ما يحتوي @ → نعرض mock examples (user@gmail.com, user@dtteeth.com)
    // 2. يحتوي @ بدون domain → نعرض domains كاملة
    // 3. يحتوي @ مع domain partial → نعرض domains اللي تطابق

    final int atIndex = text.indexOf('@');

    List<String> newSuggestions;

    if (text.isEmpty) {
      newSuggestions = [];
    } else if (atIndex == -1) {
      // ما في @ بعد — نعرض اقتراحات بناءً على ما كتبه + @ + domain
      final String prefix = text.trim();
      if (prefix.isEmpty || !_isValidLocalPart(prefix)) {
        newSuggestions = [];
      } else {
        newSuggestions = _commonDomains
            .map((domain) => '$prefix@$domain')
            .toList();
      }
    } else {
      // فيه @ — نقسّم النص
      final String localPart = text.substring(0, atIndex);
      final String domainPart = text.substring(atIndex + 1).toLowerCase();

      if (localPart.isEmpty) {
        newSuggestions = [];
      } else if (domainPart.isEmpty) {
        // المستخدم كتب @ فقط → نعرض كل الـ domains
        newSuggestions = _commonDomains
            .map((domain) => '$localPart@$domain')
            .toList();
      } else {
        // domain partial → فلترة الـ domains اللي تبدأ بـ ما كتبه
        newSuggestions = _commonDomains
            .where((domain) => domain.startsWith(domainPart))
            .map((domain) => '$localPart@$domain')
            .toList();
      }
    }

    setState(() {
      _suggestions = newSuggestions;
      _showSuggestions = newSuggestions.isNotEmpty;
    });
  }

  /// تحقق من أن الـ local part (قبل الـ @) يمكن أن يكون valid.
  bool _isValidLocalPart(String text) {
    if (text.isEmpty) return false;
    return RegExp(r'^[a-zA-Z0-9._%+-]+$').hasMatch(text);
  }

  /// عند اختيار اقتراح من القائمة.
  void _onSuggestionTap(String suggestion) {
    widget.controller.text = suggestion;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );
    widget.onChanged(suggestion);
    setState(() => _showSuggestions = false);
    // نخلي الـ focus بنفس الحقل (المستخدم ممكن يكمّل تعديل)
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
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label ──
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Text(
            widget.label ?? context.l10n.email,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isLight ? AppColors.lightText2 : AppColors.darkText2,
              height: 1.2,
            ),
          ),
        ),

        // ── حقل الإدخال ──
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
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
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 16, end: 12),
                child: Icon(
                  Icons.alternate_email_rounded,
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
                  // ⚠️ Enter key support: callback ينادى دائماً
                  onSubmitted: widget.onSubmitted,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.start,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.go, // ← يبيّن "Go" للـ keyboard
                  autocorrect: false,
                  // إيقاف اقتراحات المتصفح — حنا منعرض اقتراحات domains خاصة فينا.
                  autofillHints: const <String>[],
                  enableSuggestions: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isLight
                        ? AppColors.lightText1
                        : AppColors.darkText1,
                    height: 1.2,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint ?? context.l10n.emailHint,
                    hintStyle: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: isLight
                          ? AppColors.lightText4
                          : AppColors.darkText4,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    isDense: true,
                  ),
                ),
              ),
              // زر مسح النص (يظهر إذا فيه نص)
              if (widget.controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    widget.controller.clear();
                    widget.onChanged('');
                  },
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.only(end: 16, start: 8),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: isLight
                          ? AppColors.lightText3
                          : AppColors.darkText3,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ── Suggestions Panel ──
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _showSuggestions && _suggestions.isNotEmpty
              ? _buildSuggestionsPanel(isLight)
              : const SizedBox(width: double.infinity),
        ),

        // ── رسالة الخطأ ──
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
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
                            height: 1.4,
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

  /// لوحة الاقتراحات.
  Widget _buildSuggestionsPanel(bool isLight) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isLight
              ? AppColors.lightSurface
              : AppColors.darkSurface,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: isLight ? 0.08 : 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                border: Border(
                  bottom: BorderSide(
                    color: isLight
                        ? AppColors.lightBorder
                        : AppColors.darkBorder,
                    width: 0.5,
                  ),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'اقتراحات',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            // suggestions list
            ..._suggestions
                .take(5)
                .map((s) => _buildSuggestionItem(s, isLight)),
          ],
        ),
      ),
    );
  }

  /// عنصر اقتراح واحد.
  Widget _buildSuggestionItem(String suggestion, bool isLight) {
    return _SuggestionTile(
      suggestion: suggestion,
      isLight: isLight,
      onTap: () => _onSuggestionTap(suggestion),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                          SUGGESTION TILE
// ══════════════════════════════════════════════════════════════════════════

class _SuggestionTile extends StatefulWidget {
  const _SuggestionTile({
    required this.suggestion,
    required this.isLight,
    required this.onTap,
  });

  final String suggestion;
  final bool isLight;
  final VoidCallback onTap;

  @override
  State<_SuggestionTile> createState() => _SuggestionTileState();
}

class _SuggestionTileState extends State<_SuggestionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        // مهم: behavior translucent عشان يلتقط النقرة على كامل الـ container
        behavior: HitTestBehavior.translucent,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          color: _isHovered
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          child: Row(
            children: [
              Icon(
                Icons.alternate_email_rounded,
                size: 16,
                color: _isHovered
                    ? AppColors.primary
                    : (widget.isLight
                        ? AppColors.lightText3
                        : AppColors.darkText3),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.suggestion,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _isHovered
                        ? AppColors.primary
                        : (widget.isLight
                            ? AppColors.lightText1
                            : AppColors.darkText1),
                  ),
                ),
              ),
              Icon(
                Icons.north_west_rounded, // arrow indicating "click to fill"
                size: 14,
                color: _isHovered
                    ? AppColors.primary
                    : (widget.isLight
                        ? AppColors.lightText4
                        : AppColors.darkText4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
