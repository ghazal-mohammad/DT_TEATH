// ════════════════════════════════════════════════════════════════════════════
// warehouse_material_movement_dialog.dart
//
// مودال "حركة مخزون" — تسجيل عملية إدخال (+) أو إخراج (−) على مادة.
// يطابق متطلب التقرير UC81 / "تعديل كمية المواد (تسجيل عمليات الإدخال أو الإخراج)".
//
// يُرجِع التغيّر الصافي (delta) موقّعاً:
//   إدخال → +amount، إخراج → −amount. null = إلغاء.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../domain/entities/warehouse_material.dart';

class WarehouseMaterialMovementDialog extends StatefulWidget {
  const WarehouseMaterialMovementDialog({super.key, required this.material});

  final WarehouseMaterial material;

  /// يُرجِع delta موقّع (موجب=إدخال، سالب=إخراج) أو null عند الإلغاء.
  static Future<int?> show(BuildContext context, WarehouseMaterial material) {
    return showDialog<int>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => WarehouseMaterialMovementDialog(material: material),
    );
  }

  @override
  State<WarehouseMaterialMovementDialog> createState() =>
      _WarehouseMaterialMovementDialogState();
}

class _WarehouseMaterialMovementDialogState
    extends State<WarehouseMaterialMovementDialog> {
  bool _isIn = true; // true = إدخال، false = إخراج
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = context.l10n;
    final value = int.tryParse(_controller.text.trim());
    if (value == null || value <= 0) {
      setState(() => _error = l10n.whMovementInvalid);
      return;
    }
    if (!_isIn && value > widget.material.quantity) {
      setState(() => _error = l10n.whMovementExceeds);
      return;
    }
    Navigator.of(context).pop(_isIn ? value : -value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final m = widget.material;
    return Dialog(
      backgroundColor: isLight ? Colors.white : AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.whMovementTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${m.name} — ${l10n.whMovementCurrent}: ${m.quantity} ${m.unit}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isLight ? AppColors.lightText3 : AppColors.darkText3,
                ),
              ),
              const SizedBox(height: AppSizes.spaceLG),
              // Toggle إدخال / إخراج
              Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      label: l10n.whMovementIn,
                      icon: Icons.south_west_rounded,
                      color: const Color(0xFF10B981),
                      selected: _isIn,
                      onTap: () => setState(() => _isIn = true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TypeButton(
                      label: l10n.whMovementOut,
                      icon: Icons.north_east_rounded,
                      color: const Color(0xFFEF4444),
                      selected: !_isIn,
                      onTap: () => setState(() => _isIn = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceLG),
              Text(
                l10n.whMovementAmount,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofocus: true,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  isDense: true,
                  errorText: _error,
                  suffixText: m.unit,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceLG),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton.secondary(
                    label: l10n.cancel,
                    onPressed: () => Navigator.of(context).pop(),
                    size: AppButtonSize.small,
                  ),
                  const SizedBox(width: 10),
                  AppButton.primary(
                    label: l10n.save,
                    onPressed: _submit,
                    size: AppButtonSize.small,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            border: Border.all(
              color: selected ? color : AppColors.lightBorder,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? color : AppColors.lightText3),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: selected ? color : AppColors.lightText2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
