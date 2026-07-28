// ════════════════════════════════════════════════════════════════════════════
// employee_profile_sidebar.dart
//
// العمود الجانبي + الأفاتار + بطاقات جانبية — part of employee_profile_content.dart (تقسيم الصفحات العملاقة).
// ════════════════════════════════════════════════════════════════════════════

part of 'employee_profile_content.dart';

// ══════════════════════════════════════════════════════════════════════════
//                          العمود الجانبي (sticky)
// ══════════════════════════════════════════════════════════════════════════

class _ProfileSidebar extends StatelessWidget {
  const _ProfileSidebar({
    required this.data,
    required this.editing,
    required this.avatarBytes,
    required this.pickingImage,
    required this.saving,
    required this.onChangePhoto,
    required this.onStartEdit,
    required this.onSaveEdit,
    required this.onCancelEdit,
  });

  final _EmployeeData data;
  final bool editing;
  final Uint8List? avatarBytes;
  final bool pickingImage;
  final bool saving;
  final VoidCallback onChangePhoto;
  final VoidCallback onStartEdit;
  final VoidCallback onSaveEdit;
  final VoidCallback onCancelEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: _Palette.of(context).cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: _Avatar(
              initial: data.fullName.trim().isEmpty
                  ? 'م'
                  : data.fullName.trim().substring(0, 1),
              bytes: avatarBytes,
              imageUrl: data.avatarUrl,
              loading: pickingImage,
              onChangePhoto: onChangePhoto,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            data.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: AppColors.lightText1,
            ),
          ),
          const SizedBox(height: 10),
          Center(child: _RoleBadge(label: data.roleTitle)),
          const SizedBox(height: 10),
          Text(
            data.email,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _Palette.of(context).pinkAccent,
            ),
          ),
          const SizedBox(height: 18),
          _SectionLabelDivider(label: context.l10n.profileGeneralInfo),
          const SizedBox(height: 14),
          _SideMetaCard(
            icon: Icons.event_outlined,
            label: context.l10n.profileHireDate,
            value: data.hireDate,
            tint: AppColors.profileTintBlue,
          ),
          if (data.salary.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _SensitiveMetaCard(
              icon: Icons.payments_outlined,
              label: context.l10n.profileSalary,
              value: _formatSalary(data.salary),
              tint: AppColors.profileTintViolet,
            ),
          ],
          const SizedBox(height: 18),
          _SidebarActions(
            editing: editing,
            saving: saving,
            onStartEdit: onStartEdit,
            onSaveEdit: onSaveEdit,
            onCancelEdit: onCancelEdit,
          ),
        ],
      ),
    );
  }
}

// ── خط فاصل بعنوان في الوسط (— معلومات عامة —) ──────────────────────────────
class _SectionLabelDivider extends StatelessWidget {
  const _SectionLabelDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(height: 1, color: _Palette.of(context).cardBorder),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _Palette.of(context).label,
            ),
          ),
        ),
        Expanded(
          child: Divider(height: 1, color: _Palette.of(context).cardBorder),
        ),
      ],
    );
  }
}

// ── بطاقة معلومة في العمود الجانبي ──────────────────────────────────────────
class _SideMetaCard extends StatelessWidget {
  const _SideMetaCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _Palette.of(context).label,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.lightText1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 17, color: _Palette.of(context).accent),
          ),
        ],
      ),
    );
  }
}

/// بطاقة meta لحقل حسّاس (راتب...) — مُخفاة افتراضيًا بنقاط مع زرّ عين للكشف.
/// خصوصية على الأجهزة المشتركة؛ لا تُخزَّن ولا تُسجَّل — إخفاء عرض فقط.
class _SensitiveMetaCard extends StatefulWidget {
  const _SensitiveMetaCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tint;

  @override
  State<_SensitiveMetaCard> createState() => _SensitiveMetaCardState();
}

class _SensitiveMetaCardState extends State<_SensitiveMetaCard> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final String action = _revealed ? context.l10n.hide : context.l10n.show;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        color: widget.tint,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _Palette.of(context).label,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _revealed ? widget.value : '••••••',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.lightText1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Semantics(
            button: true,
            label: action,
            child: Tooltip(
              message: action,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => setState(() => _revealed = !_revealed),
                  child: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      _revealed
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 17,
                      color: _Palette.of(context).accent,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarActions extends StatelessWidget {
  const _SidebarActions({
    required this.editing,
    required this.saving,
    required this.onStartEdit,
    required this.onSaveEdit,
    required this.onCancelEdit,
  });

  final bool editing;
  final bool saving;
  final VoidCallback onStartEdit;
  final VoidCallback onSaveEdit;
  final VoidCallback onCancelEdit;

  @override
  Widget build(BuildContext context) {
    if (!editing) {
      return _WideButton(
        label: context.l10n.profileEdit,
        icon: Icons.edit_outlined,
        primary: true,
        onTap: onStartEdit,
      );
    }
    return Column(
      children: [
        _WideButton(
          label: saving
              ? context.l10n.profileSaving
              : context.l10n.profileSaveChanges,
          icon: Icons.check_rounded,
          primary: true,
          onTap: saving ? null : onSaveEdit,
        ),
        const SizedBox(height: 8),
        _WideButton(
          label: context.l10n.cancel,
          icon: Icons.close_rounded,
          primary: false,
          onTap: saving ? null : onCancelEdit,
        ),
      ],
    );
  }
}

class _WideButton extends StatelessWidget {
  const _WideButton({
    required this.label,
    required this.icon,
    required this.primary,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = primary ? _Palette.of(context).accent : Colors.white;
    final fg = primary ? Colors.white : AppColors.lightText1;
    final border = primary
        ? _Palette.of(context).accent
        : _Palette.of(context).cardBorder;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      child: Opacity(
        opacity: onTap == null ? 0.7 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatefulWidget {
  const _Avatar({
    required this.initial,
    required this.bytes,
    required this.loading,
    required this.onChangePhoto,
    this.imageUrl = '',
  });

  final String initial;
  final Uint8List? bytes;

  /// رابط صورة من السيرفر (يُعرض لو ما في صورة محلية مختارة).
  final String imageUrl;
  final bool loading;
  final VoidCallback onChangePhoto;

  @override
  State<_Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<_Avatar> {
  String get initial => widget.initial;
  Uint8List? get bytes => widget.bytes;
  String get imageUrl => widget.imageUrl;
  bool get loading => widget.loading;
  VoidCallback get onChangePhoto => widget.onChangePhoto;

  /// خلفية متدرّجة + الحرف الأول — تُعرض لما ما في صورة (أو فشل تحميلها).
  Widget _fallbackLetter() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: _Palette.avatarGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Center(
      child: Text(
        initial,
        style: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 56,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final bool hasLocal = bytes != null;
    final bool hasNetwork = imageUrl.isNotEmpty;
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Semantics(
            button: true,
            image: true,
            label: context.l10n.profileChangePhoto,
            child: GestureDetector(
              onTap: onChangePhoto,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  width: 132,
                  height: 132,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: _Palette.of(
                          context,
                        ).accent.withValues(alpha: 0.24),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: hasLocal
                      ? Image.memory(bytes!, fit: BoxFit.cover)
                      : hasNetwork
                      // webHtmlElementStrategy.fallback: لو حجب الـ CORS جلب
                      // الصورة، تُعرض عبر <img> مباشرة (الويب فقط) بدل الفشل.
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          webHtmlElementStrategy:
                              WebHtmlElementStrategy.fallback,
                          errorBuilder: (_, __, ___) => _fallbackLetter(),
                        )
                      : _fallbackLetter(),
                ),
              ),
            ),
          ),
          if (loading)
            Positioned(
              width: 132,
              height: 132,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.black.withValues(alpha: 0.35),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          // النقطة الخضراء (متصل) أعلى يسار الصورة.
          const Positioned(top: 10, left: 10, child: _OnlineDot()),
          // زر "تغيير الصورة" أسفل وسط الصورة.
          Positioned(
            bottom: 4,
            child: InkWell(
              onTap: loading ? null : onChangePhoto,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _Palette.of(context).accent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.edit_outlined,
                      size: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      context.l10n.profileChangePhoto,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: AppColors.success,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    // بنفسجي-كحلي (لون الدور المعتمد بالتطبيق) — بدل الزهري، بطلب من الفريق.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
