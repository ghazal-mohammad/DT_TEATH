// ════════════════════════════════════════════════════════════════════════════
// warehouse_settings_security_tab.dart
//
// تبويب الأمان — part of warehouse_settings_content.dart (تقسيم الصفحات العملاقة).
// ════════════════════════════════════════════════════════════════════════════

part of 'warehouse_settings_content.dart';

// ══════════════════════════════════════════════════════════════════════════
//  TAB 1 — الأمان
// ══════════════════════════════════════════════════════════════════════════

class _SecurityTabContent extends StatefulWidget {
  const _SecurityTabContent({required this.isLight});
  final bool isLight;

  @override
  State<_SecurityTabContent> createState() => _SecurityTabContentState();
}

class _SecurityTabContentState extends State<_SecurityTabContent> {
  final _currentPass = TextEditingController();
  final _newPass = TextEditingController();
  final _confirmPass = TextEditingController();
  bool _otpEnabled = true;

  @override
  void dispose() {
    _currentPass.dispose();
    _newPass.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── بطاقة 1: تغيير كلمة المرور ─────────────────────────────────
        _SettingsCard(
          isLight: widget.isLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardHeader(
                isLight: widget.isLight,
                title: context.l10n.settingsChangePassword,
                subtitle: context.l10n.settingsChangePasswordDesc,
              ),
              const SizedBox(height: 20),
              AppFormField(
                label: context.l10n.settingsCurrentPassword,
                controller: _currentPass,
                obscureText: true,
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, c) {
                  if (c.maxWidth < 460) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppFormField(
                            label: context.l10n.settingsNewPassword,
                            controller: _newPass,
                            obscureText: true),
                        const SizedBox(height: 14),
                        AppFormField(
                            label: context.l10n.settingsConfirmPassword,
                            controller: _confirmPass,
                            obscureText: true),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: AppFormField(
                            label: context.l10n.settingsNewPassword,
                            controller: _newPass,
                            obscureText: true),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AppFormField(
                            label: context.l10n.settingsConfirmPassword,
                            controller: _confirmPass,
                            obscureText: true),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              // RTL: للنسخة المطلوبة (الأساسي أقصى يسار، الثانوي يمينه)
              // نضع الأساسي آخر child والثانوي قبله.
              // Wrap بدل Row — بعرض ضيق (موبايل) ما بيسع الزرّان جنب بعض
              // بدون overflow، فـ Wrap بينزّل الثاني لسطر جديد بدل ما يفيض.
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  AppButton(
                    label: context.l10n.cancel,
                    onPressed: () {
                      _currentPass.clear();
                      _newPass.clear();
                      _confirmPass.clear();
                    },
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.small,
                  ),
                  AppButton(
                    label: context.l10n.settingsUpdatePassword,
                    onPressed: () {},
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.small,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: _kCardGap),

        // ── بطاقة 2: المصادقة الثنائية ─────────────────────────────────
        _SettingsCard(
          isLight: widget.isLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardHeader(
                isLight: widget.isLight,
                title: context.l10n.settings2FA,
                subtitle: context.l10n.settings2FADesc,
              ),
              const SizedBox(height: 4),
              _TogglePref(
                isLight: widget.isLight,
                label: context.l10n.settings2FAOtpTitle,
                description: context.l10n.settings2FAOtpDesc,
                value: _otpEnabled,
                onChanged: (v) => setState(() => _otpEnabled = v),
              ),
            ],
          ),
        ),

      ],
    );
  }
}

