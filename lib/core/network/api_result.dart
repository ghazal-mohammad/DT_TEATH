// ════════════════════════════════════════════════════════════════════════════
// api_result.dart
//
// نمط Either لكل الـ Repositories.
// القرار 7: dartz — Either<Failure, Success>.
//
// الاستخدام:
//   Future<ApiResult<List<Material>>> getMaterials();
//
// وعند الاستهلاك في الـ BLoC:
//   result.fold(
//     (failure) => emit(ErrorState(failure.message)),
//     (materials) => emit(LoadedState(materials)),
//   );
// ════════════════════════════════════════════════════════════════════════════

import 'package:dartz/dartz.dart';

import 'failure.dart';

/// اختصار شائع لنمط الإرجاع من كل Repository.
typedef ApiResult<T> = Future<Either<Failure, T>>;

/// اختصار متزامن (نادر الاستخدام).
typedef SyncResult<T> = Either<Failure, T>;
