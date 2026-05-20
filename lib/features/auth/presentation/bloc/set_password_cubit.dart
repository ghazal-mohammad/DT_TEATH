// ════════════════════════════════════════════════════════════════════════════
// set_password_cubit.dart
//
// Cubit لشاشة Set Password — يستدعي POST /api/employee/setPassword.
// ياخد: email + verification_code + password.
// ════════════════════════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/auth_models.dart';
import '../../../../core/network/failure.dart';
import '../../domain/repositories/auth_repository.dart';

enum SetPasswordStatus { initial, submitting, success, failure }

class SetPasswordState extends Equatable {
  const SetPasswordState({
    this.status = SetPasswordStatus.initial,
    this.user,
    this.errorMessage,
  });

  final SetPasswordStatus status;
  final EmployeeUser? user;
  final String? errorMessage;

  SetPasswordState copyWith({
    SetPasswordStatus? status,
    EmployeeUser? user,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SetPasswordState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}

class SetPasswordCubit extends Cubit<SetPasswordState> {
  SetPasswordCubit(this._repo) : super(const SetPasswordState());

  final AuthRepository _repo;

  Future<void> submit({
    required String email,
    required String verificationCode,
    required String password,
  }) async {
    emit(state.copyWith(status: SetPasswordStatus.submitting, clearError: true));

    try {
      final user = await _repo.setPassword(
        email: email,
        verificationCode: verificationCode,
        password: password,
      );
      emit(state.copyWith(status: SetPasswordStatus.success, user: user));
    } on Failure catch (f) {
      emit(state.copyWith(
        status: SetPasswordStatus.failure,
        errorMessage: f.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: SetPasswordStatus.failure,
        errorMessage: 'خطأ غير متوقع — حاول مرة أخرى',
      ));
    }
  }
}
