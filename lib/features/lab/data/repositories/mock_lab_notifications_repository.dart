// ════════════════════════════════════════════════════════════════════════════
// mock_lab_notifications_repository.dart
//
// تنفيذ mock لـ [LabNotificationsRepository] ببيانات في الذاكرة + stream.
// البذرة هنا (نُقلت من الصفحة). تُستبدل بـ Remote عند ربط الباك.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/entities/lab_notification.dart';
import '../../domain/repositories/lab_notifications_repository.dart';

/// تنفيذ mock للإشعارات — يخزّنها في الذاكرة (تضيع عند restart).
class MockLabNotificationsRepository implements LabNotificationsRepository {
  MockLabNotificationsRepository() {
    _items = _seed();
    _controller =
        StreamController<List<NotificationItem>>.broadcast(onListen: _emit);
  }

  late List<NotificationItem> _items;
  late final StreamController<List<NotificationItem>> _controller;

  static const _mockLatency = Duration(milliseconds: 80);

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_items));
    }
  }

  @override
  Future<List<NotificationItem>> getAll() async {
    await Future<void>.delayed(_mockLatency);
    return List.unmodifiable(_items);
  }

  @override
  Future<void> markAllRead() async {
    for (final n in _items) {
      n.isRead = true;
    }
    _emit();
  }

  @override
  Future<void> markRead(Object id) async {
    for (final n in _items) {
      if (n.id == id) n.isRead = true;
    }
    _emit();
  }

  @override
  Stream<List<NotificationItem>> watchAll() => _controller.stream;

  // ── بذرة الإشعارات (مؤقّتة حتى ربط الـ API) ───────────────────────────────
  static List<NotificationItem> _seed() => [
        NotificationItem(
          kind: NotificationKind.urgent,
          title: 'طلبية تنتهي اليوم',
          description:
              'الطلبية LAB-045 (تلبيسة PFM) للطبيبة د. سارة يجب تسليمها قبل الساعة 14:00.',
          category: 'الطلبات',
          timeLabel: 'الآن',
          day: NotificationDay.today,
          icon: Icons.local_fire_department_rounded,
          action: 'فتح الطلب',
        ),
        NotificationItem(
          kind: NotificationKind.urgent,
          title: 'طلبية تنتهي اليوم',
          description:
              'جسر 3 وحدات (LAB-042) للطبيب د. خالد يجب إنهاؤه قبل الساعة 16:00.',
          category: 'الطلبات',
          timeLabel: 'منذ 12 دقيقة',
          day: NotificationDay.today,
          icon: Icons.local_fire_department_rounded,
          action: 'فتح الطلب',
        ),
        NotificationItem(
          kind: NotificationKind.material,
          title: 'مادة وصلت للحد الأدنى',
          description:
              'كمية سيراميك زيركون انخفضت إلى 8 قطع — أقل من الحد الأدنى المسموح (10 قطع).',
          category: 'المواد',
          timeLabel: 'منذ ساعة',
          day: NotificationDay.today,
          icon: Icons.inventory_2_outlined,
          action: 'طلب من المستودع',
        ),
        NotificationItem(
          kind: NotificationKind.order,
          title: 'طلبية جديدة وصلت',
          description:
              'الطبيبة د. ليلى أرسلت طلبية جديدة — طقم Acrylic كامل (LAB-041).',
          category: 'الطلبات',
          timeLabel: 'منذ ساعتين',
          day: NotificationDay.today,
          icon: Icons.add_circle_outline_rounded,
          action: 'مراجعة',
        ),
        NotificationItem(
          kind: NotificationKind.system,
          title: 'تم توريد المواد',
          description:
              'وصلت 30 قطعة من PFM Alloy من المستودع — طلبية رقم MAT-104.',
          category: 'المستودع',
          timeLabel: 'أمس 16:42',
          day: NotificationDay.yesterday,
          icon: Icons.check_circle_outline_rounded,
          isRead: true,
        ),
        NotificationItem(
          kind: NotificationKind.order,
          title: 'تم تسليم الطلبية',
          description:
              'تم تسليم الطلبية LAB-039 (جسر PFM) للطبيب د. أحمد بنجاح.',
          category: 'الطلبات',
          timeLabel: 'أمس 14:15',
          day: NotificationDay.yesterday,
          icon: Icons.task_alt_rounded,
          isRead: true,
        ),
        NotificationItem(
          kind: NotificationKind.system,
          title: 'تم إضافة مخبري جديد',
          description: 'انضم يوسف ناصر (فني زيركون) إلى فريق المخبر.',
          category: 'الفريق',
          timeLabel: 'أمس 09:30',
          day: NotificationDay.yesterday,
          icon: Icons.person_add_alt_1_rounded,
          isRead: true,
        ),
        NotificationItem(
          kind: NotificationKind.material,
          title: 'تحديث مخزون',
          description: 'تم تحديث مستويات مخزون 12 مادة في النظام.',
          category: 'المواد',
          timeLabel: 'أمس 08:00',
          day: NotificationDay.yesterday,
          icon: Icons.refresh_rounded,
          isRead: true,
        ),
        NotificationItem(
          kind: NotificationKind.system,
          title: 'صيانة النظام',
          description: 'صيانة دورية ستجري الليلة بين الساعة 02:00 و 03:00 ص.',
          category: 'النظام',
          timeLabel: 'أمس 12:00',
          day: NotificationDay.yesterday,
          icon: Icons.build_outlined,
          isRead: true,
        ),
      ];
}
