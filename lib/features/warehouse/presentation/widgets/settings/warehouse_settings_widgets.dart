// ════════════════════════════════════════════════════════════════════════════
// warehouse_settings_widgets.dart
//
// ودجات مشتركة قابلة لإعادة الاستخدام — part of warehouse_settings_content.dart (تقسيم الصفحات العملاقة).
// ════════════════════════════════════════════════════════════════════════════

part of 'warehouse_settings_content.dart';

// ══════════════════════════════════════════════════════════════════════════
//  REUSABLE PIECES
// ══════════════════════════════════════════════════════════════════════════

/// ترويسة بطاقة (عنوان + وصف اختياري).
class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.isLight,
    required this.title,
    this.subtitle,
  });

  final bool isLight;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isLight ? AppColors.lightText1 : AppColors.darkText1,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              color: isLight ? AppColors.lightText3 : AppColors.darkText3,
            ),
          ),
        ],
      ],
    );
  }
}

/// صفّ توضّع فيه: نص رئيسي + وصف + Switch.
class _TogglePref extends StatelessWidget {
  const _TogglePref({
    required this.isLight,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final bool isLight;
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    color: isLight ? AppColors.lightText3 : AppColors.darkText3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }
}

class _PrefDivider extends StatelessWidget {
  const _PrefDivider({required this.isLight});
  final bool isLight;

  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    thickness: 1,
    color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
  );
}

/// بطاقة اختيار اللغة.
class _LangOptionCard extends StatelessWidget {
  const _LangOptionCard({
    required this.isLight,
    required this.badge,
    required this.title,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  final bool isLight;
  final String badge;
  final String title;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? AppColors.primary
        : (isLight ? AppColors.lightBorder : AppColors.darkBorder);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isLight ? AppColors.lightBg : AppColors.darkBg,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
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
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                    sub,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      color: isLight
                          ? AppColors.lightText3
                          : AppColors.darkText3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _RadioDot(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.lightText4,
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
    );
  }
}
// ══════════════════════════════════════════════════════════════════════════
//  CARDS
// ══════════════════════════════════════════════════════════════════════════

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.isLight,
    required this.child,
    this.padding,
  });

  final bool isLight;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSizes.spaceLG),
      decoration: BoxDecoration(
        color: isLight ? AppColors.baseComponent : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: child,
    );
  }
}

class _DangerCard extends StatelessWidget {
  const _DangerCard({required this.isLight, required this.child});
  final bool isLight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // لون برتقالي/تحذير خفيف يطابق الـ mockup
    const dangerTint = AppColors.warnTintLight2;
    const dangerBorder = AppColors.warnBorderLight2;
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      decoration: BoxDecoration(
        color: isLight ? dangerTint : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(
          color: isLight ? dangerBorder : AppColors.darkBorder,
        ),
      ),
      child: child,
    );
  }
}
