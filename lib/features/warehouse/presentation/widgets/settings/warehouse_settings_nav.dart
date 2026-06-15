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
  });

  final bool isLight;
  final _SettingsTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const selectedBg = AppColors.primary;
    final unselectedColor =
        isLight ? AppColors.lightText1 : AppColors.darkText1;
    return Material(
      color: selected ? selectedBg : Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                tab.icon,
                size: 18,
                color: selected ? Colors.white : unselectedColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tab.label(context),
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : unselectedColor,
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

// ── Narrow tab bar (mobile/tablet portrait) ──────────────────────────────
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
      child: Row(
        children: _SettingsTab.values
            .map((t) => Expanded(
                  child: _SidebarItem(
                    isLight: isLight,
                    tab: t,
                    selected: active == t,
                    onTap: () => onSelect(t),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

