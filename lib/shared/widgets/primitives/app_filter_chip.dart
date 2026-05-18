// ════════════════════════════════════════════════════════════════════════════
// app_filter_chip.dart
//
// شريحة تصفية موحّدة (Filter Chip) — `.fc`, `.fc.on`
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — الأسطر 791–803
//
// القواعد الأصلية:
//   .fc { padding:6px 14px; border-radius:50px; font-size:13.5px;
//         font-weight:600; border:1px solid var(--cyan-brd);
//         background:rgba(255,255,255,0.02); cursor:pointer;
//         transition:all 0.18s; color:var(--t3); }
//   .fc.on { background:rgba(158,251,236,0.18);
//           border-color:rgba(158,251,236,0.40); color:var(--cyan-b); }
//   .fc:hover:not(.on) { border-color:var(--cyan-b); color:var(--t1); }
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/theme/app_colors.dart';

/// شريحة تصفية (filter chip) قابلة للتبديل.
///
/// تُستخدم في الصفحات التي تحتوي على تصفيات سريعة:
/// - شاشة طلبات المخبر: "الكل | قيد التنفيذ | مكتمل | مؤجّل"
/// - شاشة المستودع: "الكل | منتهي | ينفذ | صالح"
///
/// مثال:
/// ```dart
/// AppFilterChipRow(
///   options: ['الكل', 'قيد التنفيذ', 'مكتمل'],
///   selectedIndex: _selected,
///   onChanged: (i) => setState(() => _selected = i),
/// )
/// ```
class AppFilterChip extends StatefulWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<AppFilterChip> createState() => _AppFilterChipState();
}

class _AppFilterChipState extends State<AppFilterChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    // تحديد الألوان وفق الحالة:
    final Color backgroundColor;
    final Color borderColor;
    final Color textColor;

    if (widget.isSelected) {
      // .fc.on: rgba(158,251,236,0.18) bg, rgba(158,251,236,0.40) border, cyan-b
      backgroundColor = const Color(0x2E9EFBEC); // 0.18
      borderColor = const Color(0x669EFBEC); // 0.40
      textColor = isLight ? const Color(0xFF1A1C4E) : AppColors.accent;
    } else if (_isHovered) {
      // :hover:not(.on): border:cyan-b, color:t1
      backgroundColor = isLight
          ? const Color(0x051A1C4E)
          : const Color(0x05FFFFFF);
      borderColor = AppColors.accent;
      textColor = isLight ? AppColors.lightText1 : AppColors.darkText1;
    } else {
      // .fc: rgba(255,255,255,0.02), cyan-brd, t3
      backgroundColor = isLight
          ? const Color(0x051A1C4E)
          : const Color(0x05FFFFFF);
      borderColor = isLight ? AppColors.lightBorder : AppColors.darkBorder;
      textColor = isLight ? AppColors.lightText3 : AppColors.darkText3;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180), // transition 0.18s
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(50), // 50px = pill
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13.5,
              fontWeight: FontWeight.w600, // 600
              color: textColor,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// صف أفقي من شرائح التصفية — `.fc-row` في HTML.
///
/// يضمن التباعد الصحيح بين الشرائح (4px) مع دعم الـ wrapping.
class AppFilterChipRow extends StatelessWidget {
  const AppFilterChipRow({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4, // CSS: gap:4px
      runSpacing: 4,
      children: List.generate(options.length, (i) {
        return AppFilterChip(
          label: options[i],
          isSelected: i == selectedIndex,
          onTap: () => onChanged(i),
        );
      }),
    );
  }
}
