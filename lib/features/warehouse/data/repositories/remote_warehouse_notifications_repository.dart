// ════════════════════════════════════════════════════════════════════════════
// remote_warehouse_notifications_repository.dart
//
// تنفيذ Remote لـ [WarehouseNotificationsRepository]. نفس منطق المخبر
// (remote_lab_notifications_repository.dart): لا endpoint جماعي لـ"تحديد
// الكل مقروء" بالباك حالياً، فنعوّضه بحلقة PATCH لكل إشعار غير مقروء.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core/network/failure.dart';
import '../../../../core/utils/app_date.dart';
import '../../domain/entities/warehouse_notification.dart';
import '../../domain/repositories/warehouse_notifications_repository.dart';
import '../datasources/warehouse_notifications_remote_datasource.dart';

class RemoteWarehouseNotificationsRepository
    implements WarehouseNotificationsRepository {
  RemoteWarehouseNotificationsRepository(this._remote) {
    _controller = StreamController<List<WarehouseNotification>>.broadcast(
      onListen: _emit,
    );
  }

  final WarehouseNotificationsRemoteDataSource _remote;
  late final StreamController<List<WarehouseNotification>> _controller;
  List<WarehouseNotification> _cache = const [];

  void _emit() {
    if (!_controller.isClosed) _controller.add(List.unmodifiable(_cache));
  }

  @override
  Future<List<WarehouseNotification>> getAll() async {
    try {
      final raw = await _remote.getAll();
      _cache = raw.map(_fromJson).toList();
      _emit();
      return List.unmodifiable(_cache);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> markRead(String id) async {
    try {
      await _remote.markRead(id);
      _cache = _cache
          .map((n) => n.id == id ? _copyAsRead(n) : n)
          .toList(growable: false);
      _emit();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> markAllRead() async {
    final unread = _cache.where((n) => !n.isRead).toList();
    for (final n in unread) {
      await markRead(n.id);
    }
  }

  @override
  Stream<List<WarehouseNotification>> watchAll() => _controller.stream;

  WarehouseNotification _copyAsRead(WarehouseNotification n) =>
      WarehouseNotification(
        id: n.id,
        title: n.title,
        body: n.body,
        time: n.time,
        category: n.category,
        isRead: true,
        actionLabel: n.actionLabel,
      );

  WarehouseNotification _fromJson(Map<String, dynamic> j) {
    final type = (j['type'] ?? '').toString();
    return WarehouseNotification(
      id: '${j['id'] ?? ''}',
      title: (j['title'] ?? '').toString(),
      body: (j['body'] ?? '').toString(),
      time: AppDate.relative(j['created_at']?.toString()),
      category: _categoryOf(type),
      isRead: j['is_read'] == true,
    );
  }

  NotificationCategory _categoryOf(String type) {
    if (type.contains('low_stock')) return NotificationCategory.low;
    if (type.contains('expiry')) return NotificationCategory.expiry;
    if (type.contains('order')) return NotificationCategory.order;
    return NotificationCategory.general;
  }

  Failure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const TimeoutFailure();
    }
    if (e.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }
    final status = e.response?.statusCode;
    if (status == null) return const NetworkFailure();
    final data = e.response?.data;
    final msg = (data is Map && data['message'] is String)
        ? data['message'] as String
        : null;
    return ServerFailure(msg ?? 'تعذّر جلب الإشعارات', code: '$status');
  }
}
