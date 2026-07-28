// ════════════════════════════════════════════════════════════════════════════
// employee_profile_main_column.dart
//
// العمود الرئيسي + العلاقات + المهارات — part of employee_profile_content.dart (تقسيم الصفحات العملاقة).
// ════════════════════════════════════════════════════════════════════════════

part of 'employee_profile_content.dart';

// ══════════════════════════════════════════════════════════════════════════
//                          العمود الرئيسي
// ══════════════════════════════════════════════════════════════════════════

class _MainColumn extends StatelessWidget {
  const _MainColumn({
    required this.data,
    required this.editing,
    this.loading = false,
  });

  final _EmployeeData data;
  final bool editing;

  /// هل ما زال طلب showProfile قيد التحميل؟ (تظهر shimmer placeholders
  /// مكان أقسام الباك بدل ما تنطّ فجأة لاحقاً).
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StatsRow(),
        const SizedBox(height: 18),
        _InfoSection(
          icon: Icons.person_outline_rounded,
          title: context.l10n.profilePersonalInfo,
          subtitle: context.l10n.profilePersonalInfoSubtitle,
          editing: editing,
          fields: [
            _RowSpec(
              icon: Icons.phone_outlined,
              label: context.l10n.profilePhone,
              value: data.phone,
              onChanged: (v) => data.phone = v,
            ),
            _RowSpec(
              icon: Icons.phone_in_talk_outlined,
              label: context.l10n.profileSecondaryPhone,
              value: data.secondaryPhone,
              onChanged: (v) => data.secondaryPhone = v,
            ),
            // الجنس وتاريخ الميلاد بيانات ثابتة — تُعرض ولا يعدّلها الموظف.
            _RowSpec(
              icon: Icons.wc_outlined,
              label: context.l10n.profileGender,
              value: data.gender,
              onChanged: (v) => data.gender = v,
              editable: false,
            ),
            if (data.birthDate.trim().isNotEmpty)
              _RowSpec(
                icon: Icons.calendar_month_outlined,
                label: context.l10n.profileBirthDate,
                value: data.birthDate,
                onChanged: (v) => data.birthDate = v,
                editable: false,
              ),
            _RowSpec(
              icon: Icons.favorite_outline_rounded,
              label: context.l10n.profileMaritalStatus,
              value: data.maritalStatus,
              onChanged: (v) => data.maritalStatus = v,
              options: const ['أعزب', 'متزوج', 'مطلّق', 'أرمل'],
            ),
          ],
        ),
        // ── جدول الدوام الحقيقي من الباك (schedule[]) ────────────────────
        if (data.workSchedule.isNotEmpty) ...[
          const SizedBox(height: 18),
          _RelationSection(
            icon: Icons.schedule_outlined,
            title: context.l10n.profileWorkSchedule,
            items: [
              for (final s in ([...data.workSchedule]
                ..sort((a, b) => a.day.index.compareTo(b.day.index))))
                _RelationItem(
                  primary: workDayLabel(context.l10n, s.day),
                  secondary: '',
                  trailing: '${s.start} — ${s.end}',
                ),
            ],
          ),
        ],
        // ── أقسام حقيقية من الباك (showProfile) ──────────────────────────
        // أثناء التحميل: shimmer placeholders مكان الأقسام القادمة من الباك
        // (الشهادات/الخبرات/الدورات/المهارات) بدل ما تظهر فجأة بعد الرد.
        if (loading) ...[
          const SizedBox(height: 18),
          const AppShimmerCard(height: 140),
          const SizedBox(height: 18),
          const AppShimmerCard(height: 140),
          const SizedBox(height: 18),
          const AppShimmerCard(height: 100),
        ],
        if (data.educations.isNotEmpty) ...[
          const SizedBox(height: 18),
          _RelationSection(
            icon: Icons.school_outlined,
            title: context.l10n.profileEducations,
            items: [
              for (final e in data.educations)
                _RelationItem(
                  primary: e.degree,
                  secondary: e.institution,
                  trailing: [
                    AppDate.display(e.completionDate, fallback: ''),
                    e.grade,
                  ].where((x) => x.isNotEmpty).join(' · '),
                ),
            ],
          ),
        ],
        if (data.experiences.isNotEmpty) ...[
          const SizedBox(height: 18),
          _RelationSection(
            icon: Icons.work_history_outlined,
            title: context.l10n.profileExperiences,
            items: [
              for (final x in data.experiences)
                _RelationItem(
                  primary: x.title,
                  secondary: x.company,
                  trailing:
                      '${AppDate.display(x.startDate, fallback: '?')} — ${AppDate.display(x.endDate, fallback: context.l10n.profileOngoing)}',
                ),
            ],
          ),
        ],
        if (data.trainings.isNotEmpty) ...[
          const SizedBox(height: 18),
          _RelationSection(
            icon: Icons.military_tech_outlined,
            title: context.l10n.profileTrainings,
            items: [
              for (final t in data.trainings)
                _RelationItem(
                  primary: t.courseTitle,
                  secondary: t.trainer,
                  trailing: AppDate.display(t.courseDate, fallback: ''),
                ),
            ],
          ),
        ],
        if (data.skills.isNotEmpty) ...[
          const SizedBox(height: 18),
          _SkillsSection(skills: data.skills),
        ],
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                  أقسام علائقية (شهادات/خبرات/تدريبات/مهارات)
// ══════════════════════════════════════════════════════════════════════════

/// بناء رابط صورة البروفايل الكامل من قيمة الباك.
/// الباك يرجّع مساراً نسبياً مثل "profile_pictures/xxx.jpg" (يُخدَم عبر
/// /storage/ بعد storage:link)، أو URL كاملاً مبنياً بـ asset().
String _resolvePictureUrl(String raw) {
  final v = raw.trim().replaceAll(r'\', '/');
  if (v.isEmpty) return '';
  if (v.startsWith('http://') || v.startsWith('https://')) {
    // الباك يبني الرابط بـ asset() مع APP_URL=http://localhost (بدون :8000)
    // فيشاور Apache بدل Laravel → 404. نعيد كتابة المضيف على baseUrl الصحيح
    // مع الإبقاء على المسار كما هو.
    final uri = Uri.tryParse(v);
    if (uri == null) return v;
    final bool wrongLocalHost =
        (uri.host == 'localhost' || uri.host == '127.0.0.1') &&
            !v.startsWith(AppUrls.baseUrl);
    if (!wrongLocalHost) return v;
    final base = Uri.parse(AppUrls.baseUrl);
    return uri
        .replace(scheme: base.scheme, host: base.host, port: base.port)
        .toString();
  }
  final path = v.startsWith('/') ? v.substring(1) : v;
  return '${AppUrls.baseUrl}/storage/$path';
}

/// تنسيق الراتب: "1800000.00" → "1,800,000 ل.س".
String _formatSalary(String raw) {
  var s = raw.trim();
  final dot = s.indexOf('.');
  if (dot != -1) s = s.substring(0, dot);
  final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return raw;
  final buf = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return '$buf ل.س';
}

/// تحويل الحالة الاجتماعية من رمز الباك (إنجليزي) لعربي للعرض.
String _maritalToAr(String en) {
  switch (en.trim().toLowerCase()) {
    case 'single':
      return 'أعزب';
    case 'married':
      return 'متزوج';
    case 'divorced':
      return 'مطلّق';
    case 'widowed':
      return 'أرمل';
    default:
      return en;
  }
}

/// عكس [_maritalToAr]: من العربي لرمز الباك (للإرسال).
String? _maritalToApi(String ar) {
  switch (ar.trim()) {
    case 'أعزب':
      return 'single';
    case 'متزوج':
      return 'married';
    case 'مطلّق':
      return 'divorced';
    case 'أرمل':
      return 'widowed';
    default:
      return null;
  }
}

class _RelationItem {
  const _RelationItem({
    required this.primary,
    required this.secondary,
    required this.trailing,
  });
  final String primary;
  final String secondary;
  final String trailing;
}

class _RelationSection extends StatelessWidget {
  const _RelationSection({
    required this.icon,
    required this.title,
    required this.items,
  });

  final IconData icon;
  final String title;
  final List<_RelationItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: _Palette.of(context).cardBorder),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _Palette.of(context).blueIconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 19, color: _Palette.of(context).blueAccent),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightText1,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _Palette.of(context).blueIconBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${items.length}',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _Palette.of(context).blueAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _RelationRow(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _RelationRow extends StatelessWidget {
  const _RelationRow({required this.item});
  final _RelationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.profileSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: _Palette.of(context).cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: _Palette.of(context).blueAccent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.primary,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.lightText1,
                  ),
                ),
                if (item.secondary.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.secondary,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _Palette.of(context).label,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (item.trailing.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              item.trailing,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _Palette.of(context).blueAccent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SkillsSection extends StatelessWidget {
  const _SkillsSection({required this.skills});
  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: _Palette.of(context).cardBorder),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _Palette.of(context).pinkBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.auto_awesome_outlined,
                    size: 19, color: _Palette.of(context).pinkAccent),
              ),
              const SizedBox(width: 10),
              Text(
                context.l10n.profileSkills,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightText1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in skills)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: _Palette.of(context).pinkBg,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    border: Border.all(
                        color: _Palette.of(context).pinkAccent.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    s,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _Palette.of(context).pinkAccent,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

