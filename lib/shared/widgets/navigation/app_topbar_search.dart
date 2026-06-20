// ════════════════════════════════════════════════════════════════════════════
// app_topbar_search.dart
//
// حقل البحث في التوب بار — مطابق لـ CSS class `.tb-srch`.
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — الأسطر 619–626
//
// القواعد الأصلية:
//   .tb-srch {
//     display:flex; align-items:center; gap:6px;
//     background:rgba(158,251,236,0.07); border:1px solid var(--cyan-brd);
//     border-radius:50px; padding:5px 11px;
//     width:240px; transition:all 0.25s;
//   }
//   .tb-srch:focus-within {
//     border-color:var(--cyan-b);
//     background:rgba(158,251,236,0.12);
//     box-shadow:0 0 0 3px rgba(158,251,236,0.08);
//   }
//   .tb-srch input {
//     flex:1; border:none; background:transparent;
//     font-size:14px; color:var(--t1); text-align:right;
//   }
//   .tb-srch input::placeholder { color:var(--t4) }
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/l10n/build_context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_sizes.dart';

/// حقل بحث في التوب بار مع أيقونة وتأثيرات focus.
///
/// يتمدد على عرض ثابت (240px) ويصبح دائري الحواف (radius:50px).
/// عند الـ focus، تتضيء الحواف ويظهر glow خفيف.
///
/// يدعم RTL تلقائياً — text-align حسب اتجاه النص.
///
/// مثال:
/// ```dart
/// AppTopbarSearch(
///   onChanged: (query) => bloc.search(query),
///   placeholder: 'بحث في النظام...',
/// )
/// ```
class AppTopbarSearch extends StatefulWidget {
  const AppTopbarSearch({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.placeholder,
    this.width = AppSizes.topbarSearchWidth,
  });

  /// TextEditingController اختياري — لو ما تم تمريره، يُنشأ داخلياً.
  final TextEditingController? controller;

  /// callback لما النص يتغيّر.
  final ValueChanged<String>? onChanged;

  /// callback لما المستخدم يضغط Enter.
  final ValueChanged<String>? onSubmitted;

  /// نص الـ placeholder (null → يُحلّ عبر context.l10n.search).
  final String? placeholder;

  /// عرض الحقل — افتراضياً 240px (من CSS).
  final double width;

  @override
  State<AppTopbarSearch> createState() => _AppTopbarSearchState();
}

class _AppTopbarSearchState extends State<AppTopbarSearch> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isFocused = false;
  bool _ownController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownController = true;
    }
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    if (_ownController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    // ── الألوان: خلفية رمادية ناعمة + تركيز كحلي/إندِغو (صفر تركواز) ──────
    // لون التركيز = primary بالفاتح، brand بالغامق.
    final Color focusAccent = isLight ? AppColors.primary : AppColors.brand;

    final Color bgColor = isLight
        ? (_isFocused ? Colors.white : AppColors.lightBg1)
        : (_isFocused ? AppColors.darkBg1 : AppColors.darkBg2);

    final Color borderColor = _isFocused
        ? focusAccent
        : (isLight ? AppColors.lightBorder : AppColors.darkBorder);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250), // 0.25s من CSS
      curve: Curves.easeOut,
      width: widget.width,
      height: AppSizes.topbarSearchHeight,
      // من CSS: padding:5px 11px
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(50), // border-radius:50px
        boxShadow: _isFocused
            ? [
                // glow خفيف بلون التركيز (كحلي/إندِغو) بدل التركواز
                BoxShadow(
                  color: focusAccent.withValues(alpha: 0.12),
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.search,
            size: AppSizes.iconSM,
            color: _isFocused
                ? focusAccent
                : (isLight ? AppColors.lightText3 : AppColors.darkText3),
          ),
          const SizedBox(width: 6), // gap:6px
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              // text-align:right في CSS — في RTL = start = right بصرياً
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14, // من CSS
                fontWeight: FontWeight.w500,
                height: 1.2,
                color: isLight ? AppColors.lightText1 : AppColors.darkText1,
              ),
              decoration: InputDecoration(
                hintText: widget.placeholder ?? context.l10n.search,
                hintStyle: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isLight ? AppColors.lightText4 : AppColors.darkText4,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                filled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
