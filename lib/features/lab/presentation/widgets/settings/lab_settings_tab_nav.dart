// ════════════════════════════════════════════════════════════════════════════
// lab_settings_tab_nav.dart
//
// شريط تبويب الإعدادات — part of lab_settings_page.dart (تقسيم الصفحات العملاقة).
// ════════════════════════════════════════════════════════════════════════════

part of '../../pages/lab_settings_page.dart';

// ══════════════════════════════════════════════════════════════════════════
//  TAB NAV
// ══════════════════════════════════════════════════════════════════════════

// شريط تبويب أفقي دائماً (بكل الأحجام) — كل عنصر ياخد عرضه الطبيعي ضمن Row
// قابلة للتمرير أفقياً بدل عمود جانبي عمودي، فتبقى التبويبات الأربعة بسطر
// واحد جنب بعض بغض النظر عن عرض الشاشة.
class _TabNav extends StatelessWidget {
  const _TabNav({
    required this.selectedIndex,
    required this.onTap,
    required this.isLight,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.lock_outline, context.l10n.settingsTabSecurity),
      (Icons.notifications_none, context.l10n.notifications),
      (Icons.tune, context.l10n.settingsTabPreferences),
      (Icons.person_outline, context.l10n.labProfile),
    ];

    Widget buildItem(int i, IconData icon, String label) {
      final isSelected = selectedIndex == i;
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            margin: const EdgeInsetsDirectional.only(end: AppSizes.spaceSM),
            padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : (isLight
                      ? AppColors.lightSurface
                      : AppColors.darkSurface),
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              border: isSelected
                  ? null
                  : Border.all(
                      color: isLight
                          ? AppColors.lightBorder
                          : AppColors.darkBorder,
                    ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : (isLight
                          ? AppColors.lightText2
                          : AppColors.darkText2),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : (isLight ? AppColors.lightText1 : AppColors.darkText1),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++)
            buildItem(i, items[i].$1, items[i].$2),
        ],
      ),
    );
  }
}

