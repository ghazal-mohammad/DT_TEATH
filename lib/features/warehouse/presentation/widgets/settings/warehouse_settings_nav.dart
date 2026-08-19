// ════════════════════════════════════════════════════════════════════════════
// warehouse_settings_nav.dart
//
// السايدبار + شريط التبويب — part of warehouse_settings_content.dart (تقسيم الصفحات العملاقة).
// ════════════════════════════════════════════════════════════════════════════

part of 'warehouse_settings_content.dart';

// ══════════════════════════════════════════════════════════════════════════
//  TAB BAR (أفقي دائماً)
// ══════════════════════════════════════════════════════════════════════════

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
            // العنصر ياخد عرضه الطبيعي (بلا Expanded) ضمن Row قابلة للتمرير
            // أفقياً — نفس أسلوب `_TabNav` بإعدادات المخبر — بدل تقسيم
            // العرض بالتساوي (كان يخلّي التسميات الطويلة متل "الملف
            // الشخصي" تنكسر لسطرين).
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                tab.icon,
                size: 18,
                color: selected ? Colors.white : unselectedColor,
              ),
              const SizedBox(width: 12),
              Text(
                tab.label(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : unselectedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({
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
                ),
              ),
          ],
        ),
      ),
    );
  }
}

