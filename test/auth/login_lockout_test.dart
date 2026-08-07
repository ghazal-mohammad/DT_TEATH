import 'package:dt_teeth/core/auth/auth_models.dart';
import 'package:dt_teeth/core/network/failure.dart';
import 'package:dt_teeth/features/auth/domain/repositories/auth_repository.dart';
import 'package:dt_teeth/features/auth/presentation/bloc/login_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepo extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepo repo;

  const user = EmployeeUser(
    id: 1,
    name: 'ليلى',
    email: 'laila@x.com',
    role: EmployeeRole.labManager,
    isActive: true,
    token: 'tok',
  );

  setUp(() => repo = _MockAuthRepo());

  Future<void> failNTimes(LoginCubit cubit, int n) async {
    when(() => repo.login(email: any(named: 'email'), password: any(named: 'password')))
        .thenThrow(const ServerFailure('بيانات غير صحيحة', code: '401'));
    for (var i = 0; i < n; i++) {
      await cubit.login(email: 'a@b.com', password: 'wrong');
    }
  }

  test('يمرّر رسالة الفشل العادية قبل بلوغ الحدّ', () async {
    final cubit = LoginCubit(repo);
    await failNTimes(cubit, 4);
    expect(cubit.state.status, LoginStatus.failure);
    expect(cubit.state.errorMessage, 'بيانات غير صحيحة');
  });

  test('يقفل بعد 5 محاولات فاشلة ويمنع طلب الباك أثناء القفل', () async {
    final cubit = LoginCubit(repo);
    await failNTimes(cubit, 5);

    // المحاولة الخامسة فعّلت القفل.
    expect(cubit.state.errorMessage, contains('حاول بعد'));
    final callsBefore =
        verify(() => repo.login(email: any(named: 'email'), password: any(named: 'password')))
          ..called(5);
    callsBefore;

    // محاولة أثناء القفل: لا تلمس الباك.
    await cubit.login(email: 'a@b.com', password: 'wrong');
    verifyNever(() =>
        repo.login(email: any(named: 'email'), password: any(named: 'password')));
    expect(cubit.state.errorMessage, contains('حاول بعد'));
  });

  test('نجاح الدخول يصفّر العدّاد (لا قفل من محاولات سابقة)', () async {
    final cubit = LoginCubit(repo);
    await failNTimes(cubit, 3); // تحت الحدّ.

    when(() => repo.login(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => user);
    await cubit.login(email: 'a@b.com', password: 'correct');
    expect(cubit.state.status, LoginStatus.success);

    // بعد النجاح، فشلتان جديدتان لا تكفيان لقفل (العدّاد صُفِّر).
    await failNTimes(cubit, 2);
    expect(cubit.state.errorMessage, 'بيانات غير صحيحة');
    expect(cubit.state.errorMessage, isNot(contains('حاول بعد')));
  });

  test('حقل فارغ ⇒ رسالة تحقّق بلا لمس الباك', () async {
    final cubit = LoginCubit(repo);
    await cubit.login(email: '', password: '');
    expect(cubit.state.status, LoginStatus.failure);
    verifyNever(() =>
        repo.login(email: any(named: 'email'), password: any(named: 'password')));
  });
}
