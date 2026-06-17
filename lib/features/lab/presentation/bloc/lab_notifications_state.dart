// ════════════════════════════════════════════════════════════════════════════
// lab_notifications_state.dart
//
// State لـ LabNotificationsCubit: مرحلة التحميل + الإشعارات + الفلتر النشط.
// القوائم المُفلترة/المجمّعة والعدّادات computed.
// ════════════════════════════════════════════════════════════════════════════

import '../../domain/entities/lab_notification.dart';

enum LabNotificationsStatus { loading, loaded, error }

/// State كامل لصفحة إشعارات المخبر.
class LabNotificationsState {
  const LabNotificationsState({
    required this.status,
    required this.items,
    required this.filter,
    this.errorMessage,
  });

  const LabNotificationsState.initial()
      : status = LabNotificationsStatus.loading,
        items = const [],
        filter = 'all',
        errorMessage = null;

  final LabNotificationsStatus status;
  final List<NotificationItem> items;

  /// all | unread | urgent | order | material | system.
  final String filter;
  final String? errorMessage;

  bool _matchesFilter(NotificationItem i) {
    switch (filter) {
      case 'unread':
        return !i.isRead;
      case 'urgent':
        return i.kind == NotificationKind.urgent;
      case 'order':
        return i.kind == NotificationKind.order;
      case 'material':
        return i.kind == NotificationKind.material;
      case 'system':
        return i.kind == NotificationKind.system;
      default:
        return true;
    }
  }

  List<NotificationItem> get filtered =>
      items.where(_matchesFilter).toList(growable: false);

  List<NotificationItem> get today => filtered
      .where((n) => n.day == NotificationDay.today)
      .toList(growable: false);

  List<NotificationItem> get yesterday => filtered
      .where((n) => n.day == NotificationDay.yesterday)
      .toList(growable: false);

  int get total => items.length;
  int get unread => items.where((i) => !i.isRead).length;
  int kindCount(NotificationKind k) => items.where((i) => i.kind == k).length;

  LabNotificationsState copyWith({
    LabNotificationsStatus? status,
    List<NotificationItem>? items,
    String? filter,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LabNotificationsState(
      status: status ?? this.status,
      items: items ?? this.items,
      filter: filter ?? this.filter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
