// ════════════════════════════════════════════════════════════════════════════
// app_search_warmup.dart
//
// تسخين كاش مركز الأوامر: يجلب قوائم المخبر بصمت في الخلفية مرّة واحدة/جلسة،
// فيبحث [AppSearch] في كل شيء فورًا دون الحاجة لزيارة كل صفحة أولاً.
//
// من طرفنا بحت (لا باك إضافي — نفس endpoints القوائم). فشل أي مصدر لا يؤثّر على
// البقية ولا يظهر للمستخدم. يُعاد ضبطه عند تسجيل الخروج عبر SessionCacheRegistry.
// ════════════════════════════════════════════════════════════════════════════

import '../auth/auth_models.dart';
import '../auth/current_user.dart';
import '../di/injection_container.dart';
import '../../features/lab/domain/repositories/lab_material_requests_repository.dart';
import '../../features/lab/domain/repositories/lab_orders_repository.dart';
import '../../features/lab/domain/repositories/lab_products_repository.dart';
import '../../features/lab/domain/repositories/lab_repository.dart';
import '../../features/lab/domain/repositories/lab_stock_repository.dart';

class AppSearchWarmup {
  AppSearchWarmup._();

  static bool _done = false;

  /// يُشغِّل التسخين مرّة واحدة لكل جلسة (لمدير المخبر فقط — بيانات المستودع Mock
  /// بعد). آمن للاستدعاء المتكرّر (محروس بـ [_done]).
  static void run() {
    if (_done) return;
    if (CurrentUser.instance.role != EmployeeRole.labManager) return;
    _done = true;
    _fire(() => sl<LabOrdersRepository>().getAll());
    _fire(() => sl<LabProductsRepository>().getAll());
    _fire(() => sl<LabRepository>().getTechnicians());
    _fire(() => sl<LabMaterialRequestsRepository>().getAll());
    _fire(() => sl<LabStockRepository>().getAll());
  }

  /// يُعاد الضبط عند انتهاء الجلسة ليُسخَّن الكاش من جديد عند الدخول التالي.
  static void reset() => _done = false;

  static void _fire(Future<dynamic> Function() f) {
    try {
      f().ignore(); // fire-and-forget؛ ignore يمنع unhandled عند فشل الشبكة.
    } catch (_) {
      // مصدر غير مُسجَّل/خطأ متزامن — نتجاهل بصمت.
    }
  }
}
