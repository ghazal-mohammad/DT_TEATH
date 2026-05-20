// ════════════════════════════════════════════════════════════════════════════
// login_cubit.dart
//
// Cubit لشاشة Login — يستدعي POST /api/employee/login.
// عند النجاح: يحفظ التوكن (داخل الـrepository) ويرجع EmployeeUser بحالة success.
// ════════════════════════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/auth_models.dart';
import '../../../../core/network/failure.dart';
import '../../domain/repositories/auth_repository.dart';

enum LoginStatus { initial, submitting, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.user,
    this.errorMessage,
  });

  final LoginStatus status;
  final EmployeeUser? user;
  final String? errorMessage;

  LoginState copyWith({
    LoginStatus? status,
    EmployeeUser? user,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repo) : super(const LoginState());

  final AuthRepository _repo;

  Future<void> login({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'يرجى إدخال البريد وكلمة المرور',
      ));
      return;
    }

    emit(state.copyWith(status: LoginStatus.submitting, clearError: true));

    try {
      final user = await _repo.login(email: email.trim(), password: password);
      emit(state.copyWith(status: LoginStatus.success, user: user));
    } on Failure catch (f) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: f.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'خطأ غير متوقع — حاول مرة أخرى',
      ));
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(const LoginState());
  }
}
