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
//
// الأجزاء الداخلية الخاصّة في order_details/lab_order_details_parts.dart
// (part of هذا الملف — تبقى private وتشارك نفس الاستيرادات).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/repositories/lab_orders_repository.dart';
import 'lab_order_models.dart';

part 'order_details/lab_order_details_parts.dart';

class LabOrderDetailsDialog extends StatefulWidget {
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
  State<LabOrderDetailsDialog> createState() => _LabOrderDetailsDialogState();
}

class _LabOrderDetailsDialogState extends State<LabOrderDetailsDialog> {
  late LabOrderFull _order = widget.order;

  @override
  void initState() {
    super.initState();
    _loadFullDetails();
  }

  /// يجلب التفاصيل الكاملة (showLabOrder) لإضافة طلبات التعديل — دون حجب العرض:
  /// نعرض بيانات القائمة فورًا ثم نُحدّث عند وصول التفاصيل. فشله صامت.
  Future<void> _loadFullDetails() async {
    try {
      final full = await sl<LabOrdersRepository>().getOne(widget.order.id);
      if (mounted) setState(() => _order = full);
    } catch (_) {/* نُبقي بيانات القائمة */}
  }

  @override
  Widget build(BuildContext context) {
    final LabOrderFull order = _order;
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
                      // عناصر الطلب — تُعرض كاملةً عند تعدّد القطع (الباك يرجّع
                      // items متعددة؛ البطاقة تلخّص الأولى فقط).
                      if (order.parts.length > 1) ...[
                        const SizedBox(height: 18),
                        _SectionHeader(label: context.l10n.orderDetailsItems),
                        const SizedBox(height: 10),
                        _OrderPartsList(parts: order.parts),
                      ],
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
                      // طلبات التعديل — من showLabOrder (تظهر عند وصول التفاصيل).
                      if (order.modifications.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        _SectionHeader(
                            label: context.l10n.orderDetailsModifications),
                        const SizedBox(height: 10),
                        _ModificationsList(mods: order.modifications),
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
//  MODIFICATIONS LIST — طلبات التعديل/الإصلاح على الطلبية (من showLabOrder)
// ══════════════════════════════════════════════════════════════════════════

class _ModificationsList extends StatelessWidget {
  const _ModificationsList({required this.mods});

  final List<LabOrderModification> mods;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.statusWarnBg.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        children: [
          for (int i = 0; i < mods.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.lightBorder),
            _ModRow(mod: mods[i]),
          ],
        ],
      ),
    );
  }
}

class _ModRow extends StatelessWidget {
  const _ModRow({required this.mod});

  final LabOrderModification mod;

  @override
  Widget build(BuildContext context) {
    final sub = [
      if (mod.fault.isNotEmpty) mod.fault,
      if (mod.status.isNotEmpty) mod.status,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.build_outlined,
                  size: 16, color: AppColors.statusWarn),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mod.details.isEmpty ? '—' : mod.details,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightText1,
                  ),
                ),
              ),
            ],
          ),
          if (sub.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 24),
              child: Text(
                sub,
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.lightText3),
              ),
            ),
          ],
          if (mod.responseNotes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 24),
              child: Text(
                mod.responseNotes,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.lightText2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  ORDER PARTS LIST — كل قطع الطلب (سن/نوع/مادة/سعر) عند تعدّدها
// ══════════════════════════════════════════════════════════════════════════

class _OrderPartsList extends StatelessWidget {
  const _OrderPartsList({required this.parts});

  final List<LabOrderPart> parts;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.tableHeader.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        children: [
          for (int i = 0; i < parts.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.lightBorder),
            _PartRow(index: i + 1, part: parts[i]),
          ],
        ],
      ),
    );
  }
}

class _PartRow extends StatelessWidget {
  const _PartRow({required this.index, required this.part});

  final int index;
  final LabOrderPart part;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtitle = [
      if (part.material.isNotEmpty) part.material,
      if (part.tooth.isNotEmpty) '${l10n.colTooth} ${part.tooth}',
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$index',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  part.type.isEmpty ? '—' : part.type,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.lightText1,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.lightText3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (part.price > 0) ...[
            const SizedBox(width: 10),
            Text(
              '${_formatPartPrice(part.price)} ل.س',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.lightText1,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// تنسيق السعر بفواصل آلاف.
  static String _formatPartPrice(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
