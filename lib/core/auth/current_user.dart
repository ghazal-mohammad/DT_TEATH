// ════════════════════════════════════════════════════════════════════════════
// current_user.dart
//
// مخزن بسيط للمستخدم المسجَّل حالياً — يُعبَّأ من ردّ login/setPassword
// (نفس نموذج الباك: EmployeeUser)، وتقرأه الشاشات لعرض الاسم والدور الحقيقيين
// بدل بيانات الـ mock.
//
// singleton + ChangeNotifier ليعيد بناء الواجهات تلقائياً عند الدخول/الخروج.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';

import 'auth_models.dart';

class CurrentUser extends ChangeNotifier {
  CurrentUser._();

  static final CurrentUser instance = CurrentUser._();

  EmployeeUser? _user;

  /// المستخدم الحالي (null = غير مسجَّل).
  EmployeeUser? get user => _user;

  /// الاسم الحقيقي من الباك (null لو ما في مستخدم).
  String? get name => _user?.name;

  /// الدور الحقيقي من الباك.
  EmployeeRole? get role => _user?.role;

  bool get isLoggedIn => _user != null;

  void setUser(EmployeeUser user) {
    _user = user;
    notifyListeners();
  }

  void clear() {
    _user = null;
    notifyListeners();
  }
}
