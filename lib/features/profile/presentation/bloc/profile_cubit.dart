// ════════════════════════════════════════════════════════════════════════════
// profile_cubit.dart
//
// Cubit الملف الشخصي للموظف (مشترك بين المخبر والمستودع — نفس الـ API).
//   • load()  → GET  /api/employee/showProfile
//   • save()  → POST /api/employee/editProfile
//
// الواجهة تستهلك state.profile فقط، فأي إعادة تصميم لاحقة لا تكسر الربط.
// ════════════════════════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/edit_profile_payload.dart';
import '../../domain/entities/employee_profile.dart';
import '../../domain/repositories/profile_repository.dart';

enum ProfileStatus { initial, loading, loaded, saving, error }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  final ProfileStatus status;
  final EmployeeProfile? profile;
  final String? errorMessage;

  bool get hasData => profile != null;

  ProfileState copyWith({
    ProfileStatus? status,
    EmployeeProfile? profile,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repo) : super(const ProfileState());

  final ProfileRepository _repo;

  Future<void> load() async {
    // عرض فوري من الكاش (زيارة لاحقة للصفحة) ثم تحديث صامت من الباك — يلغي
    // وميض الشيمر في كل زيارة. أول زيارة (بلا كاش) تُظهر شيمر التحميل المعتاد.
    final cached = _repo.cachedProfile;
    if (cached != null) {
      // تأجيل بإطار واحد حتى يشترك BlocConsumer في الصفحة، فيلتقط listenerها
      // حالة "المُحمَّل من الكاش" ويدمجها (الاشتراك يحدث بعد إنشاء الـ Cubit).
      await Future<void>.delayed(Duration.zero);
      emit(state.copyWith(
          status: ProfileStatus.loaded, profile: cached, clearError: true));
    } else {
      emit(state.copyWith(status: ProfileStatus.loading, clearError: true));
    }
    try {
      final profile = await _repo.getProfile();
      emit(state.copyWith(status: ProfileStatus.loaded, profile: profile));
    } on Failure catch (f) {
      // لا نُظهر خطأ فوق بيانات كاش صالحة — نُبقي العرض ونتجاهل فشل التحديث.
      if (cached == null) {
        emit(state.copyWith(
            status: ProfileStatus.error, errorMessage: f.message));
      }
    } catch (_) {
      if (cached == null) {
        emit(state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'خطأ غير متوقع أثناء تحميل الملف الشخصي',
        ));
      }
    }
  }

  Future<void> save(EditProfilePayload payload) async {
    emit(state.copyWith(status: ProfileStatus.saving, clearError: true));
    try {
      final profile = await _repo.updateProfile(payload);
      emit(state.copyWith(status: ProfileStatus.loaded, profile: profile));
    } on Failure catch (f) {
      emit(state.copyWith(status: ProfileStatus.error, errorMessage: f.message));
    } catch (_) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'خطأ غير متوقع أثناء حفظ التعديلات',
      ));
    }
  }
}
