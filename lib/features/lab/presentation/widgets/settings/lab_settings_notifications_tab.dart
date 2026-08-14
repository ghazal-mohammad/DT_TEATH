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
  @override
  Widget build(BuildContext context) {
    final divider = Divider(
      height: 1,
      color: widget.isLight ? AppColors.lightBorder : AppColors.darkBorder,
    );
    final prefs = context.watch<LabSettingsPrefsCubit>().state;
    final cubit = context.read<LabSettingsPrefsCubit>();

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
              value: prefs.urgent,
              onChanged: (v) => cubit.setNotif(LabNotifPref.urgent, v),
              isLight: widget.isLight,
            ),
            divider,
            _ToggleRow(
              title: context.l10n.labSettingsNotifNewFromDoctors,
              subtitle: context.l10n.labSettingsNotifNewFromDoctorsDesc,
              value: prefs.newOrders,
              onChanged: (v) => cubit.setNotif(LabNotifPref.newOrders, v),
              isLight: widget.isLight,
            ),
            divider,
            _ToggleRow(
              title: context.l10n.settingsNotifLowMaterials,
              subtitle: context.l10n.settingsNotifLowMaterialsDesc,
              value: prefs.lowStock,
              onChanged: (v) => cubit.setNotif(LabNotifPref.lowStock, v),
              isLight: widget.isLight,
            ),
            divider,
            _ToggleRow(
              title: context.l10n.labSettingsNotifWarehouseUpdates,
              subtitle: context.l10n.labSettingsNotifWarehouseUpdatesDesc,
              value: prefs.warehouse,
              onChanged: (v) => cubit.setNotif(LabNotifPref.warehouse, v),
              isLight: widget.isLight,
            ),
            divider,
            _ToggleRow(
              title: context.l10n.labSettingsNotifTeamUpdates,
              subtitle: context.l10n.labSettingsNotifTeamUpdatesDesc,
              value: prefs.team,
              onChanged: (v) => cubit.setNotif(LabNotifPref.team, v),
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
              value: prefs.emailSummary,
              onChanged: (v) => cubit.setNotif(LabNotifPref.emailSummary, v),
              isLight: widget.isLight,
            ),
            divider,
            _ToggleRow(
              title: context.l10n.settingsNotifSound,
              subtitle: context.l10n.settingsNotifSoundDesc,
              value: prefs.sounds,
              onChanged: (v) => cubit.setNotif(LabNotifPref.sounds, v),
              isLight: widget.isLight,
            ),
          ]),
        ),
      ],
    );
  }
}

