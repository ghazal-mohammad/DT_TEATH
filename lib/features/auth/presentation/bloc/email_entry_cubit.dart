// ════════════════════════════════════════════════════════════════════════════
// email_entry_cubit.dart
//
// Cubit لإدارة حالة شاشة Email Entry (Phase 3.3).
//
// الحالات:
//   - initial: المستخدم لسه يكتب
//   - submitting: جاري إرسال الطلب للـ API
//   - success: نجح الإرسال → سيتم التنقّل للشاشة التالية
//   - error: فشل (network/validation)
//
// Phase 3.6 سيُربط بـ AuthRepository الفعلي.
// حالياً في Phase 3.3 → mock فقط (يحاكي 1.2s delay + success).
// ════════════════════════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/validators.dart';

// ══════════════════════════════════════════════════════════════════════════
//                              STATE
// ══════════════════════════════════════════════════════════════════════════

/// حالة شاشة Email Entry.
class EmailEntryState extends Equatable {
  const EmailEntryState({
    this.email = '',
    this.status = EmailEntryStatus.initial,
    this.errorMessage,
  });

  /// النص الحالي في حقل الإيميل.
  final String email;

  /// حالة الـ flow.
  final EmailEntryStatus status;

  /// رسالة خطأ من الـ API (لو موجودة).
  final String? errorMessage;

  /// هل الإيميل صالح للإرسال؟
  bool get isEmailValid => Validators.isValidEmail(email);

  /// هل الزر يجب أن يكون visually disabled؟
  /// السياسة الجديدة: الزر مفعّل دائماً ما لم يكن جاري الإرسال.
  /// لو الإيميل غير valid، الـ submit() يعرض رسالة خطأ.
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

/// حالات الـ flow.
enum EmailEntryStatus {
  /// المستخدم يكتب.
  initial,

  /// جاري إرسال الطلب للـ API.
  submitting,

  /// نجح الإرسال — جاهز للانتقال للـ OTP screen.
  success,

  /// فشل (errorMessage يحوي السبب).
  failure,
}

// ══════════════════════════════════════════════════════════════════════════
//                              CUBIT
// ══════════════════════════════════════════════════════════════════════════

/// Cubit لإدارة شاشة Email Entry.
class EmailEntryCubit extends Cubit<EmailEntryState> {
  EmailEntryCubit() : super(const EmailEntryState());

  /// تحديث الإيميل عند الكتابة.
  void emailChanged(String value) {
    emit(state.copyWith(email: value, clearError: true));
  }

  /// إرسال الطلب للـ API.
  ///
  /// Phase 3.3: mock implementation فقط.
  /// Phase 3.6: استبدال بـ AuthRepository.requestCode(email).
  Future<void> submit() async {
    final String trimmed = state.email.trim();

    // 1. لو فارغ تماماً → خطأ
    if (trimmed.isEmpty) {
      emit(
        state.copyWith(
          status: EmailEntryStatus.failure,
          errorMessage: 'email_required',
        ),
      );
      return;
    }

    // 2. لو نص غير فارغ → نتقدّم محلياً حتى يكتمل الربط بالباك.
    //    هذا يسمح لنا بمراجعة الواجهات الأخرى دون انتظار API.
    // 3. ابدأ الـ submit
    emit(state.copyWith(status: EmailEntryStatus.submitting, clearError: true));

    try {
      // Phase 3.3: الباك-اند لسا مش جاهز، نكمل محلياً.
      // سيتم ربط هذا بـ _authRepository.requestCode(state.email) في Phase 3.6.
      await Future<void>.delayed(const Duration(milliseconds: 200));

      emit(state.copyWith(status: EmailEntryStatus.success));
    } catch (e) {
      // فشل شبكي حقيقي
      emit(
        state.copyWith(
          status: EmailEntryStatus.failure,
          errorMessage: 'network_error',
        ),
      );
    }
  }

  /// إعادة تعيين الحالة (مفيد عند الرجوع للشاشة).
  void reset() {
    emit(const EmailEntryState());
  }
}
