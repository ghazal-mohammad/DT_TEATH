// ════════════════════════════════════════════════════════════════════════════
// technician_schedule_dialog.dart
//
// حوار تحرير جدول دوام الفنّي — يربط طرفَي الباك:
//   • showTechnician/{id}                → يجلب الجدول الحالي عند الفتح.
//   • updateTechnicianWorkSchedule/{id}  → يحفظ الجدول المعدَّل.
//
// لكل يوم (السبت→الجمعة) مفتاح تفعيل + وقت بداية/نهاية. الباك يشترط يوم عمل
// واحد على الأقل ونهاية بعد البداية. مصمَّم بروح المشروع ويحترم الثيمين.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/di/injection_container.dart';
import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/network/failure.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../../../core/domain/work_schedule.dart';
import '../../../domain/repositories/lab_repository.dart';

/// حوار تحرير جدول دوام فنّي. يرجّع true عند حفظ ناجح (لتحديث القائمة).
class TechnicianScheduleDialog extends StatefulWidget {
  const TechnicianScheduleDialog({
    super.key,
    required this.technicianId,
    required this.technicianName,
  });

  final int technicianId;
  final String technicianName;

  static Future<bool?> show(
    BuildContext context, {
    required int id,
    required String name,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) =>
          TechnicianScheduleDialog(technicianId: id, technicianName: name),
    );
  }

  @override
  State<TechnicianScheduleDialog> createState() =>
      _TechnicianScheduleDialogState();
}

class _TechnicianScheduleDialogState extends State<TechnicianScheduleDialog> {
  /// الأيام المُفعّلة فقط تُخزَّن هنا (غياب اليوم = إجازة).
  final Map<WorkDay, WorkShift> _shifts = {};
  bool _loading = true;
  bool _saving = false;
  String? _error;
  String? _validation;

  static const _defaultStart = '09:00';
  static const _defaultEnd = '17:00';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final tech = await sl<LabRepository>().getTechnician(widget.technicianId);
      for (final raw in tech.schedule) {
        final shift = WorkShift.fromRaw(raw);
        if (shift != null) _shifts[shift.day] = shift;
      }
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = userMessageFromError(e);
        });
      }
    }
  }

  void _toggleDay(WorkDay day, bool on) {
    setState(() {
      _validation = null;
      if (on) {
        _shifts[day] =
            WorkShift(day: day, start: _defaultStart, end: _defaultEnd);
      } else {
        _shifts.remove(day);
      }
    });
  }

  Future<void> _pickTime(WorkDay day, {required bool isStart}) async {
    final current = _shifts[day];
    if (current == null) return;
    final initial = _parseTod(isStart ? current.start : current.end);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      // إدخال رقمي مباشرةً (بلا ساعة تناظرية) — أوضح للمستخدم.
      initialEntryMode: TimePickerEntryMode.input,
      builder: (ctx, child) => MediaQuery(
        // عرض 12 ساعة مع صباحي/مسائي (AM/PM). التخزين يبقى 24 ساعة (H:i) عبر
        // _fmt ليطابق الباك — TimeOfDay.hour دائماً 0–23 مهما كان العرض.
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );
    if (picked == null) return;
    final hm = _fmt(picked);
    setState(() {
      _validation = null;
      _shifts[day] = isStart
          ? _shifts[day]!.copyWith(start: hm)
          : _shifts[day]!.copyWith(end: hm);
    });
  }

  Future<void> _save() async {
    // يوم عمل واحد على الأقل (شرط الباك).
    if (_shifts.isEmpty) {
      setState(() => _validation = context.l10n.techScheduleNeedOne);
      return;
    }
    // النهاية بعد البداية لكل يوم مُفعّل.
    for (final s in _shifts.values) {
      if (_mins(s.end) <= _mins(s.start)) {
        setState(() => _validation = context.l10n.techScheduleEndAfterStart);
        return;
      }
    }
    setState(() {
      _saving = true;
      _validation = null;
    });
    // نرسل بترتيب الأسبوع.
    final ordered = WorkDay.values
        .where(_shifts.containsKey)
        .map((d) => _shifts[d]!.toApi())
        .toList();
    try {
      await sl<LabRepository>()
          .updateTechnicianSchedule(widget.technicianId, ordered);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _validation = userMessageFromError(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: isLight ? Colors.white : AppColors.darkSurface,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: size.width > 620 ? 540 : size.width * 0.95,
          maxHeight: size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(isLight),
            Flexible(child: _body(isLight)),
            _footer(isLight),
          ],
        ),
      ),
    );
  }

  // ── Header — لافندر بروح مودالات المخبر ─────────────────────────────────
  Widget _header(bool isLight) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.spaceLG, AppSizes.spaceLG, AppSizes.spaceMD, AppSizes.spaceLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLight
              ? [AppColors.primary, AppColors.brand]
              : [AppColors.darkBg1, AppColors.darkBg2],
        ),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule_rounded, size: 22, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.techScheduleTitle,
                  style: AppTextStyles.headlineSmall
                      .copyWith(color: Colors.white),
                ),
                if (widget.technicianName.isNotEmpty)
                  Text(
                    widget.technicianName,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: Colors.white.withValues(alpha: 0.85)),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.l10n.close,
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _body(bool isLight) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(AppSizes.space3XL),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(AppSizes.space2XL),
        child: Center(
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final day in WorkDay.values) ...[
            _DayRow(
              label: workDayLabel(context.l10n, day),
              shift: _shifts[day],
              isLight: isLight,
              onToggle: (on) => _toggleDay(day, on),
              onPickStart: () => _pickTime(day, isStart: true),
              onPickEnd: () => _pickTime(day, isStart: false),
            ),
            const SizedBox(height: AppSizes.spaceSM),
          ],
          if (_validation != null) ...[
            const SizedBox(height: 4),
            Text(
              _validation!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }

  Widget _footer(bool isLight) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.spaceLG, 0, AppSizes.spaceLG, AppSizes.spaceLG),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AppButton.secondary(
            label: context.l10n.cancel,
            onPressed: () => Navigator.of(context).pop(),
            size: AppButtonSize.small,
          ),
          const SizedBox(width: 10),
          AppButton.primary(
            label: context.l10n.save,
            onPressed: (_loading || _error != null || _saving) ? null : _save,
            isLoading: _saving,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }


  static TimeOfDay _parseTod(String hm) {
    final p = hm.split(':');
    return TimeOfDay(
      hour: int.tryParse(p.isNotEmpty ? p[0] : '') ?? 9,
      minute: int.tryParse(p.length > 1 ? p[1] : '') ?? 0,
    );
  }

  static String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static int _mins(String hm) {
    final p = hm.split(':');
    return (int.tryParse(p.isNotEmpty ? p[0] : '') ?? 0) * 60 +
        (int.tryParse(p.length > 1 ? p[1] : '') ?? 0);
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  DAY ROW — صف يوم واحد: تفعيل + وقتان
// ══════════════════════════════════════════════════════════════════════════

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.label,
    required this.shift,
    required this.isLight,
    required this.onToggle,
    required this.onPickStart,
    required this.onPickEnd,
  });

  final String label;
  final WorkShift? shift;
  final bool isLight;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;

  @override
  Widget build(BuildContext context) {
    final bool on = shift != null;
    final Color accent = isLight ? AppColors.primary : AppColors.brand;
    final Color border = on
        ? accent.withValues(alpha: 0.5)
        : (isLight ? AppColors.lightBorder : AppColors.darkBorder);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceMD, vertical: AppSizes.spaceSM + 2),
      decoration: BoxDecoration(
        color: on
            ? accent.withValues(alpha: 0.06)
            : (isLight ? AppColors.lightBg : AppColors.darkBg2),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: on
                    ? (isLight ? AppColors.lightText1 : AppColors.darkText1)
                    : (isLight ? AppColors.lightText3 : AppColors.darkText3),
              ),
            ),
          ),
          Switch(
            value: on,
            activeThumbColor: accent,
            onChanged: onToggle,
          ),
          const Spacer(),
          if (on) ...[
            _TimeChip(
              time: shift!.start,
              icon: Icons.login_rounded,
              onTap: onPickStart,
              isLight: isLight,
            ),
            const SizedBox(width: 6),
            Text(
              '→',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isLight ? AppColors.lightText3 : AppColors.darkText3,
              ),
            ),
            const SizedBox(width: 6),
            _TimeChip(
              time: shift!.end,
              icon: Icons.logout_rounded,
              onTap: onPickEnd,
              isLight: isLight,
            ),
          ] else
            Text(
              context.l10n.techScheduleDayOff,
              style: AppTextStyles.bodySmall.copyWith(
                color: isLight ? AppColors.lightText4 : AppColors.darkText4,
              ),
            ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.time,
    required this.icon,
    required this.onTap,
    required this.isLight,
  });

  final String time;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final Color accent = isLight ? AppColors.primary : AppColors.brand;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : AppColors.darkBg1,
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            border: Border.all(color: accent.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: accent),
              const SizedBox(width: 5),
              Text(
                time,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
