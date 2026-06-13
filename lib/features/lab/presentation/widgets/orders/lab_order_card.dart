// ════════════════════════════════════════════════════════════════════════════
// lab_order_card.dart
//
// بطاقة طلبية طبيب في شبكة "طلبات الأطباء" (رأس + طبيب + معلومات + footer)
// مع أجزائها الداخلية — مُستخرَجة من lab_orders_page.dart ضمن تقسيم الصفحات.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../data/mock/lab_dashboard_mock_data.dart';
import '../lab_order_models.dart';

/// بطاقة طلبية واحدة في شبكة طلبات الأطباء.
class LabOrderCard extends StatefulWidget {
  const LabOrderCard({
    super.key,
    required this.order,
    required this.onView,
    required this.onProcess,
  });

  final LabOrderFull order;
  final VoidCallback onView;
  final VoidCallback onProcess;

  @override
  State<LabOrderCard> createState() => _LabOrderCardState();
}

class _LabOrderCardState extends State<LabOrderCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final accent = labOrderAccentColor(
      statusVariant: o.statusVariant,
      isUrgent: o.isUrgent,
    );
    final initial =
        o.doctor.replaceAll('د. ', '').characters.firstOrNull ?? '';
    final radius = BorderRadius.circular(AppSizes.radiusLG);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : AppColors.darkBg1,
          borderRadius: radius,
          border: Border.all(
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hover ? 0.07 : 0.03),
              blurRadius: _hover ? 18 : 10,
              offset: Offset(0, _hover ? 8 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            children: [
              // الشريط الجانبي الملوّن (RTL = left visual)
              PositionedDirectional(
                end: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 5, color: accent),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(18, 14, 22, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Header: رقم (يمين) + نوع (يسار) ─────────────
                    // RTL: أوّل child = يمين، فالـ ID يمين والنوع يسار.
                    Row(
                      children: [
                        Text(
                          o.id,
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color:
                                isLight ? AppColors.primary : AppColors.darkText1,
                          ),
                        ),
                        const Spacer(),
                        _TypePill(label: o.type),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // ── الطبيب (avatar+اسم يمين) + شارة عاجل (يسار) ─
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isLight
                                ? AppColors.statusInfoBg
                                : AppColors.darkChipBlueBg,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            initial,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isLight
                                  ? AppColors.primary
                                  : AppColors.darkChipBlueText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          o.doctor,
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color:
                                isLight ? AppColors.lightText1 : AppColors.darkText1,
                          ),
                        ),
                        const Spacer(),
                        if (o.isUrgent) const _UrgentPill(),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // ── صندوق المعلومات (المادة/السن/الموعد) ────────
                    _InfoBox(material: o.material, tooth: o.tooth, date: o.date),
                    const SizedBox(height: 14),
                    // ── Footer: حالة (يمين) + عرض/معالجة (يسار) ─────
                    // RTL convention: status badge يمين، الزر الأساسي (معالجة) يسار.
                    Row(
                      children: [
                        _StatusBadge(variant: o.statusVariant),
                        const Spacer(),
                        _ViewButton(onTap: widget.onView),
                        const SizedBox(width: 6),
                        _ProcessButton(onTap: widget.onProcess),
                      ],
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
}

// ── pieces ─────────────────────────────────────────────────────────────

class _TypePill extends StatelessWidget {
  const _TypePill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isLight ? AppColors.surfaceTintCool : AppColors.darkBg2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isLight ? AppColors.lightText2 : AppColors.darkText2,
        ),
      ),
    );
  }
}

class _UrgentPill extends StatelessWidget {
  const _UrgentPill();

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isLight ? AppColors.statusUrgentBg : AppColors.darkChipRedBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 13,
            color: isLight ? AppColors.statusUrgent : AppColors.darkChipRedText,
          ),
          const SizedBox(width: 4),
          Text(
            context.l10n.priorityUrgent,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color:
                  isLight ? AppColors.statusUrgent : AppColors.darkChipRedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.material,
    required this.tooth,
    required this.date,
  });

  final String material;
  final String tooth;
  final String date;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isLight ? AppColors.surfaceTintCool2 : AppColors.darkBg2,
        borderRadius: BorderRadius.circular(12),
      ),
      // RTL: أوّل child = يمين. الترتيب المطلوب (يمين→يسار):
      //   [المادة] | [السن] | [الموعد]
      child: Row(
        children: [
          Expanded(child: _cell(context.l10n.colMaterial, material, isLight)),
          _divider(isLight),
          Expanded(child: _cell(context.l10n.colTooth, tooth, isLight)),
          _divider(isLight),
          Expanded(child: _cell(context.l10n.colDate, date, isLight)),
        ],
      ),
    );
  }

  Widget _divider(bool isLight) => Container(
        width: 1,
        height: 28,
        color: isLight ? AppColors.borderTintCool : AppColors.darkBorder,
      );

  Widget _cell(String label, String value, bool isLight) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isLight ? AppColors.lightText3 : AppColors.darkText3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isLight ? AppColors.lightText1 : AppColors.darkText1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.variant});
  final LabOrderBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final c = LabStatusColors.of(variant);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      // RTL: نص يمين، dot يسار → [Text, SizedBox, dot].
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            labStatusLabel(context, variant),
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: c.fg,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: c.fg, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

class _ProcessButton extends StatelessWidget {
  const _ProcessButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isLight ? AppColors.primary : AppColors.brand,
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 5),
              Text(
                context.l10n.labOrderProcess,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
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

class _ViewButton extends StatelessWidget {
  const _ViewButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : AppColors.darkBg1,
            border: Border.all(
                color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Text(
            context.l10n.actionView,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isLight ? AppColors.lightText1 : AppColors.darkText1,
            ),
          ),
        ),
      ),
    );
  }
}
