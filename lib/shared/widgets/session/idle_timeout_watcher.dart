// ════════════════════════════════════════════════════════════════════════════
// idle_timeout_watcher.dart
//
// يراقب خمول المستخدم ويستدعي [onTimeout] بعد [timeout] بلا أي تفاعل — لقفل
// الجلسة تلقائياً على الأجهزة المشتركة (أمان). يعمل فقط أثناء وجود جلسة نشطة
// (يُشتقّ من [sessionListenable]/[isActive])، ويُصفّر عدّاده عند أي تفاعل مؤشّر.
//
// لا يمسّ تخطيط الطفل: يلفّه بـ Listener شفّاف (translucent) لا يبتلع الأحداث.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// يلفّ [child] ويقفل الجلسة تلقائياً بعد خمول [timeout].
class IdleTimeoutWatcher extends StatefulWidget {
  const IdleTimeoutWatcher({
    super.key,
    required this.timeout,
    required this.sessionListenable,
    required this.isActive,
    required this.onTimeout,
    required this.child,
  });

  /// مدّة الخمول قبل القفل التلقائي.
  final Duration timeout;

  /// مصدر يُعلِم بتغيّر حالة الجلسة (دخول/خروج) لإعادة تسليح العدّاد فورًا حتى
  /// دون تفاعل — عادةً CurrentUser.instance (ChangeNotifier).
  final Listenable sessionListenable;

  /// هل توجد جلسة نشطة الآن؟ (لا نقفل ولا نعدّ على شاشات الدخول.)
  final bool Function() isActive;

  /// يُستدعى عند انقضاء المهلة والجلسة نشطة.
  final VoidCallback onTimeout;

  final Widget child;

  @override
  State<IdleTimeoutWatcher> createState() => _IdleTimeoutWatcherState();
}

class _IdleTimeoutWatcherState extends State<IdleTimeoutWatcher> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    widget.sessionListenable.addListener(_onSessionChanged);
    // نشاط لوحة المفاتيح أيضًا — كي لا يُقفل أثناء كتابة نموذج طويل بلا مؤشّر.
    HardwareKeyboard.instance.addHandler(_onKey);
    _armIfActive();
  }

  @override
  void dispose() {
    widget.sessionListenable.removeListener(_onSessionChanged);
    HardwareKeyboard.instance.removeHandler(_onKey);
    _timer?.cancel();
    super.dispose();
  }

  /// معالج مفاتيح لا يبتلع الحدث (يرجّع false) — يعدّه نشاطًا فقط.
  bool _onKey(KeyEvent event) {
    _onActivity();
    return false;
  }

  /// يُسلّح العدّاد إن كانت الجلسة نشطة، وإلا يوقفه.
  void _armIfActive() {
    _timer?.cancel();
    if (widget.isActive()) {
      _timer = Timer(widget.timeout, _onElapsed);
    }
  }

  void _onSessionChanged() => _armIfActive();

  void _onElapsed() {
    if (widget.isActive()) widget.onTimeout();
  }

  void _onActivity() {
    // نُعيد التسليح عند التفاعل فقط إن كانت الجلسة نشطة.
    if (widget.isActive()) _armIfActive();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _onActivity(),
      onPointerMove: (_) => _onActivity(),
      onPointerSignal: (_) => _onActivity(),
      child: widget.child,
    );
  }
}
