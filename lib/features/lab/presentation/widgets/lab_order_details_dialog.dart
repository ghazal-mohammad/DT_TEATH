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

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/mock/lab_dashboard_mock_data.dart';
import 'lab_order_models.dart';

part 'order_details/lab_order_details_parts.dart';

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
