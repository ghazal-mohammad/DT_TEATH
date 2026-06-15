// ════════════════════════════════════════════════════════════════════════════
// lab_settings_notifications_tab.dart
//
// تبويب الإشعارات — part of lab_settings_page.dart (تقسيم الصفحات العملاقة).
// ════════════════════════════════════════════════════════════════════════════

part of '../../pages/lab_settings_page.dart';

// ══════════════════════════════════════════════════════════════════════════
//  NOTIFICATIONS TAB — الإشعارات
// ══════════════════════════════════════════════════════════════════════════

class _NotificationsTab extends StatefulWidget {
  const _NotificationsTab({required this.isLight});
  final bool isLight;

  @override
  State<_NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<_NotificationsTab> {
  bool _urgent = true;
  bool _newOrders = true;
  bool _lowStock = true;
  bool _warehouse = true;
  bool _team = false;
  bool _emailSummary = true;
  bool _sounds = false;

  @override
  Widget build(BuildContext context) {
    final divider = Divider(
      height: 1,
      color: widget.isLight ? AppColors.lightBorder : AppColors.darkBorder,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SettingCard(
          isLight: widget.isLight,
          title: context.l10n.settingsNotifPrefs,
          subtitle: context.l10n.settingsNotifPrefsDesc,
          child: Column(children: [
            _ToggleRow(
              title: context.l10n.labSettingsNotifUrgentOrders,
              subtitle: context.l10n.labSettingsNotifUrgentOrdersDesc,
              value: _urgent,
              onChanged: (v) => setState(() => _urgent = v),
              isLight: widget.isLight,
            ),
            divider,
            _ToggleRow(
              title: context.l10n.labSettingsNotifNewFromDoctors,
              subtitle: context.l10n.labSettingsNotifNewFromDoctorsDesc,
              value: _newOrders,
              onChanged: (v) => setState(() => _newOrders = v),
              isLight: widget.isLight,
            ),
            divider,
            _ToggleRow(
              title: context.l10n.settingsNotifLowMaterials,
              subtitle: context.l10n.settingsNotifLowMaterialsDesc,
              value: _lowStock,
              onChanged: (v) => setState(() => _lowStock = v),
              isLight: widget.isLight,
            ),
            divider,
            _ToggleRow(
              title: context.l10n.labSettingsNotifWarehouseUpdates,
              subtitle: context.l10n.labSettingsNotifWarehouseUpdatesDesc,
              value: _warehouse,
              onChanged: (v) => setState(() => _warehouse = v),
              isLight: widget.isLight,
            ),
            divider,
            _ToggleRow(
              title: context.l10n.labSettingsNotifTeamUpdates,
              subtitle: context.l10n.labSettingsNotifTeamUpdatesDesc,
              value: _team,
              onChanged: (v) => setState(() => _team = v),
              isLight: widget.isLight,
            ),
          ]),
        ),

        const SizedBox(height: AppSizes.spaceLG),

        _SettingCard(
          isLight: widget.isLight,
          title: context.l10n.settingsNotifChannels,
          subtitle: context.l10n.settingsNotifChannelsDesc,
          child: Column(children: [
            _ToggleRow(
              title: context.l10n.settingsNotifDailyEmail,
              subtitle: context.l10n.settingsNotifDailyEmailDesc,
              value: _emailSummary,
              onChanged: (v) => setState(() => _emailSummary = v),
              isLight: widget.isLight,
            ),
            divider,
            _ToggleRow(
              title: context.l10n.settingsNotifSound,
              subtitle: context.l10n.settingsNotifSoundDesc,
              value: _sounds,
              onChanged: (v) => setState(() => _sounds = v),
              isLight: widget.isLight,
            ),
          ]),
        ),
      ],
    );
  }
}

