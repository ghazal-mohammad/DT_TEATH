// ════════════════════════════════════════════════════════════════════════════
// warehouse_settings_nav.dart
//
// السايدبار + شريط التبويب — part of warehouse_settings_content.dart (تقسيم الصفحات العملاقة).
// ════════════════════════════════════════════════════════════════════════════

part of 'warehouse_settings_content.dart';

// ══════════════════════════════════════════════════════════════════════════
//  SIDEBAR (wide)
// ══════════════════════════════════════════════════════════════════════════

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.isLight,
    required this.active,
    required this.onSelect,
  });

  final bool isLight;
  final _SettingsTab active;
  final ValueChanged<_SettingsTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      isLight: isLight,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _SettingsTab.values
            .map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _SidebarItem(
                  isLight: isLight,
                  tab: t,
                  selected: active == t,
                  onTap: () => onSelect(t),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.isLight,
    required this.tab,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final bool isLight;
  final _SettingsTab tab;
  final bool selected;
  final VoidCallback onTap;

  /// وضع مضغوط (شريط التبويب الأفقي بالموبايل) — العنصر ياخد عرضه الطبيعي
  /// بدل الامتداد الكامل (Expanded)، والنص سطر واحد بلا التفاف — لتفادي
  /// انكسار التسميات الطويلة ("الملف الشخصي") لسطرين جوا Row مضغوطة.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    const selectedBg = AppColors.primary;
    final unselectedColor =
        isLight ? AppColors.lightText1 : AppColors.darkText1;
    final Widget label = Text(
      tab.label(context),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: selected ? Colors.white : unselectedColor,
      ),
    );
    return Material(
      color: selected ? selectedBg : Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
            children: [
              Icon(
                tab.icon,
                size: 18,
                color: selected ? Colors.white : unselectedColor,
              ),
              const SizedBox(width: 12),
              compact ? label : Expanded(child: label),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Narrow tab bar (mobile/tablet portrait) ──────────────────────────────
// كل تبويب ياخد عرضه الطبيعي (بلا Expanded) ضمن Row قابلة للتمرير أفقياً —
// نفس أسلوب `_TabNav` بإعدادات المخبر — بدل تقسيم العرض بالتساوي على 4
// عناصر (كان يخلّي التسميات الطويلة متل "الملف الشخصي" تنكسر لسطرين).
class _NarrowTabBar extends StatelessWidget {
  const _NarrowTabBar({
    required this.isLight,
    required this.active,
    required this.onSelect,
  });

  final bool isLight;
  final _SettingsTab active;
  final ValueChanged<_SettingsTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      isLight: isLight,
      padding: const EdgeInsets.all(6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final t in _SettingsTab.values)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 6),
                child: _SidebarItem(
                  isLight: isLight,
                  tab: t,
                  selected: active == t,
                  onTap: () => onSelect(t),
                  compact: true,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

