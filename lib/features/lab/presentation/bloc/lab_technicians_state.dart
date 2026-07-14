// ════════════════════════════════════════════════════════════════════════════
// lab_technicians_state.dart
//
// State لـ LabTechniciansCubit: مرحلة التحميل + قائمة المخبريين (view models) +
// قائمة الطلبات المتاحة للتوكيل + رسالة الخطأ. العدّادات computed.
// ════════════════════════════════════════════════════════════════════════════

import '../../domain/entities/lab_order.dart';
import '../../domain/entities/technician_performance.dart';
import '../widgets/technicians/lab_technician_view_data.dart';

enum LabTechniciansStatus { loading, loaded, error }

/// State كامل لصفحة إدارة المخبريين.
class LabTechniciansState {
  const LabTechniciansState({
    required this.status,
    required this.technicians,
    required this.orders,
    this.performance = const [],
    this.errorMessage,
  });

  const LabTechniciansState.initial()
      : status = LabTechniciansStatus.loading,
        technicians = const [],
        orders = const [],
        performance = const [],
        errorMessage = null;

  final LabTechniciansStatus status;
  final List<TechnicianItem> technicians;

  /// طلبات متاحة للتوكيل (محلية لمودال التوكيل).
  final List<LabOrderFull> orders;

  /// تقرير أداء الفنّيين (showTechniciansPerformance) — الشهر الحالي.
  final List<TechnicianPerformance> performance;
  final String? errorMessage;

  int get total => technicians.length;
  int get active =>
      technicians.where((t) => t.status == TechnicianStatus.active).length;
  int get available =>
      technicians.where((t) => t.status == TechnicianStatus.available).length;

  LabTechniciansState copyWith({
    LabTechniciansStatus? status,
    List<TechnicianItem>? technicians,
    List<LabOrderFull>? orders,
    List<TechnicianPerformance>? performance,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LabTechniciansState(
      status: status ?? this.status,
      technicians: technicians ?? this.technicians,
      orders: orders ?? this.orders,
      performance: performance ?? this.performance,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
