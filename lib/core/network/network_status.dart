// ════════════════════════════════════════════════════════════════════════════
// network_status.dart
//
// حالة الاتصال بالشبكة (متصل/غير متصل) — تُشتقّ تفاعليًا من نتائج طلبات Dio:
//   • نجاح أي استجابة        → متصل.
//   • خطأ اتصال/مهلة (بلا رد) → غير متصل.
//
// نهج بلا اعتماد خارجي ولا كود خاص بالويب: يعتمد على حركة الشبكة الفعلية
// (الـ SWR يحدّث دوريًا فيبقى محدَّثًا). singleton + ChangeNotifier لتحديث
// شريط "لا يوجد اتصال" تلقائيًا.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';

class NetworkStatus extends ChangeNotifier {
  NetworkStatus._();

  static final NetworkStatus instance = NetworkStatus._();

  bool _isOnline = true;

  /// هل الاتصال متاح (افتراضيًا true حتى يثبت العكس)؟
  bool get isOnline => _isOnline;

  /// يضبط الحالة ويُشعِر المستمعين فقط عند التغيّر الفعلي (تجنّب rebuilds زائدة).
  void _set(bool online) {
    if (_isOnline == online) return;
    _isOnline = online;
    notifyListeners();
  }

  void markOnline() => _set(true);
  void markOffline() => _set(false);
}
