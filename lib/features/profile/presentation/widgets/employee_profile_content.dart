// ════════════════════════════════════════════════════════════════════════════
// employee_profile_content.dart
//
// محتوى الملف الشخصي الموحّد للموظف (مخبر + مستودع) — تصميم بعمودين.
// المصدر: تصميم المخبر المعتمد كمرجع لتوحيد النظامين.
//
// البنية:
//   • عمود جانبي (يمين، sticky): صورة + اسم + شارة الدور + بريد + بطاقة
//     "معلومات عامة" (تاريخ التوظيف/اللغات/ملاحظات) + شريط اكتمال الملف +
//     زر "تعديل الملف الشخصي".
//   • عمود رئيسي (يسار، قابل للسكرول وحده): 3 بطاقات إحصائية +
//     المعلومات الشخصية + المعلومات الوظيفية (شبكة بطاقات بشريط لوني جانبي).
//
// الربط بالباك إند محفوظ كما هو: ProfileCubit (showProfile / editProfile).
// التعديل Inline: زر التعديل يحوّل قيم الشبكة إلى حقول قابلة للتعديل.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/auth/auth_models.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/forms/app_form_select.dart';
import '../../domain/entities/edit_profile_payload.dart';
import '../../domain/entities/employee_profile.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/utils/app_date.dart';
import '../../../../shared/widgets/feedback/glass_toast.dart';
import '../bloc/profile_cubit.dart';

// ══════════════════════════════════════════════════════════════════════════
//                         نظام الألوان الخاص بالمخبر
// ══════════════════════════════════════════════════════════════════════════

class _Palette {
  static const Color accent = AppColors.primary; // navy
  static const List<Color> avatarGradient = [Color(0xFF2E3270), Color(0xFF14163F)];

  // حبّتا البطاقات الملوّنة (تتبادل أزرق/وردي كل صفّين).
  static const Color blueIconBg = Color(0xFFE3ECFA);
  static const Color blueAccent = Color(0xFF2E48B5);

  static const Color pinkBg = Color(0xFFFBEFF5);
  static const Color pinkIconBg = Color(0xFFF7E1EC);
  static const Color pinkAccent = Color(0xFFC03E7C);

  // ألوان محايدة.
  static const Color cardBorder = Color(0xFFE7EBF3);
  static const Color label = Color(0xFF8A93A7);
}

// ══════════════════════════════════════════════════════════════════════════
//                              DATA MODEL
// ══════════════════════════════════════════════════════════════════════════

class _EmployeeData {
  String fullName;
  String roleTitle; // شارة الدور (مدير المخبر — مطابق لـ UserRole في الباك)
  String email;
  String phone;
  String nationalId;
  String birthDate;
  String gender;
  String address;
  String employeeId;
  String department;
  String position;
  String workDays;
  String dayOff;
  String weeklyHours;
  String hireDate;
  String languages;
  String adminNotes;
  int completion;

  // حقول حقيقية من الباك (showProfile)
  String secondaryPhone;
  String maritalStatus;
  String salary;
  String avatarUrl;
  List<Education> educations;
  List<Experience> experiences;
  List<Training> trainings;
  List<String> skills;

  _EmployeeData({
    required this.fullName,
    required this.roleTitle,
    required this.email,
    required this.phone,
    required this.nationalId,
    required this.birthDate,
    required this.gender,
    required this.address,
    required this.employeeId,
    required this.department,
    required this.position,
    required this.workDays,
    required this.dayOff,
    required this.weeklyHours,
    required this.hireDate,
    required this.languages,
    required this.adminNotes,
    required this.completion,
    this.secondaryPhone = '',
    this.maritalStatus = '',
    this.salary = '',
    this.avatarUrl = '',
    this.educations = const [],
    this.experiences = const [],
    this.trainings = const [],
    this.skills = const [],
  });

  static _EmployeeData mockData() => _EmployeeData(
        fullName: 'رامي الصالح',
        roleTitle: 'مدير المخبر',
        email: 'rami@dt-teeth.com',
        phone: '0991234567',
        nationalId: '01010101234',
        birthDate: '1990 / 06 / 15',
        gender: 'ذكر',
        address: '',
        employeeId: 'LAB-2026-007',
        department: 'مخبر التعويضات السنية',
        position: 'مدير المخبر',
        workDays: 'السبت - الخميس',
        dayOff: 'الجمعة',
        weeklyHours: '48 ساعة',
        hireDate: 'يناير 2024',
        languages: 'العربية، الإنجليزية',
        adminNotes: 'مشرف ممتاز وملتزم بالمواعيد',
        completion: 100,
      );

  _EmployeeData copy() => _EmployeeData(
        fullName: fullName,
        roleTitle: roleTitle,
        email: email,
        phone: phone,
        nationalId: nationalId,
        birthDate: birthDate,
        gender: gender,
        address: address,
        employeeId: employeeId,
        department: department,
        position: position,
        workDays: workDays,
        dayOff: dayOff,
        weeklyHours: weeklyHours,
        hireDate: hireDate,
        languages: languages,
        adminNotes: adminNotes,
        completion: completion,
        secondaryPhone: secondaryPhone,
        maritalStatus: maritalStatus,
        salary: salary,
        avatarUrl: avatarUrl,
        educations: educations,
        experiences: experiences,
        trainings: trainings,
        skills: skills,
      );
}

// ══════════════════════════════════════════════════════════════════════════
//                              MAIN CONTENT
// ══════════════════════════════════════════════════════════════════════════

class EmployeeProfileContent extends StatefulWidget {
  const EmployeeProfileContent({super.key});

  @override
  State<EmployeeProfileContent> createState() => _EmployeeProfileContentState();
}

class _EmployeeProfileContentState extends State<EmployeeProfileContent> {
  late _EmployeeData _data;
  _EmployeeData? _draft;
  bool _editing = false;

  Uint8List? _avatarBytes;
  bool _pickingImage = false;

  // الربط بالباك إند — ProfileCubit (مشترك مخبر/مستودع).
  late final ProfileCubit _cubit;
  bool _savingEdit = false;

  final ScrollController _mainCtrl = ScrollController();
  final ScrollController _narrowCtrl = ScrollController();
  final ScrollController _sideCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _data = _EmployeeData.mockData();
    _cubit = sl<ProfileCubit>()..load();
  }

  @override
  void dispose() {
    _cubit.close();
    _mainCtrl.dispose();
    _narrowCtrl.dispose();
    _sideCtrl.dispose();
    super.dispose();
  }

  // ── مزامنة بيانات الخادم → نموذج الواجهة (مع الحفاظ على التصميم كما هو) ──
  void _onCubitState(BuildContext context, ProfileState state) {
    if (state.status == ProfileStatus.loaded && state.profile != null) {
      final wasSaving = _savingEdit;
      setState(() {
        _data = _mergeFromProfile(context.l10n, _data, state.profile!);
        if (wasSaving) {
          _editing = false;
          _draft = null;
        }
        _savingEdit = false;
      });
      if (wasSaving) {
        GlassToast.show(
          context,
          message: context.l10n.profileSavedSuccess,
          icon: Icons.check_circle_rounded,
        );
      }
    } else if (state.status == ProfileStatus.error && _savingEdit) {
      _savingEdit = false;
      GlassToast.show(
        context,
        message: state.errorMessage ?? context.l10n.profileSaveError,
        icon: Icons.error_outline_rounded,
      );
    }
  }

  /// دمج بيانات الخادم فوق النموذج الحالي. الحقول التي لا يوفّرها الباك في
  /// showProfile تبقى كما هي (placeholder تصميمي).
  _EmployeeData _mergeFromProfile(
      AppLocalizations l10n, _EmployeeData base, EmployeeProfile p) {
    final c = base.copy();
    if (p.name.isNotEmpty) c.fullName = p.name;
    if (p.email.isNotEmpty) c.email = p.email;
    if (p.phone.isNotEmpty) c.phone = p.phone;
    c.roleTitle = _rolePosition(l10n, p.role);
    c.position = _rolePosition(l10n, p.role);
    if (p.hireDate.isNotEmpty) c.hireDate = AppDate.display(p.hireDate);
    // الجنس الراجع من الباك (نص أو 1/2) → نطبّعه لقيمة الـ dropdown.
    if (p.gender.trim().isNotEmpty) {
      final g = p.gender.trim().toLowerCase();
      if (g == '1' || g == 'male' || g.contains('ذكر')) {
        c.gender = 'ذكر';
      } else if (g == '2' || g == 'female' || g.contains('أنثى') || g.contains('انثى')) {
        c.gender = 'أنثى';
      }
    }
    // العنوان وتاريخ الميلاد (يظهران فور إضافتهما لردّ showProfile بالباك).
    if (p.address.isNotEmpty) c.address = p.address;
    if (p.dateOfBirth.isNotEmpty) c.birthDate = AppDate.display(p.dateOfBirth);
    // حقول حقيقية إضافية من الباك.
    c.secondaryPhone = p.secondaryPhone;
    c.maritalStatus = _maritalToAr(p.maritalStatus);
    c.salary = p.salary;
    if (p.profilePicture.isNotEmpty) {
      c.avatarUrl = _resolvePictureUrl(p.profilePicture);
    }
    c.educations = p.educations;
    c.experiences = p.experiences;
    c.trainings = p.trainings;
    c.skills = p.skills;
    return c;
  }

  // ترجمة دور الموظف للعرض (القيمة المرسلة للباك تبقى عبر enum منفصل).
  static String _rolePosition(AppLocalizations l10n, EmployeeRole r) =>
      switch (r) {
        EmployeeRole.labManager => l10n.roleLabManager,
        EmployeeRole.warehouseManager => l10n.roleWarehouseManager,
        EmployeeRole.admin => l10n.roleAdmin,
        _ => l10n.roleEmployee,
      };

  Future<void> _pickAvatar() async {
    if (_pickingImage) return;
    setState(() => _pickingImage = true);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked == null) {
        if (mounted) setState(() => _pickingImage = false);
        return;
      }
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _avatarBytes = bytes;
        _pickingImage = false;
      });
      GlassToast.show(
        context,
        message: context.l10n.profilePhotoUpdated,
        icon: Icons.check_circle_rounded,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _pickingImage = false);
      GlassToast.show(
        context,
        message: context.l10n.profilePhotoError(e),
        icon: Icons.error_outline_rounded,
      );
    }
  }

  void _startEdit() {
    setState(() {
      _draft = _data.copy();
      _editing = true;
    });
  }

  void _cancelEdit() {
    setState(() {
      _draft = null;
      _editing = false;
    });
  }

  void _saveEdit() {
    if (_draft == null || _savingEdit) return;
    final d = _draft!;
    // الحقول التي يقبلها الباك ويمكن إرسالها بأمان: name, phone, address,
    // gender(1|2), profile_picture. (تاريخ الميلاد نص حرّ فلا يُرسل تفادياً
    // لرفض الـ validation على نوع date.)
    final payload = EditProfilePayload(
      name: d.fullName,
      phone: d.phone,
      address: d.address,
      secondaryPhone: d.secondaryPhone,
      maritalStatus: _maritalToApi(d.maritalStatus),
      imageBytes: _avatarBytes,
      imageFilename: 'profile_picture.jpg',
    );
    setState(() {
      _data = d;
      _savingEdit = true;
    });
    _cubit.save(payload);
  }

  _EmployeeData get _current => _editing ? _draft! : _data;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      bloc: _cubit,
      listener: _onCubitState,
      builder: (context, state) {
        // نعرض المحتوى فوراً ببيانات placeholder (_data) ونُحدّثه لمّا يرجع
        // الباك عبر الـ listener — بدون حجب الصفحة بـ spinner لانهائي لو
        // تأخّر/فشل طلب showProfile (شائع على الويب بسبب CORS).
        return _buildContent(context);
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final isWide = c.maxWidth >= 900;

      final sidebar = _ProfileSidebar(
        data: _current,
        editing: _editing,
        avatarBytes: _avatarBytes,
        pickingImage: _pickingImage,
        saving: _savingEdit,
        onChangePhoto: _pickAvatar,
        onStartEdit: _startEdit,
        onSaveEdit: _saveEdit,
        onCancelEdit: _cancelEdit,
      );

      final main = _MainColumn(
        data: _current,
        editing: _editing,
      );

      if (isWide) {
        // العمود الجانبي ثابت (لا يسكرول)، العمود الرئيسي وحده يسكرول.
        // مهم: ما منلف كلشي بـ Padding خارجي — منخلّي الـ padding جوّا الـ
        // ScrollView لحتى السكرول‌بار يطلع على حافة الـ viewport (متل الإشعارات).
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العمود الجانبي ثابت (لا يتحرك مع سكرول المحتوى)، لكن نمنحه
            // سكرول داخلياً ليتفادى overflow إن زاد ارتفاعه عن الشاشة.
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(22, 22, 20, 22),
              child: SizedBox(
                width: 340,
                child: SingleChildScrollView(
                  controller: _sideCtrl,
                  child: sidebar,
                ),
              ),
            ),
            Expanded(
              child: Scrollbar(
                controller: _mainCtrl,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _mainCtrl,
                  physics: const AlwaysScrollableScrollPhysics(),
                  // الـ padding جوّا → المحتوى منزاح عن السكرول‌بار،
                  // والسكرول‌بار على حافة الواجهة.
                  padding: const EdgeInsetsDirectional.fromSTEB(8, 22, 22, 22),
                  child: main,
                ),
              ),
            ),
          ],
        );
      }

      // ضيّق: سكرول واحد كامل، الجانبي فوق ثم المحتوى.
      return Scrollbar(
        controller: _narrowCtrl,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _narrowCtrl,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              sidebar,
              const SizedBox(height: 18),
              main,
            ],
          ),
        ),
      );
    });
  }
}

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
        border: Border.all(color: _Palette.cardBorder),
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
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _Palette.pinkAccent,
            ),
          ),
          const SizedBox(height: 18),
          _SectionLabelDivider(label: context.l10n.profileGeneralInfo),
          const SizedBox(height: 14),
          _SideMetaCard(
            icon: Icons.event_outlined,
            label: context.l10n.profileHireDate,
            value: data.hireDate,
            tint: const Color(0xFFEFF2FA),
          ),
          if (data.salary.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _SideMetaCard(
              icon: Icons.payments_outlined,
              label: 'الراتب',
              value: _formatSalary(data.salary),
              tint: const Color(0xFFF4EEFB),
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
        const Expanded(child: Divider(height: 1, color: _Palette.cardBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _Palette.label,
            ),
          ),
        ),
        const Expanded(child: Divider(height: 1, color: _Palette.cardBorder)),
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
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _Palette.label,
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
            child: Icon(icon, size: 17, color: _Palette.accent),
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
          label: saving ? context.l10n.profileSaving : context.l10n.profileSaveChanges,
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
    final bg = primary ? _Palette.accent : Colors.white;
    final fg = primary ? Colors.white : AppColors.lightText1;
    final border = primary ? _Palette.accent : _Palette.cardBorder;
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
          GestureDetector(
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
                      color: _Palette.accent.withValues(alpha: 0.24),
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
                            errorBuilder: (_, __, ___) =>
                                _fallbackLetter(),
                          )
                        : _fallbackLetter(),
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
          const Positioned(
            top: 10,
            left: 10,
            child: _OnlineDot(),
          ),
          // زر "تغيير الصورة" أسفل وسط الصورة.
          Positioned(
            bottom: 4,
            child: InkWell(
              onTap: loading ? null : onChangePhoto,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: _Palette.accent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.edit_outlined, size: 13, color: Colors.white),
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

// ══════════════════════════════════════════════════════════════════════════
//                          العمود الرئيسي
// ══════════════════════════════════════════════════════════════════════════

class _MainColumn extends StatelessWidget {
  const _MainColumn({
    required this.data,
    required this.editing,
  });

  final _EmployeeData data;
  final bool editing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StatsRow(),
        const SizedBox(height: 18),
        _InfoSection(
          icon: Icons.person_outline_rounded,
          title: context.l10n.profilePersonalInfo,
          subtitle: context.l10n.profilePersonalInfoSubtitle,
          editing: editing,
          fields: [
            _RowSpec(
              icon: Icons.phone_outlined,
              label: context.l10n.profilePhone,
              value: data.phone,
              onChanged: (v) => data.phone = v,
            ),
            _RowSpec(
              icon: Icons.phone_in_talk_outlined,
              label: 'الهاتف الثانوي',
              value: data.secondaryPhone,
              onChanged: (v) => data.secondaryPhone = v,
            ),
            // الجنس وتاريخ الميلاد بيانات ثابتة — تُعرض ولا يعدّلها الموظف.
            _RowSpec(
              icon: Icons.wc_outlined,
              label: context.l10n.profileGender,
              value: data.gender,
              onChanged: (v) => data.gender = v,
              editable: false,
            ),
            if (data.birthDate.trim().isNotEmpty)
              _RowSpec(
                icon: Icons.calendar_month_outlined,
                label: context.l10n.profileBirthDate,
                value: data.birthDate,
                onChanged: (v) => data.birthDate = v,
                editable: false,
              ),
            _RowSpec(
              icon: Icons.favorite_outline_rounded,
              label: 'الحالة الاجتماعية',
              value: data.maritalStatus,
              onChanged: (v) => data.maritalStatus = v,
              options: const ['أعزب', 'متزوج', 'مطلّق', 'أرمل'],
            ),
            _RowSpec(
              icon: Icons.location_on_outlined,
              label: context.l10n.profileAddress,
              value: data.address,
              onChanged: (v) => data.address = v,
            ),
          ],
        ),
        // ── أقسام حقيقية من الباك (showProfile) ──────────────────────────
        if (data.educations.isNotEmpty) ...[
          const SizedBox(height: 18),
          _RelationSection(
            icon: Icons.school_outlined,
            title: 'الشهادات العلمية',
            items: [
              for (final e in data.educations)
                _RelationItem(
                  primary: e.degree,
                  secondary: e.institution,
                  trailing: [
                    AppDate.display(e.completionDate, fallback: ''),
                    e.grade,
                  ].where((x) => x.isNotEmpty).join(' · '),
                ),
            ],
          ),
        ],
        if (data.experiences.isNotEmpty) ...[
          const SizedBox(height: 18),
          _RelationSection(
            icon: Icons.work_history_outlined,
            title: 'الخبرات العملية',
            items: [
              for (final x in data.experiences)
                _RelationItem(
                  primary: x.title,
                  secondary: x.company,
                  trailing:
                      '${AppDate.display(x.startDate, fallback: '?')} — ${AppDate.display(x.endDate, fallback: 'الآن')}',
                ),
            ],
          ),
        ],
        if (data.trainings.isNotEmpty) ...[
          const SizedBox(height: 18),
          _RelationSection(
            icon: Icons.military_tech_outlined,
            title: 'الدورات التدريبية',
            items: [
              for (final t in data.trainings)
                _RelationItem(
                  primary: t.courseTitle,
                  secondary: t.trainer,
                  trailing: AppDate.display(t.courseDate, fallback: ''),
                ),
            ],
          ),
        ],
        if (data.skills.isNotEmpty) ...[
          const SizedBox(height: 18),
          _SkillsSection(skills: data.skills),
        ],
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                  أقسام علائقية (شهادات/خبرات/تدريبات/مهارات)
// ══════════════════════════════════════════════════════════════════════════

/// بناء رابط صورة البروفايل الكامل من قيمة الباك.
/// الباك يرجّع مساراً نسبياً مثل "profile_pictures/xxx.jpg" (يُخدَم عبر
/// /storage/ بعد storage:link)، أو URL كاملاً مبنياً بـ asset().
String _resolvePictureUrl(String raw) {
  final v = raw.trim().replaceAll(r'\', '/');
  if (v.isEmpty) return '';
  if (v.startsWith('http://') || v.startsWith('https://')) {
    // الباك يبني الرابط بـ asset() مع APP_URL=http://localhost (بدون :8000)
    // فيشاور Apache بدل Laravel → 404. نعيد كتابة المضيف على baseUrl الصحيح
    // مع الإبقاء على المسار كما هو.
    final uri = Uri.tryParse(v);
    if (uri == null) return v;
    final bool wrongLocalHost =
        (uri.host == 'localhost' || uri.host == '127.0.0.1') &&
            !v.startsWith(AppUrls.baseUrl);
    if (!wrongLocalHost) return v;
    final base = Uri.parse(AppUrls.baseUrl);
    return uri
        .replace(scheme: base.scheme, host: base.host, port: base.port)
        .toString();
  }
  final path = v.startsWith('/') ? v.substring(1) : v;
  return '${AppUrls.baseUrl}/storage/$path';
}

/// تنسيق الراتب: "1800000.00" → "1,800,000 ل.س".
String _formatSalary(String raw) {
  var s = raw.trim();
  final dot = s.indexOf('.');
  if (dot != -1) s = s.substring(0, dot);
  final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return raw;
  final buf = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return '$buf ل.س';
}

/// تحويل الحالة الاجتماعية من رمز الباك (إنجليزي) لعربي للعرض.
String _maritalToAr(String en) {
  switch (en.trim().toLowerCase()) {
    case 'single':
      return 'أعزب';
    case 'married':
      return 'متزوج';
    case 'divorced':
      return 'مطلّق';
    case 'widowed':
      return 'أرمل';
    default:
      return en;
  }
}

/// عكس [_maritalToAr]: من العربي لرمز الباك (للإرسال).
String? _maritalToApi(String ar) {
  switch (ar.trim()) {
    case 'أعزب':
      return 'single';
    case 'متزوج':
      return 'married';
    case 'مطلّق':
      return 'divorced';
    case 'أرمل':
      return 'widowed';
    default:
      return null;
  }
}

class _RelationItem {
  const _RelationItem({
    required this.primary,
    required this.secondary,
    required this.trailing,
  });
  final String primary;
  final String secondary;
  final String trailing;
}

class _RelationSection extends StatelessWidget {
  const _RelationSection({
    required this.icon,
    required this.title,
    required this.items,
  });

  final IconData icon;
  final String title;
  final List<_RelationItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: _Palette.cardBorder),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _Palette.blueIconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 19, color: _Palette.blueAccent),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightText1,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _Palette.blueIconBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${items.length}',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _Palette.blueAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _RelationRow(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _RelationRow extends StatelessWidget {
  const _RelationRow({required this.item});
  final _RelationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: _Palette.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: _Palette.blueAccent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.primary,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.lightText1,
                  ),
                ),
                if (item.secondary.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.secondary,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _Palette.label,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (item.trailing.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              item.trailing,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _Palette.blueAccent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SkillsSection extends StatelessWidget {
  const _SkillsSection({required this.skills});
  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: _Palette.cardBorder),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _Palette.pinkBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome_outlined,
                    size: 19, color: _Palette.pinkAccent),
              ),
              const SizedBox(width: 10),
              const Text(
                'المهارات',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightText1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in skills)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: _Palette.pinkBg,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    border: Border.all(
                        color: _Palette.pinkAccent.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    s,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _Palette.pinkAccent,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                          بطاقات الإحصاء
// ══════════════════════════════════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    // الترتيب في RTL: أول عنصر = أقصى اليمين. لمطابقة الموك أب
    // (96% أقصى اليسار، 142 أقصى اليمين) نضع 142 أولاً ثم 2.4 ثم 96.
    final stats = [
      _StatSpec(
        value: '142',
        unit: '',
        label: context.l10n.profileStatCompletedOrders,
        badge: context.l10n.profileBadgeThisMonth,
        icon: Icons.check_circle_outline_rounded,
        accent: const Color(0xFF12A150),
        bg: AppColors.statusSuccessBg,
      ),
      _StatSpec(
        value: '2.4',
        unit: 'س',
        label: context.l10n.profileStatExecTime,
        badge: context.l10n.profileBadgeAverage,
        icon: Icons.schedule_rounded,
        accent: AppColors.statusProgress,
        bg: const Color(0xFFF4ECFB),
      ),
      _StatSpec(
        value: '96',
        unit: '%',
        label: context.l10n.profileStatOnTime,
        badge: '2%+',
        icon: Icons.star_border_rounded,
        accent: const Color(0xFF2E48B5),
        bg: const Color(0xFFEFF3FD),
      ),
    ];

    return LayoutBuilder(builder: (context, c) {
      final isNarrow = c.maxWidth < 560;
      if (isNarrow) {
        return Column(
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              _StatCard(spec: stats[i]),
              if (i < stats.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      }
      // IntrinsicHeight يمنح الصفّ ارتفاعاً محدوداً → stretch آمن لتساوي
      // ارتفاع البطاقات (بدون IntrinsicHeight يصبح القيد عمودياً غير محدود
      // داخل سكرول عمودي فيُرمى خطأ "infinite height").
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              Expanded(child: _StatCard(spec: stats[i])),
              if (i < stats.length - 1) const SizedBox(width: 14),
            ],
          ],
        ),
      );
    });
  }
}

class _StatSpec {
  const _StatSpec({
    required this.value,
    required this.unit,
    required this.label,
    required this.badge,
    required this.icon,
    required this.accent,
    required this.bg,
  });
  final String value;
  final String unit;
  final String label;
  final String badge;
  final IconData icon;
  final Color accent;
  final Color bg;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.spec});
  final _StatSpec spec;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: spec.bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: spec.accent.withValues(alpha: 0.14)),
      ),
      child: Stack(
        children: [
          // خط جانبي ملوّن على الحافة اليسرى (مطابق للتصميم).
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: Container(width: 4, color: spec.accent),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // RTL: أول عنصر = اليمين → أيقونة.
                    Container(
                      width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(spec.icon, size: 20, color: spec.accent),
              ),
              // الطرف الآخر (اليسار) → شارة صغيرة.
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: spec.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  spec.badge,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: spec.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // القيمة + الوحدة (LTR لعرض الأرقام بشكل سليم) محاذاة لليمين.
          Align(
            alignment: Alignment.centerRight,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    spec.value,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      color: AppColors.lightText1,
                    ),
                  ),
                  if (spec.unit.isNotEmpty) ...[
                    const SizedBox(width: 2),
                    Text(
                      spec.unit,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.lightText1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
                const SizedBox(height: 3),
                Text(
                  spec.label,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _Palette.label,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                       قسم المعلومات (شبكة بطاقات بشريط جانبي)
// ══════════════════════════════════════════════════════════════════════════

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.editing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<_RowSpec> fields;
  final bool editing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: _Palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: _Palette.accent),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.lightText1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _Palette.label,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, c) {
            const gap = 12.0;
            final twoCols = c.maxWidth >= 460;
            final itemWidth = twoCols ? (c.maxWidth - gap) / 2 : c.maxWidth;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0; i < fields.length; i++)
                  SizedBox(
                    // الحقل الأخير الفردي يمتد لكامل العرض.
                    width: (i == fields.length - 1 && fields.length.isOdd)
                        ? c.maxWidth
                        : itemWidth,
                    child: _FieldPill(
                      spec: fields[i],
                      editing: editing,
                      // تبادُل الألوان أزرق/وردي كل صفّين.
                      pink: (i ~/ 2).isOdd,
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _RowSpec {
  _RowSpec({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.options,
    this.isDate = false,
    this.editable = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  /// لو موجودة، يُعرض الحقل كقائمة منسدلة (بدل إدخال نصّي حر) عند التعديل.
  final List<String>? options;

  /// لو true، يُعرض كحقل تاريخ يفتح Date Picker عند الضغط (بدل إدخال حر).
  final bool isDate;

  /// لو false، الحقل للقراءة فقط (يديره الأدمن/السكرتيرة أو ثابت) — لا يُعدَّل
  /// من الموظف حتى بوضع التعديل. يطابق عقد editProfile بالباك.
  final bool editable;
}

class _FieldPill extends StatefulWidget {
  const _FieldPill({
    required this.spec,
    required this.editing,
    required this.pink,
  });

  final _RowSpec spec;
  final bool editing;
  final bool pink;

  @override
  State<_FieldPill> createState() => _FieldPillState();
}

class _FieldPillState extends State<_FieldPill> {
  late TextEditingController _controller;

  /// عرض محلي لحقل التاريخ بعد اختيار من الـ Date Picker (يطغى على spec.value).
  String? _dateDisplay;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.spec.value);
  }

  @override
  void didUpdateWidget(_FieldPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.editing != widget.editing) {
      _controller.text = widget.spec.value;
      _dateDisplay = null;
    }
  }

  Future<void> _pickDate(Color accent) async {
    final current = _dateDisplay ?? widget.spec.value;
    DateTime initial = DateTime(2000, 1, 1);
    final api = AppDate.toApi(current);
    if (api != null) {
      final parsed = DateTime.tryParse(api);
      if (parsed != null) initial = parsed;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    final iso =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    final shown = AppDate.display(iso);
    setState(() => _dateDisplay = shown);
    widget.spec.onChanged(shown);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.pink ? _Palette.pinkAccent : _Palette.blueAccent;
    final iconBg = widget.pink ? _Palette.pinkIconBg : _Palette.blueIconBg;

    // نستخدم Stack بدلاً من IntrinsicHeight: الشريط اللوني يتمدّد عمودياً عبر
    // Positioned (top/bottom:0) فيأخذ ارتفاع المحتوى تلقائياً — وهذا يتفادى
    // رمي IntrinsicHeight لخطأ عند احتواء TextField أثناء التعديل.
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: _Palette.cardBorder),
      ),
      child: Stack(
        children: [
          // الشريط اللوني على الطرف الأيسر (يمتد لكامل الارتفاع).
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: Container(width: 4, color: accent),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.spec.icon, size: 18, color: accent),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.spec.label,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _Palette.label,
                            ),
                          ),
                          // قفل صغير للحقول غير القابلة للتعديل (عند وضع التعديل).
                          if (widget.editing && !widget.spec.editable) ...[
                            const SizedBox(width: 5),
                            const Icon(Icons.lock_outline_rounded,
                                size: 11, color: _Palette.label),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (widget.editing &&
                          widget.spec.editable &&
                          widget.spec.isDate)
                        GestureDetector(
                          onTap: () => _pickDate(accent),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 9),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F9FC),
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSM),
                              border:
                                  Border.all(color: _Palette.cardBorder),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    (_dateDisplay ?? widget.spec.value)
                                            .trim()
                                            .isEmpty
                                        ? 'اختر التاريخ'
                                        : (_dateDisplay ?? widget.spec.value),
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: (_dateDisplay ?? widget.spec.value)
                                              .trim()
                                              .isEmpty
                                          ? _Palette.label
                                          : AppColors.lightText1,
                                    ),
                                  ),
                                ),
                                Icon(Icons.calendar_month_rounded,
                                    size: 18, color: accent),
                              ],
                            ),
                          ),
                        )
                      else if (widget.editing &&
                          widget.spec.editable &&
                          widget.spec.options != null)
                        AppDropdownMenuTheme(
                          child: DropdownButtonFormField<String>(
                          initialValue: widget.spec.options!
                                  .contains(widget.spec.value)
                              ? widget.spec.value
                              : null,
                          isDense: true,
                          isExpanded: true,
                          icon: Icon(Icons.keyboard_arrow_down_rounded,
                              size: 20, color: accent),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusLG),
                          dropdownColor: Colors.white,
                          elevation: 3,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.lightText1,
                          ),
                          items: widget.spec.options!
                              .map((o) => DropdownMenuItem<String>(
                                    value: o,
                                    child: Text(
                                      o,
                                      style: const TextStyle(
                                        fontFamily: AppTextStyles.fontFamily,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.lightText1,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) widget.spec.onChanged(v);
                          },
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            filled: true,
                            fillColor: const Color(0xFFF7F9FC),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSM),
                              borderSide:
                                  const BorderSide(color: _Palette.cardBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSM),
                              borderSide: BorderSide(color: accent, width: 1.6),
                            ),
                          ),
                        ),
                        )
                      else if (widget.editing && widget.spec.editable)
                        TextField(
                          controller: _controller,
                          onChanged: widget.spec.onChanged,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.lightText1,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            filled: true,
                            fillColor: const Color(0xFFF7F9FC),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSM),
                              borderSide:
                                  const BorderSide(color: _Palette.cardBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSM),
                              borderSide: BorderSide(color: accent, width: 1.6),
                            ),
                          ),
                        )
                      else
                        Text(
                          widget.spec.value,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.lightText1,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                       حالات التحميل / الخطأ (الربط بالباك)
// ══════════════════════════════════════════════════════════════════════════

class _ProfileCenterLoader extends StatelessWidget {
  const _ProfileCenterLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: SizedBox(
          width: 34,
          height: 34,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(_Palette.accent),
          ),
        ),
      ),
    );
  }
}

class _ProfileCenterError extends StatelessWidget {
  const _ProfileCenterError({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 44, color: AppColors.lightText4),
            const SizedBox(height: 12),
            Text(
              message ?? context.l10n.profileLoadError,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.lightText2,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: onRetry,
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: _Palette.accent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      context.l10n.retry,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
