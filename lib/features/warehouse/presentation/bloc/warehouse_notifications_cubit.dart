// ════════════════════════════════════════════════════════════════════════════
// warehouse_notifications_cubit.dart
//
// Cubit إدارة إشعارات المستودع — تحميل + تحديد مقروء (واحد/الكل).
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/warehouse_notification.dart';
import '../../domain/repositories/warehouse_notifications_repository.dart';
import 'warehouse_notifications_state.dart';

class WarehouseNotificationsCubit extends Cubit<WarehouseNotificationsState> {
  WarehouseNotificationsCubit({required WarehouseNotificationsRepository repository})
      : _repository = repository,
        super(const WarehouseNotificationsState.initial());

  final WarehouseNotificationsRepository _repository;
  StreamSubscription<List<WarehouseNotification>>? _subscription;

  Future<void> load() async {
    emit(state.copyWith(
        status: WarehouseNotificationsStatus.loading, clearError: true));
    try {
      final items = await _repository.getAll();
      emit(state.copyWith(
        status: WarehouseNotificationsStatus.loaded,
        items: items,
        clearError: true,
      ));
      _subscription?.cancel();
      _subscription = _repository.watchAll().listen(
            (list) => emit(state.copyWith(items: list)),
            onError: (Object e) => emit(state.copyWith(
              status: WarehouseNotificationsStatus.error,
              errorMessage: userMessageFromError(e),
            )),
          );
    } catch (e) {
      emit(state.copyWith(
        status: WarehouseNotificationsStatus.error,
        errorMessage: userMessageFromError(e),
      ));
    }
  }

  Future<void> markRead(String id) => _repository.markRead(id);

  Future<void> markAllRead() => _repository.markAllRead();

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
