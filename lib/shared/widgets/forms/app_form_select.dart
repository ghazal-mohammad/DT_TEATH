// ════════════════════════════════════════════════════════════════════════════
// app_form_select.dart
//
// قائمة منسدلة موحّدة — `.fs`
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — الأسطر 815–820
//
// القواعد الأصلية:
//   .fs { padding:8px 11px; border:1px solid rgba(158,251,236,0.18);
//         border-radius:var(--r8); background:var(--bg2);
//         font-size:15px; color:var(--t1); cursor:pointer; }
//   .fs:focus { border-color:var(--cyan-b) }
//
// نستخدم DropdownButtonFormField من Flutter ونخصّصه ليطابق HTML.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';

/// عنصر واحد في قائمة الـ select.
class AppSelectOption<T> {
  const AppSelectOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// قائمة منسدلة موحّدة مع label.
///
/// مثال:
/// ```dart
/// AppFormSelect<String>(
///   label: 'حالة الطلب',
///   value: currentStatus,
///   options: [
///     AppSelectOption(value: 'pending', label: 'قيد الانتظار'),
///     AppSelectOption(value: 'inProgress', label: 'قيد التنفيذ'),
///     AppSelectOption(value: 'completed', label: 'مكتمل'),
///   ],
///   onChanged: (v) => setState(() => currentStatus = v!),
/// )
/// ```
class AppFormSelect<T> extends StatelessWidget {
  const AppFormSelect({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.hint,
    this.validator,
    this.enabled = true,
    this.required = false,
  });

  final String label;
  final bool required;
  final List<AppSelectOption<T>> options;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final String? Function(T?)? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final Color text1 = isLight ? AppColors.lightText1 : AppColors.darkText1;
    final Color text2 = isLight ? AppColors.lightText2 : AppColors.darkText2;
    final Color text4 = isLight ? AppColors.lightText4 : AppColors.darkText4;
    final Color bg2 = isLight ? AppColors.lightBg2 : AppColors.darkBg2;

    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: text2,
                ),
              ),
              if (required)
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
          const SizedBox(height: 5),
          DropdownButtonFormField<T>(
            initialValue: value,
            onChanged: enabled ? onChanged : null,
            validator: validator,
            isExpanded: true,
            hint: hint != null
                ? Text(
                    hint!,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 15,
                      color: text4,
                    ),
                  )
                : null,
            icon: Icon(Icons.keyboard_arrow_down, color: text2, size: 20),
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 15,
              color: text1,
            ),
            dropdownColor: isLight ? AppColors.lightBg1 : AppColors.darkBg1,
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            items: options.map((opt) {
              return DropdownMenuItem<T>(
                value: opt.value,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (opt.icon != null) ...[
                      Icon(opt.icon, size: 16, color: text2),
                      const SizedBox(width: 8),
                    ],
                    Text(opt.label),
                  ],
                ),
              );
            }).toList(),
            decoration: InputDecoration(
              filled: true,
              fillColor: bg2,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 11, // .fs padding
                vertical: 8,
              ),
              border: _border(const Color(0x2E9EFBEC)), // 0.18
              enabledBorder: _border(const Color(0x2E9EFBEC)),
              focusedBorder: _border(AppColors.accent, width: 2),
              errorBorder: _border(const Color(0xFFEF4444)),
              focusedErrorBorder: _border(
                const Color(0xFFEF4444),
                width: 2,
              ),
              errorStyle: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
