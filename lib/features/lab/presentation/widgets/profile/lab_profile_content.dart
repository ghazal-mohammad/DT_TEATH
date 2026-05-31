// ════════════════════════════════════════════════════════════════════════════
// lab_profile_content.dart
//
// محتوى صفحة الملف الشخصي لموظف/مدير المخبر — تصميم بعمودين مطابق للموك أب.
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

import '../../../../../core/auth/auth_models.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../profile/domain/entities/edit_profile_payload.dart';
import '../../../../profile/domain/entities/employee_profile.dart';
import '../../../../profile/presentation/bloc/profile_cubit.dart';

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
  String roleTitle; // شارة الدور (رئيس المخبر)
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
  });

  static _EmployeeData mockData() => _EmployeeData(
        fullName: 'رامي الصالح',
        roleTitle: 'رئيس المخبر',
        email: 'rami@dt-teeth.com',
        phone: '0991234567',
        nationalId: '01010101234',
        birthDate: '1990 / 06 / 15',
        gender: 'ذكر',
        address: 'دمشق - المزة',
        employeeId: 'LAB-2026-007',
        department: 'مخبر التعويضات السنية',
        position: 'رئيس المخبر',
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
      );
}

// ══════════════════════════════════════════════════════════════════════════
//                              MAIN CONTENT
// ══════════════════════════════════════════════════════════════════════════

class LabProfileContent extends StatefulWidget {
  const LabProfileContent({super.key});

  @override
  State<LabProfileContent> createState() => _LabProfileContentState();
}

class _LabProfileContentState extends State<LabProfileContent> {
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
    super.dispose();
  }

  // ── مزامنة بيانات الخادم → نموذج الواجهة (مع الحفاظ على التصميم كما هو) ──
  void _onCubitState(BuildContext context, ProfileState state) {
    if (state.status == ProfileStatus.loaded && state.profile != null) {
      final wasSaving = _savingEdit;
      setState(() {
        _data = _mergeFromProfile(_data, state.profile!);
        if (wasSaving) {
          _editing = false;
          _draft = null;
        }
        _savingEdit = false;
      });
      if (wasSaving) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ التعديلات بنجاح'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else if (state.status == ProfileStatus.error && _savingEdit) {
      _savingEdit = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? 'تعذّر حفظ التعديلات'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// دمج بيانات الخادم فوق النموذج الحالي. الحقول التي لا يوفّرها الباك في
  /// showProfile تبقى كما هي (placeholder تصميمي).
  _EmployeeData _mergeFromProfile(_EmployeeData base, EmployeeProfile p) {
    final c = base.copy();
    if (p.name.isNotEmpty) c.fullName = p.name;
    if (p.email.isNotEmpty) c.email = p.email;
    if (p.phone.isNotEmpty) c.phone = p.phone;
    c.roleTitle = _rolePosition(p.role);
    c.position = _rolePosition(p.role);
    if (p.hireDate.isNotEmpty) c.hireDate = p.hireDate;
    return c;
  }

  static String _rolePosition(EmployeeRole r) => switch (r) {
        EmployeeRole.labManager => 'رئيس المخبر',
        EmployeeRole.warehouseManager => 'رئيس المستودع',
        EmployeeRole.admin => 'مدير النظام',
        _ => 'موظف',
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث صورة الملف الشخصي'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _pickingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذّر اختيار الصورة: $e'),
          duration: const Duration(seconds: 3),
        ),
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
    // profile_picture. (تاريخ الميلاد نص حرّ فلا يُرسل تفادياً لرفض الـ
    // validation على نوع date.)
    final payload = EditProfilePayload(
      name: d.fullName,
      phone: d.phone,
      address: d.address,
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
        if (state.status == ProfileStatus.loading && !state.hasData) {
          return const _ProfileCenterLoader();
        }
        if (state.status == ProfileStatus.error && !state.hasData) {
          return _ProfileCenterError(
            message: state.errorMessage,
            onRetry: () => _cubit.load(),
          );
        }
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
        return Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 340, child: sidebar),
              const SizedBox(width: 20),
              Expanded(
                child: Scrollbar(
                  controller: _mainCtrl,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _mainCtrl,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(left: 4),
                    child: main,
                  ),
                ),
              ),
            ],
          ),
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
              initial: 'د',
              bytes: avatarBytes,
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
          const _SectionLabelDivider(label: 'معلومات عامة'),
          const SizedBox(height: 14),
          _SideMetaCard(
            icon: Icons.event_outlined,
            label: 'تاريخ التوظيف',
            value: data.hireDate,
            tint: const Color(0xFFEFF2FA),
          ),
          const SizedBox(height: 10),
          _SideMetaCard(
            icon: Icons.language_outlined,
            label: 'اللغات',
            value: data.languages,
            tint: const Color(0xFFF4EEFB),
          ),
          const SizedBox(height: 10),
          _SideMetaCard(
            icon: Icons.description_outlined,
            label: 'ملاحظات إدارية',
            value: data.adminNotes,
            tint: const Color(0xFFEFF2FA),
          ),
          const SizedBox(height: 18),
          _CompletionBar(percent: data.completion),
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
              fontSize: 11.5,
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

// ── شريط اكتمال الملف ───────────────────────────────────────────────────────
class _CompletionBar extends StatelessWidget {
  const _CompletionBar({required this.percent});
  final int percent;

  @override
  Widget build(BuildContext context) {
    final pct = (percent.clamp(0, 100)) / 100.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$percent%',
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: AppColors.success,
              ),
            ),
            const Text(
              'اكتمال الملف',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: _Palette.label,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          child: Stack(
            children: [
              Container(height: 8, color: const Color(0xFFE7EBF3)),
              FractionallySizedBox(
                widthFactor: pct,
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  height: 8,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.success],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
        label: 'تعديل الملف الشخصي',
        icon: Icons.edit_outlined,
        primary: true,
        onTap: onStartEdit,
      );
    }
    return Column(
      children: [
        _WideButton(
          label: saving ? 'جارٍ الحفظ…' : 'حفظ التغييرات',
          icon: Icons.check_rounded,
          primary: true,
          onTap: saving ? null : onSaveEdit,
        ),
        const SizedBox(height: 8),
        _WideButton(
          label: 'إلغاء',
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
                  fontSize: 13.5,
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

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initial,
    required this.bytes,
    required this.loading,
    required this.onChangePhoto,
  });

  final String initial;
  final Uint8List? bytes;
  final bool loading;
  final VoidCallback onChangePhoto;

  @override
  Widget build(BuildContext context) {
    final hasImage = bytes != null;
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
                  gradient: hasImage
                      ? null
                      : const LinearGradient(
                          colors: _Palette.avatarGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  image: hasImage
                      ? DecorationImage(
                          image: MemoryImage(bytes!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: _Palette.accent.withValues(alpha: 0.24),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: hasImage
                    ? null
                    : Center(
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
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_outlined, size: 13, color: Colors.white),
                    SizedBox(width: 5),
                    Text(
                      'تغيير الصورة',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 11.5,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _Palette.pinkBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: _Palette.pinkAccent.withValues(alpha: 0.20)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: _Palette.pinkAccent,
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
          title: 'المعلومات الشخصية',
          subtitle: 'البيانات التعريفية ومعلومات الاتصال',
          editing: editing,
          fields: [
            _RowSpec(
              icon: Icons.phone_outlined,
              label: 'رقم الهاتف',
              value: data.phone,
              onChanged: (v) => data.phone = v,
            ),
            _RowSpec(
              icon: Icons.badge_outlined,
              label: 'الرقم الوطني',
              value: data.nationalId,
              onChanged: (v) => data.nationalId = v,
            ),
            _RowSpec(
              icon: Icons.calendar_month_outlined,
              label: 'تاريخ الميلاد',
              value: data.birthDate,
              onChanged: (v) => data.birthDate = v,
            ),
            _RowSpec(
              icon: Icons.wc_outlined,
              label: 'الجنس',
              value: data.gender,
              onChanged: (v) => data.gender = v,
            ),
            _RowSpec(
              icon: Icons.location_on_outlined,
              label: 'العنوان',
              value: data.address,
              onChanged: (v) => data.address = v,
            ),
            _RowSpec(
              icon: Icons.assignment_ind_outlined,
              label: 'رقم الموظف',
              value: data.employeeId,
              onChanged: (v) => data.employeeId = v,
            ),
          ],
        ),
        const SizedBox(height: 18),
        _InfoSection(
          icon: Icons.work_outline_rounded,
          title: 'المعلومات الوظيفية',
          subtitle: 'القسم والدوام والمسمى الوظيفي',
          editing: editing,
          fields: [
            _RowSpec(
              icon: Icons.inventory_2_outlined,
              label: 'القسم',
              value: data.department,
              onChanged: (v) => data.department = v,
            ),
            _RowSpec(
              icon: Icons.calendar_today_outlined,
              label: 'أيام الدوام',
              value: data.workDays,
              onChanged: (v) => data.workDays = v,
            ),
            _RowSpec(
              icon: Icons.badge_outlined,
              label: 'المسمى الوظيفي',
              value: data.position,
              onChanged: (v) => data.position = v,
            ),
            _RowSpec(
              icon: Icons.do_not_disturb_on_outlined,
              label: 'يوم العطلة الأسبوعية',
              value: data.dayOff,
              onChanged: (v) => data.dayOff = v,
            ),
            _RowSpec(
              icon: Icons.access_time_rounded,
              label: 'عدد ساعات العمل الأسبوعية',
              value: data.weeklyHours,
              onChanged: (v) => data.weeklyHours = v,
            ),
          ],
        ),
      ],
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
    const stats = [
      _StatSpec(
        value: '96',
        unit: '%',
        label: 'الإنجاز في الوقت',
        badge: '2%+',
        icon: Icons.star_border_rounded,
        accent: Color(0xFF2E48B5),
        bg: Color(0xFFEFF3FD),
      ),
      _StatSpec(
        value: '2.4',
        unit: 'س',
        label: 'وقت التنفيذ',
        badge: 'متوسط',
        icon: Icons.schedule_rounded,
        accent: Color(0xFF7A4FCF),
        bg: Color(0xFFF4ECFB),
      ),
      _StatSpec(
        value: '142',
        unit: '',
        label: 'طلبات منجزة',
        badge: 'هذا الشهر',
        icon: Icons.check_circle_outline_rounded,
        accent: Color(0xFF12A150),
        bg: Color(0xFFEAF7EF),
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
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            Expanded(child: _StatCard(spec: stats[i])),
            if (i < stats.length - 1) const SizedBox(width: 14),
          ],
        ],
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: spec.bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: spec.accent.withValues(alpha: 0.14)),
      ),
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
                    fontSize: 10.5,
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
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: _Palette.label,
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
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.lightText1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 11.5,
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
  });

  final IconData icon;
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
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
    }
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

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: _Palette.cardBorder),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // المحتوى (يشغل المساحة من اليمين).
            Expanded(
              child: Padding(
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
                          Text(
                            widget.spec.label,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _Palette.label,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (widget.editing)
                            TextField(
                              controller: _controller,
                              onChanged: widget.spec.onChanged,
                              style: const TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 13.5,
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
                                  borderSide:
                                      BorderSide(color: accent, width: 1.6),
                                ),
                              ),
                            )
                          else
                            Text(
                              widget.spec.value,
                              style: const TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 14.5,
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
            ),
            // الشريط اللوني على الطرف الأيسر (آخر عنصر في RTL).
            Container(width: 4, color: accent),
          ],
        ),
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
              message ?? 'تعذّر تحميل الملف الشخصي',
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
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'إعادة المحاولة',
                      style: TextStyle(
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
