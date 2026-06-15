// ════════════════════════════════════════════════════════════════════════════
// warehouse_settings_preferences_tab.dart
//
// تبويب التفضيلات — part of warehouse_settings_content.dart (تقسيم الصفحات العملاقة).
// ════════════════════════════════════════════════════════════════════════════

part of 'warehouse_settings_content.dart';

// ══════════════════════════════════════════════════════════════════════════
//  TAB 3 — التفضيلات
// ══════════════════════════════════════════════════════════════════════════

enum _ThemeChoice { dark, light }

extension on _ThemeChoice {
  String label(BuildContext context) => switch (this) {
        _ThemeChoice.dark => context.l10n.settingsThemeDark,
        _ThemeChoice.light => context.l10n.settingsThemeLight,
      };
}

class _PreferencesTabContent extends StatefulWidget {
  const _PreferencesTabContent({required this.isLight});
  final bool isLight;

  @override
  State<_PreferencesTabContent> createState() => _PreferencesTabContentState();
}

class _PreferencesTabContentState extends State<_PreferencesTabContent> {
  /// يحوّل خيار السمة المحلي إلى [ThemeMode] الخاص بـ Flutter.
  ThemeMode _flutterMode(_ThemeChoice c) => switch (c) {
        _ThemeChoice.dark => ThemeMode.dark,
        _ThemeChoice.light => ThemeMode.light,
      };
  bool _compactView = false;
  bool _autoSave = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── السمة ───────────────────────────────────────────────────
        _SettingsCard(
          isLight: widget.isLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardHeader(
                isLight: widget.isLight,
                title: context.l10n.theme,
                subtitle: context.l10n.settingsThemeDesc,
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, c) {
                  final isNarrow = c.maxWidth < 520;
                  final currentMode = context.watch<ThemeCubit>().state;
                  // بطاقة السمة الموحّدة (تصميم المخبر المعتمد).
                  final children = _ThemeChoice.values
                      .map((t) => AppThemeOption(
                            label: t.label(context),
                            mode: _flutterMode(t),
                            selected: _flutterMode(t) == currentMode,
                            onTap: () => context
                                .read<ThemeCubit>()
                                .setMode(_flutterMode(t)),
                          ))
                      .toList();
                  if (isNarrow) {
                    return Column(
                      children: [
                        for (var i = 0; i < children.length; i++) ...[
                          children[i],
                          if (i != children.length - 1)
                            const SizedBox(height: 10),
                        ],
                      ],
                    );
                  }
                  return Row(
                    children: [
                      for (var i = 0; i < children.length; i++) ...[
                        Expanded(child: children[i]),
                        if (i != children.length - 1)
                          const SizedBox(width: 12),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: _kCardGap),

        // ── اللغة ───────────────────────────────────────────────────
        _SettingsCard(
          isLight: widget.isLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardHeader(
                isLight: widget.isLight,
                title: context.l10n.language,
                subtitle: context.l10n.settingsLanguageDesc,
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, c) {
                  final isNarrow = c.maxWidth < 520;
                  final isArabic =
                      context.watch<LocaleCubit>().state.languageCode == 'ar';
                  final ar = _LangOptionCard(
                    isLight: widget.isLight,
                    badge: 'ع',
                    title: 'العربية',
                    sub: context.l10n.settingsLangArabicHint,
                    selected: isArabic,
                    onTap: () => context
                        .read<LocaleCubit>()
                        .setLocale(SupportedLocale.arabic),
                  );
                  final en = _LangOptionCard(
                    isLight: widget.isLight,
                    badge: 'EN',
                    title: 'English',
                    sub: context.l10n.settingsLangEnglishHint,
                    selected: !isArabic,
                    onTap: () => context
                        .read<LocaleCubit>()
                        .setLocale(SupportedLocale.english),
                  );
                  if (isNarrow) {
                    return Column(
                      children: [
                        ar,
                        const SizedBox(height: 10),
                        en,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: ar),
                      const SizedBox(width: 12),
                      Expanded(child: en),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: _kCardGap),

        // ── العرض والأداء ───────────────────────────────────────────
        _SettingsCard(
          isLight: widget.isLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardHeader(
                isLight: widget.isLight,
                title: context.l10n.settingsDisplayPerf,
              ),
              const SizedBox(height: 4),
              _TogglePref(
                isLight: widget.isLight,
                label: context.l10n.settingsCompactView,
                description: context.l10n.settingsCompactViewDesc,
                value: _compactView,
                onChanged: (v) => setState(() => _compactView = v),
              ),
              _PrefDivider(isLight: widget.isLight),
              _TogglePref(
                isLight: widget.isLight,
                label: context.l10n.settingsAutoSave,
                description: context.l10n.settingsAutoSaveDesc,
                value: _autoSave,
                onChanged: (v) => setState(() => _autoSave = v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

