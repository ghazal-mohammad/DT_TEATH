// ════════════════════════════════════════════════════════════════════════════
// warehouse_material_form_parts.dart
//
// أجزاء داخلية خاصّة لمودال مادة المستودع: مُحقِّقات الحقول (validators) وزر
// الإغلاق. part of warehouse_material_form_dialog.dart — تشارك نفس الاستيرادات.
// ════════════════════════════════════════════════════════════════════════════

part of 'warehouse_material_form_dialog.dart';

// ── Validators (دوال نقية تعتمد على context.l10n فقط) ──────────────────────

String? _requiredValidator(BuildContext context, String? v) {
  if (v == null || v.trim().isEmpty) {
    return context.l10n.errorRequired;
  }
  return null;
}

String? _intValidator(BuildContext context, String? v) {
  final required = _requiredValidator(context, v);
  if (required != null) return required;
  if (int.tryParse(v!.trim()) == null) {
    return context.l10n.errorInvalidNumber;
  }
  final intVal = int.parse(v.trim());
  if (intVal < 0) return context.l10n.errorInvalidNumber;
  return null;
}

String? _optionalDoubleValidator(BuildContext context, String? v) {
  if (v == null || v.trim().isEmpty) return null;
  if (double.tryParse(v.trim()) == null) {
    return context.l10n.errorInvalidNumber;
  }
  return null;
}

// ── Close button ───────────────────────────────────────────────────────────

class _CloseButton extends StatefulWidget {
  const _CloseButton({required this.onTap, required this.isLight});

  final VoidCallback onTap;
  final bool isLight;

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.alertRed.withValues(alpha: 0.15)
                : (widget.isLight
                    ? AppColors.lightBorder.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.06)),
            border: Border.all(
              color: _hovered
                  ? AppColors.alertRed.withValues(alpha: 0.30)
                  : (widget.isLight
                      ? AppColors.lightBorder
                      : AppColors.darkBorder),
              width: AppSizes.borderThin,
            ),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.close,
            size: 13,
            color: _hovered
                ? AppColors.alertRed
                : (widget.isLight
                    ? AppColors.lightText3
                    : AppColors.darkText3),
          ),
        ),
      ),
    );
  }
}
