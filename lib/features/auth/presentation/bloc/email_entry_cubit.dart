// ════════════════════════════════════════════════════════════════════════════
// email_entry_cubit.dart
//
// Cubit لإدارة شاشة Email Entry — مربوط بـ AuthRepository.
// يستدعي POST /api/employee/sendVerification.
// ════════════════════════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/auth_flow_mode.dart';
import '../../domain/repositories/auth_repository.dart';

// ══════════════════════════════════════════════════════════════════════════
//                              STATE
// ══════════════════════════════════════════════════════════════════════════

class EmailEntryState extends Equatable {
  const EmailEntryState({
    this.email = '',
    this.status = EmailEntryStatus.initial,
    this.errorMessage,
  });

  final String email;
  final EmailEntryStatus status;
  final String? errorMessage;

  bool get isEmailValid => Validators.isValidEmail(email);
  bool get isSubmitDisabled => status == EmailEntryStatus.submitting;

  EmailEntryState copyWith({
    String? email,
    EmailEntryStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EmailEntryState(
      email: email ?? this.email,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [email, status, errorMessage];
}

enum EmailEntryStatus { initial, submitting, success, failure }

// ══════════════════════════════════════════════════════════════════════════
//                              CUBIT
// ══════════════════════════════════════════════════════════════════════════

class EmailEntryCubit extends Cubit<EmailEntryState> {
  EmailEntryCubit(this._repo) : super(const EmailEntryState());

  final AuthRepository _repo;

  /// نوع التدفّق — يحدّد أي endpoint نستدعي (تفعيل أول مرة أو إعادة تعيين).
  AuthFlowMode _mode = AuthFlowMode.activation;
  AuthFlowMode get mode => _mode;
  void setMode(AuthFlowMode mode) => _mode = mode;

  void emailChanged(String value) {
    emit(state.copyWith(email: value, clearError: true));
  }

  /// يرسل كود التحقق للإيميل عبر AuthRepository (حسب الـ mode).
  Future<void> submit() async {
    final trimmed = state.email.trim();

    if (trimmed.isEmpty) {
      emit(state.copyWith(
        status: EmailEntryStatus.failure,
        errorMessage: 'email_required',
      ));
      return;
    }
    if (!Validators.isValidEmail(trimmed)) {
      emit(state.copyWith(
        status: EmailEntryStatus.failure,
        errorMessage: 'invalid_email',
      ));
      return;
    }

    emit(state.copyWith(
      status: EmailEntryStatus.submitting,
      clearError: true,
    ));

    try {
      if (_mode == AuthFlowMode.reset) {
        await _repo.sendResetCode(email: trimmed);
      } else {
        await _repo.sendVerification(email: trimmed);
      }
      emit(state.copyWith(status: EmailEntryStatus.success));
    } on Failure catch (f) {
      emit(state.copyWith(
        status: EmailEntryStatus.failure,
        errorMessage: f.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: EmailEntryStatus.failure,
        errorMessage: 'network_error',
      ));
    }
  }

  void reset() => emit(const EmailEntryState());
}
