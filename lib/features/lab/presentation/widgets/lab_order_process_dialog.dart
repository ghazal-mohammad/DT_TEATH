// ════════════════════════════════════════════════════════════════════════════
// lab_order_process_dialog.dart
//
// مودال "معالجة الطلبية" — ملخّص الطلب + خياران (تم التسليم / غير موجود)
// كـ radio cards + زر حفظ وإلغاء.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'lab_order_models.dart';

enum LabProcessChoice { delivered, notAvailable }

class LabOrderProcessDialog extends StatefulWidget {
  const LabOrderProcessDialog({super.key, required this.order});

  final LabOrderFull order;

  static Future<LabProcessChoice?> show(
    BuildContext context,
    LabOrderFull order,
  ) {
    return showDialog<LabProcessChoice>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => LabOrderProcessDialog(order: order),
    );
  }

  @override
  State<LabOrderProcessDialog> createState() => _LabOrderProcessDialogState();
}

class _LabOrderProcessDialogState extends State<LabOrderProcessDialog> {
  LabProcessChoice _choice = LabProcessChoice.notAvailable;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double dialogWidth = width > 700 ? 620 : width * 0.95;
    final order = widget.order;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _summary(order),
                    const SizedBox(height: 18),
                    // RTL: start = اليمين. السكشن header يبدأ من اليمين
                    // مع شريط عمودي يساره (يطلع يمين النص بصرياً في RTL).
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.l10n.labProcessUpdateStatus,
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
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ChoiceCard(
                            icon: Icons.check_rounded,
                            iconColor: const Color(0xFF10B981),
                            iconBg: const Color(0xFFD0FBD7),
                            title: context.l10n.statusDelivered,
                            subtitle: context.l10n.labProcessDeliveredDesc,
                            selected: _choice == LabProcessChoice.delivered,
                            onTap: () => setState(
                              () => _choice = LabProcessChoice.delivered,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ChoiceCard(
                            icon: Icons.close_rounded,
                            iconColor: const Color(0xFFEF4444),
                            iconBg: const Color(0xFFFEE2E2),
                            title: context.l10n.whOrderFilterMissing,
                            subtitle: context.l10n.labProcessMissingDesc,
                            selected: _choice == LabProcessChoice.notAvailable,
                            onTap: () => setState(
                              () => _choice = LabProcessChoice.notAvailable,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
                // RTL: end = اليسار بصرياً. الأزرار تصطفّ على اليسار.
                // الترتيب: حفظ (primary) ثم إلغاء — في RTL: حفظ يسار، إلغاء يمينه.
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _OutlineButton(
                      label: context.l10n.cancel,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 10),
                    _PrimaryButton(
                      label: context.l10n.save,
                      onTap: () => Navigator.of(context).pop(_choice),
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

  Widget _header(BuildContext context) {
    final order = widget.order;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(22, 16, 16, 12),
      child: Row(
        children: [
          // العنوان أولاً → يظهر على اليمين بـ RTL
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.labProcessTitle,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${order.id} — ${order.doctor}',
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
                color: const Color(0xFFF1F3F8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.close_rounded, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summary(LabOrderFull o) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECFB),
        borderRadius: BorderRadius.circular(14),
      ),
      // RTL: أوّل child = يمين. الترتيب المطلوب:
      //   صف 1: [رقم الطلب يمين | الطبيب يسار]
      //   صف 2: [المادة يمين | الموعد يسار]
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _summaryCell(context.l10n.colOrderNumber, o.id)),
              Expanded(child: _summaryCell(context.l10n.colDoctor, o.doctor)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _summaryCell(
                    context.l10n.colMaterial, '${o.material} · ${o.tooth}'),
              ),
              Expanded(child: _summaryCell(context.l10n.colDate, o.date)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCell(String label, String value) {
    // RTL: النص يبدأ من اليمين داخل خليّته → start = يمين.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.lightText3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.lightText1,
          ),
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  CHOICE CARD (radio-like)
// ══════════════════════════════════════════════════════════════════════════

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.lightBorder,
              width: selected ? 2 : 1,
            ),
          ),
          // التصميم المطلوب (مطابق للمحاكاة):
          //   - أيقونة بمربع ملوّن في الزاوية العلوية اليمنى (start في RTL)
          //   - دائرة الـ radio في الزاوية العلوية اليسرى (end في RTL)
          //   - العنوان والوصف تحت بمحاذاة start (يمين في RTL)
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // أيقونة على اليمين (start)
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 20, color: iconColor),
                  ),
                  const Spacer(),
                  // دائرة الـ radio على اليسار (end)
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            selected ? AppColors.primary : AppColors.lightText4,
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightText1,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightText3,
                ),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  BUTTONS
// ══════════════════════════════════════════════════════════════════════════

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onTap});
  final String label;
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

