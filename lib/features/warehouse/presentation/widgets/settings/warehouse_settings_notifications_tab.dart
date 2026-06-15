// ════════════════════════════════════════════════════════════════════════════
// warehouse_settings_notifications_tab.dart
//
// تبويب الإشعارات — part of warehouse_settings_content.dart (تقسيم الصفحات العملاقة).
// ════════════════════════════════════════════════════════════════════════════

part of 'warehouse_settings_content.dart';

// ══════════════════════════════════════════════════════════════════════════
//  TAB 2 — الإشعارات
// ══════════════════════════════════════════════════════════════════════════

class _NotificationsPrefsTabContent extends StatefulWidget {
  const _NotificationsPrefsTabContent({required this.isLight});
  final bool isLight;

  @override
  State<_NotificationsPrefsTabContent> createState() =>
      _NotificationsPrefsTabContentState();
}

class _NotificationsPrefsTabContentState
    extends State<_NotificationsPrefsTabContent> {
  bool _lowStock = true;
  bool _expiry = true;
  bool _newOrders = true;
  bool _supplierDelay = false;
  bool _invoicesDue = true;
  bool _dailyEmail = true;
  bool _systemSound = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── تفضيلات الإشعارات ───────────────────────────────────────
        _SettingsCard(
          isLight: widget.isLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardHeader(
                isLight: widget.isLight,
                title: context.l10n.settingsNotifPrefs,
                subtitle: context.l10n.settingsNotifPrefsDesc,
              ),
              const SizedBox(height: 4),
              _TogglePref(
                isLight: widget.isLight,
                label: context.l10n.settingsNotifLowMaterials,
                description: context.l10n.settingsNotifLowMaterialsDesc,
                value: _lowStock,
                onChanged: (v) => setState(() => _lowStock = v),
              ),
              _PrefDivider(isLight: widget.isLight),
              _TogglePref(
                isLight: widget.isLight,
                label: context.l10n.whNotifExpiry,
                description: context.l10n.whNotifExpiryDesc,
                value: _expiry,
                onChanged: (v) => setState(() => _expiry = v),
              ),
              _PrefDivider(isLight: widget.isLight),
              _TogglePref(
                isLight: widget.isLight,
                label: context.l10n.whNotifNewSupply,
                description: context.l10n.whNotifNewSupplyDesc,
                value: _newOrders,
                onChanged: (v) => setState(() => _newOrders = v),
              ),
              _PrefDivider(isLight: widget.isLight),
              _TogglePref(
                isLight: widget.isLight,
                label: context.l10n.whNotifSupplierDelay,
                description: context.l10n.whNotifSupplierDelayDesc,
                value: _supplierDelay,
                onChanged: (v) => setState(() => _supplierDelay = v),
              ),
              _PrefDivider(isLight: widget.isLight),
              _TogglePref(
                isLight: widget.isLight,
                label: context.l10n.whNotifInvoicesDue,
                description: context.l10n.whNotifInvoicesDueDesc,
                value: _invoicesDue,
                onChanged: (v) => setState(() => _invoicesDue = v),
              ),
            ],
          ),
        ),

        const SizedBox(height: _kCardGap),

        // ── قنوات الإشعار ───────────────────────────────────────────
        _SettingsCard(
          isLight: widget.isLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardHeader(
                isLight: widget.isLight,
                title: context.l10n.settingsNotifChannels,
                subtitle: context.l10n.settingsNotifChannelsDesc,
              ),
              const SizedBox(height: 4),
              _TogglePref(
                isLight: widget.isLight,
                label: context.l10n.settingsNotifDailyEmail,
                description: context.l10n.settingsNotifDailyEmailDesc,
                value: _dailyEmail,
                onChanged: (v) => setState(() => _dailyEmail = v),
              ),
              _PrefDivider(isLight: widget.isLight),
              _TogglePref(
                isLight: widget.isLight,
                label: context.l10n.settingsNotifSound,
                description: context.l10n.settingsNotifSoundDesc,
                value: _systemSound,
                onChanged: (v) => setState(() => _systemSound = v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

