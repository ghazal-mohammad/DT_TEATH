// ════════════════════════════════════════════════════════════════════════════
// assign_order_dialog.dart
//
// مودال "توكيل طلبية لـ <اسم المخبري>" — قائمة طلبيات قابلة للاختيار + زر توكيل.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'lab_order_models.dart';

class AssignOrderDialog extends StatefulWidget {
  const AssignOrderDialog({
    super.key,
    required this.technicianName,
    required this.orders,
  });

  final String technicianName;
  final List<LabOrderFull> orders;

  static Future<String?> show(
    BuildContext context, {
    required String technicianName,
    required List<LabOrderFull> orders,
  }) {
    return showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => AssignOrderDialog(
        technicianName: technicianName,
        orders: orders,
      ),
    );
  }

  @override
  State<AssignOrderDialog> createState() => _AssignOrderDialogState();
}

class _AssignOrderDialogState extends State<AssignOrderDialog> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    // اختيار الطلبية الثالثة افتراضياً (مطابقة للصورة المرجعية)
    if (widget.orders.length >= 3) {
      _selectedId = widget.orders[2].id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final dialogWidth = width > 700 ? 620.0 : width * 0.95;

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
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
                  child: Column(
                    children: [
                      for (final o in widget.orders) ...[
                        _OrderRow(
                          order: o,
                          selected: _selectedId == o.id,
                          onTap: () => setState(() => _selectedId = o.id),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
                // RTL: end = اليسار. الأزرار تتراصّ يسار.
                // الترتيب: إلغاء (يمين) → توكيل primary (يسار).
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _OutlineBtn(
                      label: 'إلغاء',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 10),
                    _PrimaryBtn(
                      label: 'توكيل',
                      icon: Icons.check_rounded,
                      onTap: _selectedId == null
                          ? null
                          : () => Navigator.of(context).pop(_selectedId),
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
                'توكيل طلبية',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'اختر الطلبية لـ ${widget.technicianName}',
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
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({
    required this.order,
    required this.selected,
    required this.onTap,
  });

  final LabOrderFull order;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = LabStatusColors.of(order.statusVariant);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.lightBorder,
              width: selected ? 2 : 1,
            ),
          ),
          // RTL convention: order info (id + meta) على اليمين، status badge على اليسار.
          // ⇒ في الـ Row: Column أوّل (يمين) ثم Spacer ثم StatusBadge (يسار).
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${order.id} — ${order.type}',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.lightText1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      _meta(order.doctor),
                      _dot(),
                      _meta(order.tooth),
                      _dot(),
                      _meta(order.material),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                // RTL: نص يمين، dot يسار.
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      colors.label,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.fg,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colors.fg,
                        shape: BoxShape.circle,
                      ),
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

  Widget _meta(String t) => Text(
        t,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.lightText3,
        ),
      );

  Widget _dot() => Text(
        '•',
        style: TextStyle(color: AppColors.lightText4, fontSize: 12),
      );
}

class _PrimaryBtn extends StatelessWidget {
  const _PrimaryBtn({required this.label, required this.onTap, this.icon});
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.4),
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

