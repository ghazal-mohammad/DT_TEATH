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
import '../../../../shared/widgets/loading/app_shimmer_card.dart';
import '../bloc/profile_cubit.dart';

part 'employee_profile_sidebar.dart';
part 'employee_profile_main_column.dart';
part 'employee_profile_info_stats.dart';

// ══════════════════════════════════════════════════════════════════════════
//                         نظام الألوان الخاص بالمخبر
// ══════════════════════════════════════════════════════════════════════════

/// باليتة الملف الشخصي — واعية بالوضع (فاتح/غامق).
/// تُجلب عبر `_Palette.of(isLight)`؛ الوضع الغامق يستخدم توكنات AppColors
/// الموحّدة (نفس باليتة باقي النظام) فيتّسق الملف الشخصي مع كل الشاشات.
class _Palette {
  const _Palette._({
    required this.accent,
    required this.blueIconBg,
    required this.blueAccent,
    required this.pinkBg,
    required this.pinkIconBg,
    required this.pinkAccent,
    required this.cardBorder,
    required this.label,
  });

  final Color accent;
  final Color blueIconBg;
  final Color blueAccent;
  final Color pinkBg;
  final Color pinkIconBg;
  final Color pinkAccent;
  final Color cardBorder;
  final Color label;

  /// تدرّج الأفاتار (كحلي — يصلح للوضعين، لا يتبدّل).
  static const List<Color> avatarGradient = [
    AppColors.profileAvatarGradTop,
    AppColors.profileAvatarGradBottom,
  ];

  static const _Palette _light = _Palette._(
    accent: AppColors.primary, // navy
    blueIconBg: AppColors.profileBlueIconBg,
    blueAccent: AppColors.profileBlueAccent,
    pinkBg: AppColors.profilePinkBg,
    pinkIconBg: AppColors.profilePinkIconBg,
    pinkAccent: AppColors.profilePinkAccent,
    cardBorder: AppColors.profileCardBorder,
    label: AppColors.profileLabel,
  );

  static const _Palette _dark = _Palette._(
    accent: AppColors.brand, // إندِغو البراند للوضع الغامق
    blueIconBg: AppColors.darkChipBlueBg,
    blueAccent: AppColors.darkChipBlueText,
    pinkBg: AppColors.darkChipVioletBg,
    pinkIconBg: AppColors.darkChipVioletBg,
    pinkAccent: AppColors.darkChipVioletText,
    cardBorder: AppColors.darkBorder,
    label: AppColors.darkText3,
  );

  /// تُرجع الباليتة المناسبة حسب سطوع الثيم الحالي.
  static _Palette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? _light : _dark;
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
        return _buildContent(
          context,
          loading: state.status == ProfileStatus.loading,
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, {required bool loading}) {
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
        loading: loading,
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

