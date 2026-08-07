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

  // ── قفل محاولات الدخول (حماية من التخمين القسري من جهة العميل) ───────────
  // بعد [_maxAttempts] محاولات فاشلة متتالية نُقفل الإدخال مدّة تصاعدية، فلا
  // يُرسَل أي طلب للباك أثناء القفل. طبقة دفاع أمام حدّ المعدّل في الباك.
  static const int _maxAttempts = 5;
  static const int _baseLockSeconds = 30;
  static const int _maxLockSeconds = 300;

  int _failedAttempts = 0;
  int _lockCount = 0;
  DateTime? _lockedUntil;

  /// الثواني المتبقية على القفل (0 إن غير مقفَل).
  int get _remainingLockSeconds {
    final until = _lockedUntil;
    if (until == null) return 0;
    final diff = until.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  Future<void> login({required String email, required String password}) async {
    // مقفَل حالياً؟ ارفض فوراً دون لمس الشبكة.
    final remaining = _remainingLockSeconds;
    if (remaining > 0) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'محاولات كثيرة. حاول بعد $remaining ثانية',
      ));
      return;
    }

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
      _resetLock(); // نجاح ⇒ صفّر العدّاد والقفل.
      emit(state.copyWith(status: LoginStatus.success, user: user));
    } on Failure catch (f) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: _registerFailure(f.message),
      ));
    } catch (_) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: _registerFailure('خطأ غير متوقع — حاول مرة أخرى'),
      ));
    }
  }

  /// يسجّل محاولة فاشلة؛ يُفعّل القفل عند بلوغ الحدّ ويُرجع الرسالة المناسبة.
  String _registerFailure(String baseMessage) {
    _failedAttempts++;
    if (_failedAttempts >= _maxAttempts) {
      _failedAttempts = 0;
      _lockCount++;
      final seconds =
          (_baseLockSeconds * _lockCount).clamp(_baseLockSeconds, _maxLockSeconds);
      _lockedUntil = DateTime.now().add(Duration(seconds: seconds));
      return 'محاولات كثيرة. حاول بعد $seconds ثانية';
    }
    return baseMessage;
  }

  void _resetLock() {
    _failedAttempts = 0;
    _lockCount = 0;
    _lockedUntil = null;
  }

  Future<void> logout() async {
    await _repo.logout();
    _resetLock();
    emit(const LoginState());
  }
}
