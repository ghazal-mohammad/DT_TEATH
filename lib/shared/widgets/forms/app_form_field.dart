// ════════════════════════════════════════════════════════════════════════════
// app_form_field.dart
//
// حقل إدخال نصّي موحّد — `.fg` + `.fl` + `.fi`
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — الأسطر 805–814
//
// القواعد الأصلية:
//   .fg { display:flex; flex-direction:column; gap:5px; margin-bottom:11px }
//   .fl { font-size:13.5px; font-weight:700; color:var(--t2) }
//   .fi { padding:11px 14px; border:1px solid rgba(158,251,236,0.18);
//         border-radius:var(--r8); background:rgba(158,251,236,0.06);
//         font-size:15px; color:var(--t1); transition:all 0.2s; }
//   .fi:focus { border-color:var(--cyan-b);
//               background:rgba(158,251,236,0.10);
//               box-shadow:0 0 0 3px rgba(158,251,236,0.10); }
//   .fi::placeholder { color:var(--t4) }
//
// مزايا إضافية:
//   - دعم validation errors (إطار أحمر + رسالة خطأ أسفل الحقل)
//   - دعم أيقونة prefix/suffix
//   - دعم obscureText لكلمة المرور
//   - دعم RTL تلقائياً (اللغة العربية)
//   - دعم min/max lines للـ textarea
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';

/// حقل إدخال نصّي موحّد مع label وسلوك validation.
///
/// يغلّف TextFormField الأصلي بستايل النظام ويضيف طبقة من الأمان:
/// - margin-bottom ثابت بين الحقول
/// - label دائماً فوق الحقل (لا floating label — مطابق لـ HTML)
/// - رسالة الخطأ أسفل الحقل
///
/// مثال:
/// ```dart
/// AppFormField(
///   label: 'اسم المادة',
///   hint: 'مثال: قفازات طبية',
///   controller: nameController,
///   validator: Validators.required,
/// )
/// ```
class AppFormField extends StatefulWidget {
  const AppFormField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
    this.required = false,
  });

  /// نص الـ label فوق الحقل (إلزامي).
  final String label;

  /// إن كان الحقل إلزامياً — يعرض نجمة حمراء بعد الـ label.
  final bool required;

  final TextEditingController? controller;
  final String? hint;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autofocus;

  @override
  State<AppFormField> createState() => _AppFormFieldState();
}

class _AppFormFieldState extends State<AppFormField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final Color text1 = isLight ? AppColors.lightText1 : AppColors.darkText1;
    final Color text2 = isLight ? AppColors.lightText2 : AppColors.darkText2;
    final Color text4 = isLight ? AppColors.lightText4 : AppColors.darkText4;

    return Padding(
      // .fg margin-bottom:11px
      padding: const EdgeInsets.only(bottom: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLabel(text2),
          const SizedBox(height: 5), // .fg gap:5px
          _buildInput(context, text1, text4, isLight),
        ],
      ),
    );
  }

  Widget _buildLabel(Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.2,
            ),
          ),
          if (widget.required)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Text(
                '*',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInput(
    BuildContext context,
    Color text1,
    Color text4,
    bool isLight,
  ) {
    // التصميم مطابق تماماً لـ .fi مع تحويل حالات focus/error
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: widget.obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      onTap: widget.onTap,
      textInputAction: widget.textInputAction,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      style: TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 15, // .fi font-size:15px
        color: text1,
        height: 1.3,
      ),
      textDirection: _detectDirection(),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 15,
          color: text4,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: _isFocused
            ? const Color(0x1A9EFBEC) // 0.10 on focus
            : const Color(0x0F9EFBEC), // 0.06 default
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        // padding:11px 14px من CSS
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
        border: _outlineBorder(const Color(0x2E9EFBEC)), // 0.18
        enabledBorder: _outlineBorder(const Color(0x2E9EFBEC)),
        focusedBorder: _outlineBorder(AppColors.accent, width: 2),
        errorBorder: _outlineBorder(const Color(0xFFEF4444)),
        focusedErrorBorder: _outlineBorder(const Color(0xFFEF4444), width: 2),
        disabledBorder: _outlineBorder(
          (isLight ? AppColors.lightBorder : AppColors.darkBorder).withValues(
            alpha: 0.5,
          ),
        ),
        errorStyle: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFFEF4444),
        ),
        counterText: widget.maxLength != null ? null : '',
      ),
    );
  }

  OutlineInputBorder _outlineBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusSM), // r8
      borderSide: BorderSide(color: color, width: width),
    );
  }

  /// اكتشاف اتجاه النص تلقائياً (للبريد/الأرقام → LTR، للعربية → RTL).
  TextDirection? _detectDirection() {
    final String? text = widget.controller?.text;
    if (text == null || text.isEmpty) return null;
    // حرف لاتيني/رقم → LTR
    final firstChar = text.runes.first;
    if ((firstChar >= 0x0041 && firstChar <= 0x007A) ||
        (firstChar >= 0x0030 && firstChar <= 0x0039)) {
      return TextDirection.ltr;
    }
    return null; // يتبع الـ locale
  }
}
