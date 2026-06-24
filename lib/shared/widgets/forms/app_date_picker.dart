// ════════════════════════════════════════════════════════════════════════════
// app_date_picker.dart
//
// منتقي تاريخ مخصّص — بديل لـ Material's showDatePicker للحصول على:
//   • رأس بمحاذاة وسط (التاريخ كأرقام كبيرة + الشهر/السنة تحت)
//   • زر قلم للانتقال لإدخال نصي (DD/MM/YYYY)
//   • ألوان وخطوط مطابقة لهوية المشروع
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';

const _arMonths = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];

const _arWeekdayShort = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];

const _arWeekdayLong = [
  'الأحد', 'الإثنين', 'الثلاثاء',
  'الأربعاء', 'الخميس', 'الجمعة', 'السبت',
];

/// يعرض date picker مخصّص ويُرجع التاريخ المختار أو null.
Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String helpText = 'اختر التاريخ',
}) {
  return showDialog<DateTime>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => _AppDatePickerDialog(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: helpText,
    ),
  );
}

class _AppDatePickerDialog extends StatefulWidget {
  const _AppDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.helpText,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String helpText;

  @override
  State<_AppDatePickerDialog> createState() => _AppDatePickerDialogState();
}

class _AppDatePickerDialogState extends State<_AppDatePickerDialog> {
  late DateTime _selected;
  late DateTime _displayMonth;
  bool _textMode = false;
  late final TextEditingController _textCtrl;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
    _displayMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _textCtrl = TextEditingController(
      text:
          '${_selected.day.toString().padLeft(2, '0')}/${_selected.month.toString().padLeft(2, '0')}/${_selected.year}',
    );
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _prevMonth() {
    final prev = DateTime(_displayMonth.year, _displayMonth.month - 1);
    if (prev.isBefore(DateTime(widget.firstDate.year, widget.firstDate.month))) {
      return;
    }
    setState(() => _displayMonth = prev);
  }

  void _nextMonth() {
    final next = DateTime(_displayMonth.year, _displayMonth.month + 1);
    if (next.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month))) {
      return;
    }
    setState(() => _displayMonth = next);
  }

  void _selectDay(int day) {
    final d = DateTime(_displayMonth.year, _displayMonth.month, day);
    if (d.isBefore(widget.firstDate) || d.isAfter(widget.lastDate)) return;
    setState(() => _selected = d);
  }

  void _applyTextAndClose() {
    if (_textMode) {
      final parsed = _parseInput(_textCtrl.text);
      if (parsed == null) return;
      if (parsed.isBefore(widget.firstDate) ||
          parsed.isAfter(widget.lastDate)) {
        return;
      }
      Navigator.of(context).pop(parsed);
    } else {
      Navigator.of(context).pop(_selected);
    }
  }

  DateTime? _parseInput(String s) {
    final parts = s.split(RegExp(r'[/\-\.]'));
    if (parts.length != 3) return null;
    final d = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final y = int.tryParse(parts[2]);
    if (d == null || m == null || y == null) return null;
    if (m < 1 || m > 12) return null;
    if (d < 1 || d > 31) return null;
    try {
      final dt = DateTime(y, m, d);
      if (dt.month != m) return null; // مثلاً 31 فبراير
      return dt;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 40,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _textMode ? _buildTextInput() : _buildCalendar(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header (الجزء الكحلي) ──────────────────────────────────────────────
  Widget _buildHeader() {
    final weekday = _arWeekdayLong[_selected.weekday % 7];
    final monthName = _arMonths[_selected.month - 1];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, Color(0xFF2A2D6E)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Column(
        children: [
          // العنوان + زر القلم
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.helpText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              _IconBtn(
                icon: _textMode
                    ? Icons.calendar_today_rounded
                    : Icons.edit_outlined,
                onTap: () => setState(() => _textMode = !_textMode),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // اسم اليوم
          Text(
            weekday,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          // رقم اليوم — كبير
          Text(
            _selected.day.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 56,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          // الشهر / السنة
          Text(
            '$monthName · ${_selected.year}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── الـ Calendar ─────────────────────────────────────────────────────
  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        children: [
          _buildMonthNav(),
          const SizedBox(height: 8),
          _buildWeekdayLabels(),
          const SizedBox(height: 4),
          _buildDaysGrid(),
        ],
      ),
    );
  }

  Widget _buildMonthNav() {
    final monthName = _arMonths[_displayMonth.month - 1];
    return Row(
      children: [
        _NavBtn(icon: Icons.chevron_right, onTap: _prevMonth),
        Expanded(
          child: Text(
            '$monthName ${_displayMonth.year}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.lightText1,
            ),
          ),
        ),
        _NavBtn(icon: Icons.chevron_left, onTap: _nextMonth),
      ],
    );
  }

  Widget _buildWeekdayLabels() {
    return Row(
      children: List.generate(7, (i) {
        return Expanded(
          child: Center(
            child: Text(
              _arWeekdayShort[i],
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.lightText3,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDaysGrid() {
    final firstOfMonth = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final daysInMonth =
        DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    // weekday: 1=Mon..7=Sun. نريد بداية الأسبوع = الأحد (= 7 → 0).
    final startOffset = firstOfMonth.weekday % 7;
    final totalCells = ((startOffset + daysInMonth) / 7).ceil() * 7;

    return Column(
      children: List.generate((totalCells / 7).ceil(), (row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: List.generate(7, (col) {
              final idx = row * 7 + col;
              final dayNum = idx - startOffset + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox(height: 36));
              }
              return Expanded(child: _buildDayCell(dayNum));
            }),
          ),
        );
      }),
    );
  }

  Widget _buildDayCell(int day) {
    final cellDate = DateTime(_displayMonth.year, _displayMonth.month, day);
    final isSelected = _selected.year == cellDate.year &&
        _selected.month == cellDate.month &&
        _selected.day == cellDate.day;
    final today = DateTime.now();
    final isToday = today.year == cellDate.year &&
        today.month == cellDate.month &&
        today.day == cellDate.day;
    final isDisabled =
        cellDate.isBefore(widget.firstDate) || cellDate.isAfter(widget.lastDate);

    final bg = isSelected
        ? AppColors.primary
        : isToday
            ? AppColors.tableHeader
            : Colors.transparent;
    final fg = isSelected
        ? Colors.white
        : isDisabled
            ? AppColors.lightText4.withValues(alpha: 0.5)
            : AppColors.lightText1;

    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: isDisabled ? null : () => _selectDay(day),
      child: Container(
        height: 36,
        alignment: Alignment.center,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
        ),
        child: Text(
          day.toString(),
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14,
            fontWeight: isSelected || isToday
                ? FontWeight.w800
                : FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }

  // ── الإدخال النصي ────────────────────────────────────────────────────
  Widget _buildTextInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'أدخل التاريخ',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.lightText2,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _textCtrl,
            keyboardType: TextInputType.datetime,
            textDirection: TextDirection.ltr,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d/\-\.]')),
              LengthLimitingTextInputFormatter(10),
            ],
            onChanged: (v) {
              final parsed = _parseInput(v);
              if (parsed != null &&
                  !parsed.isBefore(widget.firstDate) &&
                  !parsed.isAfter(widget.lastDate)) {
                setState(() {
                  _selected = parsed;
                  _displayMonth = DateTime(parsed.year, parsed.month);
                });
              }
            },
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.lightText1,
            ),
            decoration: InputDecoration(
              hintText: 'يوم/شهر/سنة',
              hintStyle: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                color: AppColors.lightText4,
              ),
              filled: true,
              fillColor: const Color(0xFFF8F9FC),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                borderSide: const BorderSide(color: AppColors.lightBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                borderSide: const BorderSide(color: AppColors.lightBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.6),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'الصيغة: DD/MM/YYYY  (مثال: 16/06/2026)',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11,
              color: AppColors.lightText3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Footer ───────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.lightBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontWeight: FontWeight.w700,
                color: AppColors.lightText3,
              ),
            ),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: _applyTextAndClose,
            child: const Text(
              'تأكيد',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── أزرار صغيرة مساعدة ─────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.tableHeader.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}
