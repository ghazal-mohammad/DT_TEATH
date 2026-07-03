// ════════════════════════════════════════════════════════════════════════════
// lab_notifications_cubit.dart
//
// Cubit لإدارة شاشة إشعارات المخبر — تحميل + فلترة + تحديد الكل كمقروء.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/lab_notification.dart';
import '../../domain/repositories/lab_notifications_repository.dart';
import 'lab_notifications_state.dart';

/// Cubit إدارة إشعارات المخبر.
class LabNotificationsCubit extends Cubit<LabNotificationsState> {
  LabNotificationsCubit({required LabNotificationsRepository repository})
      : _repository = repository,
        super(const LabNotificationsState.initial());

  final LabNotificationsRepository _repository;
  StreamSubscription<List<NotificationItem>>? _subscription;

  /// تحميل الإشعارات والاشتراك بالـ stream.
  Future<void> load() async {
    emit(state.copyWith(
        status: LabNotificationsStatus.loading, clearError: true));
    try {
      final items = await _repository.getAll();
      emit(state.copyWith(
        status: LabNotificationsStatus.loaded,
        items: items,
        clearError: true,
      ));
      _subscription?.cancel();
      _subscription = _repository.watchAll().listen(
            (list) => emit(state.copyWith(items: list)),
            onError: (Object e) => emit(state.copyWith(
              status: LabNotificationsStatus.error,
              errorMessage: userMessageFromError(e),
            )),
          );
    } catch (e) {
      emit(state.copyWith(
        status: LabNotificationsStatus.error,
        errorMessage: userMessageFromError(e),
      ));
    }
  }

  /// تغيير الفلتر النشط.
  void setFilter(String filter) {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter));
  }

  /// تحديد كل الإشعارات كمقروءة.
  Future<void> markAllRead() => _repository.markAllRead();

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
