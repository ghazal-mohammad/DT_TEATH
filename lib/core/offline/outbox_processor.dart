// ════════════════════════════════════════════════════════════════════════════
// outbox_processor.dart
//
// مُصرِّف طابور الصادر: يعيد إرسال العمليات المؤجَّلة للباك عبر Dio عند توفّر
// الاتصال. يستمع لـ [NetworkStatus] فيبدأ التصريف تلقائياً عند رجوع الشبكة.
//
// السياسة:
//   • FIFO، عملية عملية. نجاح ⇒ إزالة من الطابور + إشعار المورد للمصالحة.
//   • خطأ شبكة (بلا ردّ) ⇒ توقّف؛ يُعاد لاحقاً عند الاتصال التالي.
//   • خطأ عميل دائم (4xx) ⇒ زيادة عدّاد المحاولات؛ بعد [_maxAttempts] تُسقَط
//     العملية (poison-pill) كي لا تحجب بقية الطابور.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../network/network_status.dart';
import 'outbox.dart';
import 'outbox_entry.dart';

class OutboxProcessor {
  OutboxProcessor({
    required Outbox outbox,
    required Dio dio,
    NetworkStatus? networkStatus,
  })  : _outbox = outbox,
        _dio = dio,
        _network = networkStatus ?? NetworkStatus.instance;

  final Outbox _outbox;
  final Dio _dio;
  final NetworkStatus _network;

  /// أقصى محاولات إرسال قبل إسقاط العملية (تفادي حلقة لا نهائية).
  static const int _maxAttempts = 5;

  /// يُستدعى بعد مصالحة مورد بنجاح — يتيح للمورد إعادة الجلب من الباك.
  void Function(String resource)? onResourceSynced;

  bool _running = false;

  /// يبدأ الاستماع لتغيّرات الشبكة (يُصرّف عند الاتصال).
  void start() {
    _network.addListener(_onNetworkChanged);
  }

  void dispose() {
    _network.removeListener(_onNetworkChanged);
  }

  void _onNetworkChanged() {
    if (_network.isOnline) {
      // لا ننتظر النتيجة — التصريف يجري في الخلفية.
      process();
    }
  }

  /// يصرّف الطابور مرّة واحدة. آمن ضد التشغيل المتزامن.
  Future<void> process() async {
    if (_running) return;
    if (!_network.isOnline) return;
    _running = true;
    final synced = <String>{};
    try {
      // نعمل على نسخة — الطابور قد يتغيّر بين العمليات.
      for (final entry in _outbox.entries) {
        if (!_network.isOnline) break; // انقطع مجدداً ⇒ نكمل لاحقاً.
        final outcome = await _sendOne(entry);
        if (outcome == _SendOutcome.success) {
          await _outbox.remove(entry.id);
          synced.add(entry.resource);
        } else if (outcome == _SendOutcome.permanentFailure) {
          final next = entry.copyWith(attempts: entry.attempts + 1);
          if (next.attempts >= _maxAttempts) {
            await _outbox.remove(entry.id); // إسقاط poison-pill.
          } else {
            await _outbox.update(next);
          }
        } else {
          // خطأ شبكة عابر ⇒ أوقف التصريف، نُعيد المحاولة عند الاتصال التالي.
          break;
        }
      }
    } finally {
      _running = false;
    }
    for (final resource in synced) {
      onResourceSynced?.call(resource);
    }
  }

  Future<_SendOutcome> _sendOne(OutboxEntry entry) async {
    try {
      await _dio.request<dynamic>(
        entry.path,
        data: entry.body,
        options: Options(method: entry.method.wire),
      );
      return _SendOutcome.success;
    } on DioException catch (e) {
      // بلا ردّ + نوع اتصال/مهلة ⇒ عابر (شبكة).
      const transient = {
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.sendTimeout,
      };
      if (e.response == null && transient.contains(e.type)) {
        return _SendOutcome.transientFailure;
      }
      // ردّ من الخادم (حتى خطأ) ⇒ فشل دائم لهذه العملية.
      return _SendOutcome.permanentFailure;
    } catch (_) {
      return _SendOutcome.permanentFailure;
    }
  }
}

enum _SendOutcome { success, transientFailure, permanentFailure }
