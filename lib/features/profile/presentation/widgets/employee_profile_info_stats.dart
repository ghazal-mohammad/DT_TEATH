// ════════════════════════════════════════════════════════════════════════════
// employee_profile_info_stats.dart
//
// بطاقات الإحصاء + أقسام المعلومات + الحقول — part of employee_profile_content.dart (تقسيم الصفحات العملاقة).
// ════════════════════════════════════════════════════════════════════════════

part of 'employee_profile_content.dart';

// ══════════════════════════════════════════════════════════════════════════
//                          بطاقات الإحصاء
// ══════════════════════════════════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    // قرار الفريق 2026-06-12: لا ساعات ولا "وقت تنفيذ" بملف المدير —
    // المقاييس الزمنية تُستبدل بعدادات طلبات (مثل الواجهة الرئيسية).
    // الترتيب في RTL: أول عنصر = أقصى اليمين.
    final stats = [
      _StatSpec(
        value: '142',
        unit: '',
        label: context.l10n.profileStatCompletedOrders,
        badge: context.l10n.profileBadgeThisMonth,
        icon: Icons.check_circle_outline_rounded,
        accent: AppColors.profileGreenAccent,
        bg: AppColors.statusSuccessBg,
      ),
      _StatSpec(
        value: '5',
        unit: '',
        label: context.l10n.labHeroStatInProgress,
        badge: context.l10n.labChipActive,
        icon: Icons.adjust_rounded,
        accent: AppColors.statusProgress,
        bg: AppColors.profileTintViolet2,
      ),
      _StatSpec(
        value: '7',
        unit: '',
        label: context.l10n.labStatReadyOrders,
        badge: context.l10n.profileBadgeThisMonth,
        icon: Icons.inventory_2_outlined,
        accent: AppColors.profileBlueAccent,
        bg: AppColors.profileTintBlue2,
      ),
    ];

    return LayoutBuilder(builder: (context, c) {
      final isNarrow = c.maxWidth < 560;
      if (isNarrow) {
        return Column(
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              _StatCard(spec: stats[i]),
              if (i < stats.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      }
      // IntrinsicHeight يمنح الصفّ ارتفاعاً محدوداً → stretch آمن لتساوي
      // ارتفاع البطاقات (بدون IntrinsicHeight يصبح القيد عمودياً غير محدود
      // داخل سكرول عمودي فيُرمى خطأ "infinite height").
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              Expanded(child: _StatCard(spec: stats[i])),
              if (i < stats.length - 1) const SizedBox(width: 14),
            ],
          ],
        ),
      );
    });
  }
}

class _StatSpec {
  const _StatSpec({
    required this.value,
    required this.unit,
    required this.label,
    required this.badge,
    required this.icon,
    required this.accent,
    required this.bg,
  });
  final String value;
  final String unit;
  final String label;
  final String badge;
  final IconData icon;
  final Color accent;
  final Color bg;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.spec});
  final _StatSpec spec;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: spec.bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: spec.accent.withValues(alpha: 0.14)),
      ),
      child: Stack(
        children: [
          // خط جانبي ملوّن على الحافة اليسرى (مطابق للتصميم).
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: Container(width: 4, color: spec.accent),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // RTL: أول عنصر = اليمين → أيقونة.
                    Container(
                      width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(spec.icon, size: 20, color: spec.accent),
              ),
              // الطرف الآخر (اليسار) → شارة صغيرة.
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: spec.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  spec.badge,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: spec.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // القيمة + الوحدة (LTR لعرض الأرقام بشكل سليم) محاذاة لليمين.
          Align(
            alignment: Alignment.centerRight,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    spec.value,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      color: AppColors.lightText1,
                    ),
                  ),
                  if (spec.unit.isNotEmpty) ...[
                    const SizedBox(width: 2),
                    Text(
                      spec.unit,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.lightText1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
                const SizedBox(height: 3),
                Text(
                  spec.label,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _Palette.of(context).label,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                       قسم المعلومات (شبكة بطاقات بشريط جانبي)
// ══════════════════════════════════════════════════════════════════════════

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.editing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<_RowSpec> fields;
  final bool editing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: _Palette.of(context).cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: _Palette.of(context).accent),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.lightText1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _Palette.of(context).label,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, c) {
            const gap = 12.0;
            final twoCols = c.maxWidth >= 460;
            final itemWidth = twoCols ? (c.maxWidth - gap) / 2 : c.maxWidth;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0; i < fields.length; i++)
                  SizedBox(
                    // الحقل الأخير الفردي يمتد لكامل العرض.
                    width: (i == fields.length - 1 && fields.length.isOdd)
                        ? c.maxWidth
                        : itemWidth,
                    child: _FieldPill(
                      spec: fields[i],
                      editing: editing,
                      // تبادُل الألوان أزرق/وردي كل صفّين.
                      pink: (i ~/ 2).isOdd,
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
