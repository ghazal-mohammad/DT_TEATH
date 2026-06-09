// ════════════════════════════════════════════════════════════════════════════
// lab_order_details_dialog.dart
//
// مودال "تفاصيل الطلبية" — مطابق للتصميم المرجعي:
//   - Hero header بخلفية لافندر (عنوان + subtitle + close)
//   - Status banner (لافندر): حالة + تاريخ التسليم المتوقع
//   - Section "معلومات الطلبية"
//   - بطاقتان side-by-side: بيانات الطلبية | بيانات الطبيب
//   - Section "تقدم العمل" + timeline (3 خطوات)
//   - Section "ملاحظات" + box رمادي
//   - Footer: زر "إغلاق" في الزاوية اليسرى السفلى
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/mock/lab_dashboard_mock_data.dart';
import 'lab_order_models.dart';

class LabOrderDetailsDialog extends StatelessWidget {
  const LabOrderDetailsDialog({super.key, required this.order});

  final LabOrderFull order;

  static Future<void> show(BuildContext context, LabOrderFull order) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => LabOrderDetailsDialog(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double dialogWidth = width > 800 ? 720 : width * 0.95;
    final double dialogMaxHeight = MediaQuery.of(context).size.height * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: dialogMaxHeight,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(orderId: order.id, onClose: () => Navigator.of(context).pop()),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _StatusBanner(order: order),
                      const SizedBox(height: 18),
                      _SectionHeader(label: context.l10n.orderDetailsInfoSection),
                      const SizedBox(height: 10),
                      LayoutBuilder(builder: (ctx, c) {
                        final isNarrow = c.maxWidth < 540;
                        final orderCard = _OrderInfoCard(order: order);
                        final doctorCard = _DoctorInfoCard(order: order);
                        if (isNarrow) {
                          return Column(
                            children: [
                              orderCard,
                              const SizedBox(height: 12),
                              doctorCard,
                            ],
                          );
                        }
                        // RTL: أوّل child = يمين.
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: orderCard),
                            const SizedBox(width: 12),
                            Expanded(child: doctorCard),
                          ],
                        );
                      }),
                      const SizedBox(height: 18),
                      _SectionHeader(label: context.l10n.orderDetailsProgress),
                      const SizedBox(height: 14),
                      _ProgressTimeline(variant: order.statusVariant),
                      if (order.notes.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        _SectionHeader(label: context.l10n.orderDetailsNotes),
                        const SizedBox(height: 10),
                        _NotesBox(notes: order.notes),
                      ],
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
                // RTL: end = اليسار → زر إغلاق في الزاوية اليسرى السفلى.
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: _CloseButton(onTap: () => Navigator.of(context).pop()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  HEADER (lavender background)
// ══════════════════════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  const _Header({required this.orderId, required this.onClose});
  final String orderId;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(22, 18, 16, 18),
      decoration: const BoxDecoration(
        // خلفية لافندر فاتح
        color: Color(0xFFEEEEFB),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // العنوان والـ subtitle (RTL: يمين)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // RTL: التركيب يقرأ يمين → يسار: "تفاصيل الطلبية LAB-045"
                Row(
                  mainAxisSize: MainAxisSize.min,
                  textBaseline: TextBaseline.alphabetic,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  children: [
                    Text(
                      context.l10n.orderDetailsHeading,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.lightText1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      orderId,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.orderDetailsSubtitleLab,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightText3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // زر الإغلاق (RTL: يسار)
          InkWell(
            onTap: onClose,
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
}

// ══════════════════════════════════════════════════════════════════════════
//  STATUS BANNER (lavender full-width strip)
// ══════════════════════════════════════════════════════════════════════════

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.order});
  final LabOrderFull order;

  @override
  Widget build(BuildContext context) {
    final c = LabStatusColors.of(order.statusVariant);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEFB),
        borderRadius: BorderRadius.circular(12),
      ),
      // RTL: أوّل child = يمين. حالة الطلبية يمين، تاريخ التسليم يسار.
      child: Row(
        children: [
          // حالة الطلبية (يمين)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.orderDetailsStatusLabel,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightText3,
                  ),
                ),
                const SizedBox(height: 6),
                // pill: نص يمين، dot يسار
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      labStatusLabel(context, order.statusVariant),
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: c.fg,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: c.fg,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // تاريخ التسليم المتوقع (يسار)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.orderDetailsExpectedDelivery,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightText3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  order.date,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.lightText1,
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
//  SECTION HEADER (with vertical bar on right)
// ══════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    // RTL: start = يمين. النص يمين، الشريط يسار النص (يطلع يمين بصرياً للنص).
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
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
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  INFO CARDS
// ══════════════════════════════════════════════════════════════════════════

class _OrderInfoCard extends StatelessWidget {
  const _OrderInfoCard({required this.order});
  final LabOrderFull order;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: context.l10n.orderDetailsOrderData,
      rows: [
        (label: context.l10n.colType, value: order.type, pillColor: null),
        (label: context.l10n.colMaterial, value: order.material, pillColor: null),
        (label: context.l10n.colTooth, value: order.tooth, pillColor: null),
        if (order.cost != null)
          (
            label: context.l10n.orderDetailsCost,
            value: '${_formatMoney(order.cost!)} ل.س',
            pillColor: null,
          ),
      ],
    );
  }
}

/// تنسيق رقم بفواصل آلاف (1200000 → 1,200,000).
String _formatMoney(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

class _DoctorInfoCard extends StatelessWidget {
  const _DoctorInfoCard({required this.order});
  final LabOrderFull order;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: context.l10n.orderDetailsDoctorData,
      rows: [
        (label: context.l10n.orderDetailsSenderDoctor, value: order.doctor, pillColor: null),
        (
          label: context.l10n.orderDetailsPriority,
          value: order.isUrgent
              ? context.l10n.priorityUrgent
              : context.l10n.priorityNormal,
          pillColor: order.isUrgent
              ? const Color(0xFFEF4444)
              : AppColors.lightText3,
        ),
        (label: context.l10n.orderDetailsReceivingLab, value: 'مختبر الشام', pillColor: null),
        if (order.assignedTechnician != null)
          (
            label: context.l10n.orderDetailsExecutor,
            value: order.assignedTechnician!,
            pillColor: null,
          ),
      ],
    );
  }
}

typedef _InfoRowData = ({String label, String value, Color? pillColor});

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows});
  final String title;
  final List<_InfoRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ترويسة البطاقة: عنوان + bar (RTL: نص يمين، bar يساره)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.lightText1,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: AppColors.lightBorder),
          for (final r in rows) ...[
            const SizedBox(height: 8),
            _InfoRow(label: r.label, value: r.value, pillColor: r.pillColor),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.pillColor,
  });
  final String label;
  final String value;
  final Color? pillColor;

  @override
  Widget build(BuildContext context) {
    // RTL: أوّل child = يمين. التصميم: value يمين، label يسار.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // value (يمين)
          if (pillColor != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: pillColor!.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: pillColor,
                ),
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.lightText1,
              ),
            ),
          const Spacer(),
          // label (يسار)
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.lightText3,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  PROGRESS TIMELINE (3 steps)
// ══════════════════════════════════════════════════════════════════════════

class _ProgressTimeline extends StatelessWidget {
  const _ProgressTimeline({required this.variant});
  final LabOrderBadgeVariant variant;

  /// تحديد الخطوة الحالية بناءً على status:
  /// newOrder → 0 (تم الاستلام), manufacturing → 1, ready → 2.
  int get _currentStep {
    switch (variant) {
      case LabOrderBadgeVariant.ready:
        return 2;
      case LabOrderBadgeVariant.manufacturing:
        return 1;
      case LabOrderBadgeVariant.newOrder:
      case LabOrderBadgeVariant.urgent:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // الخطوات: index 0 → "تم الاستلام" (يمين في RTL = أوّل خطوة)
    //           index 1 → "قيد التصنيع"
    //           index 2 → "جاهز للتسليم" (يسار = آخر خطوة)
    final steps = [
      context.l10n.orderTimelineReceived,
      context.l10n.statusManufacturing,
      context.l10n.orderDetailsReadyForDelivery,
    ];
    final dates = <int, String>{0: '20-04-2026'};

    return Row(
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                color: i <= _currentStep
                    ? AppColors.primary
                    : AppColors.lightBorder,
              ),
            ),
          _TimelineStep(
            label: steps[i],
            date: dates[i],
            isActive: i == _currentStep,
            isDone: i < _currentStep,
          ),
        ],
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.date,
    required this.isActive,
    required this.isDone,
  });
  final String label;
  final String? date;
  final bool isActive;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final Color circleColor = isActive || isDone
        ? AppColors.primary
        : const Color(0xFFD8DBE6);
    final Color labelColor = isActive || isDone
        ? AppColors.lightText1
        : AppColors.lightText4;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDone ? AppColors.primary : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: circleColor, width: 2),
          ),
          child: isDone
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : isActive
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: labelColor,
          ),
        ),
        if (date != null) ...[
          const SizedBox(height: 2),
          Text(
            date!,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: AppColors.lightText3,
            ),
          ),
        ],
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  NOTES BOX
// ══════════════════════════════════════════════════════════════════════════

class _NotesBox extends StatelessWidget {
  const _NotesBox({required this.notes});
  final String notes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Text(
        notes,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.lightText2,
          height: 1.55,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  CLOSE BUTTON
// ══════════════════════════════════════════════════════════════════════════

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.lightBorder),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Text(
            context.l10n.close,
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
