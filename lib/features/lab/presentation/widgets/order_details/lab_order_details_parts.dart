// ════════════════════════════════════════════════════════════════════════════
// lab_order_details_parts.dart
//
// الأجزاء الداخلية الخاصّة لمودال تفاصيل الطلبية (Header / StatusBanner /
// SectionHeader / InfoCards / Timeline / NotesBox / CloseButton).
// part of lab_order_details_dialog.dart — تبقى private للمكتبة، والاستيرادات
// كلها معرّفة في الملف الرئيسي.
// ════════════════════════════════════════════════════════════════════════════

part of '../lab_order_details_dialog.dart';

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
        color: AppColors.surfaceTintIndigo2,
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
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.lightText1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      orderId,
                      style: const TextStyle(
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
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
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
        color: AppColors.surfaceTintIndigo2,
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
                  style: const TextStyle(
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
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightText3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  order.date,
                  style: const TextStyle(
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
            style: const TextStyle(
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
        // "المختبر المستقبِل" حُذف — لا مصدر حقيقي له بالباك (كل التطبيق
        // يخدم مختبراً واحداً، والباك لا يرجّع اسمه ضمن بيانات الطلبية).
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
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
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
          const Divider(height: 1, color: AppColors.lightBorder),
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
              style: const TextStyle(
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
            style: const TextStyle(
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
      case LabOrderBadgeVariant.cancelled:
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
    // لا تواريخ حقيقية لكل خطوة بالباك (LabOrderResource لا يرجّع created_at/
    // updated_at) — نعرض الخطوات بلا تاريخ بدل تاريخ ثابت وهمي لكل الطلبيات.

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
            date: null,
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
        : AppColors.borderTintNeutral;
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
                      decoration: const BoxDecoration(
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
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: labelColor,
          ),
        ),
        if (date != null) ...[
          const SizedBox(height: 2),
          Text(
            date!,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11,
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
        color: AppColors.surfaceTintCool3,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Text(
        notes,
        style: const TextStyle(
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
            style: const TextStyle(
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
