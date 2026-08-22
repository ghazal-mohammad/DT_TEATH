// ════════════════════════════════════════════════════════════════════════════
// remote_lab_notifications_repository.dart
//
// تنفيذ Remote لـ [LabNotificationsRepository] — يجلب إشعارات المستخدم الحالي
// عبر [LabNotificationsRemoteDataSource] ويطابق عقد الـ Mock (نفس الواجهة + stream).
//
// مطابقة العقد مع الباك (تحقّق فعلي 2026-08-22):
//   العنصر: {id, type, title, body, is_read, reference_type, reference_id,
//            created_at}. لا يوجد `category` ولا `action_type/action_id` —
//   نشتقّهما من `type`.
//   لا يوجد endpoint لـ"تحديد الكل مقروء" بالباك حالياً (الدالة موجودة بالكود
//   بس غير موصولة بـ route) — نعوّضها بحلقة PATCH لكل إشعار غير مقروء.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/network/failure.dart';
import '../../../../core/utils/app_date.dart';
import '../../domain/entities/lab_notification.dart';
import '../../domain/repositories/lab_notifications_repository.dart';
import '../datasources/lab_notifications_remote_datasource.dart';

class RemoteLabNotificationsRepository implements LabNotificationsRepository {
  RemoteLabNotificationsRepository(this._remote) {
    _controller =
        StreamController<List<NotificationItem>>.broadcast(onListen: _emit);
  }

  final LabNotificationsRemoteDataSource _remote;
  late final StreamController<List<NotificationItem>> _controller;
  List<NotificationItem> _cache = const [];

  void _emit() {
    if (!_controller.isClosed) _controller.add(List.unmodifiable(_cache));
  }

  @override
  Future<List<NotificationItem>> getAll() async {
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
  Future<void> markRead(Object id) async {
    try {
      await _remote.markRead(id);
      for (final n in _cache) {
        if (n.id == id) n.isRead = true;
      }
      _emit();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> markAllRead() async {
    // لا يوجد route جماعي بالباك حالياً — نستدعي markRead لكل عنصر غير مقروء.
    final unread = _cache.where((n) => !n.isRead).toList();
    for (final n in unread) {
      if (n.id != null) await markRead(n.id!);
    }
  }

  @override
  Stream<List<NotificationItem>> watchAll() => _controller.stream;

  NotificationItem _fromJson(Map<String, dynamic> j) {
    final type = (j['type'] ?? '').toString();
    return NotificationItem(
      id: j['id'],
      kind: _kindOf(type),
      title: (j['title'] ?? '').toString(),
      description: (j['body'] ?? '').toString(),
      category: _categoryLabelOf(type),
      timeLabel: AppDate.relative(j['created_at']?.toString()),
      day: _dayOf(j['created_at']?.toString()),
      icon: _iconOf(type),
      isRead: j['is_read'] == true,
    );
  }

  NotificationKind _kindOf(String type) {
    if (type.contains('low_stock')) return NotificationKind.material;
    if (type.contains('order')) return NotificationKind.order;
    return NotificationKind.system;
  }

  String _categoryLabelOf(String type) {
    if (type.contains('low_stock')) return 'المواد';
    if (type.contains('order')) return 'الطلبات';
    return 'النظام';
  }

  IconData _iconOf(String type) {
    if (type.contains('low_stock')) return Icons.inventory_2_outlined;
    if (type.contains('order')) return Icons.add_circle_outline_rounded;
    return Icons.check_circle_outline_rounded;
  }

  /// النموذج الحالي يدعم اليوم/أمس فقط (لا "أقدم") — أي شي أقدم من أمس
  /// يُصنَّف "أمس" كأقرب تقريب متاح ضمن قيود [NotificationDay].
  NotificationDay _dayOf(String? iso) {
    final dt = iso == null ? null : DateTime.tryParse(iso);
    if (dt == null) return NotificationDay.today;
    final local = dt.isUtc ? dt.toLocal() : dt;
    final now = DateTime.now();
    final isToday = local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    return isToday ? NotificationDay.today : NotificationDay.yesterday;
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
