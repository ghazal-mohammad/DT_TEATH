// ════════════════════════════════════════════════════════════════════════════
// lab_repository.dart
//
// عقد (interface) لخدمات المخبر. الـ presentation يتعامل مع هذا الـ interface
// فقط — التنفيذ في data/repositories/lab_repository_impl.dart.
// ════════════════════════════════════════════════════════════════════════════

import '../../data/models/lab_technician.dart';

abstract class LabRepository {
  /// آخر قائمة فنّيين مُحمَّلة (للعرض الفوري عند إعادة زيارة الصفحة)، أو null
  /// إن لم تُحمَّل بعد. تُمكّن نمط stale-while-revalidate في الـ Cubit.
  List<LabTechnician>? get cachedTechnicians;

  /// جلب كل فنيي المخبر من الباك (لتوكيل الطلبيات).
  Future<List<LabTechnician>> getTechnicians();
}
