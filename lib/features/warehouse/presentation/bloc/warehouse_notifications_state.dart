// ════════════════════════════════════════════════════════════════════════════
// warehouse_notifications_state.dart
//
// State لـ WarehouseNotificationsCubit — الفلترة نفسها بتصير بالـ widget
// (زي ما كانت بالـ Mock القديم) بما إنها UI-only، هون بس حالة التحميل والقائمة.
// ════════════════════════════════════════════════════════════════════════════

import '../../domain/entities/warehouse_notification.dart';

enum WarehouseNotificationsStatus { loading, loaded, error }

class WarehouseNotificationsState {
  const WarehouseNotificationsState({
    required this.status,
    required this.items,
    this.errorMessage,
  });

  const WarehouseNotificationsState.initial()
      : status = WarehouseNotificationsStatus.loading,
        items = const [],
        errorMessage = null;

  final WarehouseNotificationsStatus status;
  final List<WarehouseNotification> items;
  final String? errorMessage;

  WarehouseNotificationsState copyWith({
    WarehouseNotificationsStatus? status,
    List<WarehouseNotification>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WarehouseNotificationsState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
