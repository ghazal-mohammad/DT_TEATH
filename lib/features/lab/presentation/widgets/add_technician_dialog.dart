// ════════════════════════════════════════════════════════════════════════════
// add_technician_dialog.dart
//
// مودال إضافة مخبري جديد — مطابق للصورة المرجعية.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../shared/widgets/forms/app_form_select.dart';
import '../../../../core/theme/app_text_styles.dart';

class TechnicianFormResult {
  TechnicianFormResult({
    required this.name,
    required this.role,
    required this.phone,
    required this.shiftStart,
    required this.shiftEnd,
    required this.skills,
    required this.notes,
  });

  final String name;
  final String role;
  final String phone;
  final String shiftStart;
  final String shiftEnd;
  final List<String> skills;
  final String notes;
}

class AddTechnicianDialog extends StatefulWidget {
  const AddTechnicianDialog({super.key});

  static Future<TechnicianFormResult?> show(BuildContext context) {
    return showDialog<TechnicianFormResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => const AddTechnicianDialog(),
    );
  }

  @override
  State<AddTechnicianDialog> createState() => _AddTechnicianDialogState();
}

class _AddTechnicianDialogState extends State<AddTechnicianDialog> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _role = 'فني تلبيسات';
  String _shiftStart = '08:00 AM';
  String _shiftEnd = '04:00 PM';
  final Set<String> _selectedSkills = {};

  static const _roles = [
    'فني تلبيسات',
    'فني جسور',
    'فنية أكريل',
    'فني زيركون',
    'فني وجوه',
    'فني تركيبات',
  ];
  static const _allSkills = [
    'PFM',
    'Zirconia',
    'E-max',
    'Acrylic',
    'جسور',
    'أطقم',
    'وجوه',
    'تركيبات',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String get _initials {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts.first.characters.firstOrNull ?? '?';
    return '${parts.first.characters.firstOrNull ?? ''}${parts[1].characters.firstOrNull ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final dialogWidth = width > 700 ? 560.0 : width * 0.95;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth, maxHeight: 720),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _previewCard(),
                      const SizedBox(height: 18),
                      _sectionLabel(context.l10n.techSectionBasic),
                      const SizedBox(height: 10),
                      _fieldLabel(context.l10n.techFieldFullName),
                      const SizedBox(height: 6),
                      _textField(_nameCtrl,
                          hint: context.l10n.techFieldFullNameHint),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _fieldLabel(context.l10n.techFieldRole),
                                const SizedBox(height: 6),
                                _roleDropdown(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _fieldLabel(context.l10n.techFieldPhone),
                                const SizedBox(height: 6),
                                _textField(_phoneCtrl, hint: '09xxxxxxxx'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _fieldLabel(context.l10n.techFieldShiftStart),
                                const SizedBox(height: 6),
                                _timeBox(_shiftStart, () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: const TimeOfDay(hour: 8, minute: 0),
                                  );
                                  if (time != null) {
                                    setState(() => _shiftStart = time.format(context));
                                  }
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _fieldLabel(context.l10n.techFieldShiftEnd),
                                const SizedBox(height: 6),
                                _timeBox(_shiftEnd, () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: const TimeOfDay(hour: 16, minute: 0),
                                  );
                                  if (time != null) {
                                    setState(() => _shiftEnd = time.format(context));
                                  }
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _sectionLabel(context.l10n.techSkills),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final s in _allSkills) _skillChip(s),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _sectionLabel(context.l10n.invFormNotes),
                      const SizedBox(height: 10),
                      _textField(
                        _notesCtrl,
                        hint: context.l10n.techNotesHint,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
                child: Row(
                  children: [
                    _PrimaryBtn(
                      label: context.l10n.techAddButton,
                      icon: Icons.check_rounded,
                      onTap: () {
                        Navigator.of(context).pop(TechnicianFormResult(
                          name: _nameCtrl.text.trim(),
                          role: _role,
                          phone: _phoneCtrl.text.trim(),
                          shiftStart: _shiftStart,
                          shiftEnd: _shiftEnd,
                          skills: _selectedSkills.toList(),
                          notes: _notesCtrl.text.trim(),
                        ));
                      },
                    ),
                    const SizedBox(width: 10),
                    _OutlineBtn(
                      label: context.l10n.cancel,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECFB),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(22, 16, 16, 16),
      child: Row(
        children: [
          // العنوان أولاً → يظهر على اليمين بـ RTL
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.techAddTitle,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                context.l10n.techAddSubtitle,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightText3,
                ),
              ),
            ],
          ),
          const Spacer(),
          // زر الإغلاق آخر → يظهر على اليسار بـ RTL
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.close_rounded, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewCard() {
    final hasName = _nameCtrl.text.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              _initials,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          // RTL: start = يمين. النص العربي يحاذي يمين العمود.
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasName ? _nameCtrl.text.trim() : context.l10n.techNoNameYet,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightText1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _role,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightText3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        const Spacer(),
        Text(
          text,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.lightText1,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.lightText2,
        ),
      ),
    );
  }

  Widget _textField(TextEditingController c, {String? hint, int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      style: TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 13,
        color: AppColors.lightText1,
      ),
      onChanged: (_) => setState(() {}), // refresh preview
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 13,
          color: AppColors.lightText4,
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _roleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: AppDropdownMenuTheme(
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _role,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              color: AppColors.lightText1,
            ),
            items: [
              for (final r in _roles)
                DropdownMenuItem(value: r, child: Text(r)),
            ],
            onChanged: (v) => setState(() => _role = v ?? _role),
          ),
        ),
      ),
    );
  }

  Widget _timeBox(String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.lightText1,
              ),
            ),
            const Spacer(),
            Icon(Icons.access_time_rounded,
                size: 16, color: AppColors.lightText3),
          ],
        ),
      ),
    );
  }

  Widget _skillChip(String skill) {
    final selected = _selectedSkills.contains(skill);
    return GestureDetector(
      onTap: () => setState(() {
        if (selected) {
          _selectedSkills.remove(skill);
        } else {
          _selectedSkills.add(skill);
        }
      }),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.lightBorder,
            ),
          ),
          child: Text(
            skill,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.lightText2,
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  const _PrimaryBtn({required this.label, required this.onTap, this.icon});
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: Colors.white),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  const _OutlineBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.lightBorder),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.lightText1,
            ),
          ),
        ),
      ),
    );
  }
}
