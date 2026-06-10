// ════════════════════════════════════════════════════════════════════════════
// lab_repository.dart
//
// عقد (interface) لخدمات المخبر. الـ presentation يتعامل مع هذا الـ interface
// فقط — التنفيذ في data/repositories/lab_repository_impl.dart.
// ════════════════════════════════════════════════════════════════════════════

import '../../data/models/lab_technician.dart';

abstract class LabRepository {
  /// جلب كل فنيي المخبر من الباك (لتوكيل الطلبيات).
  Future<List<LabTechnician>> getTechnicians();
}
