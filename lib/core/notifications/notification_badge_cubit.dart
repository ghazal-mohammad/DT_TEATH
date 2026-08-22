// ════════════════════════════════════════════════════════════════════════════
// notification_badge_cubit.dart
//
// عدّاد الإشعارات غير المقروءة — مصدر واحد مشترك يغذّي نقطة/رقم البادج على
// جرس الإشعارات بالـ topbar بكل صفحات المخبر والمستودع (مش بس صفحة
// الإشعارات نفسها). يُستدعى refresh() من AppShellLayout عند كل تنقّل، مع
// throttle بسيط لتفادي إغراق الباك بطلبات متكرّرة عند إعادة بناء متلاحقة.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../network/endpoints.dart';

class NotificationBadgeCubit extends Cubit<int> {
  NotificationBadgeCubit(this._dio) : super(0);

  final Dio _dio;
  DateTime? _lastFetch;
  static const _minInterval = Duration(seconds: 5);

  /// يجلب العدّاد الحقيقي من الباك — مؤجَّل (throttled) إلا لو [force].
  Future<void> refresh({bool force = false}) async {
    final now = DateTime.now();
    if (!force &&
        _lastFetch != null &&
        now.difference(_lastFetch!) < _minInterval) {
      return;
    }
    _lastFetch = now;
    try {
      final res =
          await _dio.get<dynamic>(ApiEndpoints.notificationsUnreadCount);
      final data = res.data;
      final inner = (data is Map) ? data['data'] : null;
      final count = (inner is Map) ? inner['unread_count'] : null;
      if (count is int) emit(count);
    } catch (_) {
      // فشل صامت — البادج مجرّد مؤشر ثانوي، ما بيستاهل كسر الصفحة.
    }
  }
}
