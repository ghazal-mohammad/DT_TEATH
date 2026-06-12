// lab_dashboard_mock_data.dart
// بيانات وهمية لـ Dashboard المخبر (Phase 5.1)

/// نوع badge لطلبات المخبر.
/// "مستعجل" ليست حالة — هي خاصية يحددها الطبيب وتُعرض كشارة منفصلة (isUrgent).
enum LabOrderBadgeVariant {
  newOrder,
  manufacturing,
  ready,
}

/// مستوى أولوية الطلب.
enum LabOrderPriority {
  urgent,    // عاجل
  medium,    // متوسطة
  normal,    // عادية
}

/// بيانات طلب واحد في Dashboard المخبر.
class LabOrderItem {
  const LabOrderItem({
    required this.orderId,
    required this.patientName,
    required this.doctorName,
    required this.type,
    required this.dueDate,
    required this.statusVariant,
    required this.statusKey,
    this.isUrgent = false,
    this.material = '',
    this.tooth = '',
    this.priority = LabOrderPriority.normal,
  });

  final String orderId;
  final String patientName;
  final String doctorName;
  final String type;
  final String dueDate;
  final LabOrderBadgeVariant statusVariant;
  final String statusKey;
  final bool isUrgent;
  final String material;
  final String tooth;
  final LabOrderPriority priority;
}

/// بيانات مخبري في جدول الفريق.
class LabTechnicianItem {
  const LabTechnicianItem({
    required this.name,
    required this.shift,
    required this.currentTask,
    required this.isBusy,
  });

  final String name;
  final String shift;
  final String currentTask;
  final bool isBusy;
}

/// بيانات وهمية لـ Dashboard المخبر.
class LabDashboardMockData {
  LabDashboardMockData._();

  // Hero stats
  static const int todayOrdersCount = 12;
  static const int inProgressCount = 5;
  // الطلبات الموصّلة للطبيب (تم التوصيل) — مقياس المدير بدل "نسبة الإنجاز".
  static const int deliveredCount = 31;

  // Stat card values
  static const int newOrdersCount = 4;
  static const int manufacturingCount = 23;
  static const int readyCount = 7;
  static const int urgentTodayCount = 2;

  // Today orders table — مطابق للتصميم المرجعي
  static const List<LabOrderItem> todayOrders = [
    LabOrderItem(
      orderId: 'LAB-045',
      patientName: '—',
      doctorName: 'د. سارة',
      type: 'تلبيسة',
      material: 'PFM',
      tooth: '#14',
      dueDate: '27-03-2026',
      priority: LabOrderPriority.urgent,
      statusVariant: LabOrderBadgeVariant.newOrder,
      statusKey: 'labOrdersFilterNew',
    ),
    LabOrderItem(
      orderId: 'LAB-044',
      patientName: '—',
      doctorName: 'د. خالد',
      type: 'جسر',
      material: 'Zirconia',
      tooth: '#14-12',
      dueDate: '28-03-2026',
      priority: LabOrderPriority.medium,
      statusVariant: LabOrderBadgeVariant.manufacturing,
      statusKey: 'labOrdersFilterManufacturing',
    ),
    LabOrderItem(
      orderId: 'LAB-043',
      patientName: '—',
      doctorName: 'د. أحمد',
      type: 'تلبيسة',
      material: 'Metal',
      tooth: '#36',
      dueDate: '30-03-2026',
      priority: LabOrderPriority.normal,
      statusVariant: LabOrderBadgeVariant.ready,
      statusKey: 'labOrdersFilterReady',
    ),
    LabOrderItem(
      orderId: 'LAB-042',
      patientName: '—',
      doctorName: 'د. سارة',
      type: 'وجه',
      material: 'E-max',
      tooth: '#21',
      dueDate: '27-03-2026',
      priority: LabOrderPriority.urgent,
      statusVariant: LabOrderBadgeVariant.manufacturing,
      statusKey: 'labOrdersFilterManufacturing',
    ),
    LabOrderItem(
      orderId: 'LAB-041',
      patientName: '—',
      doctorName: 'د. ليلى',
      type: 'طقم',
      material: 'Acrylic',
      tooth: '#كامل',
      dueDate: '02-04-2026',
      priority: LabOrderPriority.normal,
      statusVariant: LabOrderBadgeVariant.newOrder,
      statusKey: 'labOrdersFilterNew',
    ),
    LabOrderItem(
      orderId: 'LAB-040',
      patientName: '—',
      doctorName: 'د. خالد',
      type: 'تلبيسة',
      material: 'Zirconia',
      tooth: '#26',
      dueDate: '29-03-2026',
      priority: LabOrderPriority.medium,
      statusVariant: LabOrderBadgeVariant.manufacturing,
      statusKey: 'labOrdersFilterManufacturing',
    ),
    LabOrderItem(
      orderId: 'LAB-039',
      patientName: '—',
      doctorName: 'د. أحمد',
      type: 'جسر',
      material: 'PFM',
      tooth: '#34-36',
      dueDate: '31-03-2026',
      priority: LabOrderPriority.medium,
      statusVariant: LabOrderBadgeVariant.ready,
      statusKey: 'labOrdersFilterReady',
    ),
  ];

  // Lab team
  static const List<LabTechnicianItem> team = [
    LabTechnicianItem(
      name: 'كمال ح.',
      shift: '8:00 - 16:00',
      currentTask: 'صب طقم',
      isBusy: true,
    ),
    LabTechnicianItem(
      name: 'ليلى م.',
      shift: '9:00 - 17:00',
      currentTask: 'طلاء Zirconia',
      isBusy: true,
    ),
    LabTechnicianItem(
      name: 'وسيم ن.',
      shift: '10:00 - 18:00',
      currentTask: '—',
      isBusy: false,
    ),
  ];
}
