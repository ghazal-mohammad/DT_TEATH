// ════════════════════════════════════════════════════════════════════════════
// lab_settings_security_tab.dart
//
// تبويب الأمان — part of lab_settings_page.dart (تقسيم الصفحات العملاقة).
// ════════════════════════════════════════════════════════════════════════════

part of '../../pages/lab_settings_page.dart';

// ══════════════════════════════════════════════════════════════════════════
//  SECURITY TAB — الأمان
// ══════════════════════════════════════════════════════════════════════════

class _SecurityTab extends StatefulWidget {
  const _SecurityTab({required this.isLight});
  final bool isLight;

  @override
  State<_SecurityTab> createState() => _SecurityTabState();
}

class _SecurityTabState extends State<_SecurityTab> {
  final TextEditingController _currentPwd = TextEditingController();
  final TextEditingController _newPwd = TextEditingController();
  final TextEditingController _confirmPwd = TextEditingController();
  bool _twoFA = true;

  @override
  void dispose() {
    _currentPwd.dispose();
    _newPwd.dispose();
    _confirmPwd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 1) تغيير كلمة المرور ─────────────────────────────────
        _SettingCard(
          isLight: widget.isLight,
          title: context.l10n.settingsChangePassword,
          subtitle: context.l10n.settingsChangePasswordDesc,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PasswordField(
                label: context.l10n.settingsCurrentPassword,
                controller: _currentPwd,
                isLight: widget.isLight,
              ),
              const SizedBox(height: AppSizes.spaceLG),
              LayoutBuilder(builder: (ctx, c) {
                final wide = c.maxWidth > 520;
                final f1 = _PasswordField(
                  label: context.l10n.settingsNewPassword,
                  controller: _newPwd,
                  isLight: widget.isLight,
                );
                final f2 = _PasswordField(
                  label: context.l10n.settingsConfirmPassword,
                  controller: _confirmPwd,
                  isLight: widget.isLight,
                );
                if (wide) {
                  return Row(children: [
                    Expanded(child: f1),
                    const SizedBox(width: AppSizes.spaceLG),
                    Expanded(child: f2),
                  ]);
                }
                return Column(children: [
                  f1,
                  const SizedBox(height: AppSizes.spaceLG),
                  f2,
                ]);
              }),
              const SizedBox(height: AppSizes.spaceLG),
              // RTL convention: primary (تحديث) في الأقصى يسار، secondary (إلغاء) يمينه.
              // → في الكود: primary ثم secondary بحيث Row first child = يمين بصرياً.
              // المطلوب: primary يسار، فالـ Row يبدأ بـ primary أوّلاً يخلّيه يمين — غلط.
              // الصحيح: secondary أوّل (يصير يمين)، primary آخر (يصير يسار).
              // SingleChildScrollView أفقي بدل Row مباشرة — بعرض ضيق
              // (موبايل) ما بيسع الزرّان جنب بعض بدون overflow، فيتمرّرو
              // أفقياً بدل ما يفيضو (Wrap كبديل بيمدّد بعض أنواع الأزرار
              // لعرض الحاوية كاملاً — راجع الملاحظة بنسخة المستودع).
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _SecondaryButton(
                      label: context.l10n.cancel,
                      isLight: widget.isLight,
                      onTap: () {
                        _currentPwd.clear();
                        _newPwd.clear();
                        _confirmPwd.clear();
                      },
                    ),
                    const SizedBox(width: AppSizes.spaceSM),
                    _PrimaryButton(
                      label: context.l10n.settingsUpdatePassword,
                      icon: Icons.check_rounded,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.spaceLG),

        // ── 2) المصادقة الثنائية ─────────────────────────────────
        _SettingCard(
          isLight: widget.isLight,
          title: context.l10n.settings2FA,
          subtitle: context.l10n.settings2FADesc,
          child: Column(
            children: [
              _ToggleRow(
                title: context.l10n.settings2FAOtpTitle,
                subtitle: context.l10n.settings2FAOtpDesc,
                value: _twoFA,
                onChanged: (v) => setState(() => _twoFA = v),
                isLight: widget.isLight,
              ),
            ],
          ),
        ),

      ],
    );
  }
}

