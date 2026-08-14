// ════════════════════════════════════════════════════════════════════════════
// lab_settings_preferences_tab.dart
//
// تبويب التفضيلات — part of lab_settings_page.dart (تقسيم الصفحات العملاقة).
// ════════════════════════════════════════════════════════════════════════════

part of '../../pages/lab_settings_page.dart';

// ══════════════════════════════════════════════════════════════════════════
//  PREFERENCES TAB — التفضيلات
// ══════════════════════════════════════════════════════════════════════════

class _PreferencesTab extends StatefulWidget {
  const _PreferencesTab({required this.isLight});
  final bool isLight;

  @override
  State<_PreferencesTab> createState() => _PreferencesTabState();
}

class _PreferencesTabState extends State<_PreferencesTab> {
  @override
  Widget build(BuildContext context) {
    final divider = Divider(
      height: 1,
      color: widget.isLight ? AppColors.lightBorder : AppColors.darkBorder,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── السمة ──────────────────────────────────────────────
        _SettingCard(
          isLight: widget.isLight,
          title: context.l10n.theme,
          subtitle: context.l10n.settingsThemeDesc,
          child: LayoutBuilder(builder: (ctx, c) {
            final wide = c.maxWidth > 520;
            // الاختيار يُشتق من الحالة الفعلية لـ ThemeCubit (مصدر الحقيقة).
            final currentMode = context.watch<ThemeCubit>().state;
            final widgets = [
              for (final (label, mode) in [
                (context.l10n.settingsThemeSystem, ThemeMode.system),
                (context.l10n.settingsThemeLight, ThemeMode.light),
                (context.l10n.settingsThemeDark, ThemeMode.dark),
              ])
                AppThemeOption(
                  label: label,
                  mode: mode,
                  selected: mode == currentMode,
                  onTap: () => context.read<ThemeCubit>().setMode(mode),
                ),
            ];
            if (wide) {
              return Row(children: [
                for (int i = 0; i < widgets.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSizes.spaceMD),
                  Expanded(child: widgets[i]),
                ],
              ]);
            }
            return Column(children: [
              for (int i = 0; i < widgets.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSizes.spaceMD),
                widgets[i],
              ],
            ]);
          }),
        ),

        const SizedBox(height: AppSizes.spaceLG),

        // ── حجم الخط (وصولية) ──────────────────────────────────
        _SettingCard(
          isLight: widget.isLight,
          title: context.l10n.settingsTextSize,
          subtitle: context.l10n.settingsTextSizeDesc,
          child: AppTextSizeSelector(isLight: widget.isLight),
        ),

        const SizedBox(height: AppSizes.spaceLG),

        // ── اللغة ──────────────────────────────────────────────
        _SettingCard(
          isLight: widget.isLight,
          title: context.l10n.language,
          subtitle: context.l10n.settingsLanguageDesc,
          child: LayoutBuilder(builder: (ctx, c) {
            final wide = c.maxWidth > 520;
            // الاختيار يُشتق من LocaleCubit (مصدر الحقيقة).
            final isArabic =
                context.watch<LocaleCubit>().state.languageCode == 'ar';
            final widgets = [
              _LanguageOption(
                title: 'English',
                badge: 'EN',
                hint: context.l10n.settingsLangEnglishHint,
                selected: !isArabic,
                onTap: () => context
                    .read<LocaleCubit>()
                    .setLocale(SupportedLocale.english),
                isLight: widget.isLight,
              ),
              _LanguageOption(
                title: context.l10n.languageArabic,
                badge: 'ع',
                hint: context.l10n.settingsLangArabicHint,
                selected: isArabic,
                onTap: () => context
                    .read<LocaleCubit>()
                    .setLocale(SupportedLocale.arabic),
                isLight: widget.isLight,
              ),
            ];
            if (wide) {
              return Row(children: [
                Expanded(child: widgets[0]),
                const SizedBox(width: AppSizes.spaceMD),
                Expanded(child: widgets[1]),
              ]);
            }
            return Column(children: [
              widgets[0],
              const SizedBox(height: AppSizes.spaceMD),
              widgets[1],
            ]);
          }),
        ),

        const SizedBox(height: AppSizes.spaceLG),

        // ── العرض والأداء ──────────────────────────────────────
        _SettingCard(
          isLight: widget.isLight,
          title: context.l10n.settingsDisplayPerf,
          subtitle: null,
          child: Column(children: [
            _ToggleRow(
              title: context.l10n.settingsCompactView,
              subtitle: context.l10n.settingsCompactViewDesc,
              value: context.watch<CompactViewCubit>().state,
              onChanged: (v) => context.read<CompactViewCubit>().setCompact(v),
              isLight: widget.isLight,
            ),
            divider,
            _ToggleRow(
              title: context.l10n.settingsAutoSave,
              subtitle: context.l10n.settingsAutoSaveDesc,
              value: context.watch<LabSettingsPrefsCubit>().state.autosave,
              onChanged: (v) =>
                  context.read<LabSettingsPrefsCubit>().setAutosave(v),
              isLight: widget.isLight,
            ),
          ]),
        ),
      ],
    );
  }
}

