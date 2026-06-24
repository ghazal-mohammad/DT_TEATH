// ════════════════════════════════════════════════════════════════════════════
// lab_settings_widgets.dart
//
// ودجات مشتركة — part of lab_settings_page.dart (تقسيم الصفحات العملاقة).
// ════════════════════════════════════════════════════════════════════════════

part of '../../pages/lab_settings_page.dart';

// ══════════════════════════════════════════════════════════════════════════
//  REUSABLE — SETTING CARD
// ══════════════════════════════════════════════════════════════════════════

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.isLight,
    required this.title,
    this.subtitle,
    this.child,
    this.trailing,
    this.tint,
    this.tintBorder,
  });

  final bool isLight;
  final String title;
  final String? subtitle;
  final Widget? child;
  final Widget? trailing;
  final Color? tint;
  final Color? tintBorder;

  @override
  Widget build(BuildContext context) {
    final bg = tint ??
        (isLight ? AppColors.lightSurface : AppColors.darkSurface);
    final border = tintBorder ??
        (isLight ? AppColors.lightBorder : AppColors.darkBorder);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: title + subtitle ← يمين (start) | trailing ← يسار (end)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isLight
                            ? AppColors.lightText1
                            : AppColors.darkText1,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isLight
                              ? AppColors.lightText3
                              : AppColors.darkText3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSizes.spaceMD),
                trailing!,
              ],
            ],
          ),
          if (child != null) ...[
            const SizedBox(height: AppSizes.spaceLG),
            child!,
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  REUSABLE — TOGGLE ROW
// ══════════════════════════════════════════════════════════════════════════

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isLight,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceMD),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // النص ← start (يمين بـ RTL)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isLight
                        ? AppColors.lightText1
                        : AppColors.darkText1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isLight
                        ? AppColors.lightText4
                        : AppColors.darkText3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.spaceMD),
          // الـ Switch ← end (يسار بـ RTL)
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  REUSABLE — PASSWORD FIELD
// ══════════════════════════════════════════════════════════════════════════

class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.isLight,
  });

  final String label;
  final TextEditingController controller;
  final bool isLight;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: widget.isLight
                ? AppColors.lightText2
                : AppColors.darkText2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: widget.isLight ? Colors.white : AppColors.darkGlass2,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: Border.all(
              color: widget.isLight
                  ? AppColors.lightBorder
                  : AppColors.darkBorder,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: _obscure,
            autofillHints: const [AutofillHints.password],
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: widget.isLight
                  ? AppColors.lightText1
                  : AppColors.darkText1,
            ),
            decoration: InputDecoration(
              hintText: '••••••••',
              contentPadding: const EdgeInsetsDirectional.fromSTEB(
                14, 12, 8, 12,
              ),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: widget.isLight
                      ? AppColors.lightText3
                      : AppColors.darkText3,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  REUSABLE — LANGUAGE OPTION
// ══════════════════════════════════════════════════════════════════════════

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.title,
    required this.badge,
    required this.hint,
    required this.selected,
    required this.onTap,
    required this.isLight,
  });

  final String title;
  final String badge;
  final String hint;
  final bool selected;
  final VoidCallback onTap;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(AppSizes.spaceMD),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.08)
                : (isLight ? Colors.white : AppColors.darkSurface),
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.lightBorder,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Radio circle (يسار بـ RTL = end)
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : AppColors.lightBorder,
                    width: 2,
                  ),
                  color: selected ? AppColors.primary : Colors.transparent,
                ),
                child: selected
                    ? const Icon(Icons.circle, size: 6, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              // Title + hint
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isLight
                            ? AppColors.lightText1
                            : AppColors.darkText1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hint,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isLight
                            ? AppColors.lightText3
                            : AppColors.darkText3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Badge (end)
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceTintIndigo,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
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
//  REUSABLE — BUTTONS
// ══════════════════════════════════════════════════════════════════════════

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 11, 16, 11),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: Colors.white),
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

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.onTap,
    required this.isLight,
    this.danger = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isLight;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final fg = danger
        ? AppColors.dangerStrong
        : (isLight ? AppColors.lightText1 : AppColors.darkText1);
    final border = danger
        ? AppColors.dashPink
        : (isLight ? AppColors.lightBorder : AppColors.darkBorder);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 11, 16, 11),
          decoration: BoxDecoration(
            color: danger ? AppColors.dangerTintLight : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: Border.all(color: border),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
