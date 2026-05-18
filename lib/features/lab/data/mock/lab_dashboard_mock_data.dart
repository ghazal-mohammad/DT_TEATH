// lab_dashboard_mock_data.dart
// بيانات وهمية لـ Dashboard المخبر (Phase 5.1)

/// نوع badge لطلبات المخبر.
enum LabOrderBadgeVariant {
  newOrder,
  manufacturing,
  ready,
  urgent,
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
  });

  final String orderId;
  final String patientName;
  final String doctorName;
  final String type;
  final String dueDate;
  final LabOrderBadgeVariant statusVariant;
  final String statusKey;
  final bool isUrgent;
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
  static const int completionRate = 96;

  // Stat card values
  static const int newOrdersCount = 4;
  static const int manufacturingCount = 23;
  static const int readyCount = 7;
  static const int urgentTodayCount = 2;

  // Today orders table
  static const List<LabOrderItem> todayOrders = [
    LabOrderItem(
      orderId: 'LAB-143',
      patientName: 'سامية ع.',
      doctorName: 'د. سامية',
      type: 'تلبيسة',
      dueDate: '27-05-2026',
      statusVariant: LabOrderBadgeVariant.manufacturing,
      statusKey: 'labOrdersFilterManufacturing',
    ),
    LabOrderItem(
      orderId: 'LAB-168',
      patientName: 'م. ر.',
      doctorName: 'د. خالد',
      type: 'جسر',
      dueDate: '27-05-2026',
      statusVariant: LabOrderBadgeVariant.newOrder,
      statusKey: 'labOrdersFilterNew',
      isUrgent: true,
    ),
    LabOrderItem(
      orderId: 'LAB-144',
      patientName: 'تركيز ع.',
      doctorName: 'د. رنا',
      type: 'Zirconia',
      dueDate: '28-05-2026',
      statusVariant: LabOrderBadgeVariant.ready,
      statusKey: 'labOrdersFilterReady',
    ),
    LabOrderItem(
      orderId: 'LAB-129',
      patientName: 'أحمد س.',
      doctorName: 'د. أحمد',
      type: 'Metal',
      dueDate: '29-05-2026',
      statusVariant: LabOrderBadgeVariant.manufacturing,
      statusKey: 'labOrdersFilterManufacturing',
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
