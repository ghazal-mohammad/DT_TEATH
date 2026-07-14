// ════════════════════════════════════════════════════════════════════════════
// lab_repository.dart
//
// عقد (interface) لخدمات المخبر. الـ presentation يتعامل مع هذا الـ interface
// فقط — التنفيذ في data/repositories/lab_repository_impl.dart.
// ════════════════════════════════════════════════════════════════════════════

import '../../data/models/lab_technician.dart';
import '../entities/technician_performance.dart';

abstract class LabRepository {
  /// آخر قائمة فنّيين مُحمَّلة (للعرض الفوري عند إعادة زيارة الصفحة)، أو null
  /// إن لم تُحمَّل بعد. تُمكّن نمط stale-while-revalidate في الـ Cubit.
  List<LabTechnician>? get cachedTechnicians;

  /// جلب كل فنيي المخبر من الباك (لتوكيل الطلبيات).
  Future<List<LabTechnician>> getTechnicians();

  /// جلب فنّي واحد كامل (مع جدول الدوام) — showTechnician.
  Future<LabTechnician> getTechnician(int id);

  /// تحديث جدول دوام الفنّي — updateTechnicianWorkSchedule.
  /// [schedule] عناصرها {day_of_week, start_time (H:i), end_time (H:i)}.
  Future<void> updateTechnicianSchedule(
    int id,
    List<Map<String, String>> schedule,
  );

  /// تقرير أداء/تقييم الفنّيين — showTechniciansPerformance.
  /// [from]/[to] اختياريان (yyyy-MM-dd)؛ الافتراضي = الشهر الحالي.
  Future<List<TechnicianPerformance>> getTechniciansPerformance({
    String? from,
    String? to,
  });
}
